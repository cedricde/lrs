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

require_once(dirname(__FILE__) . "/../common.inc.php");
require_once(dirname(__FILE__) . "/../mimetypes.inc.php");

/*
 * Init webmin
 */
$config_directory = "./";
global $lbsconf;
lib_init_config();

/*
 * Load mime
 */
print("Load mime type :\n");
 
$exticonsfile = "/etc/webmin/lsc/extension.icons";

$icons = array();
$mimetypes = array();

print("LSC_load_mime_type : ".LSC_load_mime_types($exticonsfile, $icons, $mimetypes)."\n");

/*printf("exticonsfile : %s\n", var_export($exticonsfile , true));
printf("icons : %s\n", var_export($icons, true));
printf("mimetypes : %s\n", var_export($mimetypes, true));*/
?>
