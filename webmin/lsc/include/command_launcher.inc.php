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

require_once(dirname(__FILE__) . "/clean_path.inc.php");
require_once(dirname(__FILE__) . "/config.inc.php");
require_once(dirname(__FILE__) . "/copy.inc.php"); // Use LSC_Copy function
require_once(dirname(__FILE__) . "/delete.inc.php"); // Use LSC_Delete function
require_once(dirname(__FILE__) . "/scheduler.inc.php"); // Use LSC_Scheduler_Command and LSC_Scheduler_Command_on_Host class
require_once(dirname(__FILE__) . "/get_mac.php"); // get_mac_address_from_full_hostname function
require_once(dirname(__FILE__) . "/ssh.inc.php"); // Use LSC_Session class
require_once(dirname(__FILE__) . "/lock_unlock_table.inc.php");
require_once(dirname(__FILE__) . "/commands_on_host.inc.php");
require_once(dirname(__FILE__) . "/commands_history.inc.php");
require_once(dirname(__FILE__) . "/inventory.php");

/**
 * Command launcher class
 */
class LSC_Command_Launcher {
	var $id_command_on_host;
	var $command_on_host;		/**< LSC_Scheduler_Command_on_Host instance class */
	var $command;			/**< LSC_Scheduler_Command instance class */
	var $session;			/**< LSC_Session instance class */

	var $errors = 0;		/**< number errors */
	var $error_message;
	var $I_hold_this_command = false;

	var $start_command_return_var;	/**< This variable content the LSC_cmdFlush return array value */

	/**
	 * LSC Command Launcher constructor
	 *
	 */
	function LSC_Command_Launcher($id_command_on_host)
	{
		$this->id_command_on_host = $id_command_on_host;

		if ( $this->id_command_on_host != -1 ) {
			lsc_lock_table(array(COMMANDS_ON_HOST_TABLE,COMMANDS_TABLE, COMMANDS_HISTORY_TABLE), "WRITE");
			$this->command_on_host = new LSC_Scheduler_Command_on_Host($this->id_command_on_host);
			
			if ($this->command_on_host->current_pid == -1) {
				lsc_command_on_host_set_current_pid($this->id_command_on_host, getmypid());
				lsc_unlock_tables();
				$this->I_hold_this_command = true;
				$this->command = $this->command_on_host->get_command();
				if ($this->connection_init()!=0) {
					lsc_command_on_host_set_current_pid($this->id_command_on_host, -1);
					$this->I_hold_this_command = false;
					$this->errors++;
				}
			} else {
				lsc_unlock_tables();
				$this->I_hold_this_command = false;
			}
			
			if ($this->command_on_host->errors > 0) $this->errors++;
		}
	}
	
	function free()
	{
		lsc_command_on_host_set_current_pid($this->id_command_on_host, -1);
		$this->I_hold_this_command = false;
		/*
		if ($this->I_hold_this_command) {
			lsc_command_on_host_set_current_pid($this->id_command_on_host, -1);
			$this->I_hold_this_command = false;
		}
		*/
	}

	/**
	 * Files copy
	 *
	 * @return 0 if success deleted else -1
	 *
	 */
	function files_copy()
	{
		if ( count($this->command->files) > 0 ) {
			lsc_command_history_append(
				$this->id_command_on_host, 
				date("Y-m-d H:i:s"),
				"upload_in_progress",
				"",
				""
			);

			lsc_command_on_host_set_current_state($this->id_command_on_host, "upload_in_progress");
			lsc_command_on_host_set_uploaded_state($this->id_command_on_host, "WORK_IN_PROGRESS");

			$result= LSC_Copy(
				$this->session, 
				$this->command->path_source, 
				$this->command->files,
				$this->command->path_destination
			);

			if ( $result["return_var"] == 0 ) {
				// Copy success
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"upload_done",
					$result["stdout"],
					$result["stderr"]
				);
				
				lsc_command_on_host_set_current_state($this->id_command_on_host, "upload_done");
				lsc_command_on_host_set_uploaded_state($this->id_command_on_host, "DONE");
			} else {
				// Copy error
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"upload_failed",
					$result["stdout"],
					$result["stderr"]
				);

				lsc_command_on_host_set_current_state($this->id_command_on_host, "upload_failed");
				lsc_command_on_host_set_uploaded_state($this->id_command_on_host, "FAILED");

				return -1;
			}
		}
	}

	/**
	 * Start file
	 *
	 * @return 0 if success deleted else -1
	 *
	 * @note LSC_cmdFlush return array value is copied in $this->start_command_return_var
	 *
	 */
	function file_start()
	{
		debug(1, "File_start begining...");
		
		if ($this->command->start_script_enable) {
			/*
			 * Add new command_history (execution_in_progress)
			 */
			lsc_command_history_append(
				$this->id_command_on_host,
				date("Y-m-d H:i:s"),
				"execution_in_progress",
				"",
				""
			);
			
			/*
			 * Update command on host to "execution in progress"
			 */
			lsc_command_on_host_set_current_state($this->id_command_on_host, "execution_in_progress");
			lsc_command_on_host_set_executed_state($this->id_command_on_host, "WORK_IN_PROGRESS");
			
			// Make go to directory command
			if ($this->command->path_destination == "") {
				$start_command = sprintf($this->command->start_file." ".$this->command->parameters);
			} else {
				$cdirname = dirname($this->command->start_file);
				if ($cdirname == ".") $cdirname = "";
				$go_to_directory_command = "cd ".clean_path($this->session->root_path.$this->command->path_destination.$cdirname);
				$start_command = $go_to_directory_command.";".sprintf("./".$this->command->start_file." ".$this->command->parameters);
			}
			
			// Launch $start_command
			
			unset($output);unset($return_var);unset($return_var);unset($stdout);unset($stderr);
			lsc_ssh(
				$this->session->user, 
				$this->session->ip, 
				$start_command, 
				$output, 
				$return_var, 
				$stdout, 
				$stderr
			);

			debug(1, "command launch is : ".$start_command);
			debug(1, "command launch stdout : ".$stdout);
			debug(1, "command launch stderr : ".$stderr);
			
			/*
			 * Build stdout and stderr
			 */
			/*
			 $result["stdout"] = sprintf("%s\n%s\n", $go_to_directory_command, $start_command);
			$result["stderr"] = "";
			foreach($start_command_return_var as $cmd) {
				$result["stdout"] .= implode("\n", $cmd["STDOUT"]);
				$result["stderr"] .= implode("\n", $cmd["STDERR"]);
			}
			$result["return_var"] = $this->start_command_return_var[count($this->start_command_return_var)-1]["EXIT_CODE"];
			*/
			/*
			 * Add new command_history (execution_done or execution_failed)
			 */
			
			if ( $return_var == 0 ) {
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"execution_done",
					$stdout,
					$stderr
				);
	
				/*
				 * Update command_on_host.current_state and
				 * command_on_host.executed
				 */
				lsc_command_on_host_set_current_state($this->id_command_on_host, "execution_done");
				lsc_command_on_host_set_executed_state($this->id_command_on_host, "DONE");
			} else {
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"execution_failed",
					$stdout,
					$stderr
				);


				/*
				 * Update command_on_host.current_state and
				 * command_on_host.executed
				 */
				
				lsc_command_on_host_set_current_state($this->id_command_on_host, "execution_failed");
				lsc_command_on_host_set_executed_state($this->id_command_on_host, "FAILED");
	
				return -1;
			}
		}
	}

	/**
	 * Files delete (not implemented)
	 *
	 * @return 0 if success deleted else -1
	 *
	 */
	function files_delete()
	{
		/**
		 * Add new command_history (delete_in_progress)
		 */
		lsc_command_history_append(
			$this->id_command_on_host,
			date("Y-m-d H:i:s"),
			"delete_in_progress",
			"",
			""
		);
				 
		/*
		 * Update command on host to "upload in progress"
		 */
		lsc_command_on_host_set_current_state($this->id_command_on_host, "delete_in_progress");
		lsc_command_on_host_set_deleted_state($this->id_command_on_host, "WORK_IN_PROGRESS");
				
		/*
		 * Do delete
		 */
		/*
		 $result = LSC_Delete(
			$this->session, 
			$this->command->path_destination,
			$this->command->files
		);*/

		unset($output);unset($return_var);unset($return_var);unset($stdout);unset($stderr);
		$tries = 3;
		do {
			$dir = clean_path($this->session->root_path.$this->command->path_destination);
			if (ereg('^(/+cygdrive/+./+)?[ \.//\]+$', $dir)) break;
			$cmd="rm -rvf ".$dir;
			lsc_ssh(
				$this->session->user, 
				$this->session->ip, 
				$cmd,
				$output,
				$return_var, 
				$stdout, 
				$stderr
			);
			$tries--;
			if ( $return_var == 0 ) {
				$tries = 0;
			} else {
				sleep(10);
			}
		} while ($tries);
		
		if ( $return_var == 0 ) {
			// Success 
			lsc_command_history_append(
				$this->id_command_on_host,
				date("Y-m-d H:i:s"),
				"delete_done",
				$stdout,
				$stderr
			);

			lsc_command_on_host_set_current_state($this->id_command_on_host, "delete_done");
			lsc_command_on_host_set_deleted_state($this->id_command_on_host, "DONE");
		} else {
			// Error
			lsc_command_history_append(
				$this->id_command_on_host,
				date("Y-m-d H:i:s"),
				"delete_failed",
				$stdout,
				$stderr
			);

			
			lsc_command_on_host_set_current_state($this->id_command_on_host, "delete_failed");
			lsc_command_on_host_set_deleted_state($this->id_command_on_host, "FAILED");

			return -1;
		}
	}

	/**
	 * Execute the command
	 *
	 * Step :
	 * <ol>
	 *	<li>copy files</li>
	 *	<li>execute file</li>
	 *	<li>delete files</li>
	 * </ol>
	 *
	 * @return -1 = file_copy error\n
	 * -2 = file_start error\n
	 * -3 = files_delete error\n
	 * -4 = I doesn't hold command
	 * -99 = internal error
	 */
	function execute() 
	{
		global $DEBUG;
		$DEBUG=9;
		if ($this->errors > 0) return -99;
		if (!$this->I_hold_this_command) return -4;
		
		debug(1, "LSC_Command_Launcher->execute...");
		
		$this->command_on_host->refresh();
		/*
		 * Test if command_on_host is in pause or stop state
		 */
		 if (($this->commond_on_host->current_state=="pause") || ($this->commond_on_host->current_state=="stop")) {
			 debug(1, "command_on_host is in pause or stop state");
			 return;
		 }
		
		/*
		 * Test if start_date < now < end_date
		 */
		if ($this->command_on_host->start_date!="0000-00-00 00:00:00") {
			if (strtotime($this->command_on_host->start_date)>time()) {
				debug(1, "start_date > now");
				return;
			}
		}
		
		if ($this->command_on_host->end_date!="0000-00-00 00:00:00") {
			if (strtotime($this->command_on_host->end_date)<time()) {
				debug(1, "end_date < now");
				return;
			}
		}
		
		debug(2, "LSC_Command_Launcher->execute: copy files step");
		/*
		 * First step : copy files
		 */
		$this->command_on_host->refresh();
		if (( $this->command_on_host->uploaded == "TODO" ) && ( $this->command_on_host->state != "upload_in_progress" ))
		{
			if ( count($this->command->files) > 0 ) {
				if ($this->files_copy()<0) {
					// Error
					return -1;
				}
			} else {
				// $this->command->files is empty, then ignore this step
				lsc_command_on_host_set_current_state($this->id_command_on_host, "upload_done");
				lsc_command_on_host_set_uploaded_state($this->id_command_on_host, "IGNORED");
			}
		}

		debug(2, "LSC_Command_Launcher->execute: execute file step");
		/*
		 * Second step : execute file
		 */
		$this->command_on_host->refresh();
		if (
			(($this->command_on_host->uploaded == "DONE") || ($this->command_on_host->uploaded == "IGNORED"))
			&&
			($this->command_on_host->executed == "TODO" )
			&&
			( $this->command_on_host->state != "execution_in_progress" )
			
		) {
			if ( $this->command->start_script_enable ) {
				if ($this->file_start()<0) {
					// Error
					return -2;
				}
			} else {
				// $this->command->start_script_enable is disable, then ignore this step
				lsc_command_on_host_set_current_state($this->id_command_on_host, "execution_done");
				lsc_command_on_host_set_executed_state($this->id_command_on_host, "IGNORED");
			}
		}
	
		debug(2, "LSC_Command_Launcher->execute: delete files step");
		/*
		 * Third step : delete files
		 */
		$this->command_on_host->refresh();
		if (
			($this->command_on_host->uploaded == "DONE") &&
			(($this->command_on_host->executed == "DONE") || ($this->command_on_host->executed == "IGNORED"))
			&&
			( $this->command_on_host->state != "delete_in_progress" ) &&
			($this->command_on_host->deleted == "TODO")
		) {
			if ($this->command->delete_file_after_execute_successful_enable) {
				if ($this->files_delete()<0) {
					// Error
					return -3;
				}
			} else {
				// $this->command->delete_file_after_execute_successfull_enable is disable, then ignore this step
				lsc_command_on_host_set_current_state($this->id_command_on_host, "delete_done");
				lsc_command_on_host_set_deleted_state($this->id_command_on_host, "IGNORED");
			}
		} elseif (
				($this->command_on_host->uploaded == "IGNORED") && 
				(
					($this->command_on_host->executed == "IGNORED") ||
					($this->command_on_host->executed == "DONE")
				)
			) {
			lsc_command_on_host_set_current_state($this->id_command_on_host, "delete_done");
			lsc_command_on_host_set_deleted_state($this->id_command_on_host, "IGNORED");
		}

		/*
		 * Start inventory
		 */
		 $this->command_on_host->refresh();
		 if ($this->command->start_inventory_enable) {
			lsc_command_history_append(
				$this->id_command_on_host,
				date("Y-m-d H:i:s"),
				"inventory_in_progress",
				"",
				""
			);
			 unset($command);unset($output);unset($return_var);unset($stdout);unset($stderr);
			 start_inventory(
			 	$this->session->ip, 
				$command, 
				$output, 
				$return_var, 
				$stdout, 
				$stderr
			);
			
			if ($return_var==0) {
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"inventory_done",
					$stdout,
					$stderr
				);
			} else {
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"inventory_failed",
					$stdout,
					$stderr
				);
			}
		 }
		
		/*
		 * Test if all step are done, if yes then command is totaly DONE
		 */
		$this->command_on_host->refresh();
		if (	(
			($this->command_on_host->uploaded == "DONE") ||
			($this->command_on_host->uploaded == "IGNORED")
			) 
				&& 
			(
			($this->command_on_host->executed == "DONE") ||
			($this->command_on_host->executed == "IGNORED")
			)
				&&
			(
			($this->command_on_host->deleted == "DONE") ||
			($this->command_on_host->deleted == "IGNORED")
			)
		) {
			// 
			lsc_command_on_host_set_current_state($this->id_command_on_host, "done");
		}
	}

	/**
	 * This function initialise session instance (LSC_Session) (Private function)
	 *
	 * Instance is created with mac adress of command_on_host.host 
	 *
	 * @return Return 0 if success else return -1
	 *
	 */
	function connection_init()
	{
		global $database, $debug, $config;
		
		$mac = get_mac_address_from_full_hostname($this->command_on_host->host);
		                  
		if ( $mac != "" ) {
			$remains_connection_attempt = lsc_command_on_host_get_remains_connection_attempt($this->id_command_on_host);
			while($remains_connection_attempt > 0) {
				$this->command_on_host->refresh();
				
				if (
					($this->command_on_host->current_state=="stop") ||
					($this->command_on_host->current_state=="pause")
				) {
					return 0;
				}
				
				/* Check if next_attempt is not properly initialized (pre 1.0.3 transition) */
				if ($this->command_on_host->next_launch_date == "0000-00-00 00:00:00" &&
				    $this->command_on_host->start_date != "0000-00-00 00:00:00" ) {
				
				    	lsc_command_on_host_set_next_launch_date($this->id_command_on_host, $this->command_on_host->start_date);
					return(0);
				}
				
				$this->session = new LSC_Session($mac, $this->command->username);
					
				if ($this->session->ping_error == false) {
					/*
					 * No error
					 */
					
					if ($this->session->errors == 0) {
						// Set command_on_host_state
						lsc_command_on_host_set_current_state(
							$this->id_command_on_host,
							"scheduled"
						);
						return 0;
					}
				} else {
					/*
					 * Ping error: Wake on lan and retry
					 */
					if ($this->command->wake_on_lan_enable) {
						$this->wake_on_lan_mac($mac);
						sleep($config["delay_between_wake_on_lan_and_new_connection"]*60);
						$this->session = new LSC_Session($mac, $this->command->username);
						if ($this->session->ping_error == false) {
							/*
							 * No error
							 */
							// Set command_on_host_state
							lsc_command_on_host_set_current_state(
								$this->id_command_on_host,
								"scheduled"
							);
							return 0;
						}
					}
				}
				
				/*
				 * Connection error ...
				 */

				lsc_command_on_host_set_current_state(
					$this->id_command_on_host,
					"not_reachable"
				);
				lsc_command_history_append(
					$this->id_command_on_host,
					date("Y-m-d H:i:s"),
					"not_reachable",
					$this->session->ssh_stderr,
					$this->session->msgerror
				);

    	    	    	    	/* decrement connection attempts */
				lsc_command_on_host_set_remains_connection_attempt(
					$this->id_command_on_host, 
					--$remains_connection_attempt
				);
				
    	    	    	    	/* re-schedule */
				if ($this->command_on_host->next_launch_date == "0000-00-00 00:00:00") {
				    	lsc_command_on_host_set_next_launch_date($this->id_command_on_host, date("Y-m-d H:i:s"));
				}

				lsc_command_on_host_adjust_next_launch_date(
					$this->id_command_on_host,
					"+ interval ".$this->command->next_connection_delay." minute"
				);

				return -1;					
				
			}
			return -1;
		} else {
			debug(9, "Address mac not found");
			lsc_command_on_host_set_current_state(
				$this->id_command_on_host,
				"not_reachable"
			);
			
			$message_error="Error : host (".addslashes($this->command_on_host->host).") not found in ether list";
			lsc_command_history_append(
				$this->id_command_on_host,
				date("Y-m-d H:i:s"),
				"not_reachable",
				"",
				$message_error
			);


			$this->error_message="Host (".addslashes($this->command_on_host->host).") not found in ether list";
			$this->errors++;
			return -2;
		}
	}
	
	function wake_on_lan_mac($mac)
	{
		// read the lbs config file for WOL binary ? this would create a dependency
		system("/tftpboot/revoboot/bin/wake $mac");
	}
}
?>
