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
         echo "network.cgi: no MAC address avaiable <br>";
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

$network = tmplInit(array("network_file" => "network.tpl"));
$network->set_block("network_file", "csv_file", "csv_file_block");
$network->set_block("network_file", "network", "network_block");
$network->set_block("network_file", "modem", "modem_block");
$network->set_block("network_file", "vide", "vide_block");

########################
#    Filling Blocks    #
########################

  if(isset($hash_machine['NET'])){

    # network file
    $nb_ligne = 0;
    for ($nb_ligne; $nb_ligne < count($hash_machine['NET']); $nb_ligne++) {
       $network->set_var(array("NETWORK_TYPE" => IsEmpty($hash_machine['NET'][$nb_ligne]['NETWORK_TYPE'], "N/A" ),
                               "NETWORK_DESCRIPTION" => IsEmpty($hash_machine['NET'][$nb_ligne]['CARD_TYPE'], "N/A" ),
                               "NETWORK_MAX_SPEED" => IsEmpty($hash_machine['NET'][$nb_ligne]['BANDWIDTH'], "N/A" ),
                               "NETWORK_MAC_ADDRESS" => IsEmpty($hash_machine['NET'][$nb_ligne]['ETHER'], "N/A" ),
                               "NETWORK_IP_ADDRESS" => IsEmpty($hash_machine['NET'][$nb_ligne]['IP'], "N/A" ),
                               "NETWORK_MASK" => IsEmpty($hash_machine['NET'][$nb_ligne]['BROADCAST'], "N/A" ),
                               "NETWORK_STATUS" => IsEmpty($hash_machine['NET'][$nb_ligne]['STATE'], "N/A" ),
                               "NETWORK_MIB_TYPE" => IsEmpty($hash_machine['NET'][$nb_ligne]['MIB'], "N/A" ),
                               "NETWORK_GW" => IsEmpty($hash_machine['NET'][$nb_ligne]['GW'], "N/A"),
                               "NETWORK_DNS" => IsEmpty($hash_machine['NET'][$nb_ligne]['DNS'], "N/A")));
      $network->parse("network_block", "network", true);
    }

    #csv
    $link = giveFileLink($nom_pc_csv, $net);
    $network->set_var("CSV_LINK", $link); 
    $network->set_var("CSV_CAT", "Network");

  }
  else{
  #netork file
    $network->set_var(array("NETWORK_TYPE" => "N/A",
			"NETWORK_DESCRIPTION" => "N/A",
			"NETWORK_MAX_SPEED" => "N/A",
			"NETWORK_MAC_ADDRESS" => "N/A",
			"NETWORK_IP_ADDRESS" => "N/A",
			"NETWORK_MASK" => "N/A",
			"NETWORK_STATUS" => "N/A",
                            "NETWORK_MIB_TYPE" => "N/A",
                            "NETWORK_GW" => "N/A",
                            "NETWORK_DNS" => "N/A" ));
    $network->parse("network_block", "network", "true");
    
    # csv
    $network->set_var("CSV_CAT", "Network");
    $network->set_var("CSV_LINK", "N/A"); 
    
   }

$network->parse("csv_file_block", "csv_file", true);

#############################
#    Filling Modem Block    #
#############################

if (isset($hash_machine['MODEMS'])){
	$link = giveFileLink($nom_pc_csv, "Modems");
	$network->set_var("CSV_LINK", $link);
	$network->set_var("CSV_CAT", "Modems");
	$network->parse("csv_file_block", "csv_file", true);

        $nb_ligne=0;
        for($nb_ligne; $nb_ligne < count($hash_machine['MODEMS']); $nb_ligne++){
                $network->set_var(array("VENDOR"  => IsEmpty($hash_machine['MODEMS'][$nb_ligne]['TYPE'], "N/A"),
                                        "EXP_DESC" => IsEmpty($hash_machine['MODEMS'][$nb_ligne]['STAMP'], "N/A"),
                                        "TYPE" => IsEmpty($hash_machine['MODEMS'][$nb_ligne]['MODEL'], "N/A")));
                $network->parse("modem_block", "modem", true);
        }
}
else $network->parse("modem_block", "vide");  # don't display the block



######################
#    Printing all    #
######################

$network->parse("vide_block", "vide");

# header
echo perl_exec("./lbs_header.cgi", array("inventory network", $text{'index_title'}, "network"));
	
# main
$network->pparse("out", "network_file");

# footer
echo perl_exec("./lbs_footer.cgi", array("2"));
?>
