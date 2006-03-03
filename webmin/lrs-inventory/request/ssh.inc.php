<?php
#
# Linbox Rescue Server - Secure Remote Control Module
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

include_once('system.inc.php');
include_once('common.inc.php');

/*
 * all this define is used when no persistant connection is possible.
 * I need to lunch all cmd in one time using ';' separtor.
 * ex : ssh user@host ls -l ; echo OK ;
 *
 * But the exec retourns all results in one array.
 * I use some tags to associate commands and results
 * and catch errors
*/
define("STDERR_FILE", "/tmp/LSC_stderr");
define("STDERR_SEPARATOR", "##STDERR##");
define("CMD_CATCH_STDERR", "echo ".escapeshellarg(STDERR_SEPARATOR)." && cat ".STDERR_FILE." && rm -f ".STDERR_FILE);
define("CMD_SPLIT_STDERR", "2>>  ".STDERR_FILE." ; echo ".escapeshellarg(STDERR_SEPARATOR)." >> ".STDERR_FILE); 
define("STDOUT_SEPARATOR", "####");
define("CMD_SPLIT_STDOUT", " echo ".escapeshellarg(STDOUT_SEPARATOR));

class LSC_Session {
  var $cmd = array();		# All cmd that will be executed in 1 ssh session
  var $mac = "";
  var $ip = "";
  var $group = "";
  var $hostname = "";
  var $platform = "";
  var $profil = "";
  var $user = "";		# Distant user
  var $ether = array();
  var $auto_flush = 0;		# Not implemented (for persistant connection later..)
  var $error = "";		# Error occured ??
  var $msgerror = "";

  #FIXME: session fuck, must rewrite it !
  #
  # Initialize Session using mac adress. Needed every time
  # Get hostname, ip, platform (windows - linux), distant user
  # distant home user
  function LSC_session($mac)
  {
    $no_ip = 1;
//    session_start();
      $this->mac = $mac;
//    if (!isset($_SESSION['session']))
//    {    
      $this->ip = $this->LSC_GetIpbyEther($mac, $this->ether, $no_ip);
      $this->hostname = $this->LSC_GetHostName($this->ether, $mac, $this->group, $this->profil);
      $this->ip = $this->LSC_getIpByHost($no_ip);
      if (LSC_sysPing($this->ip)) {
        $this->error++;
        $this->msgerror = "Sorry, I can't contact coputer with mac $mac";
      }
      $this->platform = $this->LSC_getPlatform();
      $this->user = $this->LSC_getGoodUser($_ENV['REMOTE_USER']);
      $this->home = $this->LSC_getHomePath();

  /*    $_SESSION['session'] = $this;
    }
    else {
      $this = $_SESSION['session'];
    } */
    #FIXME : get ip by Netbios (nmblookup)
    #FIXME : get ip by OCS ?
  }

  function LSC_initPersistante($auto_flush)
  {
    return ("Not implemented. User LSC_addCmd and LSC_cmdFlush.");
  }

  # Add a command.
  # Command will be executed with cmdFlush with all other command
  function LSC_cmdAdd($cmd)
  {
    $this->cmd[count($this->cmd)] = $cmd;
    if ($auto_flush == 1)
      return (LSC_cmdFlush());
    return (0);
  }

  # Execute all cmd in 1 ssh session
  # Using only 1 ssh session is more fast that
  # lunch 1 command in 1 session
  # the ";" shell command separator is used
  # with some redirector to get all results.
  # return a tab like this :
  # array (
  #    "cmd1" => array (
  #       "STDOUT" => array (
  #             "line1",
  #             "linen"
  #       ),
  #       "STDERR" => array (
  #             "line1",
  #             "linen"
  #        ),
  #    "cmd2" [...]
  #    )
  # type is "distant" or "local"
  # "local" executes all cmd in the local machine
  # "distant" executes all cmd in a distant machine (ssh)
  function LSC_cmdFlush($type = "distant", $asynchrone = 0, $asynch_name = "")
  {
    if (count($this->cmd) == 0)
      return (0);
    if ($asynchtone == 1)
      return (LSC_cmdFlushAsynch($type, $asynch_name));
    if ($type == "distant")
       $cmd = sprintf("ssh %s@%s \"", $this->user, $this->ip);
    for ($i = 0, $j = count($this->cmd); $i < $j; $i++) {
      $cmd .= sprintf(" %s %s ; %s ;", $this->cmd[$i], CMD_SPLIT_STDERR, CMD_SPLIT_STDOUT); 
    }
    $cmd .= CMD_CATCH_STDERR.(($type == "distant") ? "\"" : "");

    exec($cmd, $out, $err);
    $cur_cmd = 0;
    $res = array($this->cmd[0] => array("STDOUT" => array(), "STDERR" => array()));
    foreach ($out as $key => $value) {
      if ($value == STDERR_SEPARATOR)
        break ;
      if ($value == STDOUT_SEPARATOR) {
        $cur_cmd++;
        continue ;
      }
      $res[$this->cmd[$cur_cmd]]["STDOUT"][] = $value;
    }
    for ($i = $key+1, $cur_cmd = 0; isset($out[$i]); $i++) {
      if ($out[$i] == STDERR_SEPARATOR)
        $cur_cmd++;
      else {
        $res[$this->cmd[$cur_cmd]]["STDERR"][] = $out[$i];
      }
    }
    unset($this->cmd);
    return ($res);
  }

/* asynchrone function :
use bash -c 'exec nohup setsid "cmd > /dev/null & echo \$!"';
#FIXME: not finish !!!
*/
  function LSC_cmdFlushAsync($type = "distant", $name = "all")
  {
     if (count($this->cmd) == 0)
      return (0);
     $cmd = "bash -c 'exec nohup setsid ";
     if ($type == "distant")
       $cmd .= sprintf("ssh %s@%s \"", $this->user, $this->ip);
    for ($i = 0, $j = count($this->cmd); $i < $j; $i++) {
      $cmd .= sprintf(" %s %s ; %s ;", $this->cmd[$i], CMD_SPLIT_STDERR, CMD_SPLIT_STDOUT);
    }
    $cmd .= CMD_CATCH_STDERR.(($type == "distant") ? "\"" : "");
    $cmd .= " > /dev/null & echo \$!'";
    echo $cmd;
    //$pid = exec($cmd);
    return ("");
  }

/*************************
 *** Private functions ***
 *************************/

  #FIXME : linux/unix system ??
  # Return the home of the distant user
  function LSC_getHomePath()
  {
    $cmd = sprintf("ssh %s@%s cygpath --windows \`pwd\` 2>&1", $this->user, $this->ip);

    $ret = exec($cmd);
    return ($ret);
  }

  #FIXME : more flexible
  # Return the distant OS (Windows or Linux)
  function LSC_getPlatform()
  {
    exec("xprobe ".$this->ip." 2>&1", $out);
    $key = LSC_arrayEreg("FINAL", $out);
    if (strpos($out[$key], "Windows")!== FALSE)
      return ("Windows");
    else
      return ("Linux");
  }

  # Get the correct root user
  # (It's administrator under Windows)
  function LSC_getGoodUser($user)
  {
   if ($this->platform == "Windows" && $user == "root")
     return ("Administrateur");
   #FIXME: internationalise  windows account administrator name !!
   return ($user);
  }

  # Get the IP reference in the Ether file using the
  # mac adress.
  # no_ip set to 1 if we have an ip
  function LSC_getIpByEther($mac, &$ether, &$no_ip)
  {
    if ($no_ip) {
      $ether = etherLoadByMac();
      $ip = $ether["$mac"]["ip"];
    }
    if (!stristr($ip, "dynami")) {
      $no_ip = 0;
      return ($ip);
    }
    return ("");
  }

  # Try to get the ip by hostname
  # if no_ip == 0, don't try, We get it before.
  # if not, try to get and set no_ip.
  function LSC_getIpByHost(&$no_ip)
  {
    if ($no_ip)
      $ip = gethostbyname($this->hostname);
    if ($ip != $this->hostname) {
      $no_ip = 0;
      return ($ip);
    }
    return ("");
  }

  # Parse the ether line to get name, profile and group
  # return only name (but set other)
  function LSC_GetHostName($ether, $mac, &$group, &$profil)
  {
//    list($name, $profil, $group) = split("[ :]", $ether["$mac"]["name"]);

    ereg('([^\/\:]+)$', $ether["$mac"]["name"], $matches);

    $name = $matches[1];

    return ($name);
  }

}
?>
