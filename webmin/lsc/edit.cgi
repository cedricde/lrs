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

/*
 * Get variable are :
 *
 * - edit = file to edit (this doesn't content the path)
 * - pwd = explorer current directory
 * - repository = repository current directory
 * - mac = distant host mac address
 * - content = if file edit formular is submited, this variable content file new data
 */
if ($_POST["return_submit"] != "") {
	if ($_GET["current_tab"] == "explorer") {
		printf(
			"<html><head><meta http-equiv=\"refresh\" content=\"0;url=./explorer.cgi?mac=%s&profile=%s&group=%s\"></head></html>",
			$_GET["mac"],
			$_GET["profile"],
			$_GET["group"]
		);
	} elseif ($_GET["current_tab"] == "repository") {
		printf(
			"<html><head><meta http-equiv=\"refresh\" content=\"0;url=./repository.cgi?mac=%s&profile=%s&group=%s\"></head></html>",
			$_GET["mac"],
			$_GET["profile"],
			$_GET["group"]
		);
	}
	exit();
}

 
require_once(dirname(__FILE__) . "/include/common.inc.php");
require_once(dirname(__FILE__) . "/include/config.inc.php");
require_once(dirname(__FILE__) . "/include/tmpl.inc.php"); /**< Use LSC_Tmpl class */
require_once(dirname(__FILE__) . "/include/debug.inc.php"); /**< Use Debug function */
require_once(dirname(__FILE__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__FILE__) . "/include/widget.inc.php"); /**< Use LSC_Widget_... functions */
require_once(dirname(__FILE__) . "/include/mimetypes.inc.php"); /**< Use LSC_load_mime_types function */
require_once(dirname(__FILE__) . "/include/file.inc.php"); /**< Use LSC_Distant_File class */
require_once(dirname(__FILE__) . "/include/clean_path.inc.php"); /**< Use clean_path function */

$OUTPUT_TYPE = "WEB";
//$DEBUG = 0;

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

if ($_GET["current_tab"] == "explorer") {
	/*
	 * Open the session
	 */
	include(dirname(__FILE__). "/open_session.inc.php"); // set $session instance
}
/*
 * Open the file
 */
if ($_GET["current_tab"] == "explorer") {
	$file_to_edit = new LSC_Distant_File($session, $_COOKIE["pwd"] . "/" . $_GET["edit"]);
} elseif ($_GET["current_tab"] == "repository") {
	$file_to_edit = new LSC_File(realpath($repository_home_directory . "/" . $_COOKIE["repository_pwd"] . "/" . $_GET["edit"]));
}

/*
 * handle user action
 */
if ($_POST["edit_save_submit"] != "")
{
	/*
	 * Write data to file
	 */
	 
	if ($file_to_edit->write_content(stripslashes($_POST["content"]))) {
		// No error
		$success_message = "Le fichier a été modifié avec succès";
	} else {
		// Error
		$error_message = "Erreur lors de l'écrite des données dans le fichier";
	}
} else {
	/*
	 * Read data from file
	 */

	if ($file_to_edit->get_content()) {
		// No error
		
	} else {
		// Error
		$error_message = "Erreur de lecture du fichier";
	}
}



/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("edit_page" => "edit_page.tpl" ));

$template->header_param = array("lsc repository", $text{'editor_title'});

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

$template->set_var("SCRIPT_NAME", "edit.cgi");
$template->set_var("MAC", urlencode($_GET["mac"]));
$template->set_var("PROFILE", urlencode($_GET["profile"]));
$template->set_var("GROUP", urlencode($_GET["group"]));
$template->set_var("EDIT_FILE", urlencode($_GET["edit"]));
$template->set_var("CURRENT_TAB", $_GET["current_tab"]);


if ($_GET["current_tab"] == "explorer") {
	$template->set_var("COMPLETE_PATH_FILE_TO_EDIT", clean_path($_COOKIE["pwd"] . "/" . $_GET["edit"]));
} elseif ($_GET["current_tab"] == "repository") {
	$template->set_var("COMPLETE_PATH_FILE_TO_EDIT", clean_path($_COOKIE["repository_pwd"] . "/" . $_GET["edit"]));
}

$template->set_var("CONTENT_DATA", $file_to_edit->content);


/*
 * Display
 */
$template->pparse("out", "edit_page", "edit_page");
?>
