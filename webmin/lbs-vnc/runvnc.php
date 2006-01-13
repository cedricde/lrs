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
# Scan VNC ports and if open ports are found, connect to it
#
function scanRunVNC($ip, $type, $ssh)
{
  global $config, $text;
  // 5800 = http, 5900 = tcp

  if (strlen($ip) == 0)
    return;

  $port = $config["default_httpvnc_port"];
  if ($type) $port = $config["default_vnc_port"];

  // try ssh 
  if ($ssh) 
    {
      $ssh = new sshtunnel($_SERVER["REMOTE_ADDR"], $ip, $config["default_vnc_port"]);
      $destip = $ip;
      if ($ssh->test()) {
	return;
      }
      $port = $ssh->connect();
      $server = $_SERVER['SERVER_NAME'];
      $ip = $server;

      sleep(3);
     }

  $max = 1;
  $timeout = 1;
  if ($ssh) {
    $max = 0;
    $timeout = 5;
  }
  $i = 0;
  while ($i <= $max) {
    $fd = @fsockopen($ip, $port+$i, $errno, $errstr, $timeout);
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
	  if ($ssh) {
	    echo perl_exec("lbs_header.cgi", array("remote_control", $text{'index_title'}." ".$destip, "index"));
	    echo '
   <APPLET CODE=VncViewer.class ARCHIVE=VncViewer.jar WIDTH=1024 HEIGHT=800>
   <PARAM NAME="PORT" VALUE="'.($port+$i).'">
   <PARAM NAME="PASSWORD" VALUE="">
   <PARAM NAME="Offer Relogin" VALUE="No">
   </APPLET><BR>';
	    echo perl_exec("lbs_footer.cgi", array("2"));
	    exit;
	  } else {
	    lib_redirect("http://$ip:".($port+$i)."/");
	  }
	}
    }
    $i++;
  }

  #echo "$errstr ($errno)<br>\n";
  return;

}
?>