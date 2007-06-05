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

//include("open_session.inc.php");
if ($_GET["mac"] != "") 
	$session = new LSC_Session($_GET["mac"], "root", false, false);

/*
 * Handle action
 */
if ($_GET["action"]=="play") {
	lsc_command_on_host_set_play($_GET["id_command_on_host_play"]);
} elseif ($_GET["action"]=="pause") {
	lsc_command_on_host_set_pause($_GET["id_command_on_host_pause"]);
} elseif ($_GET["action"]=="stop") {
	lsc_command_on_host_set_stop($_GET["id_command_on_host_stop"]);
}


/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("command_on_host_detail_page" => "command_on_host_detail_page.tpl" ));

if ($SCRIPT_NAME=="all_commands.cgi") {
	$template->header_param = array("lsc all_commands", $text{'explorer_title'});
} else {
	$template->header_param = array("lsc commands_states", $text{'explorer_title'});
}

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
 * Get commands_on_host information
 */
$query="
SELECT
	id_command,
	DATE_FORMAT(next_launch_date, '%d-%m-%Y %H:%i:%s'),
	current_state,
	uploaded,
	executed,
	deleted,
	host,
	number_attempt_connection_remains
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

function return_icon($state)
{
	switch($state) {
		case "TODO":
			return "led-grey.gif";
		break;
		case "IGNORED":
			return "led-black.gif";
		break;
		case "DONE":
			return "led-green.gif";
		break;
		case "FAILED":
			return "led-red.gif";
		break;
		case "WORK_IN_PROGRESS":
			return "led-orange.gif";
		break;
	}
}

$template->set_var("COMMAND_RUN_DATE", $database->f(1));
$template->set_var("UPLOADED_ICON", return_icon($database->f("uploaded")));
$template->set_var("EXECUTED_ICON", return_icon($database->f("executed")));
$template->set_var("DELETED_ICON", return_icon($database->f("deleted")));
$template->set_var("UPLOADED", $text[$database->f("uploaded")]);
$template->set_var("EXECUTED", $text[$database->f("executed")]);
$template->set_var("DELETED", $text[$database->f("deleted")]);
$template->set_var("ATTEMPTS", $database->f("number_attempt_connection_remains"));

switch ($database->f("current_state")) {
	case "upload_in_progress" :
		$template->set_var("CURRENT_STATE_ICON","led-orange.gif");
	break;
	case "upload_done" :
		$template->set_var("CURRENT_STATE_ICON","led-green.gif");
	break;
	case "upload_failed" :
		$template->set_var("CURRENT_STATE_ICON","led-red.gif");
	break;
	case "execution_in_progress":
		$template->set_var("CURRENT_STATE_ICON","led-orange.gif");
	break;
	case "execution_done":
		$template->set_var("CURRENT_STATE_ICON","led-green.gif");
	break;
	case "execution_failed":
		$template->set_var("CURRENT_STATE_ICON","led-red.gif");
	break;
	case "delete_in_progress":
		$template->set_var("CURRENT_STATE_ICON","led-orange.gif");
	break;
	case "delete_done":
		$template->set_var("CURRENT_STATE_ICON","led-green.gif");
	break;
	case "delete_failed":
		$template->set_var("CURRENT_STATE_ICON","led-red.gif");
	break;
	case "not_reachable":
		$template->set_var("CURRENT_STATE_ICON","led-red.gif");
	break;
	case "done":
		$template->set_var("CURRENT_STATE_ICON","led-green.gif");
	break;
	case "pause":
		$template->set_var("CURRENT_STATE_ICON","led-black.gif");
	break;
	case "stop":
		$template->set_var("CURRENT_STATE_ICON","led-black.gif");
	break;
	case "scheduled":
		$template->set_var("CURRENT_STATE_ICON","led-grey.gif");
	break;
}

$template->set_block("command_on_host_detail_page", "BUTTON_PLAY", "play");
$template->set_block("command_on_host_detail_page", "BUTTON_PAUSE", "pause");
$template->set_block("command_on_host_detail_page", "BUTTON_STOP", "stop");

$current_state=$database->f("current_state");

if (
	($current_state!="pause") &&
	($current_state!="not_reachable") &&
	($current_state!="upload_failed") &&
	($current_state!="execution_failed'") &&
	($current_state!="delete_failed") &&
	($current_state!="inventory_failed")
	
) {
	$template->set_var("play", "");
} else {
	$template->parse("play", "BUTTON_PLAY");
}

if (
	($current_state!="scheduled")
) {
	$template->set_var("pause", "");
} else {
	$template->parse("pause", "BUTTON_PAUSE");
}

if (
	($current_state != "scheduled") &&
	($current_state != "not_reachable") &&
	($current_state != "upload_failed") &&
	($current_state != "execution_failed") &&
	($current_state != "delete_failed") &&
	($current_state != "inventory_failed") &&
	($current_state != "upload_in_progress") &&
	($current_state != "execution_in_progress") &&
	($current_state != "delete_in_progress") &&
	($current_state != "inventory_in_progress")
) {
	$template->set_var("stop", "");
} else {
	$template->parse("stop", "BUTTON_STOP");
}


$template->set_var("CURRENT_STATE", $text[$database->f("current_state")]);
$template->set_var("HOSTNAME", $database->f("host"));

/*
 * Command detail
 */
$query="SELECT
	DATE_FORMAT(date_created, '%d-%m-%Y %H:%i:%s'),
	DATE_FORMAT(start_date, '%d-%m-%Y %H:%i:%s'),
	DATE_FORMAT(end_date, '%d-%m-%Y %H:%i:%s'),
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
	files,
	webmin_username
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
	

	$template->set_var("COMMAND_WEBMIN_USER", $database->f("webmin_username"));
	$template->set_var("COMMAND_START_FILE",$database->f("start_file"));
	$template->set_var("COMMAND_PARAMETERS",$database->f("parameters"));
	$template->set_var("COMMAND_PATH_DESTINATION",$database->f("path_destination"));
	$template->set_var("COMMAND_PATH_SOURCE",$database->f("path_source"));
	if ($database->f("create_directory")=="enable") {
		$template->set_var("COMMAND_CREATE_DIRECTORY",$text{"yes"});
	} else {
		$template->set_var("COMMAND_CREATE_DIRECTORY",$text{"no"});
	}
	
	if ($database->f("start_script")=="enable") {
		$template->set_var("COMMAND_START_SCRIPT", $text{"yes"});
	} else {
		$template->set_var("COMMAND_START_SCRIPT", $text{"no"});
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
		$template->set_var("COMMAND_START_INVENTORY",$text{"yes"});
	} else {
		$template->set_var("COMMAND_START_INVENTORY",$text{"no"});
	}

	if ($database->f("wake_on_lan")=="enable") {
		$template->set_var("COMMAND_WAKE_ON_LAN",$text{"yes"});
	} else {
		$template->set_var("COMMAND_WAKE_ON_LAN",$text{"no"});
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
	DATE_FORMAT(date, '%d-%m-%Y %H:%i:%s') as date,
	state,
	stderr,
	stdout
FROM
	".COMMANDS_HISTORY_TABLE."
WHERE
	id_command_on_host=\"".$_GET["id_command_on_host"]."\"
";


$database->query($query);

$template->set_block("command_on_host_detail_page", "HISTORY_LIST_ROW", "row2");

if ($database->num_rows() > 0) {
while($database->next_record()) {
	switch ($database->f("state")) {
		case "upload_in_progress" :
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "upload_done" :
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "upload_failed" :
			$template->set_var("HISTORY_LIST_ICON","led-red.gif");
		break;
		case "execution_in_progress":
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "execution_done":
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "execution_failed":
			$template->set_var("HISTORY_LIST_ICON","led-red.gif");
		break;
		case "delete_in_progress":
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "delete_done":
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "delete_failed":
			$template->set_var("HISTORY_LIST_ICON","led-red.gif");
		break;
		case "not_reachable":
			$template->set_var("HISTORY_LIST_ICON","led-red.gif");
		break;
		case "done":
			$template->set_var("HISTORY_LIST_ICON","led-green.gif");
		break;
		case "pause":
			$template->set_var("HISTORY_LIST_ICON","led-black.gif");
		break;
		case "stop":
			$template->set_var("HISTORY_LIST_ICON","led-black.gif");
		break;
		case "scheduled":
			$template->set_var("HISTORY_LIST_ICON","led-gray.gif");
		break;
	}
	
	$template->set_var("HISTORY_LIST_DATE", $database->f("date"));
	$template->set_var("HISTORY_LIST_STATE", $text[$database->f("state")]);
	if ($database->f("stdout") == "") {
		$template->set_var("HISTORY_LIST_STDOUT", "-");
	} else {
		$template->set_var("HISTORY_LIST_STDOUT", nl2br($database->f("stdout")));
	}

	if ($database->f("stderr") == "") {
		$template->set_var("HISTORY_LIST_STDERR", "-");
	} else {
		$template->set_var("HISTORY_LIST_STDERR", nl2br($database->f("stderr")));
	}
	$template->parse("row2", "HISTORY_LIST_ROW", true);
}
	$template->set_block("command_on_host_detail_page", "HISTORY_LIST_EMPTY");
	$template->set_var("HISTORY_LIST_EMPTY", "");
} else {
	$template->set_var("row2", "");
}

/*
 *
 */
 
 if ($SCRIPT_NAME!="all_commands.cgi") {
	$template->set_block("command_on_host_detail_page", "LOCATION_ALL_COMMANDS");
	$template->set_var("LOCATION_ALL_COMMANDS", "");
	if ($current_mode!="group") {
		$template->set_block("command_on_host_detail_page", "LOCATION_COMMANDS_ON_HOST_GROUP_MODE");
		$template->set_var("LOCATION_COMMANDS_ON_HOST_GROUP_MODE", "");
	} else {
		$template->set_block("command_on_host_detail_page", "LOCATION_COMMANDS_ON_HOST");
		$template->set_var("LOCATION_COMMANDS_ON_HOST", "");
	}
 }

if ($SCRIPT_NAME!="commands_states.cgi") {
	$template->set_block("command_on_host_detail_page", "LOCATION_COMMANDS_ON_HOST_GROUP_MODE");
	$template->set_var("LOCATION_COMMANDS_ON_HOST_GROUP_MODE", "");
	$template->set_block("command_on_host_detail_page", "LOCATION_COMMANDS_ON_HOST");
	$template->set_var("LOCATION_COMMANDS_ON_HOST", "");
}

/*
 * Send standard variable to template
 */
$template->set_var("SCRIPT_NAME", $SCRIPT_NAME);
$template->set_var("MAC", urlencode($_GET['mac']));
$template->set_var("PROFILE", urlencode($_GET['profile']));
$template->set_var("GROUP", urlencode($_GET['group']));
$template->set_var("ID_COMMAND_ON_HOST", $_GET["id_command_on_host"]);

/*
 * Display
 */
$template->pparse("out", "command_on_host_detail_page", "commands_detail_page");
?>

