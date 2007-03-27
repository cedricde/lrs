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
 * Create a new command on host
 */
print("Test class : LSC_Scheduler_Command_on_Host - Insert a new command on host\n");

$new_command_on_host = new LSC_Scheduler_Command_on_Host();

$new_command_on_host->id_command = "1";
$new_command_on_host->host = "host1";
$new_command_on_host->start_date = "2005-09-24 12:45:42";
$new_command_on_host->end_date = "2005-09-25 14:20:12";
$new_command_on_host->current_state = "done";
$new_command_on_host->uploaded = false;
$new_command_on_host->executed = false;
$new_command_on_host->deleted = false;
$new_command_on_host->next_launch_date = "2005-09-24 19:00:00";

print_r($new_command_on_host);

$id_command_on_host = $new_command_on_host->update();

print("index de la commande ajouté est : " . $id_command_on_host . "\n");

/**
 * Get a new command
 */
print("Test class : LSC_Scheduler_Command_on_Host - get a command\n");

$get_command_on_host = new LSC_Scheduler_Command_on_Host($id_command_on_host);

print_r($get_command_on_host);

// Test if datas are aqual
if (
	($new_command_on_host->id_command_on_host == $get_command_on_host->id_command_on_host) &&
	($new_command_on_host->id_command == $get_command_on_host->id_command) &&
	($new_command_on_host->host == $get_command_on_host->host) &&
	($new_command_on_host->start_date == $get_command_on_host->start_date) &&
	($new_command_on_host->end_date == $get_command_on_host->end_date) &&
	($new_command_on_host->current_state == $get_command_on_host->current_state) &&
	($new_command_on_host->uploaded == $get_command_on_host->uploaded) &&
	($new_command_on_host->executed == $get_command_on_host->executed) &&
	($new_command_on_host->deleted == $get_command_on_host->deleted) &&
	($new_command_on_host->next_launch_date == $get_command_on_host->next_launch_date)
) {
	print "No error, all data are equal\n";
} else {
	print "ERROR, all data aren't equal !!!\n";
}

/**
 * Modify data and update to db
 */
print("Test class : LSC_Scheduler_Command_on_Host - modify and update command\n");

$update_command_on_host = new LSC_Scheduler_Command_on_Host($id_command_on_host);

$update_command_on_host->id_command = "2";
$update_command_on_host->host = "host2";
$update_command_on_host->start_date = "2006-09-24 12:45:42";
$update_command_on_host->end_date = "2006-09-25 14:20:12";
$update_command_on_host->current_state = "pause";
$update_command_on_host->uploaded = true;
$update_command_on_host->executed = true;
$update_command_on_host->deleted = true;
$update_command_on_host->next_launch_date = "2006-09-24 19:00:00";

print_r($update_command_on_host);

$update_command_on_host->update();

/**
 * Get a new command (updated)
 */
print("Test class: LSC_Scheduler_Command_on_Host - get a command after updated\n");

$get_command_on_host2 = new LSC_Scheduler_Command_on_Host($id_command_on_host);

print_r($get_command_on_host2);

// Test if datas are equal
if (
	($update_command_on_host->id_command_on_host == $get_command_on_host2->id_command_on_host) &&
	($update_command_on_host->id_command == $get_command_on_host2->id_command) &&
	($update_command_on_host->host == $get_command_on_host2->host) &&
	($update_command_on_host->start_date == $get_command_on_host2->start_date) &&
	($update_command_on_host->end_date == $get_command_on_host2->end_date) &&
	($update_command_on_host->current_state == $get_command_on_host2->current_state) &&
	($update_command_on_host->uploaded == $get_command_on_host2->uploaded) &&
	($update_command_on_host->executed == $get_command_on_host2->executed) &&
	($update_command_on_host->deleted == $get_command_on_host2->deleted) &&
	($update_command_on_host->next_launch_date == $get_command_on_host2->next_launch_date)
) {
	print "No error, all data are equal\n";
} else {
	print "ERROR, all data aren't equal !!!\n";
}

/**
 * get_by_host_and_id_command 
 */
print("Test class : LSC_Scheduler_Command_on_Host - get_by_host_and_id_command\n");

$get_by_host_and_id_command = new LSC_Scheduler_Command_on_Host();

printf("index of command_on_host founded is : %s\n",
	$get_by_host_and_id_command->get_by_host_and_id_command(
		$update_command_on_host->host,
		$update_command_on_host->id_command
	)
);

/**
 * get_by_host_and_id_command2 
 */
print("Test class : LSC_Scheduler_Command_on_Host - get_by_host_and_id_command\n");

$get_by_host_and_id_command2 = new LSC_Scheduler_Command_on_Host();

printf("index of command_on_host founded is : %s\n",
	$get_by_host_and_id_command2->get_by_host_and_id_command(
		$update_command_on_host->host,
		$update_command_on_host->id_command+1
	)
);

Exit();

/**
 * Delete the new command
 */
print("Test class: LSC_Scheduler_Command_on_Host - delete the command\n");

$delete_command_on_host = new LSC_Scheduler_Command_on_Host($id_command_on_host);

printf("delete_command_on_host->delete() = %s\n", $delete_command_on_host->delete());


?>
