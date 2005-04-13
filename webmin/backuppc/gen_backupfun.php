<?
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


$conf_filename = '/etc/backuppc/config.pl';

/* Read the configuration settings from the config.pl file and write them to the entry variables:
 * $wakeup - WakeupSchedule - string
 * $maxbackups - MaxBackups - int
 * $blackoutbegin - BlackoutHourBegin - string / real
 * $blackoutend - BlackoutHourEnd - string / real
 * $blackoutdays - BlackoutWeekDays - array[1..7] of booleans == true if the day is a blackout day
 * $dhcps - DHCPAddrRanges - array of string - addresses ranges (eg. 192.168.0.20-60)
*/
function readGenConfFile(&$wakeup, &$maxbackups, &$blackoutbegin, &$blackoutend, &$blackoutdays, &$dhcps) {
// values from config.pl
  global $conf_filename;
  
  $filelines = @file($conf_filename);
  if (empty($filelines)) {
    halt("Error while reading configuration file; $conf_filename does not exist or is empty.");
    return false;
  }
  
  $no_comment=array();
  $j=0;
  $reg = "/^#.*$/";
  for ($i=0; $i<count($filelines);$i++) {
    if (!preg_match($reg, $filelines[$i], $m)) { 
      $no_comment[$j] = $filelines[$i];
      $j++;
    } 
  }  
  $filestr = implode("", $no_comment);
  
  $reg = "/\s*[\$]Conf\{WakeupSchedule\}\s*=\s*\[(.+)\];/";
  preg_match($reg, $filestr, $m); 
  $wakeup = $m[1];
 
  $reg = "/[\$]Conf\{MaxBackups\}\s*=\s*(.+);/";
  preg_match($reg, $filestr, $m);
  $maxbackups = $m[1];
  
  $reg = "/[\$]Conf\{BlackoutHourBegin\}\s*=\s*(.+);/";
  preg_match($reg, $filestr, $m); 
  $blackoutbegin = $m[1];
 
  $reg = "/[\$]Conf\{BlackoutHourEnd\}\s*=\s*(.+);/";
  preg_match($reg, $filestr, $m); 
  $blackoutend = $m[1];
  
  $reg = "/[\$]Conf\{BlackoutWeekDays\}\s*=\s*\[(.+)\];/";
  preg_match($reg, $filestr, $m); 
  $blackoutdays_tmp = array_map("trim", explode(",", $m[1]));
  $blackoutdays=array();
  for ($i=0; $i<7; $i++)
    $blackoutdays[$i]=(in_array($i, $blackoutdays_tmp));
  
  $dhcps=array();
  $i=0;
  $reg = "/[\$]Conf\{DHCPAddressRanges\}\s*=\s*\[(.*)/";
  while (!preg_match($reg, $no_comment[$i], $m)) $i++;
  if (!preg_match("/\]/", $m[1], $m1)) {
    $dhcps_str = $m[1];
    $i++;
    while (!preg_match("/(.*)\s*\]/", $no_comment[$i], $m)) {
      $dhcps_str .= $no_comment[$i];
      $i++;
    }
    $dhcps_str .= $m[1];
    $reg = "/\s*\{([^\}]+)\},?/";
    $n = preg_match_all($reg, $dhcps_str, $m);
    for ($i=0; $i<$n; $i++) {
     preg_match("/\s*ipAddrBase\s*=>\s*'(.+)',\s*first\s*=>\s*([0-9]+),\s*last\s*=>\s*([0-9]+),?/", $m[1][$i], $dhcp_match);
      $dhcps[$i]=$dhcp_match[1].".".$dhcp_match[2]."-".$dhcp_match[3];
    }
  } 
}

/* Write the new configuration settings to the config.pl file from the entry variables:
 * $wakeup - WakeupSchedule
 * $maxbackups - MaxBackups
 * $blackoutbegin - BlackoutHourBegin 
 * $blackoutend - BlackoutHourEnd 
 * $blackoutdays - BlackoutWeekDays
 * $dhcps - DHCPAddrRanges
 * all variables are preformated strings that need no additional change before inserting them to the file.
*/

function writeGenConfFile($wakeup, $maxbackups, $blackoutbegin, $blackoutend, $blackoutdays, $dhcps) {
  global $conf_filename;
  $filelines = @file($conf_filename);
  if (empty($filelines)) {
    halt("Error while reading configuration file; $conf_filename does not exist or is empty.");
    return false;
  }
  
  $new_filelines=array();
  $comment_reg = "/^#.*$/";
  $wakeup_reg = "/\s*[\$]Conf\{WakeupSchedule\}\s*=\s*\[.*\];/";
  $maxbackups_reg = "/[\$]Conf\{MaxBackups\}\s*=\s*.+;/";
  $blackoutbegin_reg = "/[\$]Conf\{BlackoutHourBegin\}\s*=\s*.+;/";
  $blackoutend_reg = "/[\$]Conf\{BlackoutHourEnd\}\s*=\s*.+;/";
  $blackoutdays_reg = "/[\$]Conf\{BlackoutWeekDays\}\s*=\s*\[.*\];/";
  $dhcps_reg = "/[\$]Conf\{DHCPAddressRanges\}\s*=\s*\[.*/";
  $j = 0;
  $dhcps_str=$dhcps;
  
  for ($i=0; $i<count($filelines); $i++) {
   
    if (preg_match($comment_reg, $filelines[$i], $m)) 
      $new_filelines[$j] = $filelines[$i];
    else if (preg_match($wakeup_reg, $filelines[$i], $m)) 
      $new_filelines[$j] = '$Conf{WakeupSchedule} = ['.$wakeup."];\n";
    else if (preg_match($maxbackups_reg, $filelines[$i], $m))
      $new_filelines[$j] = '$Conf{MaxBackups} = '.$maxbackups.";\n";
    else if (preg_match($blackoutbegin_reg, $filelines[$i], $m))
      $new_filelines[$j] = '$Conf{BlackoutHourBegin} = '.$blackoutbegin.";\n";
    else if (preg_match($blackoutend_reg, $filelines[$i], $m)) 
      $new_filelines[$j] = '$Conf{BlackoutHourEnd} = '.$blackoutend.";\n";
    else if (preg_match($blackoutdays_reg, $filelines[$i], $m))
      $new_filelines[$j] = '$Conf{BlackoutWeekDays} = ['.$blackoutdays."];\n";
    else if (preg_match($dhcps_reg, $filelines[$i], $m)) {
      while (!preg_match("/\]/", $filelines[$i], $m)) $i++;
      $new_filelines[$j] = '$Conf{DHCPAddressRanges} = ['.$dhcps_str."];\n";
    } else 
      $new_filelines[$j] = $filelines[$i];
    $j++;
  } 
  $file_str=implode("", $new_filelines);
  $file=fopen($conf_filename, 'w');
  fwrite($file, $file_str);
  fclose($file);
}

/* Read whole content of config.pl. */
function getConfFile() {
  global $conf_filename;
  $filelines = @file($conf_filename);
   if (empty($filelines)) {
    halt("Error while reading configuration file; $conf_filename does not exist or is empty.");
    return false;
  }
  $file_str = implode("", $filelines);
  return $file_str;
}

/* Write all of $file_str as the content of config.pl*/
function putConfFile($file_str) {
  global $conf_filename;
  $file=fopen($conf_filename, 'w');
//  $file=fopen("/etc/backuppc/config_adv.pl", 'w');
  fwrite($file, $file_str);
  fclose($file);
}

/* show error message and quit
*/
function halt($msg) {
 die("<b>Halted:</b> $msg");
 return false;
}

/* verify if LBS is installed on the machine
 * return boolean
*/
function isLBS() {
  $file = '/etc/lbs.conf';
  return file_exists($file);
}


?>
