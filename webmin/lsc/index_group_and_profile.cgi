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
require_once(dirname(__DIRNAME__) . "/include/path.inc.php"); /**< Use LSC_Path class */
require_once(dirname(__DIRNAME__) . "/include/widget.inc.php"); /**< Use LSC_Widget_where_I_m_connected function */

require_once(dirname(__DIRNAME__) . "/include/lsc_script.php");

/*
	$OUTPUT_TYPE = "WEB";
*/

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

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
			$_GET["profile"].":".$_GET["group"]."/",
			$script_list[ $_POST["action"] ]["title".$current_lang]
			);
		$scheduler->dispatch_all_commands();
		$scheduler->start_all_commands();

		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}
			
		printf(
			"<html><head><meta http-equiv=\"refresh\" content=\"0;url=commands_states.cgi?mac=%s&profile=%s&group=%s&id_command=%s\"></head></html>",
			$_GET["mac"],
			$_GET["profile"],
			$_GET["group"],
			$id_command
		);
		exit();
	}
}


/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("home_page" => "home_group_and_profile_page.tpl" ));

$template->header_param = array("lsc home", $text{'home_title'});

/*
 * Get host list of group or profile
 */
$path = new LSC_Path($_GET["profile"].":".$_GET["group"]."/");

$hosts_array = $path->get_hosts_list();
/*
 * Display widgets
 */
$template->set_var("PROFILE", $_GET["profile"]);
$template->set_var("GROUP", $_GET["group"]);
$template->set_var("MAC", "");
$template->set_var("SCRIPT_NAME", "index.cgi");

LSC_Widget_where_I_m_connected_group_and_profile($template, $_GET["group"], $_GET["profile"]);

LSC_Widget_standard_host_actions($template, lsc_script_list_file());

/*
 * Iterate all element of files_array
 */
$i = 0;

if (count($hosts_array)>0) {
	$template->set_block("home_page", "HOSTS_LIST_ROW", "rows");
	$row_class = "row-odd";
	foreach($hosts_array as $host) {
		$i++;
		$template->set_var("INDEX", $i);
		
		$template->set_var("ROW_CLASS", $row_class);
	
		$template->set_var("HOSTNAME", $host["hostname"]);
		$template->set_var("IP", $host["ip"]);
		$template->set_var("MAC", $host["mac"]);
		$template->set_var("MAC_AND_DOT", urlencode($host["mac"]));
	
		$template->parse("rows", "HOSTS_LIST_ROW", true);
		/*
		 * Switch the row class
		 */
		if ($row_class == "row-odd") $row_class = "row-even";
		else $row_class = "row-odd";
	}
	$template->set_block("home_page", "HOSTS_LIST_EMPTY");
	$template->set_var("HOSTS_LIST_EMPTY", "");
} else {
	$template->set_block("home_page", "HOSTS_LIST");
	$template->set_var("HOSTS_LIST", "");
}

/*
 * Display
 */
$template->pparse("out", "home_page", "home_page");
?>
