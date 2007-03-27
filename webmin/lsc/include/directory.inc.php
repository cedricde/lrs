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

require_once(dirname(__FILE__) . "/debug.inc.php");
require_once(dirname(__FILE__) . "/clean_path.inc.php");
require_once(dirname(__FILE__) . "/exec.inc.php");

/**
 * @file This file provides LSC_Directory and LSC_DistantDirectory class
 */

/**
 * This class provides functions to work with local directories.
 */
class LSC_Directory
{
	var $current_directory = "";		/**< Full path of directory */
	var $array_files = array();		/**< This array content all element of directory (files and subdirectory) */
	
	/**
	 * $array_files has this structure :
	 *
	 * <pre>
	 * array (
	 *	0 =>
	 *	array (
	 *		'name' => 'lsc',
	 *		'ctime' => 1129210883,
	 *		'size' => 4096,
	 *		'is_directory' => true,
	 *	),
	 *	1 =>
	 *	array (
	 *		'name' => 'README',
	 *		'ctime' => 1119277319,
	 *		'size' => 2275,
	 *		'mimetype' => NULL,
	 *		'extension' => 'README',
	 *		'is_directory' => false,
	 *	),
	 *	2 =>
	 *	array (
	 *		'name' => 'acl',
	 *		'ctime' => 1119277322,
	 *		'size' => 4096,
	 *		'is_directory' => true,
	 *	),
	 *	3 =>
	 *	array (
	 *		'name' => 'acl_security.pl',
	 *		'ctime' => 1119277319,
	 *		'size' => 5202,
	 *		'mimetype' => NULL,
	 *		'extension' => 'pl',
	 *		'is_directory' => false,
	 *	),
	 *      ...
	 * </pre>
	 */

	var $ctime;
	var $error_code = 0;
	var $name = "";
	var $directory_exist = false;		/**< is the directory exist ? */

	/**
	 * LSC_Directory constructor
	 *
	 * @param directory_path
	 *
	 * Error code is in $this->error_code.
	 *
	 * @warning This class use this global variable : mime_types_data.\n
	 * Use LSC_load_mime_type to get this variable.
	 *
	 * @see LSC_load_mime_type
	 */
	function LSC_Directory($directory_path)
	{
		//debug(1, sprintf("directory_path : %s", var_export($directory_path, true)));
		
		$this->current_directory = $directory_path;
		
		/*
		 * Test if directory_path value is empty
		 */
		if (empty($directory_path)) {
			debug(2, "ERROR : directory path name is empty");
			$this->error_code = ERROR_DIRECTORY_NAME_IS_EMPTY;
			return; // No return value because I'm in constructor
		}

		/*
		 * Test if directory exist
		 */
		if (file_exists($directory_path) === FALSE) {
			debug(2, "Directory path not exist");
			$this->directory_exist = false;
		} else {
			debug(2, "Directory path exist");
			$this->directory_exist = true;
		}
		
		/*
		 * Test if file is a directory
		 */
		if (
			$this->directory_exist &&
			!is_dir($directory_path)
		) {
			debug(2, "Error : directory_path name isn't a directory ! It's a file");
			$this->errcode = ERROR_IS_NOT_DIRECTORY;
			return false;
		}


		/*
		 * Scan the directory
		 */
		if ( $this->directory_exist ) {
			$this->ctime = filectime($this->current_directory);
			$this->scan();
		}
	}
 
	/**
	 * Scan the directory (private function)
	 *
	 * This function return all data in array_files members
	 *
	 * @note "." and ".." isn't put in array_files
	 *
	 * @warning This class use this global variable : mime_types_data.\n
	 * Use LSC_load_mime_type to get this variable.
	 *
	 * @see LSC_load_mime_type
	 */
	function scan()
	{
		global $mime_types_data; /**< This is a array whose content all mime types */
	
		debug(1, sprintf("Start scan this directory : %s...", $this->current_directory));
		$handle = opendir($this->current_directory);

		$files = array();
		while ( $file = readdir($handle) ) {
		    $files[] = $file;
		}
		sort($files);
		reset($files);
		foreach ( $files as $file ) {
			// Not treat "." and ".." file
			if (($file == ".") || ($file == "..")) {
				continue;
			}
		
			// Get the full path filename
			$full_path_filename = realpath(
				sprintf(
					"%s/%s",
					$this->current_directory,
					$file
				)
			);

			if ( is_dir( $full_path_filename ) ) {
				/*
				 * Treat directory file
				 */
				 array_push(
				 	$this->array_files,
				 	array(
						"name" => $file,
						"ctime" => filectime($full_path_filename),
						"size" => filesize($full_path_filename),
						"is_directory" => true
					)
				 );
			} elseif ( is_file( $full_path_filename ) ) {
				/*
				 * Get extension
				 */
				$filepatharray = explode(".", $file);
				$extension = $filepatharray[count($filepatharray)-1];

				/*
				 * Treat file
				 */
				 array_push(
				 	$this->array_files,
					array(
						"name" => $file,
						"ctime" => filectime($full_path_filename),
						"size" => filesize($full_path_filename),
						"mimetype" => $mime_types_data[$extension],
						"extension" => $extension,
						"is_directory" => false
					)
				 );
			}
		}
		
		closedir($handle);
		
		// Debuging informations
		debug(2, "Scanning finish");
		/* debug(9, sprintf(
			"Data scan is : %s",
			var_export($this->array_files, true)
		));*/
	}

	/**
	 * get_parent
	 *
	 * Return parent directory ( like cd ../ )
	 *
	 * @return path directory (string)
	 *
	 * @warning I use clean_path (and not realpath (php function)) to 
	 * use this function on distant host
	 */
	 function get_parent()
	 {
	 	$parent = clean_path($this->distant_directory . "/../");
		
		debug(2, sprintf(
			"The parent of %s directory is %",
			$this->distant_directory,
			$parent
		));
		
	 	return $parent;
	 }

	 /**
	  * Make a new directory
	  *
	  * @return false if some error. Error code is in $this->error_code.
	  *
	  * This function can create many directory (recursively)
	  */
	 function make_directory()
	 {
	 	debug(1, "Start make directory");
		/*
		 * Test if directory already exist
		 */
	 	if ($this->directory_exist) {
			debug(2, "Error : Directory already exist then I can't create it");
			$this->error_code = ERROR_I_CAN_NOT_CREATE_DIRECTORY_IT_ALREADY_EXIST;
			return false;
		}
		
		/*
		 * Make mkdir command
		 */
		$mkdir_command = sprintf(
			"mkdir -p --mode=0775 \"%s\"",
			$this->current_directory
		);
	
		/*
		 * Execute command
		 */
		debug(2, sprintf(
			"Mkdir command is %s",
			$mkdir_command
		));
		
		unset($output); unset($return_val); unset($stdout); unset($stderr);
		// exec($mkdir_command, $output, $return_val); Old code
		lsc_exec($mkdir_command, $output, $return_val, $stdout, $stderr);

		/*
		 * Treat error
		 */
		if ( $return_val != 0 ) {
			debug(2, sprintf(
				"Error when I create the directory\n Ouput is : %s\n Return_val is : %s",
				$output,
				$return_val
			));
			
			$this->error_code = ERROR_CREATE_DIRECTORY;
			return false;
		} else {
			debug(2, "Directory created with success");
		}

		// No error
		return true;
	 }

	 /**
	  * Delete the current directory and all its files
	  *
	  * @return false if some error. Error code is in $this->error_code.
	  *
	  * @warning This doing recursive delete !!!
	  */
	 function delete_directory()
	 {
	 	debug(1, "Delete directory");
	 	/*
		 * Test if directory not exist
		 */
	 	if (!$this->directory_exist) {
			debug(2, "Error : Directory not exist then I can't delete it");
			$this->error_code = ERROR_I_CAN_NOT_REMOVE_DIRECTORY_IT_DO_NOT_EXIST;
			return false;
		}
		
		/*
		 * Make rm command
		 */
		$rm_command = sprintf(
			"rm -Rf \"%s\"",
			$this->current_directory
		);
	
		/*
		 * Execute command
		 */
		/*
		debug(1, sprintf(
			"This command is disable for debuging security : %s",
			$rm_command
		));
		*/
		debug(2, sprintf(
			"rm command is %s",
			$mkdir_command
		));
		
		
		// exec($rm_command, $output, $return_val); Old code
		unset($output); unset($return_val); unset($stdout); unset($stderr);
		lsc_exec($rm_command, $output, $return_val, $stdout, $stderr);
		
		/*
		 * Treat error
		 */
		if ( $return_val != 0 ) {
			debug(2, sprintf(
				"Error when I delete the directory\n Ouput is : %s\n Return_val is : %s",
				$output,
				$return_val
			));
			
			$this->error_code = ERROR_REMOVE_DIRECTORY;
			return false;
		} else {
			debug(2, "Directory deleted with success");
		}


		// No error
		return true;
	 }

	 /**
	  * Return directory element only
	  *
	  * @return array as it :
	  *
	  * <pre>
	  * array[...] = array(
	  * 	"name" => ...,
	  *	"ctime" => ...,
	  *	"size" => ...,
	  * )
	  * </pre>
	  */
	 function get_directory_only()
	 {
		$buffer = array();
		foreach($this->array_files as $directory) {
			if ( $directory["is_directory"] ) {
				array_push($buffer,
					array(
						"name"=>$directory["name"],
						"ctime"=>$directory["ctime"],
						"size"=>$directory["size"]
					)
				);
			}
		}

		return $buffer;
	 }
	 
	 /**
	  * Return files elements only
	  *
	  * @return array as it :
	  *
	  * <pre>
	  * array[...] = array(
	  * 	"name" => ...,
	  *	"ctime" => ...,
	  *	"size" => ...,
	  *	"mimetype" => ...,
	  *	"extension" => ...
	  * )
	  * </pre>
	  */
	 function get_file_only()
	 {
		$buffer = array();
		foreach($this->array_files as $directory) {
			if ( !$directory["is_directory"] ) {
				array_push($buffer,
					array(
						"name" => $directory["name"],
						"ctime" => $directory["ctime"],
						"size" => $directory["size"],
						"mimetype" => $directory["mimetype"],
						"extension" => $extension
					)
				);
			}
		}

		return $buffer;
	 }

	 /**
	  * Display the directory in ASCII mode (to terminal)
	  *
	  * This function is useful to debuging
	  */
	 function show_in_ascii()
	 {
	 	printf("File list of %s directory :\n", $this->current_directory);
	 	foreach ($this->array_files as $file) {
			if ($file["is_directory"]) {
				$type = "[DIR]";
			} else {
				$type = "[FILE]";
			}
		
			printf(
				"%s\t%s\t\t\t%s\t%s\t%s\n",
				$type,
				$file["name"],
				$file["ctime"],
				$file["size"],
				$file["mimetype"]
			);
		}
	 }
}

/**
 * This class provides functions to work with distant directories.
 */
class LSC_Distant_Directory extends LSC_Directory
{
	var $distant_directory;		/**< Real distant directory */
	var $session;			/**< LSC_Session class instance */

	/**
	 * It's the constructor of LSC_DistantDirectory
	 *
	 * @param $directory_path is the distant directory path value
	 *
	 * @see LSC_Directory
	 */
	function LSC_Distant_Directory($session, $directory_path)
	{
		/*
		 * Display debug information
		 */
		/*
		debug(1, sprintf("%s - session = %s",
			__FUNCTION__,
			var_export($session, true)
		));*/
		
		/*
		debug(1, sprintf("%s - directory_path = %s",
			__FUNCTION__,
			var_export($directory_path, true)
		));*/

		/*
		 *
		 */
		$this->session = $session;
		$this->distant_directory = $directory_path;
		
		$this->LSC_Directory(clean_path(
			sprintf(
				"%s/%s/%s",
				$session->sshfs_mount,
				$session->root_path,
				$directory_path
			)
		));
	}
}



?>
