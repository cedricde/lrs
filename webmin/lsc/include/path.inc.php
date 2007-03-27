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
require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php");

/**
 * This script is used to get some information about profile or group
 */

/**
 * LSC_Path class 
 *
 * The aims of this class is to handle information of target string : extract hostname, groups name, profile...
 */
class LSC_Path
{
	var $full_path = "";		/**< Full path to host or group ... */
	var $profile = "";		/**< Profile of path */
	var $groups = array(); 		/**< This array content group and subgroup... */
	var $host = "";			/**< Hostname of path */

	/**
	 * LSC Path constructor
	 *
	 * @param $profile_and_group_name
	 *
	 * <strong>$profile_and_group_name value example :</strong>
	 *
	 * <ul>
	 *	<li>profile1: (one profile only)</li>
	 *	<li>:group1/ (one group only, "/" is important)</li>
	 *	<li>:host1 (not "/" !)</li>
	 *	<li>:group1/group2/ (one subgroup)</li>
	 *	<li>profile1:group1/group2/ (one subgroup in one profile)</li>
	 *	<li>profile1:group1/group2/host2 (one host in one subgroup in on profile)</li>
	 *	<li>host1 (not "/" and not ":" !)</li>
	 *	<li>group1/ (one group only)</li>
	 *	<li>group1/host1</li>
	 *	<li>...</li>
	 * </ul>
	 *
	 * This function don't test if path is bad.
	 *
	 * If profile = "all" or "" define all profiles.\n
	 * If profile = "none" define empty profile.
	 */
	function LSC_Path($profile_and_group_name)
	{
		$this->full_path = $profile_and_group_name;

		/*
		 * Extract profile
		 */
		$strpos = strpos($profile_and_group_name, ":");
		if ( $strpos === false ) {
			// no profile found in $profile_and_group_name
			debug(1, "Profile not found");
			$this->profile = "";
			$buffer_group_and_host_name = $profile_and_group_name;
		} elseif ( $strpos == 0 ) {
			// no profile found in $profile_and_group_name
			debug(1, "Profile not found");
			$this->profile = "";
			$buffer_group_and_host_name = substr($profile_and_group_name, 1);
		} else {
			// profile found
			debug(1, "Profile found");
			list($this->profile, $buffer_group_and_host_name) = explode(":", $profile_and_group_name);
		}

		debug(1, sprintf("buffer_group_and_host_name = %s\n", $buffer_group_and_host_name));
		debug(1, sprintf(
			"strpost(buffer_group_and_host_name, '/') = %s\n", 
			strpos($buffer_group_and_host_name, '/')
		));
	
		/*
		 * Extract group
		 */
		if (strpos($buffer_group_and_host_name, '/') !== false) {
			// group found
			debug(1, "Group found");
			
			/* Extract all groups */
			$buffer_group = substr($buffer_group_and_host_name, 0, strrpos($buffer_group_and_host_name, "/"));
			
			/* Extract host */
			$this->host = substr($buffer_group_and_host_name, strrpos($buffer_group_and_host_name, "/") + 1);
			
			$group_tmp = explode("/", $buffer_group);
			
			/*
			 * Delete all empty ("") groups
			 */
			foreach($group_tmp as $item) {
				if ($item != "") {
					array_push($this->groups, $item);
				}
			}
		} else {
			/* no group and subgroup in $buffer_group_and_host_name */
			debug(1, "Group not found");

			/* groups empty */
			$this->groups = array();	

			/* $buffer_group_and_host_name content only host name */
			$this->host = $buffer_group_and_host_name;	
		}
	}

	/**
	 * Return the name of the profile
	 */ 
	function get_profile_name()
	{
		return $this->profile;
	}

	/**
	 * Return the depth of group
	 *
	 * Return the number of subgroup
	 *
	 * @return number of subgroup
	 *
	 * Example : 
	 *	if group is "profile1:foo/bar/host"
	 *	foo->get_group_depth() return 2
	 *
	 * Other Example :
	 *	if group is "profile2:host"
	 *	foo->get_group_depth() return 0
	 *
	 */
	function get_group_depth()
	{
		return count($this->groups);
	}

	/**
	 * Return a sub group name
	 *
	 * @param level of subgroup to return
	 * @return the name of subgroup or -1 if level out of limit
	 *
	 * Example : 
	 *	if group is "profile1:foo/bar/host"
	 *	foo->get_group_name(2) return "bar"
	 */
	function get_group_name($level)
	{
		if ($level<$this->get_group_depth()) {
			return $this->groups[$level];
		} else return -1;
	}

	/**
	 * Return the path host name
	 *
	 * @return the host name
	 */
	function get_host()
	{
		return $this->host;
	}

	/**
	 * Return list of hosts
	 *
	 * This function return the path of all hosts of current path
	 *
	 * @return Array list host
	 */
	function get_hosts_list()
	{
		$ether = etherLoad(0);
		
		if ($this->host == "") {
			// Host isn't defined, then return the path of all hosts of the profile and groups
			debug(1, "Host isn't defined then return the path of all hosts of the profile and groups");

			if ($this->profile == "all" || $this->profile == "" ) {
				if ($this->groups == array()) {
					$match = "^.";
				} else  {
					$match = sprintf(".*:?%s/.*",
						implode("/", $this->groups)
					);
				}
			} elseif ($this->profile == "none") {
				$match = sprintf("^:?%s/.*",
					implode("/", $this->groups)
				);
			} else {
				$match = sprintf("^%s:%s.*",
						$this->profile,
						implode("/", $this->groups)
				);
			}

			$buffer_out = array();

			foreach($ether as $key=>$value) {
				if (strrpos($key, ":") === false)
					$key = ":" . $key;

				if (ereg($match, $key)) {
					$hostname = substr($key, strrpos($key, ":") + 1);
					if (strrpos($hostname, "/") !== false) {
						$hostname = substr($hostname, strrpos($hostname, "/") + 1);
					}
					
					$buffer_out["$hostname"] = array(
							"full_hostname" => $key,
							"ip" => $value["ip"],
							"mac" => $value["mac"],
							"hostname" => $hostname	
							);
				}
			}

			/*
			debug(9, sprintf(
				"LSC_Path - %s - list = %s",
				__FUNCTION__,
				var_export($buffer_out, true)
			));*/
			
			ksort($buffer_out);
			return $buffer_out;
		} else {
			// Host is defined, then path define ONE host only
			debug(1, "Host is defined then path define ONE host only");

			$match=sprintf("%s:%s/%s", 
				$this->profile, 
				implode("/", $this->groups), 
				$this->host
			);

			if (array_key_exists($match, $ether)) {
				debug(1, sprintf("Path : %s is matched\n", $match));

				return array($match);
			}

			$match=sprintf("%s:%s",	
				$this->profile, 
				$this->host
			);

			if (array_key_exists($match, $ether)) {
				debug(2, sprintf("Path : %s is matched", $match));
				
				$hostname = substr($match, strrpos($match, ":") + 1);
				if (strrpos($hostname, "/") !== false) {
					$hostname = substr($hostname, strrpos($hostname, "/") + 1);
				}
				debug(2, "Host found");
				return array(
					array(
						"full_hostname"=> $match,
						"ip" => $ether[$match]["ip"],
						"mac" => $ether[$match]["mac"],
						"hostname" => $hostname
					)
				);
			} else {
				/*
				 * Iterate all list to found $match host
				 */
				foreach($ether as $key=>$value) {
					$path = new LSC_Path($key);
					if ($path->get_host() == $this->host) {
						debug(2, "Host found");
						return array(array(
							"full_hostname" => $key,
							"ip" => $value["ip"],
							"mac" => $value["mac"],
							"hostname" => $this->host
						));
					}
				}
				
				debug(2, "Host not found");
			}
		}
	}
} 

?>
