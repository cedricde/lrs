#!/usr/bin/php4
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

/* rename a host $argv[1] to $argv[2] in backuppc 
 * return
    - 0 on success
    - string with a message on an error
*/

if (count($argv) <= 2)
  return "Error : not enough arguments.";
if ($argv[1] == "")
  return "Error : empty old host name.";
if ($argv[2] == "")
  return "Error : empty new host name.";

$host=$argv[1];
$new_host=$argv[2];

/* rename in hosts file */
$filename = '/etc/backuppc/hosts';
if (!file_exists($filename))
  return "Error : file $filename doesn't exist.";

$filelines = file($filename);
if (empty($filelines)) 
  return "Error :$filename does not exist or is empty.";

$filestr = "";
$reg = "/^\s*".$host."\s+([01])\s+(.*)\s*$/";
foreach ($filelines as $line) {
  if (preg_match($reg, $line, $m)) 
    $filestr .= $new_host." \t ".$m[1]." \t ".$m[2]."\n";
  else
    $filestr .= $line;
}
 
$fh = fopen($filename, "w");
if (fwrite($fh, $filestr) == FALSE)
  return "Error : cannot write to $filename.";
fclose($fh);

/* rename host's config file */
$host = strtolower($host);
$filename = "/etc/backuppc/".$host.".pl";
$new_filename = "/etc/backuppc/".$new_host.".pl";
if (rename($filename, $new_filename) == FALSE)
  return "Error : cannot rename $filename.";

/* rename host's backups */
$filename = "/var/lib/backuppc/pc/".$host;
$new_filename = "/var/lib/backuppc/pc/".$new_host;
if (is_dir($filename))
  if (rename($filename, $new_filename) == FALSE)
    return "Error : cannot rename $filename.";

return 0;
?>
