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

require_once(dirname(__FILE__) . "/file.inc.php");
require_once(dirname(__FILE__) . "/mimetypes.inc.php");

/**
 * Return some information for the explorer module
 * and load mime type support
 * $session : obj set by the class session
 * $mimefile : the file with all mime type assoc
 *
 * return a tab with :
 * platform : OS (windows or Linux)
 * separator : (/ for linux, \ for windows)
 * home : user distant home
 * mount point : the exact mount point
 * relative_root : the root directory of the local distant fs (/ for Linux, /cygdrive for Windows)
 * mount_point2 : mount_point with the root of the local distant fs
 * icons : assoc tab extenstion -> icon
 * mimetypes : assoc tab extention -> mimetype
 */
function LSC_getExplorerData($session, $mimefile = "")
{
	$explorer = array("icons" => array(), "mimetypes" => array());
	$explorer['platform'] = $session->platform;
	$explorer['separator'] = LSC_getSeparator($session->platform);
	$explorer['home'] = $session->home;
	if (!file_exists(MOUNT_EXPLORER)) {
		LSC_MkdirRec(MOUNT_EXPLORER, 0700);
	}

	$explorer['mount_point'] =  MOUNT_EXPLORER.LINUX_SEPARATOR.$session->user."@".$session->ip;
	$explorer['relative_root'] = $session->root_path;
	$explorer['mount_point2'] = $explorer['mount_point'].$explorer['relative_root'];
	if (!empty($mimefile)) {
		LSC_load_mime_types($mimefile, $explorer['icons'], $explorer['mimetypes']);
	}

	return ($explorer);
}
?>
