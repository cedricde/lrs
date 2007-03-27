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
require_once("../scheduler.inc.php");

/** 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

/** 
 * Create a new command
 */
print("Test class : LSC_Scheduler_Command - Insert a new command\n");

$new_command = new LSC_Scheduler_Command();

$new_command->start_file = "start_file.bat";
$new_command->parameters = "--user=foo --password=bar";
$new_command->path_destination = 'c:\Windows\tmp';
$new_command->create_directory_enable = true;
$new_command->start_script_enable = false;
$new_command->delete_file_after_execute_successful_enable = false;
$new_command->files = array("/home/foo", "/home/bar", "/home/foo/bar");
$new_command->start_date = "2005-10-12 14:00:00";
$new_command->end_date = "2005-10-14 18:00:00";
$new_command->target = "profil2:group1/";

print_r($new_command);

$id_command = $new_command->update();

print("index de la commande ajouté est : " . $id_command . "\n");

/**
 * Dispatch this command
 */
$new_command->dispatch();

/**
 * Repeat dispatch, it's do nothing
 */
$new_command->dispatch();
?>
