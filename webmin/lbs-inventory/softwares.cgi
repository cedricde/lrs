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
  echo "network.cgi: no MAC address available <br>";
	 exit();
}

$mac_filtered = filterMac($mac); # MAC address without ":"
$command="ls $chemin_CSV/Net*/$mac_filtered";
exec($command, $result);

if (isset($result[0])) {
    $fichier=readlink($result[0]);
    $file = array_reverse(split('/', $fichier));
    $nom_pc_csv = $file[0];
    $net = $file[1];

    $hash_machine = HashComputer($nom_pc_csv);

}



##########################
#    Declaring Blocks    #
##########################

$software = tmplInit(array("software_file" => "software.tpl"));

$software->set_block("software_file", "software", "software_block");
$software->set_block("software_file", "csv_file", "csv_file_block");
$software->set_block("software_file", "summary", "summary_block");
$software->set_block("software_file", "vide", "vide_block");



################################
#    Filling Software Block    #
################################

if (isset($hash_machine['SOFTWARES'])){
	$nb_ligne = '0';
	$Total = '0';
	for($nb_ligne; $nb_ligne < count($hash_machine['SOFTWARES']); $nb_ligne++){
            $color = class_couleur($nb_ligne); 
	    $software->set_var("SOFTWARE_BGCOLOR",  $color);
		    
	    if (isset($hash_machine['SOFTWARES'][$nb_ligne]['SIZE'])) $Size = Convert($hash_machine['SOFTWARES'][$nb_ligne]['SIZE'],1);
            $software->set_var(array("APPLICATION" => IsEmpty($hash_machine['SOFTWARES'][$nb_ligne]["APPLICATION"], "N/A"), 
	    			     "SIZE" => IsEmpty($Size, "N/A"),
  	                             "VENDOR" => IsEmpty($hash_machine['SOFTWARES'][$nb_ligne]["COMPANY"], "N/A"),
	                             "FILE_NAME" => IsEmpty($hash_machine['SOFTWARES'][$nb_ligne]["PRODUCT_NAME"], "N/A"),
	                             "FILE_VERSION" => IsEmpty($hash_machine['SOFTWARES'][$nb_ligne]["PRODUCT_VERSION"], "N/A"),
	                             "PATH" => eregi_replace("[\]", "\ ", IsEmpty($hash_machine['SOFTWARES'][$nb_ligne]["PRODUCT_PATH"], "N/A"))));
	    if (isset( $hash_machine['SOFTWARES'][$nb_ligne]['SIZE'])) $Total = $Total + $hash_machine['SOFTWARES'][$nb_ligne]['SIZE'];
				     
	    $software->parse("software_block", "software", true);
	}
	if ($Total == '0') $Total = "";
	else $Total = Convert($Total, 1);
}
else $software->parse("software_block", "vide");



################################
#    Filling Software Block    #
################################

$software->set_var(array("NUMBER_APPLICATION" => IsEmpty($nb_ligne, "N/A"),
			 "DISK_SPACE_USED" => IsEmpty( $Total, "N/A") ));
$software->parse("summary_block", "summary", true);



###########################
#    Filling CSV block    #
###########################

$software->set_var("CSV_CAT", "Softwares");
$rep = "";
if(file_exists("$chemin_CSV/Softwares/$nom_pc_csv")) $rep = "Softwares";
if(file_exists("$chemin_CSV/Results/$nom_pc_csv")) $rep = "Results";
if ($rep != "") {
	$link =  giveFileLink($nom_pc_csv, "$rep");
	$software->set_var("CSV_LINK", IsEmpty($link, "N/A"));
}
else  $software->set_var("CSV_LINK", "N/A");



######################
#    Printing all    #
######################

$software->parse("csv_file_block", "csv_file", true);

$software->parse("vide_block", "vide");

echo perl_exec("./lbs_header.cgi", array("inventory software", $text{'index_title'}, "software"));
	
$software->pparse("out", "software_file");
	
# footer
echo perl_exec("./lbs_footer.cgi", array("2"));

?>
