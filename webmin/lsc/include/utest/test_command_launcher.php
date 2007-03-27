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

require_once(dirname(__FILE__) . "/../scheduler.inc.php");
require_once(dirname(__FILE__) . "/../command_launcher.inc.php");

/** 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

/**
 * Instance the objects
 */
$new_command_launcher = new LSC_Command_Launcher();
$new_command = new LSC_Scheduler_Command();
$new_command_on_host = new LSC_Scheduler_Command_on_Host();

/**
 * Set values in new_command
 */
$new_command->date_created = "0000-00-00 00:00:00";
$new_command->start_file = "Install_firefox.bat";
$new_command->parameters = "";
$new_command->path_destination = "c/lsc/";
$new_command->path_source = "/home/lsc/repository/";
$new_command->create_directory_enable = false;
$new_command->start_script_enable = true;
$new_command->delete_file_after_execute_successful_enable= false;
$new_command->files = 
	array(
		"\"Firefox_Setup_1.0.7.exe\"",
		"Install_firefox.bat"
	);

$new_command->start_date = "0000-00-00 00:00:00";
$new_command->end_date = "0000-00-00 00:00:00";
$new_command->target = "zin";
$new_command->username = "root";

$new_command_on_host->host = "zin";
$new_command_on_host->id_command_on_host = -1;
$new_command_on_host->id_command = -1;
$new_command_on_host->start_date = "0000-00-00 00:00:00";
$new_command_on_host->end_date = "0000-00-00 00:00:00";
$new_command_on_host->current_state = "";
$new_command_on_host->next_launch_date = "0000-00-00 00:00:00";

/**
 * Set new_command_launcher instances
 */
$new_command_launcher->command = $new_command;
$new_command_launcher->command_on_host = $new_command_on_host;

print_r($new_command);
print_r($new_command_on_host);
print_r($new_command_launcher);

printf("new_command_launcher->files_copy : %s", $new_command_launcher->files_copy());
printf("new_command_launcher->start_command : %s", $new_command_launcher->file_start());
printf("new_command_launcher->files_delete : %s", $new_command_launcher->files_delete());

?>
