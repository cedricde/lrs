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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

/* TODO
 * 
 * If $_GET["execute"] == "" then redirect to explorer
 */

require_once(dirname(__FILE__) . "/include/common.inc.php");
require_once(dirname(__FILE__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__FILE__) . "/include/file.inc.php"); /**< Use LSC_Distant_File class */
require_once(dirname(__FILE__) . "/include/tmpl.inc.php");
require_once(dirname(__FILE__) . "/include/clean_path.inc.php");
require_once(dirname(__FILE__) . "/include/config.inc.php");
require_once(dirname(__FILE__) . "/include/debug.inc.php");
require_once(dirname(__FILE__) . "/include/widget.inc.php"); /**< Use LSC_Widget_where_I_m_connected function */

/*
 * Initialise webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

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
 * Open the session
 */

include("open_session.inc.php");


/*
 * Execute the command
 */
// Open file
$file = new LSC_Distant_File($session, clean_path($current_directory . "/" . $_GET["execute"]));
// Execute
$return_var = $file->execute();

/*
 * Initialise template engine
 */
$template = new LSC_Tmpl(array("execute_page" => "execute_page.tpl"));
$templtate->header_param = array("lsc explorer", $text{'execute_title'});

$template->set_var("MAC", urlencode($_GET["mac"]));
$template->set_var("PWD", urlencode($current_directory));

LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group);

$template->set_var("FILE_EXECUTED", clean_path($current_directory . "/" . $_GET["execute"]));

if ($return_var==false) {
	$template->set_block("execute_page", "RAPPORT", "rapport");
	$template->set_var("rapport", "");
} else {
	$template->set_block("execute_page", "FILE_DONT_EXIST");
	$template->set_var("FILE_DONT_EXIST", "");

	$template->set_var("STDERR", $return_var["stderr"]);
	$template->set_var("STDOUT", $return_var["stdout"]);
	$template->set_var("EXIT_CODE", $return_var["exit_code"]);
}

/*
 * Display
 */
$template->pparse("out", "execute_page", "execute_page");
?>
