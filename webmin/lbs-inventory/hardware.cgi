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

$hardware = tmplInit(array("hardware_file" => "hardware.tpl"));

$hardware->set_block("hardware_file", "processeur", "processeur_block");
$hardware->set_block("hardware_file", "cpu", "cpu_block");

$hardware->set_block("hardware_file", "vide", "vide_block");
$hardware->set_block("hardware_file", "csv_file", "csv_file_block");

$hardware->set_block("hardware_file", "memory", "memory_block");
$hardware->set_block("hardware_file", "slots", "slots_block");
$hardware->set_block("hardware_file", "swap", "swap_block");

$hardware->set_block("hardware_file", "vga", "vga_block");
$hardware->set_block("hardware_file", "sound", "sound_block");

$hardware->set_block("hardware_file", "pci", "pci_block");
$hardware->set_block("hardware_file", "pcibus", "pcibus_block");

$hardware->set_block("hardware_file", "no_lbs", "no_lbs_block");
$hardware->set_block("hardware_file", "lbs", "lbs_block");

##################
#    Ini File    #
##################

if (file_exists("$chemin_LBS/$mac_filtered" . ".ini")) $tab = AnalyzeIniFile("$chemin_LBS/$mac_filtered" . ".ini");



#################################
#    Filling Processor Block    #
#################################

if(isset($hash_machine['HARDWARE'])){
  $link = giveFileLink($nom_pc_csv, "Hardware");
  $hardware->set_var("CSV_LINK", $link); 
  $hardware->set_var("CSV_CAT", "Hardware");

  $nb_ligne = 0;
  for ($nb_ligne; $nb_ligne < count($hash_machine['HARDWARE']); $nb_ligne++){
      $hardware->set_var(array("CPU_NUMBER" => $nb_ligne+1,
                             "CPU_TYPE_PROC" =>  IsEmpty($hash_machine['HARDWARE'][$nb_ligne]['PROC_TYPE'], "N/A"),
                             "CPU_SPEED" => IsEmpty($hash_machine['HARDWARE'][$nb_ligne]['PROC_FREQ'], "N/A") ));

    if (isset($tab))
	$hardware->set_var("CPU_VENDOR", $tab["MAIN"]["cpuvendor"]);
      else 	$hardware->set_var("CPU_VENDOR", "N/A");
      $hardware->parse("processeur_block", "processeur", true);
    } # end for
}
else { # file doesn't exist
  $hardware->set_var("CSV_LINK", "N/A");
   $hardware->set_var("CSV_CAT", "Hardware");
  if (isset($tab)){
    $hardware->set_var(array("CPU_NUMBER" => "N/A",
			     "CPU_TYPE_PROC" => $tab["MAIN"]["model"],
			     "CPU_SPEED" => "~".round($tab["MAIN"]["freq"])." MHz",
                             "CPU_VENDOR"=> $tab["MAIN"]["cpuvendor"] ));
    
  } 
  else {
    $hardware->set_var(array("CPU_NUMBER" => "N/A",
			     "CPU_TYPE_PROC" => "N/A",
                              "CPU_SPEED" =>"N/A" ));

    $hardware->set_var("CPU_VENDOR", "N/A");
  }
  $hardware->parse("processeur_block", "processeur", true);

} # end else

$hardware->set_var(array("NUMBER_OF_CPU" => IsEmpty($hash_machine['HARDWARE'][0]['PROC_NB'], "N/A") ));

$hardware->parse("cpu_block", "cpu", true);

$hardware->parse("csv_file_block", "csv_file", true);



##############################
#    Filling Memory Block    #
##############################

if(isset($hash_machine['SLOTS'])){
    $link = giveFileLink($nom_pc_csv, "Slots");
    $hardware->set_var("CSV_LINK", $link);
    $hardware->set_var("CSV_CAT", "Slots");
    $hardware->parse("csv_file_block", "csv_file", true);
}
#else  $hardware->parse("csv_file_block", "csv_file", true);

$hardware->set_var(array("EMPTY_SLOTS" => IsEmpty("", "N/A"),
                         "TOTAL_SLOTS" => IsEmpty ("", "N/A"),
			 "TOTAL_MEM"   => IsEmpty(IsEmpty($hash_machine['HARDWARE'][0]['RAM'], round($tab["MAIN"]["totalmem"]/1024)),  "N/A")
			 ));
$hardware->parse("memory_block", "memory", true);


  
###########################
#    Filling RAM Block    #
###########################

if(isset($hash_machine['MEMORIES'])){
    $link = giveFileLink($nom_pc_csv, "Memories");
    $hardware->set_var("CSV_LINK", $link); 
    $hardware->set_var("CSV_CAT", "Memories");
    $hardware->parse("csv_file_block", "csv_file", true);
}
#else  $hardware->parse("csv_file_block", "vide");

if(isset($hash_machine['MEMORIES'])){
  $nb_ligne = 0;
  for($nb_ligne; $nb_ligne < count($hash_machine['MEMORIES']); $nb_ligne++){
    $hardware->set_var(array("TOTAL_RAM" => IsEmpty(IsEmpty($hash_machine['HARDWARE'][0]['RAM'], round($tab["MAIN"]["totalmem"]/1024)),  "N/A"),
                             "TYPE_RAM"  => IsEmpty($hash_machine['MEMORIES'][$nb_ligne]['TYPE'], "N/A"),
                             "CAPACITY"  => IsEmpty($hash_machine['MEMORIES'][$nb_ligne]['SIZE'], "N/A"),
                             "FREQ"      => IsEmpty($hash_machine['MEMORIES'][$nb_ligne]['FREQ'], "N/A"),
                             "SLOT_NUMBER" => IsEmpty($hash_machine['MEMORIES'][$nb_ligne]['NB_SLOTS'], "N/A") ));
    $hardware->parse("slots_block", "slots", true);
  }
}
else $hardware->parse("slots_block", "vide");



############################
#    Filling SWAP Block    #
############################

if(isset($hash_machine['HARDWARE'])){
    $hardware->set_var("SWAP_SIZE", IsEmpty($hash_machine['HARDWARE'][0]['SWAP'], "N/A"));
    $hardware->parse("swap_block", "swap", true);
} 
else $hardware->parse("swap_block", "vide");



###########################
#    Filling VGA Block    #
###########################

if(isset($hash_machine['VIDEOS'])){
   if(file_exists("$chemin_CSV/Videos/$nom_pc_csv")) $link = giveFileLink($nom_pc_csv, "Videos");
   if(file_exists("$chemin_CSV/Graphics/$nom_pc_csv")) $link = giveFileLink($nom_pc_csv, "Graphics");
    $hardware->set_var("CSV_LINK", $link); 
    $hardware->set_var("CSV_CAT", "Videos");
    $hardware->parse("csv_file_block", "csv_file", true);
}
//else  $hardware->parse("csv_file_block", "vide");

// defaults
$hardware->set_var(
		   array(
			 "CG_CHIPSET" => "N/A", 
			 "CG_DESCRIPTION" => "N/A", 
			 "CG_MEMORY" => "N/A",
			 "CG_VENDOR" => "N/A",
			 "CG_RESOLUTION" => "N/A"
			 )
		   );

// OCS informations
if(isset($hash_machine['VIDEOS'])){
  $nb_ligne = 0;
  for ($nb_ligne; $nb_ligne < count($hash_machine['VIDEOS']); $nb_ligne++){
    $hardware->set_var(array("CG_CHIPSET" => IsEmpty($hash_machine['VIDEOS'][$nb_ligne]['CHIP'], "N/A"), 
			     "CG_DESCRIPTION" => IsEmpty($hash_machine['VIDEOS'][$nb_ligne]['MODEL'], "N/A"), 
			     "CG_MEMORY" => IsEmpty($hash_machine['VIDEOS'][$nb_ligne]['VRAM_SIZE'], "N/A"), 
			     "CG_VENDOR" => IsEmpty($tab["PCI"][$key]["vendor"], "N/A"),
			     "CG_RESOLUTION" => IsEmpty($hash_machine['VIDEOS'][$nb_ligne]['RESOLUTION'], "N/A")));
    
  }
    }

// LRS chipset informations
if(isset($tab['PCI']) or isset($hash_machine['VIDEOS'])){
  if (isset($tab['PCI'])){
    $trouve = 0;
    foreach($tab["PCI"] as $key => $value) {
      if (eregi("Display control", $value["class"])) {
	$trouve = 1;
	break;
      }
    }

    if ($trouve) {
      $hardware->set_var(array(
			       "CG_CHIPSET" => IsEmpty($tab['PCI'][$key]['device'], "N/A"), 
			       "CG_VENDOR" => IsEmpty($tab["PCI"][$key]["vendor"],"N/A")
			       )
			 );
    }
  } 
}

$hardware->parse("vga_block", "vga", true);


#############################
#    Filling Sound Block    #
#############################
	       
if(isset($hash_machine['SOUND'])){
      $link = giveFileLink($nom_pc_csv, "Sound");
      $hardware->set_var("CSV_LINK", $link);
      $hardware->set_var("CSV_CAT", "Sound");
      $hardware->parse("csv_file_block", "csv_file", true);
}
#else  $hardware->parse("csv_file_block", "vide");
	   
if(isset($hash_machine['SOUND'])){
# To be filles once the informations are known
  $nb_ligne = 0;
    for($nb_ligne; $nb_ligne < count($hash_machine['SOUND']); $nb_ligne++){
        $hardware->set_var(array("SLOT_NUMBER" => IsEmpty($hash_machine['MEMORIES'][$nb_ligne]['NB_SLOTS'], "N/A") )); # to be modified
        $hardware->parse("sound_block", "sound", true);
    }
}
else $hardware->parse("sound_block", "vide");
       
       

############################
#    Filling PCI Blocks    #
############################

if(isset($tab['PCI'])){
  foreach($tab["PCI"] as $key => $value) {
    if (!eregi("Display control", $value["class"])) {
      $usb_rowspan++;
      $hardware->set_var(array("PCIBUS_CHIPSET" => IsEmpty($value["device"], "N/A" ),
			       "PCIBUS_VENDOR"  => IsEmpty($value["vendor"], "N/A" ), 
			       "PCIBUS_CLASS"   => IsEmpty($value["class"], "N/A")));
    
      $hardware->parse("pcibus_block", "pcibus", true);
    }
  } # fin foreach
}
else $hardware->parse("pcibus_block", "vide");

       
	
##########################################
#    Filling PCI/AGP/ISA availibility    # 
##########################################

if (isset($hash_machine['SLOTS'])){
 	$nb_ligne = 0;
	for($nb_ligne; $nb_ligne < count($hash_machine['SLOTS']); $nb_ligne++){
	   $hardware->set_var(array("PCI_TYPE" => IsEmpty($hash_machine['SLOTS'][$nb_ligne]['PORT_TYPE'], "N/A"),
	   			    "PCI_AVAILABILITY" => IsEmpty($hash_machine['SLOTS'][$nb_ligne]['AVAILABILITY'], "N/A"),
				    "PCI_STATE" => IsEmpty($hash_machine['SLOTS'][$nb_ligne]['STATE'], "N/A") ));
	   $hardware->parse("pci_block", "pci", true);
	}
}
else  $hardware->parse("pci_block", "vide");


       
############################
#    In case of no info    #
############################

if (!isset($hash_machine) and !isset($tab)) {
  $hardware->parse("vide_block", "vide"); 
	
  $hardware->parse("lbs_block", "vide");
	 
	  $hardware->parse("no_lbs_block", "no_lbs", true);
}
else $hardware->parse("no_lbs_block", "vide");



######################
#    Printing all    #
######################
		
$hardware->parse("vide_block", "vide");

echo perl_exec("./lbs_header.cgi", array("inventory hardware", $text{'index_title'}, "hardware"));

$hardware->pparse("out", "hardware_file");
	
echo perl_exec("./lbs_footer.cgi", array("2"));
?>
