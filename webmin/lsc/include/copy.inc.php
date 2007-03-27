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

/**
 * This function copy some files to distant host
 *
 * This function can copy one or many files recursively (traverse the subdirectory)
 * to a distant host.\n
 *
 * @warning I can't use SSHFS to copy the files because it's too slow.\n
 * Now, I must use "scp" but SSHFS is yet used to make the directory.
 *
 * @note if directory destination not exist, LSC_Copy create it.
 *
 * @param $session ssh session (LSC_Session instance)
 * @param $path_source localhost source directory (STRING)
 * @param $files_source the list of files to copy (STRING or ARRAY)
 * @param $path_destination distant host destination directory (STRING)
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
 * @todo split stdout and stderr return value
 */

function LSC_Copy($session, $path_source, $files_source, $path_destination)
{
	//debug(1, sprintf("LSC_Copy(..., %s, %s, %s)...", $path_source, var_export($files_source, true), $path_destination));

	/*
	 * Initialise result variable
	 */
	$result = array (
		"stdout" => "",
		"stderr" => "",
		"return_var" => 0
	);
	

	if (!is_array($files_source)) {
		// Convert files_source to array
		$files_source = array($files_source);

	}

	$root_path = $session->root_path;

	// This path is used by "mkdir" command step
	$path_destination_mount_ssh = sprintf("%s%s%s", 
		$session->sshfs_mount, 
		"$root_path", 
		$path_destination
	);

	// This path is used by "scp" command step
	$path_destination = $root_path.$path_destination;

	debug(2, sprintf("Path destination : \"%s\"", $path_destination));

	// Iterate all files
	foreach ($files_source as $f) {
		debug(1, sprintf("Copy file : %s", $f));

		$dirname = dirname($f);
		if ($dirname == ".") $dirname = "";
		$basename = trim(basename($f));
		debug(2, "LSC_COPY : Dirname : \"".$dirname."\" Basename : \"".trim($basename)."\"");
		/*
		 * Make directory step
		 */
		
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		$mkdir_command = "test -d '".$path_destination."' || mkdir -p '".$path_destination."'";
		lsc_ssh(
			$session->user, 
			$session->ip,
			$mkdir_command,
			$output,
			$return_var, 
			$stdout, 
			$stderr
		);		

		if ($return_var != 0) {
			// Error ! I can't make destination directory
			debug(1, sprintf("Error ! I can't make destination directory : %s", $mkdir_command));
			//debug(1, sprintf("Output value : %s", var_export($output, true)));
			debug(1, sprintf("Exit value : %s", $return_var));
			
			$result["stderr"] .= implode("\n", $output);
			$result["return_var"] = $return_var;
			return $result;
		} else {
			//debug(1, sprintf("Output value : %s", var_export($output, true)));
			$result["stdout"] .= implode("\n", $output);
		}
		debug(1, sprintf("Destination directory \"%s%s\" created.", $path_destination_mount_ssh, $dirname));

		/*
		 * Copy files step
		 */

		// Copy the file, warning : it's use "scp" comman

		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_scp(
			$session->user, 
			$session->ip, 
			$path_source."/".$dirname."/".$basename,
			$path_destination."/".$dirname,
			$output,
			$return_var,
			$stdout,
			$stderr,
			$scp_command
		);
		debug(2, "LSC_COPY - scp_command = $scp_command");
		// exec($scp_command, $output, $return_var); Old code
		$result["stdout"] .= sprintf("%s\n", $scp_command);

		if ($return_var != 0) {
			// Error ! I can't copy the file
			debug(1, sprintf("Error ! I can't copy the file : %s", $scp_command));
			//debug(1, sprintf("Output value : %s", var_export($output, true)));
			debug(1, sprintf("Exit value : %s", $return_var));

			$result["stderr"] .= implode("\n", $output);
			$result["return_var"] = $return_var;

			return $result;
		} else {
			// debug(1, sprintf("Output value : %s", var_export($output, true)));
			$result["stdout"] .= implode("\n", $output);
		}
		debug(1, sprintf("File successfully copied, command is %s", $scp_command));
		
		/*
		 * chmod +x on *.bat and *.exe
		 */
		$chmod_command = "chmod ugo+x -R \"$path_destination_mount_ssh\"/*.exe";
		unset($output); unset($stdout);	unset($stderr);	unset($return_var);
		lsc_exec($chmod_command, $output, $return_var, $stdout, $stderr);

		$chmod_command = "chmod ugo+x -R \"$path_destination_mount_ssh\"/*.bat";
		unset($output); unset($stdout);	unset($stderr);	unset($return_var);
		lsc_exec($chmod_command, $output, $return_var, $stdout, $stderr);
	}
	return $result;
}
?>
