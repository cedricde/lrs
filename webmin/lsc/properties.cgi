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

require_once(dirname(__DIRNAME__) . "/include/common.inc.php");
require_once(dirname(__DIRNAME__) . "/include/tmpl.inc.php"); /**< Use LSC_Tmpl class */
require_once(dirname(__DIRNAME__) . "/include/debug.inc.php"); /**< Use Debug function */
require_once(dirname(__DIRNAME__) . "/include/ssh.inc.php"); /**< Use LSC_Session class */
require_once(dirname(__DIRNAME__) . "/include/widget.inc.php");
require_once(dirname(__DIRNAME__) . "/include/file.inc.php");
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
include(dirname(__FILE__). "/open_session.inc.php"); // set $session instance

$file = new LSC_Distant_File($session, clean_path($current_directory . "/" . $_GET["properties"]));
print("<pre>");
print($_GET["properties"]);
print_r("attribs :".$file->get_attribs());
print("acls :");
print_r($file->get_acls());
print("<br />");
print("</pre>");
/*
 * Control action
 */

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
$template = new LSC_Tmpl(array("properties_page" => "properties_page.tpl" ));

$template->header_param = array("lsc home", $text{'home_title'});

LSC_Widget_where_I_m_connected($template, $session->hostname, $session->ip, $session->profile, $session->group);

/*
 * Transmission des paramètres vers le template
 */

$template->set_var("MAC", urlencode($_GET['mac']));
$template->set_var("GROUP", "");
$template->set_var("PROFILE", "");

/*
 * Display
 */
$template->pparse("out", "properties_page", "properties_page");
?>
