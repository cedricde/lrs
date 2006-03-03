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


function LSC_sysShutdown($session, $opt, $time)
{
  $cmd = "shutdown $opt $time";
  $session->LSC_cmdAdd($cmd);
  $res = $session->LSC_cmdFlush();
  $res = $session->LSC_cmdFlush();
  if (!empty($res[$cmd]['STDERR'])) {
//  $this->errocd = ERR_CUSTOM;
    $msg = implode("<br />", $res[$cmd]['STDERR']);
    return (FALSE);
  } 
}

function LSC_sysReboot($session, $time = 0)
{
  return (LSC_sysShutdown($session, "-r", $time));
}

function LSC_sysHalt($session, $time = 0)
{
  return (LSC_sysShutdown($session, "-s", $time));
}

function LSC_sysPing($ip, $port = 22)
{
 $fp = fsockopen($ip, $port, $errno, $errstr, 4);
 if(!$fp)
  return (1);
 fclose($fp);
 return (0); 
}
?>
