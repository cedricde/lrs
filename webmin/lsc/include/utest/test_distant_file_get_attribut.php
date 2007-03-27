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
require_once(dirname(__FILE__) . "/../file.inc.php"); // Use LSC_File class
require_once(dirname(__FILE__) . "/../mimetypes.inc.php"); // Use LSC_load_mime_types function
require_once(dirname(__FILE__) . "/../ssh.inc.php"); // Use LSC_Session class
require_once(dirname(__FILE__) . "/config_host.php"); // Define MAC_ADRESS constant

/**
 * This file is LSC_File class script test
 */

$DEBUG = 9;
$OUTPUT_TYPE = "TERMINAL";

/** 
 * Init webmin
 */
lib_init_config();
initLbsConf("/etc/lbs.conf", 1);

/**
 * Load mimetypes
 */
$exticonsfile = "/etc/webmin/lsc/extension.icons";

$mime_type_icons_data = array();
$mime_types_data = array();

LSC_load_mime_types($exticonsfile, $mime_type_icons_data, $mime_types_data);

/*
 * Open session
 */
$session = new LSC_Session(MAC_ADRESS, "root");

/*
 * Open local file
 */
$distant_file_path = "/c/CONFIG.SYS";
$file = new LSC_Distant_File($session, $distant_file_path);

print_r($file->LSC_getAttribs());
?>
