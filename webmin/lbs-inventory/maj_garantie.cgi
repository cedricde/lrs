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
  	 echo "maj_garantie: no MAC address available <br>";
	 exit();
}

	
# create the file for the informations writing
$filename = "$chemin_CSV/Info/Garantie/".$mac."_garantie.ini";

# check if file exist
if (  ! ($ptr_fichier = fopen($filename, "w+")) ) {
	 print("Can't open $filename");
	 exit;
}
else { 
	 # fill the file with form's data
	 fwrite ($ptr_fichier, "date_achat = " . "\"" . $_POST["date_achat"] . "\"\n" );
	 fwrite ($ptr_fichier, "garantie_constructeur = " . "\"" . $_POST["garantie_constructeur"] ."\"\n" );
	 fwrite ($ptr_fichier, "duree = " . "\"" . $_POST["duree"] . "\"\n" );
	 $com = $_POST["commentaires"];
	 $com = ereg_replace("&", "&amp;", $com);
	 $com = ereg_replace("<", "&lt;", $com);
	 $com = ereg_replace("\r", "<br>", $com);
	 $com= ereg_replace("\n","", $com);

	 fwrite ($ptr_fichier, "commentaires = " . "\"" . $com  . "\"\n"  );
	 fwrite ($ptr_fichier, "\n");

	 fclose($ptr_fichier);
}

#  rediret to general.cgi

$path = dirname($_SERVER['REQUEST_URI']);
# clean the path "/path/" is now "path"
$path = ereg_replace("/", "", $path);

# We have a pretty redirection function ! use it.
LIB_redirect("$path/general.cgi?mac=$mac");

?>
