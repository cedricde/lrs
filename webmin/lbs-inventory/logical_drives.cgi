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

# get the MAC address
if (in_array("mac", array_flip($_GET))) $mac = $_GET["mac"];
else {
  	 echo "general: no MAC address available <br>";
	 exit();
}

$mac_filtered = filterMac($mac); # MAC address without ":"
$command="ls $chemin_CSV/Net*/$mac_filtered";
exec($command, $result);

if (isset($result) && $result[0] != "") {
	$fichier = readlink($result[0]);
        $file = array_reverse(split('/', $fichier));
        $nom_pc_csv = $file[0];
	$hash_machine = HashComputer($nom_pc_csv);
}

##########################
#    Declaring Blocks    #
##########################

$ld = tmplInit(array("ld_file" => "logical_drives.tpl"));

$ld->set_block("ld_file", "vide", "vide_block");
$ld->set_block("ld_file", "device", "device_block");
$ld->set_block("ld_file", "drives", "drives_block");
$ld->set_block("ld_file", "hd_total", "hd_total_block");
$ld->set_block("ld_file", "csv_file", "csv_file_block");
$ld->set_block("ld_file", "designation", "designation_block");
$ld->set_block("ld_file", "partition", "partition_block");
$ld->set_block("ld_file", "disk", "disk_block");
$ld->set_block("ld_file", "no_lbs", "no_lbs_block");



########################
#    Filling Blocks    #
########################

if(isset($hash_machine['DRIVES'])){

    if (file_exists("$chemin_CSV/Drives/$nom_pc_csv")) $link = giveFileLink($nom_pc_csv, "Drives");
    if (file_exists("$chemin_CSV/LogicalDrives/$nom_pc_csv")) $link = giveFileLink($nom_pc_csv, "LogicalDrives");
    $ld->set_var("CSV_LINK", $link);

    # drives
    $nb_ligne_ld_file = count($hash_machine['DRIVES']) ;
    for ($nb_ligne=0; $nb_ligne < $nb_ligne_ld_file; $nb_ligne++) {
        $ld->set_var(array( "MOUNT_POINT"  => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['DRIVE_LETTER'], "N/A" ),
                            "FILE_SYSTEM"  => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['FILE_SYSTEM'], "N/A" ),
                            "TOTAL_SPACE"  => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['TOTAL_SPACE'], "N/A" ),
                            "FREE_SPACE"   => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['FREE_SPACE'], "N/A" ),
                            "FILE_NUMBER"  => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['NUMBER_FILES'], "N/A" ),
                            "VOLUME_NAME"  => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['VOLUME_NAME'], "N/A" ),
                            "DRIVE_TYPE"  => IsEmpty($hash_machine['DRIVES'][$nb_ligne]['DRIVE_TYPE'], "N/A" ),
    			    "MANUFACTURER" => IsEmpty("","N/A"),
                            "REFERENCE" => IsEmpty("", "N/A") ));

        if (ereg("-", $hash_machine['DRIVES'][$nb_ligne]['FREE_SPACE']) or ereg("-", $hash_machine['DRIVES'][$nb_ligne]['TOTAL_SPACE']) or $hash_machine['DRIVES'][$nb_ligne]['TOTAL_SPACE'] == '0' ) $percent = "-";
	else        $percent = round ( ($hash_machine['DRIVES'][$nb_ligne]['FREE_SPACE']*100)/$hash_machine['DRIVES'][$nb_ligne]['TOTAL_SPACE'] , 1) . "&nbsp;%";
    $ld->set_var("PERCENT_FREE", $percent);
	$ld->parse("device_block", "device",false);
	

  $ld->set_var(array("DRIVES_ROWSPAN" => sizeof($index),
	                   "TYPE_DRIVE"     => $type));
  $ld->parse("drives_block", "drives",true);
    }

    # summary 
    $total = 0;
    $free = 0;
    $files = 0;
    $percent_total = 0;

    for($num =0 ; $num < count($hash_machine['DRIVES']); $num++){
	if($hash_machine['DRIVES'][$num]['TOTAL_SPACE']!="-1" or $hash_machine['DRIVES'][$num]['FREE_SPACE'] != "-1"){
	    
            $total += $hash_machine['DRIVES'][$num]['TOTAL_SPACE'];
            $free  += $hash_machine['DRIVES'][$num]['FREE_SPACE'];
            $files += $hash_machine['DRIVES'][$num]['NUMBER_FILES'];
        }
    }

    $percent_total = round ( ($free*100)/$total , 1) . "&nbsp;%";

    # set all data
    $ld->set_var(array("TOTAL_SPACE"   => $total,
		"FREE_SPACE" => $free,
		"PERCENT_SPACE" => $percent_total,
		"NUMBER_FILES" => $files));
}
else {
  $ld->set_var( array( "MOUNT_POINT" => "N/A",
			"FILE_SYSTEM" => "N/A",
			"TOTAL_SPACE" => "N/A",
			"FREE_SPACE" => "N/A",
			"FILE_NUMBER" => "N/A",
			"VOLUME_NAME" => "N/A",
			"DRIVE_TYPE" => "N/A",
			"MANUFACTURER" => "N/A",
                         "REFERENCE"    => "N/A" ));
    $ld->parse("device_block", "device",true);
    $ld->parse("drives_block", "drives",true);

  $ld->set_var("PERCENT_FREE", "N/A");
  $ld->set_var(array("DRIVES_ROWSPAN" => "N/A",
                       "TYPE_DRIVE"     => "N/A"));

  $ld->set_var(array("TOTAL_SPACE" => "N/A",
		"FREE_SPACE" => "N/A",
		"PERCENT_SPACE" => "N/A",
		"NUMBER_FILES" => "N/A"));
    $ld->set_var("CSV_LINK", "N/A");

}

# Hard Drives
if(file_exists("$chemin_LBS/$mac_filtered".".ini")){
  $tab = AnalyzeIniFile("$chemin_LBS/$mac_filtered".".ini");
	 foreach($tab["DISK"] as $key => $value) {
		if ($value["PartNum"]){
		 # set all data with $tab which come the 'ini' file or LBS
		 $ld->set_var(array("DISK_NUMBER" => $key,
		 		"NAME"=> IsEmpty($value["name"],"-"),
		 		"CYL" => $value["cyl"],
				"HEAD" => $value["head"],
				"SECTOR" => $value["sector"],
				"CAPACITY" => $value["capacity"]));
		 # check partition exist
		 if ($value["PartNum"])	 {
		  $numpart=0; # iterator for partition
		  
		  foreach($value["PartNum"] as $number => $info) {
			 if (!$numpart) {# no partition
				 $ld->parse("designation_block", "designation");
				 $disk_rowspan++; # used to add a row which diplay partition's info
				 $numpart = $numpart + 1; 
				}
			else	 $ld->parse("designation_block", "vide"); # no partition : no block to write

			 $disk_rowspan++; # row chich display partition's info
			 
			 $ld->set_var(array("NUMBER" => $number,
					"TYPE" => HexaToType($info["Type"]),
					"LENGTH" => $info["Length"]));

			 $ld->parse("partition_block", "partition", true);
			} # end foreach
		 } # end if
		 else  $ld->parse("partition_block", "vide");

		 $ld->set_var("DISK_ROWSPAN", $disk_rowspan);
 		 $ld->parse("disk_block", "disk",true);
		 $ld->parse("vide_block", "vide");	 
		  }
		} # end foreach
	 $ld->parse("no_lbs_block", "vide");
}
else {

	 $ld->set_var("DOC_LINK", 'http://' . $_SERVER["SERVER_NAME"] . '/lbs/' . $gconfig['lang'] . '/HTML/chunked/ch06.html');
	 $ld->parse("no_lbs_block", "no_lbs", true);
	 $ld->parse("disk_block", "vide");
	 $ld->parse("vide_block", "vide");
} 



######################
#    Printing all    #
######################

$ld->parse("csv_file_block", "csv_file", true);
$ld->parse("hd_total_block", "hd_total", true);

# header
echo perl_exec("./lbs_header.cgi", array("inventory logical_drives", $text{'index_title'}, "logical_drives"));
	
# main
$ld->pparse("out", "ld_file");
	
# footer
echo perl_exec("./lbs_footer.cgi", array("2"));

?>
