<?
#
# $Id$
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#
# class to test an ssh server and manage key mismatch problems
#
Class sshtest
{
  var $ip = "";
  var $user;
  var $key = "";
  var $sshopts = "-o Batchmode=yes -o StrictHostKeyChecking=no";
  var $action = "remove";	// offending key action  
  
  //
  // constructor
  //
  function sshtest($user, $dest, $key = "/root/.ssh/id_dsa")
  {
      global $config;

      $this->user = $user;
      $this->ip = $dest;
      $this->key = $key;
  }

  //
  // check if we can establish an ssh tunnel
  //
  // 0=OK, otherwise error
  function test()
  {
	$random = rand(1024, 65500);    

	$cmd = escapeshellcmd("ssh -i $this->key -L $random:127.0.0.1:5900 $this->sshopts -n $this->user@$this->ip echo =SSHOK=");
	exec($cmd." 2>&1", $output, $ret);

	$this->cmd = $cmd;
	$this->ret = $ret;
	$this->output = $output;

	$all = join($output, "\n");
	// check for an offending key
	if (eregi("Offending key in ([^ \n\r\t:]*):([0-9]+)", $all, $matches)) {
		// remove the key
		if ($this->action == "remove") {
			return ($this->remove($matches[1], $matches[2]));
		}
	}

	// check for the echo
	if (!strstr($all, "=SSHOK=")) {
		return(255);
	}

	return(0);
  }
   
  //
  // remove a line from the file
  //
  // 0=OK, otherwise error
  function remove($file, $line)
  {
   	$lines = file($file);
	unset($lines[$line-1]);
	$all = join($lines, "");
	if (!($f = fopen($file, "w"))) {
		return(253);
   	}
   	fwrite($f, $all);
	fclose($f);
	$this->test();	// another call to add the host
	return(0);
  }
}

// test
if (0) {
	$ssh = new sshtest("Administrateur", "192.168.0.223");
	echo $ssh->test();
}

?>
