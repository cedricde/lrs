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

require_once(dirname(__FILE__) . "/debug.inc.php"); /* Load debug display function */
require_once(dirname(__FILE__) . "/config.inc.php"); /* Set all LSC configurations constants */
require_once(dirname(__FILE__) . "/LSC_DB.inc.php"); /* Load database access class */
require_once(dirname(__FILE__) . "/path.inc.php"); /* Used to get the list of all hosts of one target */
require_once(dirname(__FILE__) . "/command_launcher.inc.php"); /* Use LSC_Command_Launcher */
require_once(dirname(__FILE__) . "/commands_on_host.inc.php"); /* Import and use LSC_Scheduler_Command_on_Host class */

/**
 * Scheduler command class
 *
 * Class aim is handle command element of commands table.
 */
class LSC_Scheduler_Command 
{
	var $id_command;		/**< command database table index */
	var $date_created;		/**< command creation date (YYYY-MM-DD HH:MM:SS) */
	var $start_file; 		/**< file name to execute (script, application...) */
	var $parameters; 		/**< parameters to send to start_file */
	var $path_destination; 		/**< destination path directory (on client host)  */
	var $path_source;		/**< source path directory (on localhost) */
	var $create_directory_enable;	/**< create all directory of path_destination on client ? (boolean) */
	var $start_script_enable;	/**< start the start_file on client ? (boolean) */
	var $title;			/**< title of command */
	var $start_inventory_enable;	/**< start inventory on client ? (boolean) */

	/**  after successful execution, delete	all files copied ? (boolean) */
	var $delete_file_after_execute_successful_enable; 					

	var $files = array();		/**< list of files will be copied */
	var $start_date;		/**< the command can start after this date (YYYY-MM-DD HH:MM:SS) */
	var $end_date;			/**< the command can't start after this date (YYYY-MM-DD HH:MM:SS) */
	var $target;			/**< host or group target */

	var $errors = 0;		/**< number errors */
	var $username;			/**< name user who launch command */
	var $webmin_username;
	var $dispatched;		/**< true if command is dispatched to commands_on_host */
	
	var $wake_on_lan_enable;	/**< Wake on lan ? (boolean) */
	var $next_connection_delay;	/**< Time in minute to next attempt (integer) */
	var $max_connection_attempt;	/**< Number max of attempt */
	var $repeat = 0;	    	/**< Repeat period in minutes */

	/**
	 * LSC Scheduler Command constructor
	 *
	 * @param $id_command = -1
	 * It's index of record to read in COMMANDS table.\n
	 * If this value = -1 then the class members are set on empty.
	 *
	 * TODO : to implementing DB error
	 */
	function LSC_Scheduler_Command($id_command = -1)
	{
		$this->id_command = $id_command;
		
		if ($this->id_command == -1) {
			// Set default values
			$now = getdate();
			$this->date_created = $now[year] . "-" . $now[mon] . "-" . $now[mday] . " " . $now[hours] . ":" . $now[minutes] . ":" . $now[seconds]; // The format is YYYY-MM-DD HH:MM:SS

			$this->start_file = "";
			$this->parameters = "";
			$this->path_destination = "";
			$this->path_source = "";
			$this->create_directory_enable = false;
			$this->start_script_enable = false;
			$this->delete_file_after_execute_successful_enable = false;
			$this->files = array();
			$this->start_date = "0000-00-00 00:00:00";
			$this->end_date = "0000-00-00 00:00:00";
			$this->target = "";
			$this->username = "";
			$this->webmin_username = "";
			$this->dispatched = false;
			$this->title = "";
			$this->start_inventory_enable = false;
			$this->wake_on_lan_enable = false;
			$this->next_connection_delay = 60;
			$this->max_connection_attempt = 3;
			$this->repeat = 0;
		} else {
			$this->refresh();
		}
		return; // No error
	}

	/**
	 * Update data to database table
	 *
	 * If $id_command == -1 then a new record is create in table
	 * else the record indexed by $id_command is updated.
	 *
	 * @return id_command value\n 
	 * If a new command is insered then id_command is the new index value.\n
	 * If error -1 value is returned.
	 *
	 * TODO : to implement DB error
	 */
	function update()
	{
		global $database, $DEBUG;

		if ($this->errors > 0) return -1; // I can't update to database if instance content some errors
	
		if ($this->create_directory_enable) $create_directory = "enable";
		else $create_directory = "disable";
	
		if ($this->start_script_enable) $start_script = "enable";
		else $start_script = "disable";

		if ($this->delete_file_after_execute_successful_enable) $delete_file_after_execute_successful = "enable";
		else $delete_file_after_execute_successful = "disable";

		if ($this->dispatched) $dispatched = "YES";
		else $dispatched = "NO";

		if ($this->start_inventory_enable) $start_inventory = "enable";
		else $start_inventory = "disable";
		
		if ($this->wake_on_lan_enable) $wake_on_lan = "enable";
		else $wake_on_lan = "disable";
	
		$files = "";
		foreach($this->files as $value) {
			if ($files == "") {
				$files = $value;
			} else {
				$files = $files . "\n" . $value;
			}
		}
	
		if ($this->id_command == -1) {
			// Insert command
		
			debug(1 , "Debug : update() - insert command");
		
			$query = sprintf("
				INSERT INTO %s
				(
					date_created,
					start_file,
					parameters,
					path_destination,
					path_source,
					create_directory,
					start_script,
					delete_file_after_execute_successful,
					files,
					start_date,
					end_date,
					target,
					username,
					webmin_username,
					dispatched,
					title,
					start_inventory,
					wake_on_lan,
					next_connection_delay,
					max_connection_attempt,
					`repeat`
				)
				
				VALUES (
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s',
					'%s'
				)
			",
				COMMANDS_TABLE,
				$this->date_created,
				addslashes($this->start_file),
				addslashes($this->parameters),
				addslashes($this->path_destination),
				addslashes($this->path_source),
				$create_directory,
				$start_script,
				$delete_file_after_execute_successful,
				addslashes($files),
				$this->start_date,
				$this->end_date,
				addslashes($this->target),
				addslashes($this->username),
				addslashes($this->webmin_username),
				$dispatched,
				addslashes($this->title),
				$start_inventory,
				$wake_on_lan,
				$this->next_connection_delay,
				$this->max_connection_attempt,
				$this->repeat
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			// Return new index command
			$database->query("SELECT LAST_INSERT_ID()");
			$database->next_record();
			$this->id_command = $database->f("last_insert_id()");
			return $this->id_command;
		} else {
			// Update command
			debug(1, "Debug : update() - update command");

			$query = sprintf("
				UPDATE
					%s
				SET
					date_created = '%s',
					start_file = '%s',
					parameters = '%s',
					path_destination = '%s',
					path_source = '%s',
					create_directory = '%s',
					start_script = '%s',
					delete_file_after_execute_successful = '%s',
					files = '%s',
					start_date = '%s',
					end_date = '%s',
					target = '%s',
					username = '%s',
					webmin_username = '%s',
					dispatched = '%s',
					title = '%s',
					start_inventory = '%s',
					wake_on_lan = '%s',
					next_connection_delay = '%s',
					max_connection_attempt = '%s',
					`repeat` = '%s'
				WHERE
					id_command = '%s'
			",
				COMMANDS_TABLE,
				$this->date_created,
				addslashes($this->start_file),
				addslashes($this->parameters),
				addslashes($this->path_destination),
				addslashes($this->path_source),
				$create_directory,
				$start_script,
				$delete_file_after_execute_successful,
				addslashes($files),
				$this->start_date,
				$this->end_date,
				addslashes($this->target),
				addslashes($this->username),
				addslashes($this->webmin_username),
				$dispatched,
				addslashes($this->title),
				$start_inventory,
				$wake_on_lan,
				$this->next_connection_delay,
				$this->max_connection_attempt,
				$this->id_command,
				$this->repeat
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);
			return $this->id_command;
		}
	}

	/**
	 * Delete record to database table
	 *
	 * @return id_command deleted or -1 if nothing deleted
	 */
	function delete()
	{
		global $database, $DEBUG;

		if ($this->errors > 0) return -1; // I can't delete to database if instance content some errors

		if ($this->id_command != -1) {
			$query = sprintf("DELETE FROM %s WHERE id_command='%s'",
				COMMANDS_TABLE,
				$this->id_command
			);
	
			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			return $this->id_command;
		}
		
		return -1;
	}

	/**
	 * Dispatch the command on hosts
	 *
	 * The target command can be one host or one group.
	 *
	 * If target is a host then function create one record in COMMANDS_ON_HOST table to this host.\n
	 * If target is a group then function create some record in COMMADS_ON_HOST table. 
	 * One record by host of group.
	 * @return number of host of group or -1 if error
	 *
	 * @todo lock table
	 */
	function dispatch()
	{
		debug(1, "Start dispatch...");
		if ($this->errors > 0) return -1; // I can't delete to database if instance content some errors

		/*
		 * Test if command already dispatched
		 */

		 /*
		  * @todo : lock table
		  */
		if ( !$this->get_dispatched() ) {
			/*
			 * Get all hosts of target
			 */
			$target_path = new LSC_Path($this->target);
			$hosts_list = $target_path->get_hosts_list();
			// debug(5, sprintf("hosts_list = %s", var_export($hosts_list, true)));

			/*
			 * Iterate all host and create one command_on_host for each host
			 */
			foreach($hosts_list as $host) {
				debug(2, sprintf("Create new command on host : %s", $host["hostname"]));
				$new_command_on_host = new LSC_Scheduler_Command_on_Host();

				if ($new_command_on_host->get_by_host_and_id_command(
						$host["hostname"],
						$this->id_command
					) == -1) {
					$new_command_on_host->id_command = $this->id_command;
					$new_command_on_host->host = $host["hostname"];
					$new_command_on_host->start_date = $this->start_date;
					$new_command_on_host->end_date = $this->end_date;

					// Initialise field
					$new_command_on_host->current_state = "scheduled";
					$new_command_on_host->uploaded = "TODO";
					$new_command_on_host->executed = "TODO";
					$new_command_on_host->deleted = "TODO";
					$new_command_on_host->current_pid = -1;

					$new_command_on_host->next_launch_date = "0000-00-00 00:00:00";
					
					$new_command_on_host->number_attempt_connection_remains = $this->max_connection_attempt;
					
					$new_command_on_host->next_attempt_date_time = 0;

					$id_command_on_host = $new_command_on_host->update();

					debug(1, sprintf("New command on host are created, his id is : %s", $id_command_on_host));
				}
			}

			/*
			 * Now this command is dispatched
			 */
			$this->set_dispatched(true);
		}
		/*
		 * @todo Unlock table
		 */
	}

	/**
	 * Get dispatched field
	 *
	 * @return dispatched field value (true or false)
	 *
	 * @note dipatched member is updated.
	 */
	function get_dispatched()
	{
		global $database, $DEBUG;

		if ($this->errors > 0) return -1; // I can't get data from database if instance content some errors

		if ( $this->id_command != -1 ) {
			/*
			 * Get dispatched field value
			 */
			$query = sprintf("
				SELECT
					dispatched
				FROM
					%s
				WHERE
					id_command = '%s'
			",
				COMMANDS_TABLE,
				$this->id_command
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			if ( $database->num_rows() == 1 ) {
				$database->next_record();
				if ($database->f("dispatched") == "YES") {
					$this->dispatched = true;
				} else {
					$this->dispatched = false;
				}
				debug(1, sprintf("command found, dispatched value is : %s", $this->dispatched));
				return $this->dispatched;
			} else {
				// ERROR : Command not found in "commands" table
				$this->errors++;
				debug(1, sprintf("id_command (%s) not found in \"commands\" table", $this->id_command));
				return false;
			}
		} else {
			// id_command = -1, then return false
			debug(1, "id_command = -1 then dispatched = false");
			return false;
		}
	}

	/**
	 * Set dispatched field
	 *
	 * @param dispatched value (true or false)
	 *
	 * @return 0 if data successful updated, or -1 if error
	 *
	 * @note dipatched member and dispatched field in database is updated.
	 */
	 function set_dispatched($dispatched)
	 {
		global $database, $DEBUG;

		debug(1, sprintf("Set dispatched to %s", $dispatched));

		if ($this->errors > 0) return -1; // I can't get from database if instance content some errors

		$this->dispatched = $dispatched;

		if ($this->dispatched) $dispatched = "YES";
		else $dispatched = "NO";

		if ( $this->id_command != -1 ) {
			/*
			 * Set dispatched field value
			 */
			$query = sprintf("
				UPDATE
					%s
				SET
					dispatched = '%s'
				WHERE
					id_command = '%s'
			",
				COMMANDS_TABLE,
				$dispatched,
				$this->id_command
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			return 0;
		} else {
			// id_command = -1, then return false
			debug(1, "id_command = -1 then dispatched = false");
			return -1;
		}
	}

	/**
	 * Return in array the "commands_on_host" which are dispatched
	 *
	 * @return array host list\n
	 * or -1 if current instance isn't initialised\n
	 * or -2 if some errors
	 *
	 * <p>Each array host list element is like this :</p>
	 *
	 * <pre>
	 *	array(
	 *		"id_command_on_host" => ...
	 *		"hostname" => ...
	 *		"current_state" => ...
	 *		"uploaded" => ...
	 *		"executed" => ...
	 *		"deleted" => ...
	 *	)
	 * </pre>
	 */
	function get_host_list_dispatched()
	{
		global $database, $DEBUG;

		if ($this->errors > 0) return -2; // I can't get data from database if instance content some errors

		if ( $this->id_command != -1 ) {
			$query = sprintf("
				SELECT
					id_command_on_host,
					host,
					current_state,
					uploaded,
					executed,
					deleted
				FROM
					%s
				WHERE
					id_command = \"%s\"
				",
				COMMANDS_ON_HOST_TABLE,
				$this->id_command
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			$return_val = array();
			
			while ( $database->next_record() ) {
				$path = new LSC_Path($database->f("host"));
				$host_info = $path->get_hosts_list();
				
				array_push($return_val,
					array(
						"id_command_on_host" => $database->f("id_command_on_host"),
						"hostname" => $database->f("host"),
						"current_state" => $database->f("current_state"),
						"uploaded" => $database->f("uploaded"),
						"executed" => $database->f("executed"),
						"deleted" => $database->f("deleted"),
						"ip" => $host_info[0]["ip"],
						"mac" => $host_info[0]["mac"]
					)
				);
			}

			return $return_val;
		}

		return -1;
	}
	
	/**
	 * Refresh data
	 */
	function refresh()
	{
		global $database, $DEBUG;

		// Load values from COMMANDS table
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}
	
		$query = sprintf("
			SELECT 
				date_created, 
				start_file, 
				parameters, 
				path_destination,
				path_source, 
				create_directory, 
				start_script, 
				delete_file_after_execute_successful, 
				files, 
				start_date, 
				end_date, 
				target,
				username,
				webmin_username,
				dispatched,
				title,
				start_inventory,
				wake_on_lan,
				next_connection_delay,
				max_connection_attempt,
				`repeat`
			FROM 
				%s
			WHERE
				id_command = '%s'",
			COMMANDS_TABLE,
			$this->id_command
		);
	
		$database->query($query);
		
		if ($database->num_rows() == 1) {
			$database->next_record();
			$this->date_created = $database->f("date_created");
			$this->start_file = $database->f("start_file");
			$this->parameters = $database->f("parameters");
			$this->path_destination = $database->f("path_destination");
			$this->path_source = $database->f("path_source");
			if ($database->f("create_directory") == "enable") {
				$this->create_directory_enable = true;
			} else {
				$this->create_directory_enable = false;
			}
			
			if ($database->f("start_script") == "enable") {
				$this->start_script_enable = true;
			} else {
				$this->start_script_enable = false;
			}
	
			if ($database->f("delete_file_after_execute_successful") == "enable") {
				$this->delete_file_after_execute_successful_enable = true;
			} else {
				$this->delete_file_after_execute_successful_enable = false;
			}
	
			if ($database->f("files")=="") {
				$this->files = array();
			} else {
				$this->files = explode("\n", $database->f("files"));
			}
			
			$this->start_date = $database->f("start_date");
			$this->end_date = $database->f("end_date");
			$this->target = $database->f("target");
			$this->username = $database->f("username");
			$this->webmin_username = $database->f("webmin_username");
	
			if ($database->f("dispatched") == "YES") {
				$this->dispatched = true;
			} else {
				$this->dispatched = false;
			}
	
			$this->title = $database->f("title");
	
			if ($database->f("start_inventory") == "enable") {
				$this->start_inventory_enable = true;
			} else {
				$this->start_inventory_enable = false;
			}
			
			if ($database->f("wake_on_lan") == "enable") {
				$this->wake_on_lan_enable = true;
			} else {
				$this->wake_on_lan_enable = false;
			}
			
			$this->next_connection_delay = $database->f("next_connection_delay");
			$this->max_connection_attempt = $database->f("max_connection_attempt");
			$this->repeat = $database->f("repeat");
		} else {
			// ERROR : Command not found in "commands" table
			$this->errors++;
			debug(1, sprintf("id_command (%s) not found in \"commands\" table", $this->id_command));
			return $this->errors;
		}
	}
}

/*
 * Lock and unlock commands table functions are in "./lock_unlock_table.inc.php" file
 */
 
function lsc_command_set_pause($id_command)
{
	global $database, $DEBUG;

	debug(1, "lsc_command_set_pause");
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"pause\"
	WHERE
		id_command = \"%s\" and
		current_state = \"scheduled\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);
}

function lsc_command_set_stop($id_command)
{
	global $database, $DEBUG;

	debug(1, "lsc_command_set_stop");
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"stop\"
	WHERE
		id_command = \"%s\" and
		(
		current_state = \"not_reachable\" or
		current_state = \"scheduled\" or
		current_state = \"upload_failed\" or
		current_state = \"execution_failed\" or
		current_state = \"delete_failed\" or
		current_state = \"inventory_failed\"
		)
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);
}

function lsc_command_set_play($id_command)
{
	global $database, $DEBUG;

	debug(1, "lsc_command_set_play");
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	/*
	 *
	 */
	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"scheduled\",
		uploaded = \"TODO\"
	WHERE
		id_command = \"%s\" and
		current_state = \"upload_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);

	/*
	 *
	 */
	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"scheduled\",
		executed = \"TODO\"
	WHERE
		id_command = \"%s\" and
		current_state = \"execute_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);

	/*
	 *
	 */
	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"scheduled\",
		deleted = \"TODO\"
	WHERE
		id_command = \"%s\" and
		current_state = \"delete_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);

	/*
	 *
	 */
	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"scheduled\"
	WHERE
		id_command = \"%s\" and
		current_state = \"inventory_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);

	/*
	 *
	 */
	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"scheduled\"
	WHERE
		id_command = \"%s\" and
		(
		current_state = \"pause\" or
		current_state = \"not_reachable\"
		)
",
		COMMANDS_ON_HOST_TABLE,
		$id_command
	);
	
	$database->query($query);
}


?>
