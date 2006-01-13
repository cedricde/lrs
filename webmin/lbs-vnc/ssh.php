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

include_once("../lbs_common/php/sshtest.php");

Class sshtunnel 
{
  var $from = "";
  var $ip = "";
  var $port = 5900;
  var $user;
  var $key;

  //
  //
  //
  function sshtunnel($from, $ip, $port = "5900")
    {
      global $config;

      $this->from = $from;
      $this->ip = $ip;
      $this->port = $port;

      $this->user = $config["ssh_user"];
      $this->key = $config["ssh_key"];

    }

  //
  // connect and return the proxy port
  //
  function connect()
    {
      global $nbname;
    
      $cmd = escapeshellcmd("./proxy.pl run $this->from $this->ip $this->port $this->key $this->user $nbname");
      $handle = popen($cmd, "r");
      $string = fgets($handle, 100);
      pclose ($handle);

      if (preg_match("/port: ([0-9]+)/", $string, $matches)) {
	return $matches[1];
      } else {
	return null;
      }
    }

  //
  // check if we can establish an ssh tunnel
  //
  // 0=OK, otherwise error
  function test()
    {
      global $nbname;
    
      //$cmd = escapeshellcmd("./proxy.pl test $this->from $this->ip $this->port $this->key $this->user $nbname");
      //exec($cmd, $output, $ret);
      $ssh = new sshtest($this->user, $this->ip, $this->key);
      $ret = $ssh->test();
      return($ret);
    }
  
}


?>
