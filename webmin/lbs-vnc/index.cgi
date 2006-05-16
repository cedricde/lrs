#! /var/lib/lrs/php
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

include_once('lbs-vnc.php');

$connect_error=0;

#
# List LBS clients
#
function showMainByName($ether) {
  global $text, $connect_error, $module_info;

  if (!is_array($ether))
        return;

  $key = array_keys($ether);	
  sort($key);	
  $t = tmplInit(array("main" => "main.tpl", "erreur" => "erreur.tpl"));             
  $t->set_block("main", "main_row", "main_rows");

  foreach ($key as $k) {
    $t->set_var(array(
		      "NAME" => "&nbsp; $k &nbsp;",
		      "IP" => $ether[$k]['ip'],
		      "VNC_LINK" => "<a href='index.cgi?mac=".urlencode($ether[$k]['mac'])."&type=vnc'><img border=1 src='images/vnc.png'></a>",
		      "HTTP_LINK" => "<a href='index.cgi?mac=".urlencode($ether[$k]['mac'])."&type=http'><img border=1 src='images/vnc2.png'></a>"
		      ));
		      
    $t->parse("main_rows", "main_row", true);
  }
  
  # output everything
  if (count($key) != 0) $t->pparse("out", "main");
  
}

#
# Try to resolve the client's name and launch the VNC client
#
function tryVNC($mac, $type, $getssh)
{
  global $text, $config, $config_directory;
  global $nbname;

  # extract the host name
  $ether = etherLoadByMac();  
  ereg("([^/:]+$)", $ether["$mac"]["name"], $match);
  $nbname = $match[1];

  switch ($type) {
  case "http":
    $type = 0;
    break;
  case "vnc":
    $type = 1;
    break;
  default:
    $type = 0;
  }

  # use ssh or not ?
  $ssh = 0;
  if ($getssh != "1") {
    # GET parameters override config files
    if ($config["ssh"] == "1") {
      $ssh = 1;
    }
  } else {
    $ssh = 1;
  }
  # Get LSC parameter or not ?
  if ($ssh) {
    @$lscconfig = lib_read_file($config_directory."/lsc/config");
    if (trim($config["ssh_key"]) == "") {
      // get LSC params
      $config["ssh_key"] = $lscconfig["ssh_key"];
    }
    if (trim($config["ssh_user"]) == "") {
      // get LSC params
      $config["ssh_user"] = $lscconfig["ssh_user"];
    }
  }

  # Try 1st the IP
  $ips = "";
  $ip = $ether["$mac"]["ip"];
  if (!stristr($ip, "dynami")) {
    scanRunVNC($ip, $type, $ssh);
    $ips .= $ip;
  }
  # Then DNS
  $name = $ether["$mac"]["name"];
  preg_match("/[^\/]+$/", $name, $match); // remove the group name
  $name = $match[0];
  $ip = gethostbyname($name);
  if ($ip != $name) {
    scanRunVNC($ip, $type, $ssh);
    $ips .= " ".$ip;
  }

  # and net lookup 
  $ret = exec("sh -c \"/usr/bin/net cache flush;/usr/bin/net lookup host ".escapeshellcmd($name)." 2>&1\"");
  preg_match("/^(\d+\.\d+\.\d+\.\d+)/", $ret, $match);
  $ip = $match[1]; 
  if ($ip != "") {
      scanRunVNC($ip, $type, $ssh);	
      $ips .= " ".$ip;
  }

  # and nmblookup 
  $ret = exec("/usr/bin/nmblookup $name 2>&1");
  preg_match("/(\d+\.\d+\.\d+\.\d+) /", $ret, $match);
  $ip = $match[1]; 
  if ($ip != "") {
      scanRunVNC($ip, $type, $ssh);	
      $ips .= " ".$ip;
  }

  
  # Last try: find info from OCS Inventory
  if (is_readable("/var/lib/ocsinventory/Network/$name.csv")) {
    $lines = file("/var/lib/ocsinventory/Network/$name.csv");
    foreach ($lines as $line_num => $line) {
	$cols = split(";", $line);
	if (strcasecmp($cols[5], $mac) == 0) {
	    scanRunVNC($cols[7], $type, $ssh);
	    $ips .= " ".$ip;
	}
    }
  }
  
  # nothing found !
  echo perl_exec("lbs_header.cgi", array("remote_control", $text{'index_title'}, "index"));
  $t = tmplInit(array("main" => "main.tpl", "erreur" => "erreur.tpl"));
  $t->set_var("IPS", $ips);
  $t->pparse("out", "erreur");
  echo perl_exec("lbs_footer.cgi", array("2"));

}


# MAIN

initLbsConf($config['lbs_conf'], 1);

if (isset ($_GET['mac'])) 
{
	$retour = tryVNC($_GET['mac'], $_GET['type'], $_GET['ssh']);
	
} else {

	# show header
	echo perl_exec("lbs_header.cgi", array("remote_control", $text{'index_title'}, "index"));

	$ether = etherLoadByName();
	showMainByName($ether);

	echo perl_exec("lbs_footer.cgi", array("2"));
}
	

?>