#! /var/lib/lrs/php
<?
#
# $Id$
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

include_once('lbs-inventory.php');

# Get the MAC address
if (in_array("mac", array_flip($_GET))) $mac = $_GET["mac"];
else {
  	 echo "general: no address MAC available <br>";
	 exit();
}

# create file
$filename = "$chemin_CSV/Info/Situation_Geo/".$mac."_site_geo.ini";


# check if file exist
if (  ! ($ptr_fichier = fopen($filename, "w+"))) {
		 print("Can't open $filename");
		 exit();
} 
else {

		 # fill the file with form's data
		 $sit = $_POST["situation_geographique"];
		 $sit = ereg_replace("&", "&amp;", $sit);
		 $sit = ereg_replace("<","&lt;", $sit);
		 $sit = ereg_replace("\n","<br>", $sit);

		 $tel = $_POST["telephone_proche"];
		 $tel = ereg_replace("&","&amp;", $tel);
		 $tel = ereg_replace("<","&lt;", $tel);
		 $tel = ereg_replace("\n","<br>", $tel);

		 fwrite ($ptr_fichier, "situation_geographique = " . "\"" . $sit . "\"\n" );
		 fwrite ($ptr_fichier, "telephone_proche = " . "\"" . $tel . "\"\n" );
		 fwrite ($ptr_fichier, "\n");
		 fclose ($ptr_fichier);
}

# redirect to general.cgi
$path = dirname($_SERVER['REQUEST_URI']);
# clean $path :  "/path/" is now "path"
$path = ereg_replace("/","",$path);

# We have a pretty function to retirect ! use is
LIB_redirect("$path/general.cgi?mac=$mac");

?>
