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


# Get MAC address
if (in_array("mac", array_flip($_GET)) )
 	$mac = $_GET["mac"];
 else {
  	 echo "general: no MAC address available <br>";
	 exit();
	}

   $mac_filtered = filterMac($mac); # MAC address without ":"
   $command = "ls $chemin_CSV/Net*/$mac_filtered";
   exec($command, $result);

   if (isset($result[0])) {

           $fichier = readlink($result[0]);   	
           $file = array_reverse(split('/', $fichier));
           $nom_pc_csv = $file[0];
            
            $hash_machine = HashComputer($nom_pc_csv);
    }


##########################
#    Declaring Blocks    #
##########################

$devices = tmplInit(array("devices_file" => "external_devices.tpl"));

$devices->set_block("devices_file", "description_device", "description_device_block");
$devices->set_block("devices_file", "device", "device_block");
$devices->set_block("devices_file", "vide", "vide_block");
$devices->set_block("devices_file", "csv_file", "csv_file_block");
$devices->set_block("devices_file", "no_info_file", "info_file_block");
# V3
$devices->set_block("devices_file", "inputs_file", "inputs_file_block");
$devices->set_block("devices_file", "monitor_file", "monitor_file_block");

#################################
#    Filling Printer's Block    #
#################################

  if(isset($hash_machine['PRINTERS'])){

    # csv   
    $link = giveFileLink($nom_pc_csv, "Printers");
    $devices->set_var("CSV_LINK", $link); 
    $devices->set_var("CSV_CAT", "Printers");
    $devices->parse("csv_file_block", "csv_file", true);
 
    $nb_ligne=0;
    for ($nb_ligne; $nb_ligne < count($hash_machine['PRINTERS']); $nb_ligne++) {
    # define variables for loop $i
    $devices->set_var(array(
 			    "DEVICE_NAME" => IsEmpty($hash_machine['PRINTERS'][$nb_ligne]['NAME'], "N/A"),
			    "DEVICE_VENDOR" => "N/A",
                            "DEVICE_DRIVER"    => IsEmpty($hash_machine['PRINTERS'][$nb_ligne]['DRIVER'], "N/A"), 
			    "DEVICE_DRIVER_VERSION" => "N/A",
                            "DEVICE_PORT"      => IsEmpty($hash_machine['PRINTERS'][$nb_ligne]['PORT'], "N/A"),
			    "DEVICE_PATH"     => "N/A",
                            "DEVICE_STATE"     => "N/A" ));
    
    if (!$nb_ligne){ // first line : description
       $devices->parse("description_device_block", "description_device");
      }
    else {
       $devices->parse("description_device_block", "vide");
      }
    $devices->parse("device_block", "device", true);
   } # 'for'

  } # 'if'
  else {

    $devices->set_var("CSV_LINK", "N/A");
    $devices->set_var("CSV_CAT", "N/A");
    
  $devices->set_var(array("NUMBER_OF_DEVICES" => "N/A",
  			"DEVICE_VENDOR" => "N/A",
 			"DEVICE_NAME" => "N/A",
			"DEVICE_DRIVER" => "N/A",
			"DEVICE_DRIVER_VERSION" => "N/A",
			"DEVICE_PORT" => "N/A",
			"DEVICE_PATH" => "N/A",
			"DEVICE_STATE" => "N/A"));
  
    $devices->set_var(array("TYPE_DEVICE" => "No Device"));
  
  $devices->parse("description_device_block", "description_device");
  $devices->parse("device_block", "device");
  
  $devices->parse("info_file_block", "vide");
  $devices->parse("csv_file_block", "csv_file", true);
  }
  $devices->parse("info_file_block", "vide");

###############################
#    Filling Inputs' Block    #
###############################

if (isset($hash_machine['INPUTS'])){
    $link = giveFileLink($nom_pc_csv, "Inputs");
    $devices->set_var("CSV_LINK", $link); 
    $devices->set_var("CSV_CAT", "Inputs");
    $devices->parse("csv_file_block", "csv_file", true);

	$nb_ligne=0;
	for($nb_ligne; $nb_ligne < count($hash_machine['INPUTS']); $nb_ligne++){
		$devices->set_var(array("TYPE"      => IsEmpty($hash_machine['INPUTS'][$nb_ligne]['TYPE'], "N/A"),
					"VENDOR"    => IsEmpty($hash_machine['INPUTS'][$nb_ligne]['VENDOR'], "N/A"),
					"STD_DESC"  => IsEmpty($hash_machine['INPUTS'][$nb_ligne]['STD_DESC'], "N/A"),
					"EXP_DESC"  => IsEmpty($hash_machine['INPUTS'][$nb_ligne]['EXP_DESC'], "N/A"),
					"CSV_LINK"  => IsEmpty(giveFileLink($nom_pc_csv, 'Inputs'), "N/A"),
					"CONNECTOR" => IsEmpty($hash_machine['INPUTS'][$nb_ligne]['CONNECTOR'], "N/A") ));
		$devices->parse("inputs_file_block", "inputs_file", true);
	}
}
else $devices->parse("inputs_file_block", "vide");  # don't display the block

#################################
#    Filling Monitor's Block    #
#################################

if (isset($hash_machine['MONITORS'])){
    $link = giveFileLink($nom_pc_csv, "Monitors");
    $devices->set_var("CSV_LINK", $link); 
    $devices->set_var("CSV_CAT", "Monitors");
    $devices->parse("csv_file_block", "csv_file", true);
		
        $nb_ligne=0;
        for($nb_ligne; $nb_ligne < count($hash_machine['MONITORS']); $nb_ligne++){
                $devices->set_var(array("TYPE"  => IsEmpty($hash_machine['MONITORS'][$nb_ligne]['TYPE'], "N/A"),
					"STAMP" => IsEmpty($hash_machine['MONITORS'][$nb_ligne]['STAMP'], "N/A"),
                                        "MODEL" => IsEmpty($hash_machine['MONITORS'][$nb_ligne]['MODEL'], "N/A"),
					"CSV_LINK" => IsEmpty(giveFileLink($nom_pc_csv, 'Monitors'), "N/A"),
                                        "DESC"  => IsEmpty($hash_machine['MONITORS'][$nb_ligne]['DESC'], "N/A") ));
                $devices->parse("monitor_file_block", "monitor_file", true);
			
        }
}
else $devices->parse("monitor_file_block", "vide");  # don't display the block




######################
#    Printing all    #
######################

$devices->parse("vide_block", "vide");

# header
echo perl_exec("./lbs_header.cgi", array("inventory external_drives", $text{'index_title'}, "external_drives"));
	
# main
$devices->pparse("out", "devices_file");
	
# footer
echo perl_exec("./lbs_footer.cgi", array("2"));
?>
