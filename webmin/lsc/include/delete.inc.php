<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
 * Copyright (C) 2005	Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA	02111-1307, USA.
 */
 
require_once(dirname(__FILE__)."/exec.inc.php");
require_once(dirname(__FILE__)."/file.inc.php");

/**
 * This function delete some files on distant host
 *
 * This function can delete one or many files recursively (traverse the subdirectory)
 * to distant host.\n
 *
 * This function use SSH to distant host.\n
 * So, the delete use standard "rm" and "rmdir" command of shell.
 *
 * @note If directory is empty, it's deleted
 * 
 * @param $session ssh session (LSC_Session instance)
 * @param $path_target distant host target directory (STRING)
 * @param $files_to_delete the list of files to delete (STRING or ARRAY)
 *
 * @return return data in array like this :
 *
 * <pre>
 * 	(
 *		[stdout] => "Standard output",
 *		[stderr] => "Standard error",	
 *		[return_var] => 0 		// (number error return by command, 0 = no error)
 *      )
 * </pre>
 * 
 */
function LSC_Delete($session, $path_target, $files_to_delete)
{
	/*
	 * Initialise result variable
	 */
	$result = array (
		"stdout" => "",
		"stderr" => "",
		"return_var" => 0
	);


	if (!is_array($files_to_delete)) {
		// Convert files_to_delete to array
		$files_to_delete = array($files_to_delete);
	}
	
	/*
	 * path_target is like this (example) : 
	 * "/mnt/net/ssh/Administrateur@192.168.0.11/cygdrive/" + $path_target
	 */
	$path_target_in_ssh = sprintf("/cygdrive/%s", $path_target);

	debug(2, sprintf("Path target mount ssh : \"%s\"", $path_target_in_ssh));	

	/*
	 * $directory_list array content all directory and 
	 * subdirectory path (to delete it after files deleting)
	 */
	$directory_list = array(); 

	/*
	 * First step : iterate all files to delete it
	 */
	foreach ($files_to_delete as $f) {
		//$f=trim($m);
		debug(1, sprintf("Delete file : %s", $f));
	
		/*
		 * Set rm command
		 */
		/* Old code
		$ssh_rm_command = sprintf("ssh %s@%s rm %s",
			$session->user,
			$session->ip,
			clean_path(sprintf("/%s/%s", $path_target_in_ssh, $f))
		);
		*/
		$rm_command = sprintf("rm %s",
			clean_path(sprintf("/%s/%s", $path_target_in_ssh, $f))
		);
		
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		// exec($ssh_rm_command, $output, $return_var); Old code
		lsc_ssh(
			$session->user, 
			$session->ip,
			$rm_command,
			$output,
			$return_var,
			$stdout,
			$stderr
		);
		$result["stdout"] .= sprintf("%s\n", $rm_command);

		if ($return_var != 0) {
			debug(1, sprintf("Warning ! I can't delete file : %s", $rm_command));
			debug(1, sprintf("Output value : %s", $output));
			debug(1, sprintf("Exit value : %s", $return_var));

			$result["stderr"] .= implode("\n", $output);
			$result["return_err"] = $return_var;

		} else {
			$result["stdout"] .= implode("\n", $output);

			debug(1, sprintf("File success deleted, command is %s", $rm_command));
		}

		/*
		 * Push dirname of file in directory_list array
		 */
		if ( 
			(dirname($f) != ".") && 
			(!in_array(dirname($f), $directory_list))
		) {
			// Add dirname in directory_list array
			debug(1, sprintf("Add %s in directory_list to delete", dirname($f)));
			array_push($directory_list, dirname($f));
		}
	}

	/*
	 * Split the directory
	 *
	 * Add all parent directory in directory_list array
	 *
	 * Bad hack but useful
	 */
	foreach ($directory_list as $d) {
		$parent_buffer = get_parent_directory($d);
		while($parent_buffer != "") {
			if (!in_array($parent_buffer, $directory_list)) {
				debug(1, sprintf("Add %s in directory_list to delete", dirname($parent_buffer)));
				array_push($directory_list, $parent_buffer);
			}

			$parent_buffer = get_parent_directory($parent_buffer);
		}
	}

	/*
	 * Second step : Iterate all directory to "rmdir" it
	 */
	//debug(1, sprintf("directory_list value = %s", var_export($directory_list, true)));
	foreach ($directory_list as $d) {
		debug(1, sprintf("Delete directory %s", $d));

		/*
		 * This function use "rmdir" command. 
		 * If directory isn't empty then it's not deleted
		 * 
	 	 * Warning ! not use -p argument ! because it's delete all from / !
	 	 */
		/* Old code
		$ssh_rmdir_command = sprintf("ssh %s@%s rmdir %s",
			$session->user,
			$session->ip,
			clean_path(sprintf("/%s/%s", $path_target_in_ssh, $d))
		);
		*/
		$rmdir_command = sprintf("rmdir %s",
			clean_path(sprintf("/%s/%s", $path_target_in_ssh, $d))
		);

		unset($output); unset($return_var); unset($stdout); unset($stderr);
		// exec($ssh_rmdir_command, $output, $return_var); Old code
		
		lsc_ssh(
			$session->user,
			$session->ip, 
			$rmdir_command, 
			$output, 
			$return_var, 
			$stdout, 
			$stderr
		);
		
		$result["stdout"] .= sprintf("%s\n", $rmdir_command);
		if ($return_var != 0) {
			debug(1, sprintf("Warning ! I can't remove directory : %s", $rmdir_command));
			debug(1, sprintf("Output value : %s", $output));
			debug(1, sprintf("Exit value : %s", $return_var));

			$result["stderr"] .= implode("\n", $output);
		} else {
			$result["stdout"] .= implode("\n", $output);

			debug(1, sprintf("Directory success removed, command is %s", $rmdir_command));
		}
	}

	return $result;
}
?>
