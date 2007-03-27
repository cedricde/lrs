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

require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/debug.inc.php"); /* Load debug display function */
require_once(dirname(__FILE__) . "/config.inc.php"); /* Set all LSC configurations constants */
require_once(dirname(__FILE__) . "/LSC_DB.inc.php"); /* Load database access class */
require_once(dirname(__FILE__) . "/path.inc.php"); /* Used to get the list of all hosts of one target */
require_once(dirname(__FILE__) . "/command_launcher.inc.php"); /* Use LSC_Command_Launcher */
require_once(dirname(__FILE__) . "/commands_on_host.inc.php"); /* Import and use LSC_Scheduler_Command_on_Host class */
require_once(dirname(__FILE__) . "/commands.inc.php"); /* Import and use LSC_Scheduler_Command class */
require_once(dirname(__FILE__) . "/exec.inc.php");


/**
 * Scheduler commands list
 * 
 * LSC_Scheduler_Commands_Table class aim is handle commands table.
 */
class LSC_Scheduler_Commands_Table 
{
	var $number_command_by_page = 50;	/**< Define the number of elements by page */
	var $target_filter = "";		/**< Target filter. "" = no target filter */
	var $state_filter = "";			/**< State filter. "" = no state filter */
	
	/**
	 * Constructor
	 * 
	 * Actualy, this constructor do nothing
	 */
	function LSC_Scheduler_Commands_Table()
	{
		// Nop
	}
	

	/**
	 *
	 */
	
	/**
	 * Get all target
	 * 
	 * This function return all different targets found in commands table.
	 * 
	 * @return string arrayss
	 */
	function get_all_target()
	{
		global $database, $DEBUG;
		
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}
		
		$query = sprintf("
			SELECT
				DISTINCT(target)
			FROM
				%s
			WHERE
				dispatched=\"YES\"
			",
			COMMANDS_TABLE
		);
		
		$database->query($query);
		
		$return_val = array();
		
		while($database->next_record()) {
			array_push($return_val, $database->f(0));
		}
		
		return $return_val;
	}
}


/**
 * Scheduler commands_on_host list
 * 
 * LSC_Scheduler_Commands_on_Host_Table class aim is handle commands_on_host table.
 */
class LSC_Scheduler_Commands_on_Host_Table
{
	/**
	 * 
	 */
	function LSC_Scheduler_Commands_on_Host_Table()
	{
	}
}


/**
 * 
 */
class LSC_Scheduler 
{
	/**
	 * Add a command in Scheduler
	 *
	 * @param many commands... TODO
	 *
	 * @return id_command value\n 
	 * If a new command is insered then id_command is the new index value.\n
	 * If error -1 value is returned.
	 */
	function add_command(
		$start_file, 
		$parameters, 
		$path_destination, 
		$path_source, 
		$files,
		$target,
		$create_directory_enable = true,
		$start_script_enable = true,
		$delete_file_after_execute_successful_enable = true,
		$start_date = "0000-00-00 00:00:00",
		$end_date = "0000-00-00 00:00:00",
		$username = "root",
		$webmin_username = "root",
		$title = "",
		$wake_on_lan_enable = false,
		$next_connection_delay = 60,
		$max_connection_attempt = 3,
		$start_inventory_enable = false,
		$repeat = 0
		)
	{
		$new_command = new LSC_Scheduler_Command();

		$new_command->date_created = date("Y-m-d H:i:s");
		$new_command->start_file = $start_file;
		$new_command->parameters = $parameters;
		$new_command->path_destination = $path_destination;
		$new_command->path_source = $path_source;
		$new_command->files = $files;
		$new_command->target = $target;
		$new_command->create_directory_enable = $create_directory_enable;
		$new_command->start_script_enable = $start_script_enable;
		$new_command->delete_file_after_execute_successful_enable = $delete_file_after_execute_successful_enable;
		$new_command->start_date = $start_date;
		$new_command->end_date = $end_date;
		$new_command->username = $username;
		$new_command->webmin_username = $webmin_username;
		$new_command->title = $title;
		$new_command->wake_on_lan_enable = $wake_on_lan_enable;
		$new_command->next_connection_delay = $next_connection_delay;
		$new_command->max_connection_attempt = $max_connection_attempt;
		$new_command->start_inventory_enable = $start_inventory_enable;
		$new_command->repeat = $repeat;

		$return_var = $new_command->update();

		debug(2, sprintf("%s - new_command->update() => %s",
			__FUNCTION__,
			$return_var
		));

		return $return_var;
	}

	/**
	 * Short form of add_command to run small (built-in) script ASAP
	 *
	 * $cmd: command to launch. If it starts with /scripts/ then the script relative to the
	 *       webmin lsc directory is transfered and executed
	 * $hosts: host, or group profile
	 * $desc: description
	 */
	function add_command_quick($cmd, $hosts, $desc)
	{
		global $config, $session, $REMOTE_USER;
	
		$path_source = "";
		$path_dest = "";
		$files = array();
		$create_delete = false;
		
		// run a built-in script
		if (preg_match("/^\/scripts\//", $cmd)) {
			$fullpath = dirname(__DIRNAME__) . $cmd;
			$path_source = dirname($fullpath);
			$path_dest = $session->tmp_path;                                 
        		if ($session->platform == "Windows") $path_dest = $config['path_destination'];
			$path_dest = $config['path_destination'];
			$files[] = basename($fullpath);
			$cmd = basename($fullpath);
			$create_delete = true;
		}

		$id_command = $this->add_command(
			$cmd, 
			"", 
			$path_dest,
			$path_source,
			$files,
			$hosts,
			$create_delete,
			true,
			$create_delete,
			"0000-00-00 00:00:00",
			"0000-00-00 00:00:00",
			"root",
			$REMOTE_USER,
			$desc,
			false,
			60,
			3,
			false
		);	
		return ($id_command);
	}
	 

	/**
	 * Dispatch all commands on hosts
	 *
	 * The target command can be one host or one group.
	 * 
	 * If target is a host then function create one record in COMMANDS_ON_HOST table to this host.\n
	 * If target is a group then function create some record in COMMADS_ON_HOST table. 
	 * 
	 * This function work on all records of COMMANDS table.
	 */
	function dispatch_all_commands()
	{
		global $database, $DEBUG;
		debug(1, "LSC_Scheduler->dispatch_all_commands()...");
		
		$query = sprintf("
			SELECT
				id_command, start_date
			FROM
				%s
			WHERE
				dispatched = \"NO\"
		",
			COMMANDS_TABLE
		);

		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}
	
		$database->query($query);

		if ( $database->num_rows() > 0 ) {
			// Iterate all command to dispatch
			while ( $database->next_record() ) {
				$command = new LSC_Scheduler_Command( $database->f("id_command") );
				$command->dispatch();
			}
		} else {
			// none command to dispatch
			debug(1, "No command to dispatch");
		}
	}

	/**
	 * Start all commands which must be started
	 *
	 * This function work on all records of COMMANDS_on_HOST table.
	 * 
	 * Command isn't executed if command_on_host.current_statue == DONE
	 */
	function start_all_commands()
	{
		global $database, $DEBUG;
		debug(1, "LSC_Scheduler->start_all_commands()...");
		
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}

		$query = 
"
SELECT
	COUNT(*)
FROM
	".COMMANDS_ON_HOST_TABLE."
WHERE
	NOT current_pid=\"-1\"
";

		$database->query($query);
		$database->next_record();
		$number_command_launcher_processus = $database->f(0);
		
		if ($number_command_launcher_processus < MAX_COMMAND_LAUNCHER_PROCESSUS) {
			
			$query = sprintf("
				SELECT
					A.id_command_on_host, A.start_date
				FROM
					%s A,
					%s B
				WHERE
					(A.id_command=B.id_command) and
					NOT (A.current_state = \"done\") and
					NOT (A.current_state = \"pause\") and
					NOT (A.current_state = \"stop\") and
					NOT (A.current_state = \"upload_in_progress\") and
					NOT (A.current_state = \"execution_in_progress\") and
					NOT (A.current_state = \"delete_in_progress\") and
					NOT (A.current_state = \"inventory_in_progress\") and
					NOT (A.current_state = \"upload_failed\") and
					NOT (A.current_state = \"execution_failed\") and
					NOT (A.current_state = \"delete_failed\") and
					NOT (A.current_state = \"inventory_failed\") and
					(A.current_pid = \"-1\")
				ORDER BY
					B.date_created ASC
				LIMIT 
					%s
			",
				COMMANDS_ON_HOST_TABLE,
				COMMANDS_TABLE,
				MAX_COMMAND_LAUNCHER_PROCESSUS
			);
			
			$database->query($query);
			
			if ( $database->num_rows() > 0 ) {
				// Iterate all command to dispatch
				while ( $database->next_record() ) {
					/*
					 * Test if start_date < now < end_date
					 */
					if ($database->f("start_date") != "0000-00-00 00:00:00") {
						if (strtotime($database->f("start_date"))>time()) {
							debug(1, "Run start_date > now for ".$database->f("id_command_on_host"));
							continue;
						}
					}

					$start_command = "cd ".dirname(__FILE__)."/../;./phprun.sh \"./start_command_on_host.php -id_command_on_host ".$database->f("id_command_on_host")."\" > /dev/null & echo \$!";
					debug(1, sprintf(
						"LSC_Scheduler - %s start_command = %s",
						COMMANDS_ON_HOST,
						$start_command
					));
					
					unset($output);	unset($return_val); unset($stdout); unset($stderr);
					$output="";
					$pid = lsc_exec(
						$start_command, 
						$output, 
						$return_var,
						$stdout,
						$stderr
					);
					/*
					debug(1, sprintf(
						"LSC_Scheduler - %s start_command output = %s",
						__FUNCTION__,
						var_export($output, true)
					));
					debug(1, sprintf(
						"LSC_Scheduler - %s start_command return_val = %s",
						__FUNCTION__,
						var_export($return_val, true)
					));*/
				}
			} else {
				// none command to dispatch
				debug(1, "No command to run");
			}
		} else {
			// current number of command launcher processus = MAX_COMMAND_LAUNCHER_PROCESSUS 
			debug(1, "current number of command launcher processus = MAX_COMMAND_LAUNCHER_PROCESSUS = $number_command_launcher_processus");
		}
	}
}

/**
 * Return number of host one command
 *
 * @param id_command to select command
 * @return number of host (integer)
 */
function get_number_host_of_command($id_command)
{
	global $database, $DEBUG;
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}
	
	$query=sprintf(
"
SELECT
	COUNT(*)
FROM
	%s
WHERE
	id_command = \"%s\"
",
	COMMANDS_ON_HOST_TABLE,
	$id_command
	);

	$database->query($query);
	if ($database->num_rows() == 1) {
		$database->next_record();
		return $database->f(0);
	} else {
		return 0;
	}
	
}

/**
 * Return the state of command
 *
 * @param id_command to select command
 * @return current_state (string)
 *
 * If function found many different state then return "?"
 */
function get_state_of_command($id_command)
{
	global $database, $DEBUG;

	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}
	
	$query=sprintf(
"
SELECT
	DISTINCT(current_state)
FROM
	%s
WHERE
	id_command = \"%s\"
",
	COMMANDS_ON_HOST_TABLE,
	$id_command
	);
	
	$database->query($query);
	if ($database->num_rows() == 1) {
		$database->next_record();
		return $database->f("current_state");
	} else {
		return "?";
	}
}

?>
