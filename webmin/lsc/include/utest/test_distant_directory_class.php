<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
 * Copyright (C) 2005	Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA	02111-1307, USA.
 */

require_once(dirname(__FILE__) . "/../debug.inc.php");
require_once(dirname(__FILE__) . "/../ssh.inc.php"); // Use LSC_Session class
require_once(dirname(__FILE__) . "/../directory.inc.php"); // Use LSC_Directory class
require_once(dirname(__FILE__) . "/../mimetypes.inc.php"); // Use LSC_load_mime_types function
require_once(dirname(__FILE__) . "/config_host.php"); // Define MAC_ADRESS constant

$DEBUG = 9;
$OUTPUT_TYPE = "TERMINAL";

/** 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

/**
 * Load mimetypes
 */
$exticonsfile = "/etc/webmin/lsc/extension.icons";

$icons = array();
$mime_types_data = array();

LSC_load_mime_types($exticonsfile, $icons, $mime_types_data);

/**
 * Local test
 */

/**
 * Initialise directory
 */
/*
$test_directory = realpath(dirname(__FILE__) . "/..");
printf("test_directory = %s\n", $test_directory);

$directory = new LSC_Directory($test_directory);

//printf("directory = %s", var_export($directory, true));
*/
/**
 * Distant test
 */

/**
 * Open a new session
 */
print("Open session\n");
$new_session = new LSC_Session(MAC_ADRESS, "root");

/*
 * Open distant directory
 */
$distant_path_directory = "/c/WINNT/";
$distant_directory = new LSC_Distant_Directory($new_session, $distant_path_directory);

//printf("distant_directory = %s\n", var_export($distant_directory, true));

/*
 * Get parent directory
 */
$parent_directory = $distant_directory->get_parent();

printf("parent_directory = %s\n", $parent_directory);

/*
 * Display file list
 */
$distant_directory->show_in_ascii();
?>
