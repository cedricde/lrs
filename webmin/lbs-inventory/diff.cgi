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
if (in_array("mac", array_flip($_GET)) ) $mac = $_GET["mac"];
else {
  	 echo "general: no MAC address available <br>";
	 exit();
}

$Exist_file_MAC = 0;
$Exist_file_CSV = 0;

$mac_filtered = filterMac($mac); # MAC address without ":"
$command = "ls $chemin_CSV/Net*/$mac_filtered";
exec($command, $result);
$fichier = $result[0];
if (file_exists($fichier)) {
  $Exist_file_MAC = 1; # file exist

  $nom_pc_csv = MacToName($mac) . ".csv.diff";

  # verify CSV file exist
  if(file_exists("$chemin_CSV/Results/$nom_pc_csv")) {
  	$path = "Results";
	$Exist_file_CSV = 1;
  }
  if (file_exists("$chemin_CSV/Softwares/$nom_pc_csv")) {
  	$path = "Softwares";
	$Exist_file_CSV = 1;
  }
}

$software = tmplInit(array("software_file" => "software.tpl"));

$software->set_block("software_file", "software", "software_block");
$software->set_block("software_file", "csv_file", "csv_file_block");




# display a CVS file link
  $software->set_var("CSV_CAT", "diff");
if ($Exist_file_CSV) { 
  $link = giveFileLink($nom_pc_csv, $path);
  $software->set_var("CSV_LINK", $link);
} 
else {
  $software->set_var("CSV_LINK", "N/A");
}
$software->parse("csv_file_block", "csv_file", true);


if ( ($Exist_file_MAC) && ($Exist_file_CSV) ) { # if file exist : open it
  # carateres numbers of the CSV file
  $size_software = size_CSV("$chemin_CSV/$path/$nom_pc_csv");

     # line numbers in the CSV file
     $nb_ligne_software_file = nb_lign("$chemin_CSV/$path/$nom_pc_csv");

     $software_csv = fopen("$chemin_CSV/$path/$nom_pc_csv", "r") or die("software.cgi: can't open $chemin_CSV/$path/$nom_pc_csv");

     # generate the successive lines for each type of network present
     $nb_ligne = 0;
     for ($nb_ligne; $nb_ligne < $nb_ligne_software_file; $nb_ligne++) {
      $table_software_csv = fgetcsv($software_csv, $size_software, ";");

      $table_results[$nb_ligne]["File_Name"] = IsEmpty($table_software_csv[3], "N/A");
      $table_results[$nb_ligne]["Application"]  = IsEmpty($table_software_csv[6],"N/A");
      $table_results[$nb_ligne]["Vendor"] = IsEmpty($table_software_csv[5], "N/A");
      $table_results[$nb_ligne]["File_Version"] = IsEmpty($table_software_csv[8], "N/A");
      $table_results[$nb_ligne]["Size"] = IsEmpty($table_software_csv[4], "N/A");
      $table_results[$nb_ligne]["Path"] = IsEmpty($table_software_csv[2], "N/A");
      $table_results[$nb_ligne]["Type"] = IsEmpty($table_software_csv[7], "N/A");
   } 


   # sort the tab before completing the php page 
   $critere = $_GET["SortBy"];
   $table_results = insert_sort2($table_results,$critere); 

   $i = 0;
   for ($i; $i<sizeof($table_results); $i++) {
      $Total_Size += $table_results[$i]["Size"];
      $color = class_couleur($i); 
      $software->set_var("SOFTWARE_BGCOLOR", $color);

      # define variables or loop $i
      $software->set_var(array("APPLICATION" => $table_results[$i]["Application"],
 				"VENDOR" => $table_results[$i]["Vendor"],
				"FILE_NAME" => $table_results[$i]["File_Name"],
				"FILE_VERSION" => $table_results[$i]["File_Version"],
				"SIZE" => Convert($table_results[$i]["Size"], 1),
				"PATH" => eregi_replace("[\]", "\ ", $table_results[$i]["Path"])));


      $software->parse("software_block", "software", true);
    }

   $Total_Size = Convert($Total_Size, 1);

   $software->set_block("software_file", "summary", "summary_block");
   $software->set_var(array("NUMBER_APPLICATION" => $i,
			"DISK_SPACE_USED" => $Total_Size));
   $software->parse("summary_block", "summary", true);

}
else { # if file doesn't exist
   $color = class_couleur(0); 
   $software->set_var("SOFTWARE_BGCOLOR", $color);

   $software->set_var(array("APPLICATION" => "N/A",
 				"VENDOR" => "N/A",
				"FILE_NAME" => "N/A",
				"FILE_VERSION" => "N/A",
				"SIZE" => "N/A",
				"PATH" => "N/A"));
   $software->parse("software_block", "software", true);

   $software->set_block("software_file", "summary", "summary_block");
   $software->set_var(array("NUMBER_APPLICATION" => "0",
			"DISK_SPACE_USED" => "0"));
   $software->parse("summary_block", "summary", true);

}

	# header
	echo perl_exec("./lbs_header.cgi", array("inventory diffs", $text{'index_title'}, "software"));
	
	# main
	$software->pparse("out", "software_file");
	
	# footer
	echo perl_exec("./lbs_footer.cgi");
?>


