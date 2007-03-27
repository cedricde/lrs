#!/var/lib/lrs/php -q
<?php
/*
 * Linbox Rescue Server
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

/**
 * @file The aims of this script is start command. The command is identified by index number send in parameter.
 *
 * If id_command_on_host to start is 12, use this script like this :
 *
 *    # ./start_command_on_host.php -id_command_on_host 12
 */

putenv("WEBMIN_CONFIG=/etc/webmin/");

require_once(dirname(__FILE__) . "/../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/../lbs_common/web-lib.php");
require_once(dirname(__FILE__) . "/include/command_launcher.inc.php");
require_once(dirname(__FILE__) . "/include/commands_on_host.inc.php");

/*$DEBUG=0;
$OUTPUT_TYPE="TERMINAL";*/
/* 
 * Init webmin
 */
lib_init_config();
if ($config==-1) die("Error: config file not found\n");
initLbsConf("/etc/lbs.conf", 1);

/*
 * Get id_command_on_host value from command line argument
 */

$id_command_on_host = -1; 

for($i=0; $i<count($argv); $i++) {
	if ($argv[$i] == "-id_command_on_host") {
		if ($i+1 < count($argv)) {
			$id_command_on_host = $argv[$i+1];
		}
		break;
	}
}


/*
 * Start command launcher
 */
if ($id_command_on_host != -1) {

	if (!lsc_command_on_host_exist($id_command_on_host)) {
		printf("Row in \"commands_on_host\" table with \"id_command_on_host=%s\" not exist\n", $id_command_on_host);
		exit(-1);
	}
	
	if (lsc_command_on_host_is_done($id_command_on_host)) {
		printf("Row in \"commands_on_host\" table with \"id_command_on_host=%s\" is done\n", $id_command_on_host);
		exit(0);
	}
	
	$command_launcher = new LSC_Command_Launcher($id_command_on_host);
	
	if ($command_launcher->errors>0) {
		printf("Error : %s", $command_launcher->error_message);
		$command_launcher->free();
		exit(-1);
	}
	
	if ($command_launcher->I_hold_this_command) {
		printf("Start launch command on id_command_on_host = %s\n", $id_command_on_host);
		$command_launcher->execute();
		$command_launcher->free();
		printf("End launch command on id_command_on_host = %s\n", $id_command_on_host);
	} else {
		printf("Command on id_command_on_host = %s already started\n", $id_command_on_host);
	}
	$command_launcher->free();
} else {
	printf("Error : \"-id_command_on_host\" parameter is invalid\n");
}

?>
