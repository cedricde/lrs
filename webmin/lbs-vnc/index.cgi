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
		      "HTTP_LINK" => "<a href='index.cgi?mac=".urlencode($ether[$k]['mac'])."&type=http'><img border=1 src='images/vnc.png'></a>"
		      ));
		      
    $t->parse("main_rows", "main_row", true);
  }
  
  # output everything
  if (count($key) != 0) $t->pparse("out", "main");
  
}

#
# Try to resolve the client's name 
#
function tryVNC($mac, $type)
{
  global $text;

  $ether = etherLoadByMac();

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

  # Try 1st the IP
  $ip = $ether["$mac"]["ip"];
  if (!stristr($ip, "dynami")) {
    scanRunVNC($ip, $type);
  }
  # Then DNS
  $name = $ether["$mac"]["name"];
  preg_match("/[^\/]+$/", $name, $match); // remove the group name
  $name = $match[0];
  $ip = gethostbyname($name);
  if ($ip != $name) {
    scanRunVNC($ip, $type);
  }
  # and nmblookupheader("Location: ".$_SERVER['HTTP_REFERER']); 
  $ret = exec("/usr/bin/nmblookup $name 2>&1");
  preg_match("/(\d+\.\d+\.\d+\.\d+) /", $ret, $match);
  $ip = $match[1]; 
  if ($ip != "") {
      scanRunVNC($ip, $type);	
  }
  
  # Last try: find info from OCS Inventory
  if (is_readable("/var/lib/ocsinventory/Network/$name.csv")) {
    $lines = file("/var/lib/ocsinventory/Network/$name.csv");
    foreach ($lines as $line_num => $line) {
	$cols = split(";", $line);
	if (strcasecmp($cols[5], $mac) == 0) {
	    scanRunVNC($cols[7], $type);
	}
    }
  }
  
  # nothing found !
  echo perl_exec("lbs_header.cgi", array("remote_control", $text{'index_title'}, "index"));
  $t = tmplInit(array("main" => "main.tpl", "erreur" => "erreur.tpl"));             
  $t->pparse("out", "erreur");
  echo perl_exec("lbs_footer.cgi", array("2"));

}

#
# Scan VNC ports and if open ports are found, connect to it
#
function scanRunVNC($ip, $type)
{
  global $config;
  # 5800 = http, 5900 = tcp

  if (strlen($ip) == 0)
    return;

  $port = $config["default_httpvnc_port"];
  if ($type) $port = $config["default_vnc_port"];;

  $i = 0;
  while ($i <= 1) {
    $fd = @fsockopen($ip, $port+$i, $errno, $errstr, 1);
    if ($fd) 
      {
	// something found !
	fclose ($fd);

	if ($type) {
	  header("Content-type: VncViewer/Config");
	  header("Content-Disposition: inline; filename=\"config.vnc\"");
	  header("Cache-control: private");
	  //header("Content-transfer-encoding: binary");
	  echo "[connection]\r\nhost=$ip \r\nport=".($port+$i)."\r\n";
	  exit;
	} else {
	  lib_redirect("http://$ip:".($port+$i)."/");
	}
    }
    $i++;
  }

  #echo "$errstr ($errno)<br>\n";
  return;

}

# MAIN

initLbsConf($config['lbs_conf'], 1);

if (isset ($_GET['mac'])) 
{
	$retour = tryVNC($_GET['mac'], $_GET['type']);
	
} else {

	# show header
	echo perl_exec("lbs_header.cgi", array("remote_control", $text{'index_title'}, "index"));

	$ether = etherLoadByName();

	showMainByName($ether);
	echo perl_exec("lbs_footer.cgi", array("2"));
}
	

?>