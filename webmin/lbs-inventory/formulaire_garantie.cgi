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
if (in_array("mac", array_flip($_GET)) ) $mac = $_GET["mac"];
else {
  	 echo "general: no address MAC available <br>";
	 exit();
}

# create the template
$form = tmplInit(array("formulaire" => "formulaire_garantie.tpl"));

# set the block
$form->set_block("formulaire", "initialisation", "initialisation_block");

#OPTIONS: give the MAC address
$form->set_block("formulaire", "options", "options_block");
$form->set_var("OPTIONS", "?mac=".$mac);
$form->parse("options_block", "options",true);

# create the name file
$filename = "$chemin_CSV/Info/Garantie/".$mac."_garantie.ini";

# check if the file exist
if (file_exists($filename)) {
   # parsing file
   $ini_file = parse_ini_file($filename, true);
  
   # replace html carateres
   $com = $ini_file["commentaires"];
   $com = ereg_replace("&lt;", "<", $com);
   $com = ereg_replace("&amp;", "&", $com);
   $com = ereg_replace("<br>", "\n", $com);

   # set variables
   $form->set_var(array("INIT_DATE" => "\"" . $ini_file["date_achat"] . "\"",
			"INIT_CONSTRUCTEUR" => "\"". $ini_file["garantie_constructeur"] . "\"",
			"INIT_DUREE" => "\"" . $ini_file["duree"] . "\"",
			"INIT_COMMENTAIRE" => $com ) );
   
   # parse and display
   $form->parse("initialisation_block", "initialisation");

	echo perl_exec("lbs_header.cgi", array("inventory ", $text{'index_title'}, "index"));

	$form->pparse("out","formulaire");

	echo perl_exec("lbs_footer.cgi");
}
else {
   # File doesn't exist, set manualy the table
   $form->set_var(array("INIT_DATE" => "-",
			"INIT_CONSTRUCTEUR" => "-",
			"INIT_DUREE" => "-",
			"INIT_COMMENTAIRE" => "-" ) );
   $form->parse("initialisation_block", "initialisation");


	echo perl_exec("lbs_header.cgi", array("inventory ", $text{'index_title'}, "index"));

	$form->pparse("out","formulaire");

	echo perl_exec("lbs_footer.cgi");
	
}


?>
