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

require_once(dirname(__FILE__) . "/../scheduler.inc.php"); /**< Use LSC_Scheduler class */

/* 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

$scheduler = new LSC_Scheduler();

function add_command_on_target($target) 
{
	global $scheduler;
	/*
	 * Add new command
	 */
	$start_file = "Install_firefox.bat";
	$parameters = "";
	$path_destination = "c/lsc/";
	$path_source = "/home/lsc/repository/";
	$create_directory_enable = false;
	$start_script_enable = true;
	$delete_file_after_execute_successful_enable= true;
	$files = 
		array(
			"\"Firefox_Setup_1.0.7.exe\"",
			"Install_firefox.bat"
		);

	$start_date = "0000-00-00 00:00:00";
	$end_date = "0000-00-00 00:00:00";
	$target = ":" . $target;
	$username = "root";

	$scheduler->add_command(
		$start_file,
		$parameters,
		$path_destination,
		$path_source,
		$files,
		$target
	);
}

add_command_on_target("host1");
add_command_on_target("host2");
add_command_on_target("host3");
add_command_on_target("host4");

$scheduler->dispatch_all_commands();
$scheduler->start_all_commands();

?>
