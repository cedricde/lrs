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
require_once(dirname(__FILE__) . "/../directory.inc.php"); // Use LSC_Directory class
require_once(dirname(__FILE__) . "/../mimetypes.inc.php"); // Use LSC_load_mime_types function

$DEBUG = 9;
$OUTPUT_TYPE = "TERMINAL";


/**
 * Load mimetypes
 */
$exticonsfile = "/etc/webmin/lsc/extension.icons";

$mime_type_icons_data = array();
$mime_types_data = array();

LSC_load_mime_types($exticonsfile, $mime_type_icons_data, $mime_types_data);

/**
 * Local test
 */

/*
 * Open distant directory
 */
$path_directory = "/home/lsc/webmin/";
$directory = new LSC_Directory($path_directory);

//printf("directory = %s\n", var_export($directory, true));

/*
 * Get parent directory
 */
$parent_directory = $directory->get_parent();

printf("parent_directory = %s\n", $parent_directory);

/*
 * Display file list
 */
$directory->show_in_ascii();
?>
