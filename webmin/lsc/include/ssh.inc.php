<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
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

require_once(dirname(__FILE__) . "/profiler.inc.php");

require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/config.inc.php");
require_once(dirname(__FILE__) . "/common.inc.php");
require_once(dirname(__FILE__) . "/system.inc.php");
require_once(dirname(__FILE__) . "/debug.inc.php");
require_once(dirname(__FILE__) . "/path.inc.php");
require_once(dirname(__FILE__) . "/exec.inc.php");

/**
 * @file ssh.inc.php
 *
 * This file content class to open ssh connection and execute one or many commands on it.
 *
 * The class test script is here : lsc/include/utest/test_ssh_session_class.php
 */

include_once("../lbs_common/php/sshtest.php");

/**
 * LSC_Session class
 *
 * This class allow to open ssh connection and execute one or many commands on it.
 */
class LSC_Session {
	/*
	 * name Pulic members 
	 */

	/* { */

	var $mac = "";			/**< Distant host mac adress */
	var $ip = "";			/**< Distant host ip adress */
	var $group = "";		/**< Distant host group name */
	var $hostname = "";		/**< Distant host hostname */
	var $platform = "";		/**< Distant host platform (Linux, Windows...) */
	var $profile = "";		/**< Distant host profile name */
	var $user = "";			/**< Username whose have open session */
	var $errors = 0;		/**< Number errors */
	var $error_ssh_failed=false;
	var $error_autofs_failed=false;
	var $msgerror = "";		/**< Message errors */
	var $sshfs_mount = "";		/**< SSHFS mount path */
	var $opts = "-o Batchmode=yes -o StrictHostKeyChecking=no";	/**< SSH opts */
	var $key = "/root/.ssh/id_dsa";
	var $root_path;			/**< root path for windows clients */
	var $tmp_path;			/**< safe default for the dest directory */

	/* } */

	/* 
	 * name Private member 
	 */
	
	/* { */

	var $cmd = array();		/** This array is buffer whose content some command to execute at same time */
	var $ether = array();		/** Array buffer of ether file */

	/* } */
	
	var $ping_error = false;	/**< Ping error ? (boolean) */

	/**
	 * name Public methods
	 */

	/* { */

	/**
	 * LSC Session class constructor
	 *
	 * Initialize Session using mac adress.\n
	 * Needed every time.
	 * This constructor set hostname, ip, platform and distant user values.
	 *
	 * @param $mac : distant host mac adress
	 * @param $user="" (optional) : user name who open the session\n
	 * If $user is set to "" then it's initialisez to $_ENV['REMOVE_USER'] value
	 * @param $ping_enable to enable test ping
	 * @param if $os_type == "" then look for os type else this variable set os_type
	 * @param if $home == "" then look for home path else this variable set home
	 *
	 * FIXME : get ip by Netbios (nmblookup)
	 * FIXME : get ip by OCS ?
	 */
	function LSC_Session($mac, $user="", $ping_enable  = true, $os_type = "", $home = "")
	{
		global $config;

		if ($user == "") {
			$user=$_ENV['REMOTE_USER'];
		}
		
		debug(1, "Distant host informations :");

		/* safe defaults */
		$this->root_path = CYGWIN_WINDOWS_ROOT_PATH;
		$this->tmp_path = $config['path_destination'];;
		debug(1, sprintf("Default path : '%s'", $this->tmp_path));
		
		/* Initialize mac address */
		$this->mac = $mac;
		debug(1, sprintf("Mac address : '%s'", $mac));

		/* Load ether file */
		$this->ether = etherLoadByMac();

		/* Initialise hostname, profile and group name */
		$this->initialise_hostname_profile_and_group();
		debug(1, sprintf("Hostname : %s", $this->hostname));
		debug(1, sprintf("Group name : %s", $this->group));
		debug(1, sprintf("Profil name : %s", $this->profile));

		/* Initialise IP address */
		$this->initialise_ip();

		/* Test if host is reachable (socket test) */
		if ($ping_enable) {
			$ping = LSC_sysPing($this->ip);
			if ($ping!=0) {
				$this->errors++;
				$this->msgerror = "Sorry, cannot contact computer (mac address = '$mac', ip address = '".$this->ip."')";
				$this->ping_error = true;
				return ;
			} else {
				$this->ping_error = false;
			}
		} else {
			$this->ping_error = false;
		}
		
		debug(1, sprintf("Can I contact client ? %s (socket test)", $ping ? "no." : "yes."));
		
		/* Initialise platform type name */
		$this->initialize_os_type($os_type);
		debug(1, sprintf("OS : %s", $this->platform));
		
		/* Set connection username */
		$this->user = $this->LSC_getGoodUser($user);

		debug(1, sprintf("User name : %s", $this->user)); 

		/* Test ssh connection */
		if ($ping_enable) {
			$ssh = new sshtest($this->user, $this->ip, $this->key);
			$ret = $ssh->test();
			if ($ret!=0) {
				$this->errors++;
				$this->error_ssh_failed=true;
				$this->msgerror = "ssh connection failed (ret=$ret)";
				$this->ssh_return_var = $ssh->ret;
				$this->ssh_array_output = $ssh->output;
				$this->ssh_test_command = $ssh->cmd;
				$this->ssh_stdout = join($ssh->output, "\n");
				$this->ssh_stderr = $this->ssh_stdout;
				return;
			} else {
				$this->error_ssh_failed=false;
			}
		}
		
		/*
		 * Test autofs connection
		 */
		 if ($ping_enable && $config['explorer'] != 0) {
			 $ls_command = "ls ".MOUNT_EXPLORER."/".$this->user."@".$this->ip."/";
			 
			 lsc_exec(
				$ls_command, 
				$this->ssh_array_output, 
				$this->ssh_return_var, 
				$this->ssh_stdout, 
				$this->ssh_stderr
			);
			
			
			if (!file_exists(MOUNT_EXPLORER."/".$this->user."@".$this->ip."/")) {
				$this->errors++;
				$this->error_autofs_failed=true;
				$this->msgerror = "autofs mount failed";
				return;
			} else {
				$this->error_autofs_failed=false;
			}
		 }
		
		/* Set connection user home path. Not Used */
		/* if ($home == "") {
			$this->home = $this->LSC_getHomePath();
		} else {
			$this->home = $home;
		}*/
		
		debug(1, sprintf("User home path : %s", $this->home));

		/* Initialise sshfs mount path */
		$this->sshfs_mount = MOUNT_EXPLORER.LINUX_SEPARATOR.$this->user."@".$this->ip;
		debug(1, sprintf("SSHFS mount path is : \"%s\"", $this->sshfs_mount));
	}

	/**
	 * LSC_cmdAdd
	 *
	 * Add a command in buffer.\n
	 * This command and all other will be executed when cmdFlush is called
	 * 
	 * @param $cmd : string command to add in buffer
	 *
	 * @todo change LSC_cmdAdd to command_add
	 */
	function LSC_cmdAdd($cmd)
	{
		debug(1, sprintf("Add command in buffer : %s", $cmd));
		$this->cmd[count($this->cmd)] = $cmd;
 	}

	/**
	 * LSC_cmfFlush execute all commands are been in command buffer in 1 ssh session 
	 *
	 * Execute all cmd in 1 ssh session uUsing only 1 ssh session is more fast that
	 * lunch 1 command in 1 session.
	 * 
	 * The ";" shell command separator is used with some redirector to get all results.
	 *
	 * @param $type = "local" or "distant"\n
	 * "local" option executes all commands in the local machine (not use ssh)\n
	 * "distant" option executes all commands in a distant machine (use ssh)
	 *
	 * @return array like this :\n
	 * <pre>
	 * array (
	 *    "cmd1" => array (
	 *       "STDOUT" => array (
	 *             "line1",
	 *             "linen"
	 *       ),
	 *       "STDERR" => array (
	 *             "line1",
	 *             "linen"
	 *       ),
	 *	 "EXIT_CODE" => 0 (only for the last command !)
	 *    ),
	 *    "cmd2" [...]
	 *    )
	 * </pre>
	 *
	 * @warning EXIT_CODE is defined only for the last command !
	 * 
	 * @note When all commands are finish, the $this->cmd buffer is deleted
	 *
	 * @todo change LSC_cmdFlush to command_flush
	 */
	function LSC_cmdFlush($type = "distant")
 	{
		debug(1, "Start LSC_cmfFlush...");

		if (count($this->cmd) == 0) {
			// Exit if command buffer is empty
			debug(1, "LSC_cmfFlush do nothing because command buffer is empty");
			return (0);
		}

		if ($type == "distant") {
			// $cmd is command buffer to start (exec PHP function)

			// Add to $cmd buffer SSH command
			$cmd = sprintf("ssh %s %s@%s \"", $this->opts, $this->user, $this->ip);

			// Add to $cmd buffer all $this->cmd commands
			for ($i = 0, $j = count($this->cmd); $i < $j; $i++) {
				$cmd .= sprintf("%s ;", $this->cmd[$i]);

				if ($i + 1 < $j) {
					$cmd .= " echo ".escapeshellarg(STDOUT_SEPARATOR)." ; echo ".escapeshellarg(STDERR_SEPARATOR)." 1>&2 ; ";
				}
			}
			$tmpfname = tempnam("/tmp", "stderr");
			$cmd .= (($type == "distant") ? "\" 2>> $tmpfname" : "");

			// Start $cmd buffer
			debug(1, sprintf("Command start is : \"%s\"", $cmd) );
			exec($cmd, $output, $return_var);
			
			//debug(1, sprintf("STDOUT = \"%s\"", var_export($output, true)));
			debug(1, sprintf("Exit return value = \"%s\"", $return_var));

			$cur_cmd = 0;
			$res[$this->cmd[$cur_cmd]] = array("STDOUT" => array(), "STDERR" => array(), "STAT" => array());
			foreach ($output as $key => $value) {
				if ($value == STDOUT_SEPARATOR) {
					$cur_cmd++;
					$res[$this->cmd[$cur_cmd]] = array("STDOUT" => array(), "STDERR" => array(), "STAT" => array());
					continue ;
				}
				$res[$this->cmd[$cur_cmd]]["STDOUT"][] = $value;
			}
		}

		$fd = fopen($tmpfname, "r");
		$cur_cmd = 0;
		while (!feof ($fd)) {
			$buffer = fgets($fd);
			$buffer = str_replace("\n", "", $buffer);
			if (strlen($buffer) == 0) {
				continue;
			}

			if ($buffer == STDERR_SEPARATOR) {
				$cur_cmd++;
				 continue;
			 }
			$res[$this->cmd[$cur_cmd]]["STDERR"][] = $buffer;
		}
		$res[$this->cmd[count($this->cmd)-1]]["EXIT_CODE"] = $return_var;
		fclose($fd);
		unlink($tmpfname);
		unset($this->cmd);
		return ($res);
	}

	/* } */

	/**
	 * name Private methods
	 */
	
	/* { */

	/**
	 * LSC_getHomePath
	 *
	 * This function return the home directory of distant user.
	 *
	 * <strong>Exemple :</strong>
	 * 
	 * <p>On MS Windows platform and "Administrator" user the home directory is "C:\Documents and Settings\Administrateur".</p>
	 *
	 * @return String home user path
	 *
	 * To catch home directory on MS Windows, this function user this command : "cygpath --windows `pwd`"
	 *
	 * @bug linux/unix system not implemented
	 * @todo change LSC_getHomePath to get_home_path
	 */
	function LSC_getHomePath()
	{
		/*
		$cmd = sprintf(
			"ssh %s %s@%s cygpath --windows \`pwd\` 2>&1", 
			$this->opts,
			$this->user, 
			$this->ip
		);
		*/
		$cmd = sprintf(
			"ssh %s %s@%s pwd 2>&1", 
			$this->opts,
			$this->user, 
			$this->ip
		);

		$ret = exec($cmd);

		return ($ret);
	}


	/**
	 * Initialize OS type 
	 *
	 * <p>This function use "xprobe2" command to catch the OS type</p>
	 *
	 * Set $this->platform to "Windows" or "Linux" or "" value.\n
	 * "" = not found
	 */
	function initialize_os_type($known_type = "")
	{
		global $config;
		
		$random = mt_rand();
		if ($known_type === false) {
			return;
		}
		if ($known_type == "") {
			unset($output); unset($return_var); unset($stdout); unset($stderr);
			lsc_exec("./xprobe_safe ".$this->ip, $output, $return_var, $stdout, $stderr);
			$key = LSC_arrayEreg("Running OS", $output);
			$type = $output[$key];
		} else {
			$type = $known_type;
		}
		debug(2, "OS Type:".$type);
		if ( strpos ( $type, "Windows" ) !== FALSE) {
			$this->platform = "Windows";
			$this->tmp_path = $config[path_destination];
			return;
		} elseif ( strpos ( $type, "Linux" ) !== FALSE) {
			$this->platform = "Linux";
			$this->root_path = "/";
			$this->tmp_path = "/tmp/lsc$random";
			return;
		}
		$this->platform = "Other/N.A.";
		$this->tmp_path = "";
	}

	/**
	 * Get the good user name on platform
	 *
	 * @return string good username 
	 *
	 * <strong>Example</strong> (if platform is "Windows")
	 *
	 * <pre>
	 * $foo->LSC_getGoodUser("root") ==> "Administrateur"
	 * </pre>
	 *
	 * @todo internationalise MS Windows account administrator name
	 * @todo change LSC_getGoodUser name to get_good_user_name
	 */
	function LSC_getGoodUser($username)
	{
		global $config;
	
		if ($this->platform == "Windows" && $username == "root") {
			if ($config['winadmin'] != "")
				return ($config['winadmin']);
			else
				return ("root");
		}

		return ($username);
	}

	/**
	 * Initialise IP adress
	 * 
	 * This function use :
	 * <ul>
	 *	<li>$this->mac</li>
	 *	<li>$this->ether</li>
	 *	<li>$this->hostname</li>
	 * </ul>
	 *
	 * This function use ether LRS file to catch ip adress from mac adress.
	 * 
	 * If ip adress != "" then this function return actual ip adress ($this->ip)
	 */
	function initialise_ip()
	{
		if ($this->ip != "") {
			// Exit if ip defined
			return;
		}

		/*
		 * Get ip adress by mac adress (read in ether array)
		 */
		debug(8, "Try to get IP adress by mac adress");

		// debug(9, sprintf("Ether table content : <pre>%s</pre>", var_export($this->ether, true)));

		$ip = $this->ether[$this->mac]["ip"];

		if (!stristr($ip, "dynami")) {
			// I found IP adress
			debug(8, sprintf("I found this ip : %s", $ip));
			$this->ip = $ip;
			return;
		} else {
			debug(8, "Ip not found in ether table");
		}

		/*
		 * Get IP adress by hostname (use gethostbyname PHP function)
		 */
		debug(8, "Try to get IP adress by hostname (use gethostbyname PHP function)");
		
		$ip = gethostbyname($this->hostname);
		debug(8, sprintf("gethostbyname(%s) return \"%s\"", $this->hostname, $ip));
		if ($ip != $this->hostname) {
			// I found IP adress
			debug(1, sprintf("I found IP adress : %s", $ip));
			$this->ip = $ip;
			return;
		}
		
		$ret = exec("sh -c \"/usr/bin/net cache flush;/usr/bin/net lookup host ".escapeshellcmd($this->hostname)." 2>&1\"");
		preg_match("/^(\d+\.\d+\.\d+\.\d+)/", $ret, $match);
		if ($match[1]!="") {
			$this->ip = $match[1];
			return;
		}

		$ret = exec("/usr/bin/nmblookup ".$this->hostname." 2>&1");
		preg_match("/(\d+\.\d+\.\d+\.\d+) /", $ret, $match);
		if ($match[1]!="") {
			$this->ip = $match[1];
			return;
		}

		/*
		 * IP adress not found
		 */
		$this->ip = "";
	}

	/**
	 * Return ip adress from hostname
	 * 
	 * @return ip adress or "" if it's not found
	 *
	 * This function use $this->hostname variable.
	 *
	 * This function use gethostbyname function (PHP function) to get ip adress.
	 * 
	 * If ip adress != "" then this function return actual ip adress ($this->ip)
	 */
	function get_ip_by_name()
	{
		if ($this->ip != "") {
			return ($this->ip);
		}

		$ip = gethostbyname($this->hostname);
		debug(2, sprintf("get_ip_by_name with hostname =\"%s\" return \"%s\"", $this->hostname, $ip));
		if ($ip != $this->hostname) {
			return ($ip);
		}

		return ("");
	}

	/**
	 * Initialise hostname, profile and group
	 *
	 * This function initialise the hostname, profile and group of distant host identified by mac adresse.
	 * Ether array data is used to catch these informations.
	 *	
	 * @todo test if mac isn't found in ether array
	 */
	function initialise_hostname_profile_and_group()
	{
		debug(1, "Initialise hostname, profile and group");

		$path = new LSC_Path($this->ether[$this->mac]["name"]);

		$this->hostname = $path->host;
		$this->profile = $path->profile;
		$this->group = implode("/", $path->groups);
	}

	/* } */
}
	
?>
