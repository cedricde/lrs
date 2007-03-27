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
require_once(dirname(__FILE__) . "/command_launcher.inc.php"); /* Use LSC_Command_Launcher */

/**
 * Class to handle one command on host element 
 */
class LSC_Scheduler_Command_on_Host 
{
	var $id_command_on_host;		/**< command on host database table index */
	var $id_command;			/**< command database table index */
	var $host;				/**< full host target (profil + group + host !) */
	var $start_date;			/**< the command can start after this date (YYYY-MM-DD HH:MM:SS) */
	var $end_date;				/**< the command can't start after this date (YYYY-MM-DD HH:MM:SS) */
	var $current_state;			/**< current state of command (see COMMAND_STATES_LIST in config.inc.php file) */
	var $uploaded;				/**< is command uploaded ? (see UPLOADED_EXECUTED_DELETED_LIST in config.inc.php file) */
	var $executed;				/**< is command executed ? */
	var $deleted;				/**< is command deleted ? */
	var $next_launch_date;			/**< when this command will be started (YYYY-MM-DD HH:MM:SS) */
	var $number_attempt_connection_remains;	/**< TODO */
	var $next_attempt_date_time;		/**< php time function value */
	var $current_pid = -1;
	var $errors = 0;			/**< number errors */

	/**
	 * LSC Scheduler Command on Host constructor
	 *
	 * Read data from COMMANDS_ON_HOST table.
	 *
	 * @param $id_command_on_host
	 *
	 * It's index of record to read in COMMANDS_ON_HOST table.\n
	 * If this value = -1 then the class members are set on empty.
	 *
	 * @todo : implement DB error
	 */
	function LSC_Scheduler_Command_on_Host($id_command_on_host = -1)
	{
		global $database, $DEBUG;

		debug(1, sprintf("id_command_on_host = %s", $id_command_on_host));

		$this->id_command_on_host = $id_command_on_host;

		if ($this->id_command_on_host == -1) {
			// Set default values
			$this->id_command = -1;
			$this->host = "";
			$this->start_date = "0000-00-00 00:00:00";
			$this->end_date = "0000-00-00 00:00:00";
			$this->current_state = "";	// Undefined
			$this->uploaded = ""; 		// Undefined
			$this->executed = "";		// Undefined
			$this->deleted = "";		// Undefined
			$this->next_launch_date = "0000-00-00 00:00:00";
			$this->number_attempt_connection_remains = 0;
			$this->next_attempt_date_time = 0;
			$this->current_pid = -1;
		} else {
			$this->refresh();
		}
		return; // No error
	}

	/**
	 * Update data to database table
	 *
	 * If $id_command_on_host == -1 then a new record is create in table
	 * else the record indexed by $id_command_on_host is updated.
	 *
	 * @return id_command_on_host value\n
	 * If a new command is insered then id_command_on_host is the new index value.\n
	 * If error -1 value is returned.\n
	 * If state member is invalid -2 value is returned.\n
	 * If copied value is invalid -3.\n
	 * If executed value is invalid -4.\n
	 * If deleted valud is invalid -5.\n
	 *
	 * @todo : to implement DB error
	 * @todo : Before update or insert, test if row exist with the $host and $id_command
	 */
	function update()
	{
		global $database, $DEBUG;

		debug(2, "LSC_Scheduler_Command_on_Host->update()");		

		if ($this->errors > 0) return -1; // I can't update to database if instance content some errors
	
		/*
		 * Test if fields are valid
		 */
		if (!$this->is_state_valid()) {
			// State member is invalid !
			debug(2, sprintf("state member field is invalid : %s", $this->current_state));
			return -2; 
		}

		if (!$this->is_uploaded_valid()) {
			// copied value is invalid !
			debug(2, sprintf("uploaded field is invalid : %s", $this->uploaded));
			return -3; 
		}

		if (!$this->is_executed_valid()) {
			// executed value is invalid !
			debug(2, sprintf("executed field is invalid : %s", $this->executed));
			return -4; 
		}

		if (!$this->is_deleted_valid()) {
			// deleted value is invalid !
			debug(2, sprintf("deleted field is invalid : %s", $this->deleted));
			return -5; 
		}

		if ($this->id_command_on_host == -1) {
			// Insert new command_on_host
		
			debug(1, "Debug : update() - insert command");
		
			$query = sprintf("
				INSERT INTO %s
				(
					id_command,
					host,
					start_date,
					end_date,
					current_state,
					uploaded,
					executed,
					deleted,
					next_launch_date,
					current_pid,
					number_attempt_connection_remains,
					next_attempt_date_time
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
					'%s'
				)
			",
				COMMANDS_ON_HOST_TABLE,
				$this->id_command,
				addslashes($this->host),
				$this->start_date,
				$this->end_date,
				$this->current_state,
				$this->uploaded,
				$this->executed,
				$this->deleted,
				$this->next_launch_date,
				$this->current_pid,
				$this->number_attempt_connection_remains,
				$this->next_attempt_date_time
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			// Return new index command on host
			$database->query("SELECT LAST_INSERT_ID()");
			$database->next_record();
			$this->id_command_on_host = $database->f("last_insert_id()");
			return $this->id_command_on_host;
		} else {
			// Update command
			debug(1, "Debug : update() - update command");

			$query = sprintf("
				UPDATE
					%s
				SET
					id_command = '%s',
					host = '%s',
					start_date = '%s',
					end_date = '%s',
					current_state = '%s',
					uploaded = '%s',
					executed = '%s',
					deleted = '%s',
					next_launch_date = '%s',
					current_pid = '%s',
					number_attempt_connection_remains = '%s',
					next_attempt_date_time = '%s'
				WHERE
					id_command_on_host = '%s'
			",
				COMMANDS_ON_HOST_TABLE,
				$this->id_command,
				addslashes($this->host),
				$this->start_date,
				$this->end_date,
				$this->current_state,
				$this->uploaded,
				$this->executed,
				$this->deleted,
				$this->next_launch_date,
				$this->current_pid,
				$this->number_attempt_connection_remains,
				$this->next_attempt_date_time,
				$this->id_command_on_host
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);
			return $this->id_command_on_host;
		}

	}
	
	/**
	 * Delete record to database table
	 *
	 * @return id_command_on_host deleted or -1 if nothing deleted
	 */
	function delete()
	{
		global $database, $DEBUG;

		if ($this->errors > 0) return -1; // I can't delete to database if instance content some errors

		if ($this->id_command_on_host != -1) {
			$query = sprintf("DELETE FROM %s WHERE id_command_on_host='%s'",
				COMMANDS_ON_HOST_TABLE,
				$this->id_command_on_host
			);
	
			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			return $this->id_command_on_host;
		}
		
		return -1;
	}

	/**
	 * Test if state field is valid
	 *
	 * @return true if state is in $COMMAND_STATES_LIST, else return false
	 */
	function is_state_valid()
	{
		global $COMMAND_STATES_LIST;
		return in_array($this->current_state, $COMMAND_STATES_LIST);
	}
	
	/**
	 * Test if uploaded field is valid
	 *
	 * @return true if uploaded value is in $UPLOADED_EXECUTED_DELETED_LIST, else return false
	 */
	function is_uploaded_valid()
	{
		global $UPLOADED_EXECUTED_DELETED_LIST;
		return in_array($this->uploaded, $UPLOADED_EXECUTED_DELETED_LIST);
	}

	/**
	 * Test if executed field is valid
	 *
	 * @return true if executed value is in $UPLOADED_EXECUTED_DELETED_LIST, else return false
	 */
	function is_executed_valid()
	{
		global $UPLOADED_EXECUTED_DELETED_LIST;
		return in_array($this->executed, $UPLOADED_EXECUTED_DELETED_LIST);
	}

	/**
	 * Test if deleted field is valid
	 *
	 * @return true if deleted value is in $UPLOADED_EXECUTED_DELETED_LIST, else return false
	 */
	function is_deleted_valid()
	{
		global $UPLOADED_EXECUTED_DELETED_LIST;
		return in_array($this->deleted, $UPLOADED_EXECUTED_DELETED_LIST);
	}

	/**
	 * Search command by host and id_command fields
	 *
	 * This method set members fields values.
	 * 
	 * @param $host = host to match
	 * @param $id_command = id_command to match
	 * @return the id_command_on_host index number or -1 if command is not found.\n
	 * return -2 if the number of commands found is > 1
	 */
	function get_by_host_and_id_command($host, $id_command)
	{
		global $database, $DEBUG;

		$query = sprintf("
			SELECT
				id_command_on_host,
				start_date,
				end_date,
				current_state,
				uploaded,
				executed,
				deleted,
				next_launch_date
			FROM
				%s
			WHERE
				host = '%s' AND
				id_command = '%s'
			",
			COMMANDS_ON_HOST_TABLE,
			addslashes($host),
			$id_command
		);
		
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}

		$database->query($query);

		if ($database->num_rows() == 1) {
			$database->next_record();
			
			$this->id_command_on_host = $database->f("id_command_on_host");
			$this->id_command = $id_command;
			$this->host = $host;
			$this->start_date = $database->f("start_date");
			$this->end_date = $database->f("end_date");
			$this->current_state = $database->f("current_state");
			$this->uploaded = $database->f("uploaded");
			$this->executed = $database->f("executed");
			$this->deleted = $database->f("deleted");

			$this->next_launch_date = $database->f("next_launch_date");
		} else if ($database->num_rows() == 0) {
			return -1;
		} else {
			return -2;
		}

		return $this->id_command_on_host;
	}

	/**
	 * This function return LSC_Scheduler_Command class instance of LSC_Scheduler_Command_on_Host command
	 *
	 * @return Command (LSC_Scheduler_Command class)
	 */
	function get_command() {
		$command = new LSC_Scheduler_Command($this->id_command);

		return $command;
	}

	/**
	 * Return in array command history of current command on host
	 *
	 * @return array history list\n
	 * return -1 if current instance isn't initialied\n
	 * return -2 if some errors
	 *
	 */
	function get_history_list()
	{
		global $database, $DEBUG;

		if ( $this->errors > 0 ) return -2; // I can't get data from database if instance content some errors

		if ( $this->id_command_on_host != -1 ) {
			$query = sprintf("
				SELECT
					id_command_history,
					date,
					stderr,
					stdout,
					state
				FROM
					%s
				WHERE
					id_command_on_host = \"%s\"
				",
				COMMANDS_HISTORY_TABLE,
				$this->id_command_on_host
			);

			if (!isset($database)) {
				$database = new LSC_DB();
				if ($DEBUG >= 1) $database->Debug = true;
			}

			$database->query($query);

			$return_val = array();

			while ( $database->next_record() ) {
				array_push($return_val,
					array(
						"id_command_history" => $database->f("id_command_history"),
						"date" => $database->f("date"),
						"stderr" => $database->f("stderr"),
						"stdout" => $database->f("stdout"),
						"state" => $database->f("state")
					)
				);
			}

			return $return_val;
		}

		return -1;
	}
	
	/*
	 * @return if error return -1
	 */
	function refresh()
	{
		// Load values from COMMANDS_ON_HOST table
		if (!isset($database)) {
			$database = new LSC_DB();
			if ($DEBUG >= 1) $database->Debug = true;
		}

		$query = sprintf("
			SELECT 
				id_command,
				host,
				start_date,
				end_date,
				current_state,
				uploaded,
				executed,
				deleted,
				next_launch_date,
				number_attempt_connection_remains,
				next_attempt_date_time,
				current_pid
			FROM
				%s
			WHERE
				id_command_on_host = '%s'",
			COMMANDS_ON_HOST_TABLE,
			$this->id_command_on_host
		);

		$database->query($query);

		if ($database->num_rows() == 1) {
			$database->next_record();

			$this->id_command = $database->f("id_command");
			$this->host = $database->f("host");
			$this->start_date = $database->f("start_date");
			$this->end_date = $database->f("end_date");
			$this->current_state = $database->f("current_state");
			$this->uploaded = $database->f("uploaded");
			$this->executed = $database->f("executed");
			$this->deleted = $database->f("deleted");
			$this->next_launch_date = $database->f("next_launch_date");
			$this->number_attempt_connection_remains = $database->f("number_attempt_connection_remains");
			$this->next_attempt_date_time = $database->f("next_attempt_date_time");
			$this->current_pid = $database->f("current_pid");
		} else {
			// ERROR : Command not found in "commands_on_host" table
			$this->errros++;
			return -1; // I can't return error because I'm in constructor
		}
	}
}

/**
 * Return the number attempt connection remains
 *
 * @param $id_command_on_host
 * @return number attempt remains\n
 * return -1 if query error
 *
 */
function lsc_command_on_host_get_remains_connection_attempt($id_command_on_host)
{
	global $database, $DEBUG;

	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	SELECT 
		number_attempt_connection_remains
	FROM
		%s
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
	);
	
	$database->query($query);
	
	if ($database->next_record()) {
		return $database->f(0);
	} else {
		return -1;
	}
}

/**
 * Set number attempt connection remains
 *
 * @param $id_command_on_host
 * @param $new_number_attempt_connection_remains
 *
 */
function lsc_command_on_host_set_remains_connection_attempt($id_command_on_host, $new_number_attempt_connection_remains)
{
	global $database, $DEBUG;

	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		number_attempt_connection_remains = '%s'
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$new_number_attempt_connection_remains,
		$id_command_on_host
	);
	
	$database->query($query);
}

/**
 * Get next attempt date time
 *
 * @param id_command_on_host
 * @return next attempt date time
 *
 */
function lsc_command_on_host_get_next_attempt_date_time($id_command_on_host)
{
	global $database, $DEBUG;

	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	SELECT 
		next_attempt_date_time
	FROM
		%s
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
	);
	
	$database->query($query);
	
	if ($database->next_record()) {
		return $database->f(0);
	} else {
		return -1;
	}
}

/**
 * Set next attempt date time
 *
 * @param $id_command_on_host
 * @param new next attempt date time value
 *
 */
function lsc_command_on_host_set_next_attempt_date_time($id_command_on_host, $new_next_attempt_date_time)
{
	global $database, $DEBUG;

	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		next_attempt_date_time = '%s'
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$new_next_attempt_date_time,
		$id_command_on_host
	);
	
	$database->query($query);
}

function lsc_command_on_host_set_current_state($id_command_on_host, $new_state)
{
	global $database, $DEBUG;

	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = '%s'
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$new_state,
		$id_command_on_host
	);
	
	$database->query($query);
}

/**
 * Test if one command on host exist
 *
 * @param interger command on host index
 * @return boolean
 */
function lsc_command_on_host_exist($id_command_on_host)
{
	global $database, $DEBUG;

	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	SELECT
		COUNT(*)
	FROM
		%s
	WHERE
		id_command_on_host=\"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
	);
	
	$database->query($query);
	
	if ($database->next_record()) {
		if ($database->f(0) == 1) return true;
		else return false;
	} else {
		return false;
	}
}

/**
 * Test if command on host is DONE
 */
function lsc_command_on_host_is_done($id_command_on_host)
{
	global $database, $DEBUG;
	
	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	SELECT
		current_state
	FROM
		%s
	WHERE
		id_command_on_host=\"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
	);
	
	$database->query($query);
	
	if ($database->next_record()) {
		if ($database->f(0) == "done") return true;
		else return false;
	} else {
		return false;
	}
}

function lsc_command_on_host_set_current_pid($id_command_on_host, $new_current_pid)
{
	global $database, $DEBUG;

	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query =
"
	UPDATE
		".COMMANDS_ON_HOST_TABLE."
	SET
		current_pid = \"".$new_current_pid."\"
	WHERE
		id_command_on_host = \"".$id_command_on_host."\"
";
	
	$database->query($query);
}

function lsc_command_on_host_set_uploaded_state($id_command_on_host, $new_state)
{
	global $database, $DEBUG;

	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		uploaded = '%s'
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$new_state,
		$id_command_on_host
	);
	
	$database->query($query);
}

function lsc_command_on_host_set_executed_state($id_command_on_host, $new_state)
{
	global $database, $DEBUG;

	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		executed = '%s'
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$new_state,
		$id_command_on_host
	);
	
	$database->query($query);
}

function lsc_command_on_host_set_deleted_state($id_command_on_host, $new_state)
{
	global $database, $DEBUG;

	debug(1, __FUNCTION__);
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		deleted = '%s'
	WHERE
		id_command_on_host = \"%s\"
",
		COMMANDS_ON_HOST_TABLE,
		$new_state,
		$id_command_on_host
	);
	
	$database->query($query);
}

 
function lsc_command_on_host_set_pause($id_command_on_host)
{
	global $database, $DEBUG;

	debug(1, "lsc_command_on_host_set_pause");
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"pause\",
		current_pid = \"-1\"
	WHERE
		id_command_on_host = \"%s\" and
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
		$id_command_on_host
	);
	
	$database->query($query);
}

function lsc_command_on_host_set_stop($id_command_on_host)
{
	global $database, $DEBUG;

	debug(1, "lsc_command_on_host_set_stop");
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}

	// Get current state
	$query=
"
SELECT
	current_state,
	current_pid
FROM
	".COMMANDS_ON_HOST_TABLE."
WHERE
	id_command_on_host = \"".$id_command_on_host."\"
";

	$database->query($query);

	$database->next_record();
	$current_state = $database->f("current_state");
	if (
		($current_state == "not_reachable") ||
		($current_state == "scheduled") ||
		($current_state == "upload_failed") ||
		($current_state == "execution_failed") ||
		($current_state == "delete_failed") ||
		($current_state == "inventory_failed") ||
		($current_state == "upload_in_progress") ||
		($current_state == "execution_in_progress") ||
		($current_state == "delete_in_progress") ||
		($current_state == "inventory_in_progress")
	) {
		if ( $database->f("current_pid") != -1 ) {
			posix_kill($database->f("current_pid"), 9);
		}

		$query = sprintf(
"
	UPDATE
		%s
	SET
		current_state = \"stop\",
		current_pid = \"-1\"
	WHERE
		id_command_on_host = \"%s\"
",
			COMMANDS_ON_HOST_TABLE,
			$id_command_on_host
		);
	
		$database->query($query);

		return;
	}
}

function lsc_command_on_host_set_play($id_command_on_host)
{
	global $database, $DEBUG;

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
		id_command_on_host = \"%s\" and
		current_state = \"upload_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
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
		id_command_on_host = \"%s\" and
		current_state = \"execute_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
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
		id_command_on_host = \"%s\" and
		current_state = \"delete_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
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
		id_command_on_host = \"%s\" and
		current_state = \"inventory_failed\"
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
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
		id_command_on_host = \"%s\" and
		(
		current_state = \"pause\" or
		current_state = \"not_reachable\"
		)
",
		COMMANDS_ON_HOST_TABLE,
		$id_command_on_host
	);
	
	$database->query($query);
}


?>
