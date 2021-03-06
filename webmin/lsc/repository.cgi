#!/var/lib/lrs/php
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
require_once(dirname(__FILE__) . "/include/mimetypes.inc.php"); /**< Use LSC_load_mime_types function */
require_once(dirname(__FILE__) . "/include/tree.inc.php"); /**< Use LSC_Distant_Tree class */
require_once(dirname(__FILE__) . "/include/scheduler.inc.php"); /**< Use LSC_Scheduler class */
require_once(dirname(__FILE__) . "/include/file.inc.php"); /**< Use LSC_File class */
require_once(dirname(__FILE__) . "/include/directory.inc.php"); /**< Use LSC_Directory class */
require_once(dirname(__FILE__)."/include/extract_all_files_of_directory.inc.php");

/*
	$OUTPUT_TYPE = "WEB";
	$DEBUG = 0;
*/

if ($_GET["download"] != "") {
	/*
	 * If action is download a file, I must disable DEBUG because I mustn't write something before call header function
	 */
	$DEBUG = 0;
}

/*
 * Set pwd cookie
 */

/*
 * Define the current directory
 */
if ($_GET["repository_pwd"] == "") {
	if ( $_COOKIE["repository_pwd"] != "" ) {
		$current_repository_directory = $_COOKIE["repository_pwd"];
	} else {
		$current_repository_directory = "";
	}
} else {
	$current_repository_directory = $_GET["repository_pwd"];
	$current_repository_directory = clean_path($current_repository_directory);
	setcookie("repository_pwd", $current_repository_directory);
}

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

if (array_key_exists("repository", $config)) {
	$repository_home_directory = $config["repository"];
}

if ($_GET["delete_file"] != "") {
	/*
	 * action = Delete one file
	 */
	$full_path_file_to_delete = realpath($repository_home_directory . "/" . $current_repository_directory . "/" . $_GET["delete_file"]);
	
	debug(1, sprintf("User action - delete this file : %s", $full_path_file_to_delete));
	 
	$file = new LSC_File($full_path_file_to_delete);
	
	if ($file->remove()) {
		// No error
		$success_message = "File deleted with success";
	} else {
		// Error !
		$error_message = "Error when I delete file";
	}
}

if ($_GET["delete_directory"] != "") {
	/*
	 * action = Delete one directory
	 */
	$full_path_directory_to_delete = clean_path($repository_home_directory . "/" . $current_repository_directory . "/" . $_GET["delete_directory"]);
	
	debug(1, sprintf("User action - delete this file : %s", $full_path_directory_to_delete));
	 
	$directory = new LSC_Directory($full_path_directory_to_delete);
	
	if ($directory->delete_directory()) {
		// No error
		$success_message = "Directory deleted with success";
	} else {
		// Error !
		$error_message = "Directory when I delete file";
	}
}

if ( ( $_POST["file_upload_submit"] != "" ) && ( $_GET["process"] == 1 ) ) {
	/*
	debug(3, sprintf("_FILES = %s",
		var_export($_FILES["file_to_upload"], true)
	));*/
	/*
	 * Upload a file
	 */
	$full_path_file_to_upload = clean_path($repository_home_directory . "/" . $current_repository_directory . "/" . basename($_FILES["file_to_upload"]["name"]));
	$file = new LSC_File($full_path_file_to_upload);
	if ($file->upload($_FILES["file_to_upload"]["tmp_name"])) {
		// No error
		$success_message = "File : " . $full_path_file_to_create . " uploaded with success";
	} else {
		// Error
		$error_message = "Error cannot upload the file : " . $full_path_file_to_create;
	}
}

if (($_POST["create_file_submit"]!="") && ($_POST["type_file_to_create"] == "file")) {
	/*
	 * Create a new file
	 */
	$full_path_file_to_create = clean_path($repository_home_directory . "/" . $current_repository_directory . "/" . $_POST["filename_to_create"]);
	 
	$file = new LSC_File($full_path_file_to_create);
	if ($file->create()) {
		// No error
		$success_message = "File : " . $full_path_file_to_create . " created with success";
	} else {
		// Error
		$error_message = "Error cannot create the file : " . $full_path_file_to_create;
	}
}

if (( $_POST["create_file_submit"] != "" ) && ( $_POST["type_file_to_create"] == "directory" )) {
	/*
	 * Create a new directory
	 */
	$full_path_directory_to_create = clean_path($repository_home_directory . "/" . $current_repository_directory . "/" . $_POST["filename_to_create"]);
	 
	$directory = new LSC_Directory($full_path_directory_to_create);
	if ($directory->make_directory()) {
		// No error
		$success_message = "Directory : " . $full_path_directory_to_create . " created with success";
	} else {
		// Error
		$error_message = "Error cannot create the directory : " . $full_path_directory_to_create;
	}
}


/**
 * Load mimetypes
 */
$exticonsfile = EXTICONSFILE;

$mime_type_icons_data = array();
$mime_types_data = array();

LSC_load_mime_types($exticonsfile, $mime_type_icons_data, $mime_types_data);

include(dirname(__FILE__). "/open_session.inc.php"); // set $session instance

//if ($_GET["mac"] != "") {
//	$session = new LSC_Session($_GET["mac"], "root", false);
//} else {
//	// should open a session on the 1st machine of the group to get the OS
//	$path = new LSC_Path($_GET["profile"].":".$_GET["group"]."/");
//	$first_host = array_shift($path->get_hosts_list());
//	$session = new LSC_Session($first_host["mac"], "root", false);
//}

/*
 * Display debug informations
 */
debug(2, sprintf("MAC Address : %s", $_GET['mac']));
debug(2, sprintf("profile : %s", $_GET['profile']));
debug(2, sprintf("group : %s", $_GET['group']));
debug(2, sprintf("IP Address : %s", $session->ip));
debug(2, sprintf("repository_launch_action : %s", $_POST['repository_launch_action']));
debug(2, sprintf("repository_path_destination : %s", $_POST['repository_path_destination']));
debug(2, sprintf("repository_create_directory : %s", $_POST['repository_create_directory']));
debug(2, sprintf("repository_start_script : %s", $_POST['repository_start_script']));
debug(2, sprintf("repository_parameters : %s", $_POST['repository_parameters']));
debug(2, sprintf("repository_delete_file_after_execute_successful : %s", $repository_delete_file_after_execute_successful));

if ($DEBUG>3) {
	$i = 0;
	foreach($_POST["filename"] as $item) {
		debug(4, "====");
		debug(4, sprintf("Filename %s = %s", $i, $_POST["filename"][$i]));
		debug(4, sprintf("Select_to_copy %s = %s", $i, $_POST["select_to_copy"][$i]));
		debug(4, sprintf("Select_to_execute %s = %s", $i, $_POST["select_to_execute"][$i]));
		$i++;
	}
}

/*
 * handle user action
 */
if ($_GET["download"] != "") {
	/*
	 * action = Download one file
	 */
	debug(1, sprintf("User action - download this file : %s", clean_path($current_directory . "/" . $_GET["download"])));

	$file = new LSC_File(realpath($repository_home_directory . "/" . $current_repository_directory . "/" . $_GET["download"]));

	$file->download();
	exit();
}
 
if ($_POST["repository_launch_action"] != "") {
	/*
	 * Add command to scheduler
	 */
	if ($current_repository_directory == "") $current_repository_directory = "/";
	$path_source = clean_path("/".$config["repository"]."/".$current_repository_directory);
	
	$start_file = "";
	$files = array();
	$i = 0;
	
	foreach($_POST["select_to_copy"] as $i) {
		// push files even if they are directories since they will 
		// be uploaded with a 'scp -r'
		$item = $_POST["filename"][$i];
		array_push($files, $item);
		if ( $_POST["select_to_execute"] == $i ) {
			$start_file = $item;
		}
	}
	
	//debug(3, sprintf("Select to copy = %s", var_export($files, true)));
	debug(3, sprintf("Select to execute = %s", $start_file));
	 
	$parameters = $_POST['repository_parameters'];

	//$path_destination = $_POST['repository_path_destination'];
	$path_destination = $session->tmp_path;	
	if ($session->platform == "Windows") $path_destination = $config['path_destination'];
	
	$create_directory_enable = $_POST['repository_create_directory'];
	if ($_POST["select_to_execute"]==-1) {
		$start_script_enable = false;
	} else {
		$start_script_enable = $_POST['repository_start_script'];
	}
	$delete_file_after_execute_successful_enable = $_POST['repository_delete_file_after_execute_successful'];
	if (
		($repository_start_date!="d&egrave;s que possible" && $repository_start_date!="ASAP" )
	) {
		list($date, $time) = split(" [^ ]* ", $repository_start_date);
		list($day, $month, $year) = split("-", $date);
		$start_date = $year."-".$month."-".$day." ".$time.":00";
	} else {
		$start_date = "0000-00-00 00:00:00";
	}

	if (
		($repository_end_date!="aucune" && $repository_end_date!="none")
	) {
		list($date, $time) = split(" [^ ]* ", $repository_end_date);
		list($day, $month, $year) = split("-", $date);
		$end_date = $year."-".$month."-".$day." ".$time.":00";
	} else {
		$end_date = "0000-00-00 00:00:00";
	}

	
	if ( $_GET["mac"] != "" ) {
		$target = $session->hostname;
	} elseif (( $_GET["profile"] != "" ) || ( $_GET["group"] != "" )) {
		$target = $_GET["profile"] . ":" . $_GET["group"]."/";
	}
	$username = "root";
	$title = $_POST["repository_command_title"];
	if ($_POST["repository_wake_on_lan"] == "1") {
		$wake_on_lan_enable = true;
	} else {
		$wake_on_lan_enable = false;
	}
	
	if ($_POST["repository_next_connection_delay"] != "") {
		$next_connection_delay = $_POST["repository_next_connection_delay"];
	} else {
		$next_connection_delay = 60;
	}
	
	if ($_POST["repository_max_connection_attempt"] != "") {
		$max_connection_attempt = $_POST["repository_max_connection_attempt"];
	} else {
		$max_connection_attempt = 3;
	}
	
	if ($_POST["repository_inventory"] == 1) {
		$start_inventory_enable = true;
	} else {
		$start_inventory_enable = false;
	}
	if (!$_POST["repeat"]) {
		$repeat = 0;
	} else {
		$repeat = intval($_POST["repeat"]);
		if ($start_date == "0000-00-00 00:00:00") $start_date = date("Y-m-d G:i:00");
	}

	$scheduler = new LSC_Scheduler();

	$id_command = $scheduler->add_command(
		$start_file,
		$parameters,
		$path_destination,
		$path_source,
		$files,
		$target,
		$create_directory_enable,
		$start_script_enable,
		$delete_file_after_execute_successful_enable,
		$start_date,
		$end_date,
		$username,
		$REMOTE_USER."@".$_SERVER['REMOTE_ADDR'],
		$title,
		$wake_on_lan_enable,
		$next_connection_delay,
		$max_connection_attempt,
		$start_inventory_enable,
		$repeat
	);
	/*
	 * Dispatch all command
	 */
	$scheduler->dispatch_all_commands();
	
	/*
	 * Start all command
	 */
	$scheduler->start_all_commands();
	
	/*
	 * Redirect to command state
	 */
	if ($_GET["mac"]!="") {
		// Redirect to command_on_host state page
		
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}
				
		$query=
	"
	SELECT
		id_command_on_host
	FROM
		".COMMANDS_ON_HOST_TABLE."
	WHERE
		id_command=\"".$id_command."\"
	";
		$database->next_record();
		$id_command_on_host=$database->f(0);
				
		printf(
			"<html><head><meta http-equiv=\"refresh\" content=\"0;url=commands_states.cgi?mac=%s&profile=%s&group=%s&id_command_on_host=%s\"></head></html>",
			$_GET["mac"],
			$_GET["profile"],
			$_GET["group"],
			$id_command_on_host
		);
		exit();
	} else {
		// Redirect to command state page
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
 * Make Tree directory
 */
debug(1, "Make tree repository directory");
$tree_directory = new LSC_Tree($repository_home_directory, $current_repository_directory);

/*
 * Make file list directory
 */
debug(1, "Make file list repository directory");
$list_directory = new LSC_Directory(realpath($repository_home_directory . "/" . $current_repository_directory));

/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("repository_page" => "repository.tpl" ));

$template->header_param = array("lsc repository", $text{'repository_title'});

$template->set_var("SCRIPT_NAME", "repository.cgi");
$template->set_var("MAC", urlencode($_GET['mac']));
$template->set_var("PROFILE", urlencode($_GET['profile']));
$template->set_var("GROUP", urlencode($_GET['group']));
$template->set_var("CURRENT_TAB", "repository");

if ($_GET["mac"] != "") {
	LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group, "where_I_m_connected");
} else {
	LSC_Widget_where_I_m_connected_group_and_profile($template, $_GET["group"], $_GET["profile"], "where_I_m_connected");
}

if ($current_repository_directory == "") $current_repository_directory = "/";
$template->set_var("CURRENT_DIRECTORY_PATH", $current_repository_directory);

LSC_Widget_Tree_Directory(
	$template, 
	$tree_directory->tree,
	sprintf(
		"repository.cgi?mac=%s&profile=%s&group=%s&repository_pwd=",
		urlencode($_GET["mac"]),
		urlencode($_GET["profile"]),
		urlencode($_GET["group"])
	)
);

/*
 * Send user interface message to template
 */
if (( $success_message != "" ) || ( $error_message != "" )) {
	if ($success_message != "") {
		LSC_Widget_action_message($template, $success_message, false); // false = error disable
	} else {
		LSC_Widget_action_message($template, $error_message, true); // true = error enable
	}
} else {
	$template->set_var("action_message", "");
}

/*
 * Send file list directory to template
 */
$array_files = $list_directory->array_files; /* List of file and directory */
if (count($array_files) > 0) {
	LSC_Widget_File_List_Directory($template, $array_files, false);
	$template->set_block("repository_page", "FILE_LIST_DIRECTORY_EMPTY", "file_list_directory_empty");
	$template->set_var("file_list_directory_empty", "");
} else {
	$template->set_var("file_list_directory", "");
}

/* */

LSC_Widget_standard_file_list_directory_actions($template, $current_repository_directory);

if ($_GET["mac"] != "") {
	LSC_Widget_repository_actions($template, $config, $session->hostname);
} else {
	LSC_Widget_repository_actions($template, $config, "", $_GET["profile"], $_GET["group"]);
}
$template->set_var("OS", $session->platform);

/*
 * Transmission des param?tres vers le template
 */

/*
 * Display
 */
$template->pparse("out", "repository_page", "repository_page");
?>
