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

/* return the last part of the path string */
function folderName($dir) {
  $folders=explode("/", $dir);
  return $folders[count($folders) - 1];
}
/* delete recursively a folder */
function deldir($dir) {
  $folder = folderName($dir);
  if ($folder == "." || $folder == "..") 
    $res = TRUE;
  else {
    $handle = opendir($dir);
    while (false !== ($folderOrFile = readdir($handle))) {
      if (is_dir($dir."/".$folderOrFile)) 
        deldir($dir."/".$folderOrFile);
      else 
        unlink($dir."/".$folderOrFile);
    }
    closedir($handle);
    if (rmdir($dir))
      $res = TRUE;
  }
  return $res;
}

/* remove a host $argv[1] from backuppc */

if (count($argv) <= 1)
  return "Error : not enough arguments.";
if ($argv[1] == "")
  return "Error : empty host name.";

$host=$argv[1];
$filename = '/etc/backuppc/hosts';
if (!file_exists($filename))
  return "Error : file $filename doesn't exist.";

/* remove the proper line from the hosts file */
$filelines = file($filename);
if (empty($filelines)) 
  return "Error :$filename does not exist or is empty.";

$filestr = "";
$reg = "/^\s*".$host."\s+[01]\s+.*\s*$/";
foreach ($filelines as $line) {
  if (!preg_match($reg, $line, $m))
    $filestr .= $line;
}
 
$fh = fopen($filename, "w");
if (fwrite($fh, $filestr) == FALSE)
  return "Error : cannot write to $filename.";
fclose($fh);

/* remove hosts' configuration file */
$host = strtolower($host);
$filename = "/etc/backuppc/".$host.".pl";
if (unlink($filename) == FALSE)
  return "Error : cannot delete $filename.";

/* remove its backups */
$filename = "/var/lib/backuppc/pc/".$host;
if (is_dir($filename))
  if (deldir($filename) == FALSE)
    echo "Error : cannot delete $filename.";

return 0;
?>
