<?php
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


lib_init_config();
# web-lib.php give $GLOBALS["config"]

$temp = $GLOBALS["config"]; # <- default lbs-inventory config
if ($temp == -1) 
{ # if doesn't exist, copy the default in /etc/webmin/lbs-inventory/config (default)
  $assocTable = lib_read_file("./config");
  print "<h1> error configuration file not found, using default</h1> <br> <font size = '5' weight='bold'>Copying config into default directory (/etc/webmin/lbs-inventory) <br> Please reload the page <br> <br> </font> If you see this page a second time, please copy the config file into your lbs-inventory configuration directory <br>";
`cp ./config /etc/webmin/lbs-inventory/`;
}
else $assocTable = $temp;

$chemin = $assocTable['chemin'];

# directory path where CVS file can be found
# transfert.php put in the current directory
# FIXED : put in /var/lib/lbs
$chemin_CSV = $assocTable['chemin_CSV'];

# directory where 'ini' file form LBS can be found
$chemin_LBS = $assocTable['chemin_basedir'].'/log';

# color used in 'presentation'
$mauve_fonce="#9999ff";
$mauve_clair="#e2d1f9";
$gris_clair="#e2e2e2";
$vert="#35b4c3";
$vert_clair="#97bcc9";
?>
