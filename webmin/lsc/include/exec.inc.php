<?php
/*
 * $Id$
 *
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

require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php");

/*
 * Local exec
 */
function lsc_exec($command, &$output, &$return_var, &$stdout, &$stderr)
{
	$pid=exec($command." 2>&1", $output, $return_var);
	$stdout="";
	if (count($output)>0) {
		$separator="";
		foreach($output as $line) {
			$stdout.=$separator.$line;
			$separator="\n";
		}
	}
	
	$stderr=""; // TODO
	return $pid;
}

/*
 * Remote exec
 */
function lsc_ssh($user, $ip, &$command, &$output, &$return_var, &$stdout, &$stderr)
{
	$keychain = get_keychain();
	
	/* -tt forces tty allocation so that signals like SIGINT
	will be properly sent to the remote host */
	$ssh_command ="$keychain ssh -tt -R30080:127.0.0.1:80 -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no ".$user."@".$ip." \"".$command."\" 2>&1";
	
	$handle = popen($ssh_command, "r");
	$size_buffer=2096;
	$total=0;
	$output="";
	while($read = fread($handle, $size_buffer)) {
		$total+=$size_buffer;
		if ($total>MAX_LOG_SIZE) {
			$output.="=== LOG MEMORY LIMIT ===\n";
			break;
		} else {
			$output.=$read;
		}
	}
	$return_var = pclose($handle);
	$stdout = $output;
	$stderr = ""; // TODO. Problem: only one stream read with popen
	if ($return_var != 0) $stderr .= "*** Exit code: $return_var ***";
	$command = $ssh_command;
}

/*
 * Remote copy
 */
function lsc_scp($user, $ip, $source, $destination, &$output, &$return_var, &$stdout, &$stderr, &$scp_command)
{
	$opts = "-o Batchmode=yes -o StrictHostKeyChecking=no -r";

	$destination = ereg_replace(" ", "\\ ", $destination);

	$keychain = get_keychain();

	$scp_command ="$keychain scp $opts \"".$source."\" ".$user."@".$ip.":'".$destination."' 2>&1";
	
	exec($scp_command, $output, $return_var);
	$stdout="";
	if (count($output)>0) {
		$separator="";
		foreach($output as $line) {
			$stdout.=$separator.$line;
			$separator="\n";
		}
	}
	$stderr=""; // TODO
}

?>
