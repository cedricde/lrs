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
require_once(dirname(__FILE__) . "/include/tmpl.inc.php"); /**< Use LSC_Tmpl class */
require_once(dirname(__FILE__) . "/include/debug.inc.php"); /**< Use Debug function */
require_once(dirname(__FILE__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__FILE__) . "/include/widget.inc.php"); /**< Use LSC_Widget_where_I_m_connected, LSC_Widget_Tree_Directory and LSC_Widget_File_List_Directory, ... functions */
require_once(dirname(__FILE__) . "/include/mimetypes.inc.php"); /**< Use LSC_load_mime_types function */
require_once(dirname(__FILE__) . "/include/tree.inc.php"); /**< Use LSC_Distant_Tree class */
require_once(dirname(__FILE__) . "/include/file.inc.php"); /**< Use LSC_Distant_File class */

/*
	$OUTPUT_TYPE = "WEB";
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
if ($_GET["pwd"] == "") {
	if ( $_COOKIE["pwd"] != "" ) {
		$current_directory = $_COOKIE["pwd"];
	} else {
		$current_directory = "/";
	}
} else {
	$current_directory = $_GET["pwd"];
	$current_directory = clean_path($current_directory);
	setcookie("pwd", $current_directory);
} 

/*
 * Handle user action
 */
if ( $_GET["go_to_directory"] != "" ) {
	$current_directory .= "/" .$_GET["go_to_directory"];
	$current_directory = clean_path($current_directory);
	setcookie("pwd", $current_directory);
}


/*
 * Initialise some variable
 */
$success_message = "";
$error_message = "";

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

/**
 * Load mimetypes
 */
$exticonsfile = EXTICONSFILE;

$mime_type_icons_data = array();
$mime_types_data = array();

LSC_load_mime_types($exticonsfile, $mime_type_icons_data, $mime_types_data);

/*
 * explorer active ?
 */
if ($config['explorer'] == 0) {
	$template = new LSC_Tmpl(array("dis" => "dis.tpl" ));
	$template->header_param = array("lsc explorer", $text{'explorer_title'});
	$template->pparse("out", "dis", "dis");
	exit;
}

/*
 * Open the session
 */

include(dirname(__FILE__). "/open_session.inc.php"); // set $session instance

 

/*
 * Handle user action
 */

if ($_GET["delete_file"] != "") {
	/*
	 * action = Delete one file
	 */
	debug(1, sprintf("User action - delete this file : %s", clean_path($current_directory . "/" . $_GET["delete_file"])));
	 
	$file = new LSC_Distant_File($session, clean_path($current_directory . "/" . $_GET["delete_file"]));
	
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
	debug(1, sprintf("User action - delete this file : %s", clean_path($current_directory . "/" . $_GET["delete_directory"])));
	 
	$directory = new LSC_Distant_Directory($session, clean_path($current_directory . "/" . $_GET["delete_directory"]));
	
	if ($directory->delete_directory()) {
		// No error
		$success_message = "Directory deleted with success";
	} else {
		// Error !
		$error_message = "Directory when I delete file";
	}
}

if ($_GET["download"] != "") {
	/*
	 * action = Download one file
	 */
	debug(1, sprintf("User action - download this file : %s", clean_path($current_directory . "/" . $_GET["download"])));

	$file = new LSC_Distant_File($session, clean_path($current_directory . "/" . $_GET["download"]));

	$file->download();
	exit();
}

if (($_POST["create_file_submit"]!="") && ($_POST["type_file_to_create"] == "file")) {
	/*
	 * Create a new file
	 */
	$full_path_file_to_create = clean_path($current_directory . "/" . $_POST["filename_to_create"]);
	 
	$file = new LSC_Distant_File($session, $full_path_file_to_create);
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
	$full_path_directory_to_create = clean_path($current_directory . "/" . $_POST["filename_to_create"]);
	 
	$directory = new LSC_Distant_Directory($session, $full_path_directory_to_create);
	if ($directory->make_directory()) {
		// No error
		$success_message = "Directory : " . $full_path_directory_to_create . " created with success";
	} else {
		// Error
		$error_message = "Error cannot create the directory : " . $full_path_directory_to_create;
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
	$full_path_file_to_upload = clean_path($current_directory . "/" . basename($_FILES["file_to_upload"]["name"]));
	$file = new LSC_Distant_File($session, $full_path_file_to_upload);
	if ($file->upload($_FILES["file_to_upload"]["tmp_name"])) {
		// No error
		$success_message = "File : " . $full_path_file_to_create . " uploaded with success";
	} else {
		// Error
		$error_message = "Error cannot upload the file : " . $full_path_file_to_create;
	}
}

/*
 * Make Tree directory
 */
debug(1, "Make tree directory");
$tree_directory = new LSC_Distant_Tree($session, "", $current_directory);

if ($tree_directory->errors>0) {
	setcookie("session[".$_GET["mac"]."][platform]", "", time()+60*60);
	print("<h1>Tree directory ssh error...</h1>");
	print("<pre>");
	print_r($tree_directory);
	print_r($session);
	print("</pre>");
	exit();
}

/*
 * Make file list directory
 */
debug(1, "Make file list directory");
$list_directory = new LSC_Distant_Directory($session, $current_directory);

/*
 * Display debug informations
 */
debug(2, sprintf("MAC Address : %s", $_GET["mac"]));
debug(2, sprintf("IP Address : %s", $session->ip));

/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("explorer_page" => "explorer.tpl" ));

$template->header_param = array("lsc explorer", $text{'explorer_title'});

$template->set_var("SCRIPT_NAME", "explorer.cgi");
$template->set_var("MAC", urlencode($_GET["mac"]));
$template->set_var("PROFILE", urlencode($_GET["profile"]));
$template->set_var("GROUP", urlencode($_GET["group"]));
// $template->set_var("PWD", urlencode($current_directory)); Obselete, now I use cookie
$template->set_var("REPOSITORY_PWD", urlencode($_GET["repository_pwd"]));
$template->set_var("CURRENT_TAB", "explorer");

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

LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group);

$template->set_var("CURRENT_DIRECTORY_PATH", $current_directory);

LSC_Widget_Tree_Directory($template, $tree_directory->tree, "explorer.cgi?mac=".urlencode($_GET["mac"])."&pwd=");

$array_files = $list_directory->array_files; /* List of file and directory */

LSC_Widget_File_List_Directory($template, $array_files);
if (count($array_files) > 0) {
	$template->set_block("explorer_page", "FILE_LIST_DIRECTORY_EMPTY", "file_list_directory_empty");
	$template->set_var("file_list_directory_empty", "");
}
LSC_Widget_standard_file_list_directory_actions($template, $current_directory);
//LSC_Widget_standard_host_actions($template, $session->hostname);

/*
 * Transmission des paramètres vers le template
 */

/*
 * Display
 */
$template->pparse("out", "explorer_page", "explorer_page");
?>
