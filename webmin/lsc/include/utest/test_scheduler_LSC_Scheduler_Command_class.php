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

require_once("../scheduler.inc.php");

/** 
 * Create a new command
 */
print("Test class : LSC_Scheduler_Command - Insert a new command\n");

$new_command = new LSC_Scheduler_Command();

$new_command->start_file = "start_file.bat";
$new_command->parameters = "--user=foo --password=bar";
$new_command->path_destination = 'c:\Windows\tmp';
$new_command->path_source = "/lsc/";
$new_command->create_directory_enable = true;
$new_command->start_script_enable = false;
$new_command->delete_file_after_execute_successful_enable = false;
$new_command->files = array("/home/foo", "/home/bar", "/home/foo/bar");
$new_command->start_date = "2005-10-12 14:00:00";
$new_command->end_date = "2005-10-14 18:00:00";
$new_command->target = "host1";

print_r($new_command);

$id_command = $new_command->update();

printf("New command index is : %s\n", $id_command);

/**
 * Get a new command
 */
print("Test class: LSC_Scheduler_command - get a command\n");

$get_command = new LSC_Scheduler_Command($id_command);

print_r($get_command);

// Test if datas are equal
if (
	($new_command->start_file == $get_command->start_file) &&
	($new_command->parameters == $get_command->parameters) &&
	($new_command->path_destination == $get_command->path_destination) &&
	($new_command->path_source == $get_command->path_source) &&
	($new_command->create_directory_enable == $get_command->create_directory_enable) &&
	($new_command->start_script_enable == $get_command->start_script_enable) &&
	($new_command->delete_file_after_execute_successful_enable == $get_command->delete_file_after_execute_successful_enable) &&
	($new_command->files == $get_command->files) &&
	($new_command->start_date == $get_command->start_date) &&
	($new_command->end_date == $get_command->end_date) &&
	($new_command->target == $get_command->target)
) {
	print "No error, all data are equal\n";
} else {
	print "ERROR, all data aren't equal !!!\n";
}

/**
 * Modify data and update to db
 */
print("Test class : LSC_Scheduler_command - modify and update command\n");

$update_command = new LSC_Scheduler_Command($id_command);

$update_command->start_file = "new_start_file.bat";
$update_command->parameters = "--user=bar --password=motdepasse";
$update_command->path_destination = 'c:\WinXP\tmp';
$update_command->path_source = "/LSC2/";
$update_command->create_directory_enable = false;
$update_command->start_script_enable = true;
$update_command->delete_file_after_execute_successful_enable = true;
$update_command->files = array("/home/windows/foo", "/home/windows/bar", "/home/windows/foo/bar");
$update_command->start_date = "2006-10-12 14:00:00";
$update_command->end_date = "2006-11-19 10:00:00";
$update_command->target = "host15";

print_r($update_command);

$update_command->update();

/**
 * Get a new command (updated)
 */
print("Test class: LSC_Scheduler_Command - get a command after updated\n");

$get_command2 = new LSC_Scheduler_Command($id_command);

print_r($get_command2);

// Test if datas are equal
if (
	($update_command->start_file == $get_command2->start_file) &&
	($update_command->parameters == $get_command2->parameters) &&
	($update_command->path_destination == $get_command2->path_destination) &&
	($update_command->path_source == $get_command2->path_source) &&
	($update_command->create_directory_enable == $get_command2->create_directory_enable) &&
	($update_command->start_script_enable == $get_command2->start_script_enable) &&
	($update_command->delete_file_after_execute_successful_enable == $get_command2->delete_file_after_execute_successful_enable) &&
	($update_command->files == $get_command2->files) &&
	($update_command->start_date == $get_command2->start_date) &&
	($update_command->end_date == $get_command2->end_date) &&
	($update_command->target == $get_command2->target)
) {
	print "No error, all data are equal\n";
} else {
	print "ERROR, all data aren't equal !!!\n";
}

/**
 * Delete the new command
 */
print("Test class: LSC_Scheduler_Command - delete the command\n");

$delete_command = new LSC_Scheduler_Command($id_command);

printf("delete_command->delete() = %s\n", $delete_command->delete());
?>
