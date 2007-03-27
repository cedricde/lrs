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

require_once(dirname(__FILE__) . "/../debug.inc.php");
require_once(dirname(__FILE__) . "/../scheduler.inc.php");
require_once(dirname(__FILE__) . "/../command_launcher.inc.php");

$target="host2";

$DEBUG = 9;

/* 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

/*
 * Instance the objects
 */
$new_command = new LSC_Scheduler_Command();
$new_command->date_created = "0000-00-00 00:00:00";
$new_command->start_file = "Install_firefox.bat";
$new_command->parameters = "";
$new_command->path_destination = "c/lsc/";
$new_command->path_source = "/home/lsc/repository/";
$new_command->create_directory_enable = false;
$new_command->start_script_enable = true;
$new_command->delete_file_after_execute_successful_enable= true;
$new_command->files = 
	array(
		"\"Firefox_Setup_1.0.7.exe\"",
		"Install_firefox.bat"
	);

$new_command->start_date = "0000-00-00 00:00:00";
$new_command->end_date = "0000-00-00 00:00:00";
$new_command->target = ":" . $target;
$new_command->username = "root";

$id_command = $new_command->update();

/*
 * Dispatch command
 */
$new_command->dispatch();

/*
 * Get id_command_on_host value
 */
$new_command_on_host = new LSC_Scheduler_Command_on_Host();
$id_command_on_host = $new_command_on_host->get_by_host_and_id_command($target, $id_command);

/*
$result = $new_command_on_host->update();

printf("new_command_on_host->update() = %s", $result);
*/
/*
 * Execute the command
 */
$new_command_launcher = new LSC_Command_Launcher($id_command_on_host);

$new_command_launcher->execute();
?>
