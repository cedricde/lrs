<?php
$SCRIPT_NAME="commands_states.cgi";
$current_mode="group";

if ($_GET["id_command"]!="") {
	include("command_detail.php");
	exit();
}

if ($_GET["id_command_on_host"]!="") {
	include("command_on_host_detail.php");
	exit();
}
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

/*
 * List of page parameters :
 *	$_POST["number_command_by_page"]
 *	$_POST["state_filter"]
 *	$_POST["apply_filter_submit"]
 *	$_GET["page"]
 */
 
/*
 * List of page cookies used
 *
 *	$_COOKIE["number_command_by_page"]
 *	$_COOKIE["page"]
 */
 
/*
 * Use post, get and or cookie values to initialise local filter variables
 *
 * Local filter variables are :
 *
 *	$number_command_by_page 
 *	$state_filter
 *	$page
 */
if ($_POST["apply_filter_submit"]) {
	$number_command_by_page = $_POST["number_command_by_page"];
	$state_filter = $_POST["state_filter"];
} else {
	
	if ($_COOKIE["number_command_by_page"]=="") {
		$number_command_by_page = 10;
	} else {
		$number_command_by_page = $_COOKIE["number_command_by_page"];
	}
}

if ($_GET["page"]!="") {
	$page = $_GET["page"];
} else {
	if ($_COOKIE["page"]=="") {
		$page = 0;
	} else {
		$page = $_COOKIE["page"];
	}
}

require_once(dirname(__FILE__) . "/include/common.inc.php");
require_once(dirname(__FILE__) . "/include/config.inc.php");
require_once(dirname(__FILE__) . "/include/tmpl.inc.php"); /**< Use LSC_Tmpl class */
require_once(dirname(__FILE__) . "/include/debug.inc.php"); /**< Use Debug function */
require_once(dirname(__FILE__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__FILE__) . "/include/widget.inc.php"); /**< Use LSC_Widget_... functions */
require_once(dirname(__FILE__) . "/include/mimetypes.inc.php"); /**< Use LSC_load_mime_types function */
require_once(dirname(__FILE__) . "/include/scheduler.inc.php"); /**< Use LSC_Scheduler class */
require_once(dirname(__FILE__) . "/include/scheduler.inc.php"); /**< Use LSC_Scheduler class */
require_once(dirname(__FILE__) . "/include/LSC_DB.inc.php"); /* Load database access class */
require_once(dirname(__FILE__) . "/include/state_widget.inc.php");


$OUTPUT_TYPE = "WEB";
//$DEBUG = 0;

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

include("open_session.inc.php");

/*
 * Handle action
 */
if ($_GET["action"]=="play") {
	lsc_command_set_play($_GET["id_command_play"]);
} elseif ($_GET["action"]=="pause") {
	lsc_command_set_pause($_GET["id_command_pause"]);
} elseif ($_GET["action"]=="stop") {
	lsc_command_set_stop($_GET["id_command_stop"]);
}

/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("commands_states_on_group_and_profile_page" => "commands_states_on_group_and_profile_page.tpl" ));

$template->header_param = array("lsc commands_states", $text{'explorer_title'});

$template->set_var("SCRIPT_NAME", $SCRIPT_NAME);
$template->set_var("MAC", urlencode($_GET["mac"]));
$template->set_var("PROFILE", urlencode($_GET["profile"]));
$template->set_var("GROUP", urlencode($_GET["group"]));

if ($_GET["mac"] != "") {
	LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group);
} else {
	LSC_Widget_where_I_m_connected_group_and_profile($template, $_GET["group"], $_GET["profile"], "where_I_m_connected");
}

/*
 * Inistialise DB instance
 */

if (!isset($database)) {
	$database = new LSC_DB();
	if ($DEBUG >= 1) $database->Debug = true;
}

/**
 * Number command by page display item selected
 */
 if ($number_command_by_page==10) {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_10_SELECTED", "page_10_selected");
	 $template->parse("page_10_selected", "NUMBER_BY_PAGE_10_SELECTED");
 } else {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_10_SELECTED", "page_10_selected");
	 $template->set_var("page_10_selected", "");
 }

 if ($number_command_by_page==20) {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_20_SELECTED", "page_20_selected");
	 $template->parse("page_20_selected", "NUMBER_BY_PAGE_20_SELECTED");
 } else {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_20_SELECTED", "page_20_selected");
	 $template->set_var("page_20_selected", "");
 }

if ($number_command_by_page==50) {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_50_SELECTED", "page_50_selected");
	 $template->parse("page_50_selected", "NUMBER_BY_PAGE_50_SELECTED");
 } else {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_50_SELECTED", "page_50_selected");
	 $template->set_var("page_50_selected", "");
 }

 if ($number_command_by_page==100) {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_100_SELECTED", "page_100_selected");
	 $template->parse("page_100_selected", "NUMBER_BY_PAGE_100_SELECTED");
 } else {
	 $template->set_block("commands_states_on_group_and_profile_page", "NUMBER_BY_PAGE_100_SELECTED", "page_100_selected");
	 $template->set_var("page_100_selected", "");
 }

/**
 * Set target_filter with profil and group
 */
$target_filter=$_GET["profile"].":".$_GET["group"]."/";

$template->set_var("GROUP_AND_PROFILE", $target_filter);

/**
 * Count the number total of command with filter
 */
$query_commands_list = sprintf(
"
SELECT
	count(*)
FROM
	%s
",
	COMMANDS_TABLE
);

if ($target_filter!="all") {
	$query_commands_list .= sprintf(
"
WHERE
	target=\"%s\"
",
	$target_filter
	);
}

$database->query($query_commands_list);
if ($database->next_record()) {
	$total_commands_number = $database->f(0);
}

$number_page = ceil($total_commands_number / $number_command_by_page);

/**
 * Display pages list
 */

if ($number_page > 1) {
	if ($page==0) {
		$template->set_block("commands_states_on_group_and_profile_page", "PAGE_PREVIOUS_HIDE", "previous_page");
		$template->set_var("previous_page", "");
	} else {
		$template->set_block("commands_states_on_group_and_profile_page", "PAGE_PREVIOUS_HIDE", "previous_page");
		$template->set_var("PAGE_PREVIOUS", $page - 1);
		$template->parse("previous_page", "PAGE_PREVIOUS_HIDE");
	}
	
	$template->set_block("commands_states_on_group_and_profile_page", "PAGE_LINK", "page_link");
	$template->set_block("commands_states_on_group_and_profile_page", "PAGE_CURRENT", "page_current");
	$template->set_block("commands_states_on_group_and_profile_page", "LIST_PAGE_COL", "page");
	for($p=0;$p<$number_page;$p++) {
		if ($page == $p) {
			$template->set_var("PAGE_LABEL", $p + 1);
			$template->parse("page_current", "PAGE_CURRENT");
			$template->set_var("page_link", "");
		} else {
			$template->set_var("PAGE_NUMBER", $p);
			$template->set_var("PAGE_LABEL", $p + 1);
			$template->parse("page_link", "PAGE_LINK");
			$template->set_var("page_current", "");
			
		}
		$template->parse("page", "LIST_PAGE_COL", true);
	}
	
	if ($page==$number_page-1) {
		$template->set_block("commands_states_on_group_and_profile_page", "PAGE_NEXT_HIDE");
		$template->set_var("PAGE_NEXT_HIDE", "");	
	} else {
		$template->set_block("commands_states_on_group_and_profile_page", "PAGE_NEXT_HIDE", "next_page");
		$template->set_var("PAGE_NEXT", $page + 1);
		$template->parse("next_page", "PAGE_NEXT_HIDE");
	}
} else {
	$template->set_block("commands_states_on_group_and_profile_page", "LIST_PAGES", "list_pages");
	$template->set_var("list_pages", "");
}

/**
 * Display the list of command
 *
 * Use filter information
 */

$query_commands_list = sprintf(
"
SELECT
	id_command,
	target,
	title,
	date_created,
	DATE_FORMAT(date_created, '%%d-%%m-%%Y<br />%%H:%%i:%%s'),
	start_date,
	DATE_FORMAT(start_date, '%%d-%%m-%%Y<br />%%H:%%i:%%s'),
	end_date,
	DATE_FORMAT(end_date, '%%d-%%m-%%Y<br />%%H:%%i:%%s')
FROM
	%s
",
	COMMANDS_TABLE
);

if ($target_filter!="all") {
	$query_commands_list .= sprintf(
"
WHERE
	target=\"%s\"
",
	$target_filter
	);
}

$query_commands_list .= "
ORDER BY
	date_created DESC
";

$query_commands_list .= sprintf(
"
LIMIT
	%s, %s
",
	$page * $number_command_by_page,
	$number_command_by_page
);

$database->query($query_commands_list);
/*
 * Transmission des paramètres vers le template
 */

if ($database->num_rows() > 0) {

	/*
	 * Copy all data in array
	 */
	$commands_array = array();
	while($database->next_record()) {
		array_push($commands_array, 
			array(
				"id_command" => $database->f("id_command"),
				"target" => $database->f("target"),
				"title" => $database->f("title"),
				"date_created" => $database->f("date_created"),
				"date_created_formated" => $database->f(4),
				"start_date" => $database->f("start_date"),
				"start_date_formated" => $database->f(6),
				"end_date" => $database->f("end_date"),
				"end_date_formated" => $database->f(8)
			)
		);
	}

	/*
	 * Hide COMMANDS_STATES_LIST_EMPTY block
	 */
	$template->set_block("commands_states_on_group_and_profile_page", "COMMANDS_STATES_LIST_EMPTY");
	$template->set_var("COMMANDS_STATES_LIST_EMPTY", "");
	
	/*
	 * Display all rows
	 */
	$template->set_block("commands_states_on_group_and_profile_page", "BUTTON_PLAY", "play");
	$template->set_block("commands_states_on_group_and_profile_page", "BUTTON_PAUSE", "pause");
	$template->set_block("commands_states_on_group_and_profile_page", "BUTTON_STOP", "stop");
	$template->set_block("commands_states_on_group_and_profile_page", "COMMANDS_STATES_ROW", "row");
	$row_class = "row-odd";
	foreach($commands_array as $c) {
		$template->set_var("ROW_CLASS", $row_class);
		$template->set_var("ID_COMMAND", $c["id_command"]);
		$template->set_var("NUMBER_OF_HOST", get_number_host_of_command($c["id_command"]));
		$template->set_var("TITLE", $c["title"]);
		if ($c["date_created"] == "0000-00-00 00:00:00") {
			$template->set_var("DATE_CREATED", "-");
		} else {
			$template->set_var("DATE_CREATED", $c["date_created_formated"]);
		}
		
		if ($c["start_date"] == "0000-00-00 00:00:00") {
			$template->set_var("START_DATE", "-");
		} else {
			$template->set_var("START_DATE", $c["start_date_formated"]);
		}
		
		if ($c["end_date"] == "0000-00-00 00:00:00") {
			$template->set_var("END_DATE", "-");
		} else {
			$template->set_var("END_DATE", $c["end_date_formated"]);
		}
		
		$current_state=get_state_of_command($c["id_command"]);
		
		switch ($current_state) {
			case "upload_in_progress" :
				$template->set_var("CURRENT_STATES_ICON","led-orange.gif");
			break;
			case "upload_done" :
				$template->set_var("CURRENT_STATES_ICON","led-green.gif");
			break;
			case "upload_failed" :
				$template->set_var("CURRENT_STATES_ICON","led-red.gif");
			break;
			case "execution_in_progress":
				$template->set_var("CURRENT_STATES_ICON","led-orange.gif");
			break;
			case "execution_done":
				$template->set_var("CURRENT_STATES_ICON","led-green.gif");
			break;
			case "execution_failed":
				$template->set_var("CURRENT_STATES_ICON","led-red.gif");
			break;
			case "delete_in_progress":
				$template->set_var("CURRENT_STATES_ICON","led-orange.gif");
			break;
			case "delete_done":
				$template->set_var("CURRENT_STATES_ICON","led-green.gif");
			break;
			case "delete_failed":
				$template->set_var("CURRENT_STATES_ICON","led-red.gif");
			break;
			case "not_reachable":
				$template->set_var("CURRENT_STATES_ICON","led-red.gif");
			break;
			case "done":
				$template->set_var("CURRENT_STATES_ICON","led-green.gif");
			break;
			case "pause":
				$template->set_var("CURRENT_STATES_ICON","led-black.gif");
			break;
			case "stop":
				$template->set_var("CURRENT_STATES_ICON","led-black.gif");
			break;
			case "scheduled":
				$template->set_var("CURRENT_STATES_ICON","led-grey.gif");
			break;
			default:
				$template->set_var("CURRENT_STATES_ICON","led-orange.gif");
			break;
		}

		if ($current_state == "?") {
			$template->set_var("CURRENT_STATES", $text["many_states"]);
		} else {
			$template->set_var("CURRENT_STATES", $text[$current_state]);
		}
		
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
			($current_state!="scheduled") &&
			($current_state!="not_reachable") &&
			($current_state!="upload_failed") &&
			($current_state!="execution_failed") &&
			($current_state!="delete_failed") &&
			($current_state!="inventory_failed") &&
			($current_state!="upload_in_progress") &&
			($current_state!="execution_in_progress") &&
			($current_state!="delete_in_progress") &&
			($current_state!="inventory_in_progress")
		) {
			$template->set_var("stop", "");
		} else {
			$template->parse("stop", "BUTTON_STOP");
		}
		
		/* NOT used, this feature will be implemented in next version...
		$template->set_var("NUMBER_ATTEMPT", get_number_attempt_of_command($c["id_command"]));
		*/
		$template->parse("row", "COMMANDS_STATES_ROW", true);
		if ($row_class == "row-odd") $row_class = "row-even";
		else $row_class = "row-odd";
	}
} else {
	/*
	 * Hide COMMANDS_STATES_LIST block
	 */
	$template->set_block("commands_states_on_group_and_profile_page", "COMMANDS_STATES_LIST");
	$template->set_var("COMMANDS_STATES_LIST", "");
}
/*
 * Display
 */
$template->pparse("out", "commands_states_on_group_and_profile_page", "commands_states_on_group_and_profile_page");
?>
