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

/**
 * @file file.inc.php
 * All class and functions that work with files and directory.
 */

require_once(dirname(__FILE__) . "/errors.inc.php");
require_once(dirname(__FILE__) . "/debug.inc.php");
require_once(dirname(__FILE__) . "/clean_path.inc.php");
require_once(dirname(__FILE__) . "/config.inc.php"); // use CYGWIN_WINDOWS_ROOT_PATH constant
require_once(dirname(__FILE__) . "/exec.inc.php");

/**
 * Class to handle a local file
 */
class LSC_File
{
	var $current_directory = ""; 	/**< the dir where is the file */
	var $size = 0;			/**< file size in octet */
	var $name = "";			/**< file name */
	var $file_exist = false;	/**< Is the file exist ?? */
	var $extension = "";		/**< file extension */
	var $mimetype = "";		/**< file mime types */
	var $ctime = "";		/**< file date */
	var $error_code = 0;		/**< Last error code (0 = no error) */

	var $content;			/**< Content data of file */

	/**
	 * LSC_File class constructor
	 *
	 * @param $filename
	 *
	 * @warning This class use this global variable : mime_types_data.\n
	 * Use LSC_load_mime_type to get this variable.
	 *
	 * @see LSC_load_mime_type
	 */
	function LSC_File($filename)
	{
		debug(2, sprintf("%s - fichier : %s ", __FUNCTION__, $filename));
		
		global $mime_types_data; /**< This is a array whose content all mime types */

		/*
		 * Test if filename is empty
		 */
		if (empty($filename)) {
			debug(3, sprintf("%s - ERROR_INVALIDE_FILENAME : %s", __FUNCTION__, $filename));
			$this->error_code = ERROR_INVALIDE_FILENAME;
			return; // No return value because I'm in constructor
		}

		/*
		 * Test if file exist
		 */
		if ( file_exists($filename) ) {
			debug(3, sprintf("%s - File exist : %s", __FUNCTION__, $filename));
			$this->file_exist = true;
		} else {
			debug(3, sprintf("%s - File don't exist : %s", __FUNCTION__, $filename));
			$this->file_exist = false;
		}
		
		/*
		 * Test if file isn't a directory
		 */
		if ( 
			$this->file_exist &&
			!is_file($filename)
		) {
			debug(3, sprintf("%s - It isn't a file : %s", __FUNCTION__, $filename));
			$this->error_code = ERROR_IS_NOT_FILE;
			return; // No return value because I'm in constructor
		}

		/*
		 * Set file property (directory, filename ...)
		 */
		$this->current_directory = dirname($filename);
		$this->name = basename($filename);
		$filepatharray = explode(".", $this->name);
		$this->extension = $filepatharray[count($filepatharray)-1];

		// Set mime types property
		if (!empty($mimetypes[$this->extension]))
			$this->mimetype = $mime_types_data[$this->extension];
		else {
			$this->mimetype = DEFAULT_MIME;
		}

		if ($this->file_exist) {
			$this->size = filesize($this->current_directory."/".$this->name);
			$this->ctime = filectime($this->current_directory."/".$this->name);
		}

		/*
		debug(3, sprintf(
			"%s - class dump : %s", 
			__FUNCTION__,
			var_export(
				$this,
				true
			)
		));*/
	}

	/**
	 * This function read content of file
	 *
	 * The content is put in $this->content member 
	 *
	 * @return false if error
	 */
	function get_content()
	{
		/*
		 * Test if file exist
		 */
		if (!$this->file_exist) {
			$this->error_code = ERROR_NOT_EXIST_FILE;
			return (FALSE);
		}

		/*
		 * Test if file is readable
		 */
		if (!is_readable($this->current_directory."/".$this->name)) {
			$this->error_code = ERROR_PERMISSION;
			return (FALSE);
		}

		/*
		 * Open the file
		 */
		if (($fd = @fopen($this->current_directory."/".$this->name, 'r')) === FALSE) {
			$this->error_code = ERROR_UNKNOWN;
			return (FALSE);
		}

		/*
		 * Read the content
		 */
		debug(3, sprintf("%s - file size = %s", __FUNCTION__, $this->size));
		if ( $this->size > 0 ) {
			$this->content = fread($fd, filesize($this->current_directory."/".$this->name));
		} else {
			$this->content = "";
		}
		fclose($fd);

		// No error
		return (TRUE);
	}
	
	/**
	 * Old method name
	 *
	 * @see get_content
	 */
	function LSC_getContent()
	{
		return $this->get_content();
	}
	
	/**
	 * Write $content data in file
	 *
	 * @param $content data to write in file
	 *
	 * @return false if some error
	 */
	function write_content($content)
	{
		debug(3, sprintf("%s - file = %s", __FUNCTION__, $this->name));
		if ( !$this->file_exist ) {
			$this->create();
		}
		/*
		 * Test if file is writeable
		 */
		if (!is_writable($this->current_directory."/".$this->name)) {
			$this->error_code = ERROR_PERMISSION;
			return (FALSE);
		}

		/*
		 * Open the file in write mode
		 */
		if (($fd = @fopen($this->current_directory."/".$this->name, 'w')) === FALSE) {
			$this->error_code = ERROR_UNKNOWN;
			return (FALSE);
		}

		/*
		 * Write the content
		 */
		$this->content = $content;
		$this->size = strlen($content);
		debug(3, sprintf("%s - write %s in %s", __FUNCTION__, $this->content, $this->name));
		fwrite($fd, $this->content, $this->size);
		fclose($fd);

		// No error
		return (TRUE);
	}
	/**
	 * Old method name
	 *
	 * @see write_content method
	 */
	function LSC_writeContent($content)
	{
		return $this->write_content($content);
	}
	
	/**
	 * Download file to browser
	 *
	 * @return FALSE if some error else exit the script (use exit() function)
	 */
	function download()
	{
		/*
		 * Test if file is readable
		 */
		 if (!is_readable($this->current_directory."/".$this->name)) {
				$this->error_code = ERROR_PERMISSION;
				return (FALSE);
		 }

		/*
		 * Write browser page content
		 */
		 header("Content-type: ".$this->mimetype);
		 header("Content-Length: ".$this->size);
		 header( "Content-Disposition: filename=".$this->name);
		 readfile($this->current_directory."/".$this->name);
		 exit();
	}	
	
	/**
	 * Old method name
	 *
	 * @see download method
	 */
	function LSC_download()
	{
		return $this->download();
	}

	/**
	 * Download distant file to local host (server LRS)
	 *
	 * @param $session LSC_Session class connected to distant host
	 * @param $path_source full filename (path and filename) on distant host to download
	 *
	 * @return false if some errors
	 */
	function download_to_local_host($session, $path_source)
	{
		/*
		 * Test if file exist
		 */
		if (!$this->file_exist) {
			$this->error_code = ERROR_NOT_EXIST_FILE;
			return (FALSE);
		}

		/*
		 * Make copy command (use scp) 
		 */
		/* Old code
		$scp_command = sprintf("scp %s:%s %s/%",
			$session->ip,
			$path_source,
			$this->current_directory,
			$this->this->name
		);
		*/

		/*
		 * Execute the command
		 */
		// exec($scp_command, $output, $return_var); Oldcode
		unset($output);unset($return_var); unset($stdout); unset($stderr);unset($scp_command);
		lsc_scp(
			$session->user,
			$session->ip,
			$path_source,
			$$this->current_directory.$this->this->name,
			$output,
			$return_var,
			$stdout,
			$stderr,
			$scp_command
		);
		
		/*
		 * Test if error
		 */
		if ( $return_var != 0 ) {
			$this->error_code = ERROR_GET_ON_LOCAL_HOST;

			return false;
		}

		return true;
	}
	
	/**
	 * Old method name
	 *
	 * @see get_on_local_host
	 */
	function LSC_getOnLocal($session, $path_source)
	{
		return $this->download_on_local_host($session, $path_source);
	}
 
	/**
	 * Create a file 
	 *
	 * @return false if some error
	 *
	 * "touch" command is used to create the file.
	 */
	function create()
	{
		debug(3, 
			sprintf(
				"LSC_File - %s - filename : %s/%s", __FUNCTION__, 
				$this->current_directory,
				$this->name
			)
		);
		
		/*
		 * Test if file exist
		 */
		if ($this->file_exist) {
			$this->error_code = ERROR_CREATE_FILE;
			return false;
		}

		/*
		 * Make command
		 */
		$cmd = "touch ".escapeshellarg("/".$this->current_directory."/".$this->name).";";
		$cmd.= "chmod ugo+rwx ".escapeshellarg("/".$this->current_directory."/".$this->name)."";
		
		/*
		 * Execute command
		 */
		// exec($touch_command, $output, $return_var); Old code
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_exec(
			$cmd,
			$output,
			$return_var,
			$stdout, 
			$stderr
		);
		
		/*
		 * Test error
		 */
		if ($return_var != 0) {
			$this->error_code = ERROR_UNKNOWN;
			return false;
		} 

		// No error
		return true;
	} 
 
	/**
	 * Old method name
	 *
	 * @see create
	 */
	function LSC_create($session)
	{
		return $this->create($session);
	}
 
	/**
	 *
	 * @param $session
	 *
	 * @return false if error
	 */
	function remove()
	{
		debug(2, sprintf("LSC_File - %s : %s ", __FUNCTION__, $this->name));
		/*
		 * Test if file exist
		 */
		if (!$this->file_exist) {
			debug(2, sprintf("LSC_File - %s - error, I can't remove file  : %s ", __FUNCTION__, $this->name));
			$this->error_code = ERROR_CAN_NOT_REMOVE_FILE;
			return false;
		}

		/*
		 * Make command
		 */
		$remove_command = sprintf(
			"rm \"%s/%s\"",
			$this->current_directory,
			$this->name
		);
		debug(2, sprintf("LSC_File - %s - remove_command = %s ", __FUNCTION__, $remove_command));
		
		/*
		 * Execute command
		 */
		 
		// exec($remove_command, $output, $return_val); Oldcode
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_exec(
			$remove_command,
			$output,
			$return_var,
			$stdout, 
			$stderr
		);
		 
		if ( $return_val != 0 ) {
			debug(2, sprintf("LSC_File - %s - ERROR REMOVE FILE : %s ", __FUNCTION__, $this->name));
			$this->error_code = ERRUR_REMOVE_FILE;
			return false;
		}
		 
		// Set file_exist to false
		$this->file_exist = false;
		 
		// No error
		return (TRUE);
	} 

	/** 
	 * Old method name
	 *
	 * @see LSC_remove
	 */
	function LSC_rm($session)
	{
		return $this->remove($session);
	}

	/**
	 * Rename the filename
	 *
	 * @param $new_name is the new file name value
	 *
	 * @return false if some error
	 */
	function rename($new_name)
	{
		/*
		 * Test if name exist
		 */
		if (!$this->file_exist) {
			$this->error_code = ERROR_DELETE_FILE;
			return false;
		}
	
		/*
		 * Make command
		 */
		$move_command = sprintf(
			"mv \"%s/%s\" \"%s/%s\"",
			$this->current_directory,
			$this->name,
			$this->current_directory,
			$new_name
		);

		/*
		 * Execute command
		 */
		// exec($move_command, $output, $return_val); Old code
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_exec(
			$move_command,
			$output,
			$return_var,
			$stdout, 
			$stderr
		);

		if ($return_val != 0) {
			$this->error_code = ERROR_RENAME_FILE;
			return false;
		} 

		/*
		 * Update name with new name
		 */
		$this->name = $new_name;

		// No error
		return (TRUE);
	}
	
	/**
	 * Old method name
	 *
	 * @see rename method
	 */
	function LSC_rename($session, $to)
	{
		return $this->rename($to);
	}

	/**
	 * Execute the file 
	 *
	 * @return array like this :
	 *
	 * <pre>
	 *	array(
	 *		"stdout" => ...,
	 *		"stderr" => ...,
	 *		"exit_code" => ...
	 *	)
	 * </pre>
	 *
	 * @warning : this work only on local host
	 */
	function execute()
	{
		/*
		 * Test if name exist
		 */
		if (!$this->file_exist) {
			$this->error_code = ERROR_NOT_EXIST_FILE;
			return false;
		}
	
		/*
		 * Make command
		 */
		$execute_file = sprintf(
			"%s/%s",
			$this->current_directory,
			$this->name
		);

		/*
		 * Execute the file
		 */
		// exec($execute_file, $output, $return_val); Old code
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_exec(
			$execute_file,
			$output,
			$return_var,
			$stdout, 
			$stderr
		);


		if ($return_val != 0) {
			$this->error_code = ERROR_I_CAN_NOT_EXECUTE_FILE;
			return array(
				"stdout" => "",
				"stderr" => $output,
				"exit_code" => $return_val
			);
		} else {
			return array(
				"stdout" => "",
				"stderr" => $output,
				"exit_code" => $return_val
			);
		}
	}

	/**
	 * Upload to file (Work only on local file)
	 *
	 * @param $file_to_upload
	 *
	 * This is easy, it's cp from $file_to_upload to file of class
	 */
	 function upload($file_to_upload) 
	 {
		debug(2, sprintf("LSC_File - %s - file to upload is : %s", __FUNCTION__, $file_to_upload));
		/*
		 * Test if file to upload exist
		 */
		if (!file_exists($file_to_upload)) {
			$this->error_code = ERROR_FILE_TO_UPLOAD_NOT_EXIST;
			return false;
		}

		/*
		 * Make command
		 */
		$upload_command = "cp ".escapeshellarg($file_to_upload)." ".escapeshellarg(clean_path("/".$this->current_directory."/".$this->name)).";";
		$upload_command.= "chmod ugo+rwx ".escapeshellarg(clean_path("/".$this->current_directory."/".$this->name));
		/*
		 * Upload the file
		 */
		debug(4, sprintf("LSC_File - %s - command to execute : %s", __FUNCTION__, $upload_command));
		// exec($upload_command, $output, $return_val); Old code
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_exec(
			$upload_command,
			$output,
			$return_var,
			$stdout, 
			$stderr
		);

		if ($return_val != 0) {
			debug(2, sprintf("LSC_File - %s - ERROR : I can not upload : %s", __FUNCTION__, $file_to_upload));
			$this->error_code = ERROR_I_CAN_NOT_UPLOAD_FILE;
			return array(
				"stdout" => "",
				"stderr" => $output,
				"exit_code" => $return_val
			);
		} else {
			debug(2, sprintf("LSC_File - %s - file upload with success", __FUNCTION__));
			return array(
				"stdout" => "",
				"stderr" => $output,
				"exit_code" => $return_val
			);
		}
	}
}


/**
 * Class to handle distant file
 *
 * @see LSC_File
 */
class LSC_Distant_File extends LSC_File
{
	var $distant_directory;		/**< Real distant directory (directory only, not filename)*/
	var $session;			/**< LSC_Session class instance where is the file */
	
        /**
         * It's the constructor of LSC_Distant_File.
         *
	 * @param $session (LSC_Session class instance) is connection to host where is the file
	 * @param $filename The filename about to work.
	 *
	 * @warning This class use this global variable : mime_types_data.\n
	 * Use LSC_load_mime_type to get this variable.
	 *
	 * @see LSC_load_mime_type
	 * @see LSC_File
         */	
	function LSC_Distant_File($session, $filename)
	{
		debug(3, sprintf("%s - filename = %s", __FUNCTION__, $filename));
		$this->session = $session;
		$this->distant_directory = dirname($filename);
		$this->LSC_File(
			clean_path(
				sprintf(
					"%s/%s/%s",
					$session->sshfs_mount,
					$session->root_path,
					$filename
				)
			)
		);
	}

	/**
	 * Execute the file 
	 *
	 * @return array like this :
	 *
	 * <pre>
	 *	array(
	 *		"stdout" => ...,
	 *		"stderr" => ...,
	 *		"exit_code" => ...
	 *	)
	 * </pre>
	 *
	 * @warning : this work only on distant file
	 */
	function execute()
	{
		/*
		 * Test if name exist
		 */
		if (!$this->file_exist) {
			$this->error_code = ERROR_NOT_EXIST_FILE;
			return false;
		}
	
		/*
		 * Make command
		 */
		/* Old code
		$execute_file_over_ssh = sprintf(
			"ssh %s@%s %s/%s/%s",
			$this->session->user,
			$this->session->ip,
			CYGWIN_WINDOWS_ROOT_PATH,
			$this->distant_directory,
			$this->name
		);
		*/
		
		$execute_file_over_ssh = sprintf(
			"%s/%s/%s",
			$this->session->root_path,
			$this->distant_directory,
			$this->name
		);
		
		debug(2, sprintf("LSC_File - %s - execute_file_over_ssh = %s ", __FUNCTION__, $execute_file_over_ssh));
		
		
		/*
		 * Execute the file
		 */
		// exec($execute_file_over_ssh, $output, $return_val); Old code
		unset($output); unset($return_var); unset($stdout); unset($stderr);
		lsc_ssh(
			$this->session->user,
			$this->session->ip, 
			$execute_file_over_ssh, 
			$output, 
			$return_var, 
			$stdout, 
			$stderr
		);
		if ($return_val != 0) {
			$this->error_code = ERROR_I_CAN_NOT_EXECUTE_FILE;
			return array(
				"stdout" => "",
				"stderr" => implode("<br />", $output),
				"exit_code" => $return_val
			);
		} else {
			return array(
				"stdout" => implode("<br />", $output),
				"stderr" => "",
				"exit_code" => $return_val
			);
		}
	}

	# beacuse fucking acl depends other acl...
	# Full controle = Write, Execute, ....
	# perhaps more dependencies later...
	function LSC_setAclDepSimple($key, &$tab)
	{
		if ($key == "F") {
			$tab["W"] = 1;
			$tab["D"] = 1;
			$tab["X"] = 1;
			$tab["R"] = 1;
		}
	}

	/**
	 * Set all ACLs
	 * $ar_mods is a tab with mods tu set :
	 * array (
	 *		"user" => array (
	 *			 "mod",
	 *				"..."),
	 *		"..."
	 *		 )
	 *'mod'is the lettre use by fileacl + _ + deny/accept
	 * ex : F_accept, We_deny
	 */
	function set_acls($ar_mods)
	{
		if ($this->session->platform != "Windows") {
			return (FALSE);
		}

		$cmd = "cd ".escapeshellarg(clean_path(CYGWIN_WINDOWS_ROOT_PATH."/".$this->distant_directory."/")).";";
		foreach($ar_mods as $user => $mods)
		{
			$cmd .= "fileacl.exe ".escapeshellarg($this->name)." /S ".escapeshellarg($user).":U".";";
			$cmda = "fileacl.exe ".escapeshellarg($this->name)." /S ".escapeshellarg($user).":";
			$cmdb = "fileacl.exe ".escapeshellarg($this->name)." /D ".escapeshellarg($user).":";
			$l = strlen($cmdb);
			print("mods :");
			print_r($mods);
			print("\n");
			foreach($mods as $mod)
			{
				print("mod :".$mod."\n");
				//print("active :".$active."\n");
				$c = substr($mod, 0, strpos($mod, "_"));
				$d = substr($mod, strpos($mod, "_") + 1);
				if ($d == "accept")
					$cmda .= "$c";
				if ($d == "deny")
					$cmdb .= "$c";
			}
			$cmd.=$cmda.";".$cmdb.";";
		}
		print($cmd);
		unset($output);unset($return_var);unset($stdout);unset($stderr);
		lsc_ssh(
			$this->session->user, 
			$this->session->ip,
			$cmd,
			$output, 
			$return_var, 
			$stdout, 
			$stderr
		);
		print("\n\n");
		print($cmd);
		print("\n\n");
		if ($return_var!=0) return -1;
		
		return 0;
	}

	/**
	 * This function return acls values the file
	 * 
	 * @param
	 * $opt is /SIMPLE or /ADVANCED (see fileacl)
	 */
	function get_acls()
	{
		$all_rights = array("Rr", "Ra", "Re", "Wa", "We", "Ww", "D", "Dc", "X", "A", "O", "U", "R", "W", "P", "p", "F");
		if ($this->session->platform != "Windows") {
			return(-1);
		}
		$cmd = "cd ".escapeshellarg(clean_path(CYGWIN_WINDOWS_ROOT_PATH."/".$this->distant_directory."/")).";";
		$cmd .= "fileacl.exe ".escapeshellarg($this->name)." /SIMPLE";
		
		/* Old code
		$cmd = ("fileacl.exe ".escapeshellarg($this->distant_name)." $opt"); Old code
		$session->LSC_cmdAdd($cmd);
		$res = $session->LSC_cmdFlush();
		if ( !empty( $res[$cmd]['STDERR'] ) ) {
			$this->errocde = ERR_CUSTOM;
			$msg = implode("<br />", $res[$cmd]['STDERR']);
			return (FALSE);
		}
		*/
		unset($output);unset($return_var);unset($stdout);unset($stderr);
		lsc_ssh(
			$this->session->user, 
			$this->session->ip,
			$cmd,
			$output, 
			$return_var, 
			$stdout, 
			$stderr
		);
		//if ($return_var!=0) return -1;
		
		for ($i = 0, $j = count($output), $stat = "ACCEPT"; $i < $j; $i++, $stat = "ACCEPT") {
			$path = substr(
				$output[$i], 
				0,
				strpos($output[$i], ";")
			);

			list($usera, $mods, $inherit) = explode(
				":", 
				substr_replace($output[$i], "", 0, strlen($path)+1)
			);
			
			if (strstr($usera, "DENY!")) {
				$usera = substr($usera, strlen("DENY!"));
				$stat = "DENY";
			}
			$user = substr(strstr($usera, "\\"), 1);
			if ($user == FALSE)
				$user = $usera;

			if (!is_array($tab[$user]["ACCEPT"]))
				$tab[$user]["ACCEPT"] = array();

			if (!is_array($tab[$user]["DENY"]))
				$tab[$user]["DENY"] = array();

			for ($l = strlen($mods), $k = 0; $k < $l; $k++) {
				$cur = substr($mods, $k, 2);
				if (in_array($cur, $all_rights)) {
					$tab[$user][$stat][$cur] = 1;
					$this->LSC_setAclDepSimple($cur,&$tab[$user][$stat]);
					$k++;
					continue ;
				}
				$cur = $mods{$k};
				if (in_array($cur, $all_rights)) {
					$tab[$user][$stat][$cur] = 1;
					$this->LSC_setAclDepSimple($cur, &$tab[$user][$stat]);
				} 
			}
		}
		return ($tab);
	}


	/**
	 * get attrib of the file (A, H, S, R)
	 */
	function get_attribs()
	{
		if ($this->session->platform != "Windows")
			return (FALSE);
		$cmd ="cd ".escapeshellarg(clean_path(CYGWIN_WINDOWS_ROOT_PATH."/".$this->distant_directory."/")).";";
		$cmd .= "attrib.exe ".escapeshellarg($this->name);
		
		
		unset($output);unset($return_var);unset($stdout);unset($stderr);
		lsc_ssh(
			$this->session->user, 
			$this->session->ip,
			$cmd,
			$output, 
			$return_var, 
			$stdout, 
			$stderr
		);
		// $this->session->LSC_cmdAdd($cmd); Old code
		
		// $res = $this->session->LSC_cmdFlush(); Old code
		
		/* Old code
		
		if (!empty($res[$cmd]['STDERR'])) {
			$this->errocd = ERR_CUSTOM;
			$msg = implode("<br />", $res[$cmd]['STDERR']);
			return (FALSE);
		}*/
		print("cmd : ".$cmd."<br />");
		print("output : ");
		print_r($output);
		print("<br />");
		if ($return_var!=0) {
			return -1;
		}
		
		$attribs = (substr($output, 0, 8));
		if (strpos($attribs, "A") !== FALSE)
			$ret["A"] = 1;

		if (strpos($attribs, "R") !== FALSE)
			$ret["R"] = 1;

		if (strpos($attribs, "S") !== FALSE)
			$ret["S"] = 1;

		if (strpos($attribs, "H") !== FALSE)
			$ret["H"] = 1;

		return ($ret);
	}
	
	/**
	 * set attriv of the file
	 * $ar_attribs is :
	 */
	function set_attribs($array_attributes)
	{
		/*
		 * Make command
		 */
		$attrib_command = "cd ".escapeshellarg(clean_path(CYGWIN_WINDOWS_ROOT_PATH."/".$this->distant_directory."/")).";";
		$attrib_command .= "attrib.exe ";
		
		foreach($array_attributes as $attribute => $switch) {
			$attrib_command .= "${switch}${attribute} ";
		}
		$attrib_command .= escapeshellarg($this->name);
		/*
		 * Execute command
		 */
		unset($output);unset($return_var);unset($stdout);unset($stderr);
		lsc_ssh(
			$this->session->user, 
			$this->session->ip,
			$attrib_command,
			$output, 
			$return_var, 
			$stdout, 
			$stderr
		);
		/*
		 * Test error
		 */
		if ( $return_var != 0 ) {
			$this->error_code = ERROR_I_CAN_CHANGE_ATTRIBUTE_OF_FILE;
			return -1;
		}

		// No error
		return 0;
	}

	/**
	 * Upload to file (Work on distant file)
	 *
	 * @param $file_to_upload
	 *
	 * This is scp to upload
	 */
	 function upload($file_to_upload) 
	 {
		debug(2, sprintf("LSC_File - %s - file to upload is : %s", __FUNCTION__, $file_to_upload));
		/*
		 * Test if file to upload exist
		 */
		if (!file_exists($file_to_upload)) {
			$this->error_code = ERROR_FILE_TO_UPLOAD_NOT_EXIST;
			return false;
		}

		/*
		 * Make command
		 */

		/*
		 * Upload the file
		 */
		//debug(4, sprintf("LSC_File - %s - command to execute : %s", __FUNCTION__, $scp_upload_command));
		// exec($scp_upload_command, $output, $return_val); Old code
		unset($output);unset($return_var);unset($stdout);unset($stderr);unset($stderr);unset($scp_upload_command);
		lsc_scp(
			$this->session->user, 
			$this->session->ip,
			$file_to_upload, 
			clean_path(sprintf("/%s/%s/%s",
				$this->session->root_path,
				$this->distant_directory,
				$this->name
			)), 
			$output, 
			$return_var, 
			$stdout, 
			$stderr, 
			$scp_upload_command
		);

		if ($return_val != 0) {
			debug(2, sprintf("LSC_File - %s - ERROR : I can not upload : %s", __FUNCTION__, $file_to_upload));
			$this->error_code = ERROR_I_CAN_NOT_UPLOAD_FILE;
			return array(
				"stdout" => "",
				"stderr" => $output,
				"exit_code" => $return_var
			);
		} else {
			debug(2, sprintf("LSC_File - %s - file upload with success", __FUNCTION__));

			/*
			 * Now, I update the lufs cache (it's bad hack but useful)
			 */
			$touch_command = sprintf(
				"touch \"%s/%s\"",
				$this->current_directory,
				$this->name
			);
			
			debug(4, sprintf("LSC_File - %s - command to execute : %s (used to update LUFS cache)", __FUNCTION__, $touch_command));
			// exec($touch_command, $output2, $return_val2); Oldcode
			unset($output2); unset($return_var2); unset($stdout2); unset($stderr2);
			lsc_exec(
				$touch_command, 
				$output2, 
				$return_var2,
				$stdout2,
				$stderr2
			);
			
			return array(
				"stdout" => "",
				"stderr" => $output,
				"exit_code" => $return_var
			);
		}
	}
}




/**
 * to send file via the POST method
 */
function LSC_fileSend($session, $path)
{
	if ($session->platform == "Windows") {
		$path = LSC_cygpath($path, "WinToCyg", "", 1);
	}

	$path = str_replace(" ", "\\ ", $path);
	$cmd = sprintf(
		"scp %s %s@%s:\"%s/%s\"", 
		$_FILES['send_filename']['tmp_name'],
		$session->user, 
		$session->ip, 
		$path, 
		basename($_FILES['send_filename']['name'])
	);

	$session->LSC_cmdAdd($cmd);
	$res = $session->LSC_cmdFlush("local");
	if (!empty($res[$cmd]['STDERR'])) {
		$this->errcode = ERR_UNKNOWN;
		return (FALSE);
	}
	return (TRUE);
}

/**
 * return the good separator (/ or \)
 */
function LSC_getSeparator($platform)
{
	if ($platform == "Windows") {
		return (WINDOWS_SEPARATOR);
	}

	return (LINUX_SEPARATOR);
}

/**
 *
 */
function LSC_setLocalSeparator($path)
{
	if (substr($path, -1) != LINUX_SEPARATOR) {
			$path .= LINUX_SEPARATOR;
	}

	return ($path);
}

/**
 * Convert path name (windows path <-> cygwin path <-> linux path)
 *
 * @param $name
 * @param $cmd this command select convertion type\n
 * Value can is :
 * <ul>
 *	<li>WinToCyg</li>
 *	<li>WinToLin</li>
 *	<li>WinToLinArray</li>
 *	<li>LinToWin</li>
 * </ul>
 * @param $mount_point
 * @param $strip
 *
 *
 */
function LSC_cygpath($name, $cmd, $mount_point = "", $strip = 0)
{
	if ($cmd == "WinToCyg") { 
		if ($strip == 1) {
			$name = stripslashes($name);
		}
		$name = str_replace(WINDOWS_SEPARATOR, LINUX_SEPARATOR, $name);
		$name = $mount_point."/cygdrive/".strtolower($name{0}).substr($name, 2);
		return ($name);
	}

	if ($cmd == "WinToLin") {
		if (is_array($name)) {
			$name[1] = strtolower(substr($path[1], 0, -1));
		} else {
			if ($strip == 1) {
				$name = stripslashes($name);
			}
			$name{0} = strtolower($name{0});
			$name = str_replace(":", "", $name);
			$name = str_replace(WINDOWS_SEPARATOR, LINUX_SEPARATOR, $name);
			$name = $mount_point.LINUX_SEPARATOR.$name;
	 	}
		return ($name);
	}
	if ($cmd == "WinToLinArray") {
		$ar = explode(WINDOWS_SEPARATOR, $name);
		$ar[0] = str_replace(":", "", strtolower($ar[0]));
		array_unshift($ar, "");
		return ($ar);
	} 
	if ($cmd == "LinToWin") {
		if ($mount_point) {
			$name = str_replace($mount_point.LINUX_SEPARATOR, "", $name);
		}
		$name = str_replace(LINUX_SEPARATOR, WINDOWS_SEPARATOR, $name);
		if ($name{0} == WINDOWS_SEPARATOR) {
			$name = substr($name, 1);
		}
		$name = strtoupper($name{0}).":".substr($name, 1);
		return ($name);
	}
}

/**
 * Return parent directory ( Private function )
 *
 * @param $directory_path
 * @return parent (String)
 *
 * <strong>Example</strong>
 *
 * get_parent_directory("foo/bar/a/b") => "foo/bar/a/"
 */
function get_parent_directory($directory_path)
{
	$position = strrpos($directory_path, "/");
	if ($position === false) {
		return "";
	} else {
		return substr($directory_path, 0, $position);
	}
}

?>
