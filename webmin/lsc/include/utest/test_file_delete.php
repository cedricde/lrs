<?php
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

require_once(dirname(__FILE__) . "/../common.inc.php");
require_once(dirname(__FILE__) . "/../ssh.inc.php");
require_once(dirname(__FILE__) . "/../delete.inc.php");
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
 * Open a new session
 */
print("Open session\n");
$new_session = new LSC_Session(MAC_ADRESS, "root");

print_r($new_session);

/**
 * Delete "test_file_copy.php" file name on zin host in c:\lsc directory
 */
$files_to_delete = "test_file_copy.php";
$path_target = "c/lsc/";

printf("Start delete %s/%s on %s\n", $path_target, $files_to_delete, $new_session->ip);

$result = LSC_Delete($new_session, $path_target, $files_to_delete);

//printf("Return LSC_Delete value : %s", var_export($result, true));

/**
 * Delete all current files names on zin host in c:\lsc2\
 */
$path_source = dirname(__FILE__);
$path_target = "c/lsc2/";
$files_to_delete = array();
if ($handle = opendir($path_source)) {
	while ( false !== ($file = readdir($handle))) {
		if ($file[0]!=".") {
			array_push($files_to_delete, $file);
		}
	}
	/*
	printf("Start delete in %s directory on %s all this files : %s \n", 
		$path_target, 
		$new_session->ip, 
		var_export($files_to_delete, true)
	);*/
	$result = LSC_Delete($new_session, $path_target, $files_to_delete);

	//printf("Return LSC_Delete value : %s", var_export($result, true));
}

/**
 * Delete all files name like in ../ directory recursive on zin host in c:\lsc3\
 */
function get_dir_files($path)
{
	$files_source = array();

	if ($handle = opendir($path)) {
		while ( false !== ($file = readdir($handle))) {
			if ($file[0]!=".") {

				if ( is_dir ( $path . "/" . $file ) ) {

					$buffer_files = get_dir_files($path."/".$file);

					foreach($buffer_files as $f) {
						array_push($files_source, $file . "/" . $f);
					}
				} else {

					array_push($files_source, $file);

				}
			}
		}
	}

	return $files_source;
}

$path_source = realpath( dirname(__FILE__) . "/../" );
printf("path_source = %s", $path_source);
$path_target = "c/lsc3/";
$files_to_delete = get_dir_files($path_source);
/*
printf("Start delete in %s directory on %s all this files : %s\n", 
	$path_target,
	$new_session->ip,
	var_export($files_to_delete, true)
);*/
$result = LSC_Delete($new_session, $path_target, $files_to_delete);

/*
printf("Return LSC_Delete value : %s", var_export($result, true));
*/
?>

