<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
 * Copyright (C) 2005  Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, US
 */

require_once(dirname(__DIRNAME__) . "/include/common.inc.php");
require_once(dirname(__DIRNAME__) . "/include/tmpl.inc.php"); /**< Use LSC_Tmpl class */
require_once(dirname(__DIRNAME__) . "/include/debug.inc.php"); /**< Use Debug function */
require_once(dirname(__DIRNAME__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__DIRNAME__) . "/include/widget.inc.php"); /**< Use LSC_Widget_where_I_m_connected function */

require_once(dirname(__DIRNAME__) . "/include/lsc_script.php");

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

/*
 * Open the session
 */
//$session = new LSC_Session($_GET["mac"], "root", false);
include(dirname(__FILE__). "/open_session.inc.php"); // set $session instance

/*
 * Test ping
 */
if (LSC_sysPing($session->ip)==0) {
	// Host reachable
	$host_reachable = true;
} else {
	// Host not reachable
	$host_reachable = false;
}

/*
 * Control action
 */
if ($_POST["action"]!="") {
	$script_list = lsc_script_list_file();
	
	if (array_key_exists($_POST["action"], $script_list)) {
		require_once(dirname(__DIRNAME__) . "/include/scheduler.inc.php");
		$scheduler = new LSC_Scheduler();

		$id_command = $scheduler->add_command_quick(
			$script_list[ $_POST["action"] ][ "command" ],
			$session->hostname,
			$script_list[ $_POST["action"] ]["title".$current_lang]);
		$scheduler->dispatch_all_commands();
		$scheduler->start_all_commands();
		
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}
		
		$query = "SELECT id_command_on_host FROM ".COMMANDS_ON_HOST_TABLE.
			"WHERE id_command=\"".$id_command."\" ";
			
		$database->next_record();
		$id_command_on_host = $database->f(0);
		
		printf(
			"<html><head><meta http-equiv=\"refresh\" content=\"0;url=commands_states.cgi?mac=%s&profile=%s&group=%s&id_command_on_host=%s\"></head></html>",
			$_GET["mac"],
			$_GET["profile"],
			$_GET["group"],
			$id_command_on_host
		);
		exit();
	}
}


/*
 * Display debug informations
 */
debug(2, sprintf("MAC Address : %s", $_GET["mac"]));
debug(2, sprintf("IP Address : %s", $session->ip));
debug(2, sprintf("Hostname : %s", $session->hostname));
debug(2, sprintf("Profile name : %s", $session->profile));
debug(2, sprintf("Group name : %s", $session->group));
debug(2, sprintf("Operating system : %s", $session->platform));

/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("home_page" => "home_one_host_page.tpl" ));

$template->header_param = array("lsc home", $text{'home_title'});

LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group);

/*
 * Transmission des paramètres vers le template
 */

$template->set_var("HOST_INFO_MAC_ADDRESS", $_GET["mac"]);
$template->set_var("MAC", urlencode($_GET['mac']));
$template->set_var("HOST_INFO_IP_ADDRESS", $session->ip);
$template->set_var("HOST_INFO_HOSTNAME", $session->hostname);
$template->set_var("HOST_INFO_PROFILE", $session->profile);
$template->set_var("HOST_INFO_PROFILE_URL", urlencode($session->profile));
$template->set_var("HOST_INFO_GROUP", $session->group);
$template->set_var("HOST_INFO_GROUP_URL", urlencode($session->group));
$template->set_var("HOST_INFO_OPERATING_SYSTEM", $session->platform);
if ($host_reachable) {
	$template->set_var("HOST_INFO_REACHABLE", $text{"success"});
} else {
	$template->set_var("HOST_INFO_REACHABLE", $text{"failed"});
}

$template->set_var("SCRIPT_NAME", "index.cgi");
$template->set_var("GROUP", "");
$template->set_var("PROFILE", "");

LSC_Widget_standard_host_actions($template, lsc_script_list_file());

/*
 * Display
 */
$template->pparse("out", "home_page", "home_page");
?>


