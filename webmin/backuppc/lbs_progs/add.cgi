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

/* add a host $argv[1] to backuppc */
$dhcp_default=0;

if (count($argv) <= 1)
  return "Error : not enough arguments.";
if ($argv[1] == "")
  return "Error : empty host name.";

$host=$argv[1];
$filename = '/etc/backuppc/hosts';
if (!file_exists($filename))
  return "Error : file $filename doesn't exist.";

$fh = fopen($filename, "a");
$str = "$host \t $dhcp_default \t backuppc\n";
if (fwrite($fh, $str) == FALSE)
  return "Error : cannot write to $filename.";
fclose($fh);
// create deafault host configuration file
$host = strtolower($host);
$filename = "/etc/backuppc/".$host.".pl";
if (!($fh = fopen($filename, "w")))
  return "Error : cannot create file $filename.";
fwrite($fh, "# Configuration of $host\n\$Conf{XferMethod} = 'tar';\n\n\$Conf{TarShareName} = [];\n\n");
fwrite($fh, "\$Conf{TarClientCmd} = '/usr/bin/env LANG=en \$tarPath -c -v -f - -C \$shareName --totals';\n\n");
fwrite($fh, "\n# *** Unchanged Configuration ***\n");
fwrite($fh, "\n\n# ***\n");
fclose($fh);

return 0;
?>
