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

require_once(dirname(__FILE__) . "/include/common.inc.php");
require_once(dirname(__FILE__) . "/include/config.inc.php");
require_once(dirname(__FILE__) . "/include/tmpl.inc.php"); /**< Use LSC_Tmpl class */
require_once(dirname(__FILE__) . "/include/debug.inc.php"); /**< Use Debug function */
require_once(dirname(__FILE__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__FILE__) . "/include/widget.inc.php"); /**< Use LSC_Widget_... functions */
require_once(dirname(__FILE__) . "/include/scheduler.inc.php"); /**< Use LSC_Scheduler class */

/*
$OUTPUT_TYPE = "WEB";
$DEBUG = 0;
*/

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

include("open_session.inc.php");

/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("command_on_host_detail_page" => "command_on_host_detail_page.tpl" ));

$template->header_param = array("lsc commands_states", $text{'explorer_title'});

if ($_GET["mac"] != "") {
	LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group, "where_I_m_connected");
} elseif ( ($_GET["group"]!="") || ($_GET["profile"]!="")) {
	LSC_Widget_where_I_m_connected_group_and_profile($template, $_GET["group"], $_GET["profile"], "where_I_m_connected");
}

/*
 * Open database
 */
if (!isset($database)) {
	$database = new LSC_DB();
	if ($DEBUG >= 1) $database->Debug = true;
}

/*
 * Get id_command
 */
$query="
SELECT
	id_command
FROM
	".COMMANDS_ON_HOST_TABLE."
WHERE
	id_command_on_host=\"".$_GET["id_command_on_host"]."\"
";
$database->query($query);

if ($database->next_record()) {
	$id_command=$database->f(0);
	$template->set_var("ID_COMMAND", $id_command);
}

/*
 * Command detail
 */
$query="SELECT
	DATE_FORMAT(date_created, '%d-%m-%Y à %H:%i:%s'),
	DATE_FORMAT(start_date, '%d-%m-%Y à %H:%i:%s'),
	DATE_FORMAT(end_date, '%d-%m-%Y à %H:%i:%s'),
	title,
	start_file,
	parameters,
	path_destination,
	path_source,
	create_directory,
	start_script,
	date_created,
	start_date,
	end_date,
	target,
	start_inventory,
	wake_on_lan,
	next_connection_delay,
	max_connection_attempt,
	files
FROM
	".COMMANDS_TABLE."
WHERE
	id_command=\"".$id_command."\"
";

$database->query($query);

if ($database->next_record()) {
	$template->set_var("COMMAND_TITLE",$database->f("title"));
	
	if ($database->f("date_created") == "0000-00-00 00:00:00") {
		$template->set_var("COMMAND_DATE_CREATED", "-");
	} else {
		$template->set_var("COMMAND_DATE_CREATED", $database->f(0));
	}
	
	$template->set_var("COMMAND_START_FILE",$database->f("start_file"));
	$template->set_var("COMMAND_PARAMETERS",$database->f("parameters"));
	$template->set_var("COMMAND_PATH_DESTINATION",$database->f("path_destination"));
	$template->set_var("COMMAND_PATH_SOURCE",$database->f("path_source"));
	if ($database->f("create_directory")=="enable") {
		$template->set_var("COMMAND_CREATE_DIRECTORY","oui");
	} else {
		$template->set_var("COMMAND_CREATE_DIRECTORY","non");
	}
	
	if ($database->f("start_script")=="enable") {
		$template->set_var("COMMAND_START_SCRIPT", "oui");
	} else {
		$template->set_var("COMMAND_START_SCRIPT", "non");
	}
	
	if ($database->f("start_date") == "0000-00-00 00:00:00") {
		$template->set_var("COMMAND_START_DATE", "-");
	} else {
		$template->set_var("COMMAND_START_DATE",$database->f(1));
	}
	
	if ($database->f("end_date") == "0000-00-00 00:00:00") {
		$template->set_var("COMMAND_END_DATE", "-");
	} else {
		$template->set_var("COMMAND_END_DATE",$database->f(2));
	}
	$template->set_var("COMMAND_TARGET",$database->f("target"));
	
	if ($database->f("start_inventory")=="enable") {
		$template->set_var("COMMAND_START_INVENTORY","oui");
	} else {
		$template->set_var("COMMAND_START_INVENTORY","non");
	}

	if ($database->f("wake_on_lan")=="enable") {
		$template->set_var("COMMAND_WAKE_ON_LAN","oui");
	} else {
		$template->set_var("COMMAND_WAKE_ON_LAN","non");
	}	
	
	$template->set_var("COMMAND_NEXT_CONNECTION_DELAY", $database->f("next_connection_delay"));
	$template->set_var("COMMAND_MAX_CONNECTION_ATTEMPT", $database->f("max_connection_attempt"));
	
} else die("Internal error");

/*
 * Files list
 */
$i=0;
if ($database->f("files")!="") {
	$template->set_block("command_on_host_detail_page", "FILES_LIST_ROW", "row");
	$row_class = "row-odd";
	foreach(explode("\n", $database->f("files")) as $file) {
		$i++;		
		$template->set_var("ROW_CLASS", $row_class);
		$template->set_var("FILE_LIST_INDEX", $i);
		$template->set_var("FILE_LIST_FILENAME", $file);
		$template->parse("row", "FILES_LIST_ROW", true);
		if ($row_class == "row-odd") $row_class = "row-even";
		else $row_class = "row-odd";
	}
	
	$template->set_block("command_on_host_detail_page", "FILES_LIST_EMPTY");
	$template->set_var("FILES_LIST_EMPTY", "");
} else {
	$template->set_block("command_on_host_detail_page", "FILES_LIST_SECTION");
	$template->set_var("FILES_LIST_SECTION", "");
}

/*
 * History
 */
$query=
"
SELECT
	id_command_history,
	date,
	state
FROM
	".COMMANDS_HISTORY_TABLE."
WHERE
	id_command_on_host=\"".$_GET["id_command_on_host"]."\"
";

$database->query($query);

$template->set_block("command_on_host_detail_page", "HISTORY_LIST_ROW", "row2");
$row_class = "row-odd";
$i=0;
while($database->next_record()) {
	$i++;
	$template->set_var("ROW_CLASS", $row_class);
	$template->set_var("HISTORY_LIST_INDEX", $i);
	$template->set_var("HISTORY_LIST_DATE", $database->f("date"));
	$template->set_var("HISTORY_LIST_STATE", $database->f("state"));
	$template->set_var("HISTORY_LIST_ID_COMMAND_HISTORY",$database->f("id_command_history"));
	$template->parse("row2", "HISTORY_LIST_ROW", true);
	if ($row_class == "row-odd") $row_class = "row-even";
	else $row_class = "row-odd";
}

/*
 * Send standard variable to template
 */
$template->set_var("SCRIPT_NAME", "commands_states.cgi");
$template->set_var("MAC", urlencode($_GET['mac']));
$template->set_var("PROFILE", urlencode($_GET['profile']));
$template->set_var("GROUP", urlencode($_GET['group']));

/*
 * Display
 */
$template->pparse("out", "command_on_host_detail_page", "commands_detail_page");
?>

