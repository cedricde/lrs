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


include('lbs-inventory.php');

lib_init_config();

# Get the MAC address
if (in_array("mac", array_flip($_GET))) $mac = $_GET["mac"];
else {
  echo "general: no MAC address available <br>";
  exit();
}

if ($mac == "") { 
  echo "general: no MAC address available <br>"; 
  exit();
 }
	
$general = tmplInit(array("general" => "general.tpl"));

$mac_filtered = filterMac($mac); # MAC address without ":"
$command = "ls $chemin_CSV/Netw*/$mac_filtered";
exec($command, $result);

if (isset($result[0])) {
  $fichier = readlink($result[0]);
  $file = array_reverse(split('/', $fichier));
  $nom_pc_csv = $file[0];
  $hash_machine = HashComputer($nom_pc_csv);
}

setlocale(LC_TIME, "en");
if ($current_lang == "fr") setlocale(LC_TIME, "fr_FR");

$filestamp=get_OCS_timestamp($nom_pc_csv);
$general->set_var("LAST_DATE_OCS", $filestamp);
$filestamp=get_LRS_timestamp($mac_filtered);
$general->set_var("LAST_DATE_LRS", $filestamp);


if (file_exists("$chemin_LBS/$mac_filtered" . '.ini')) {
  $Exist_File_Ini = 1;		# 'ini' file exist
  $bootinfo = AnalyzeIniFile("$chemin_LBS/$mac_filtered" . ".ini");
}

##########################
#    Declaring Blocks    #
##########################

$general->set_block("general", "pc", "pc_block");
$general->set_block("general", "os", "os_block");
$general->set_block("general", "manufacturer", "manufacturer_block");
$general->set_block("general", "csv_file", "csv_file_block");
$general->set_block("general", "garantie", "garantie_block");
$general->set_block("general", "geo", "geo_block");
  
########################
#    Filling Blocks    #
########################

if (isset($hash_machine['HARDWARE'])) {

  if ($hash_machine['VERSION'] == "V3") {
    $version = array_reverse(split('\.', $hash_machine['HARDWARE'][0]['VERSION']));
    $build = "build " . $version[0];
    $version = $version[2] . '.' . $version[1] ;
  } else {
    $version = $hash_machine['HARDWARE'][0]['VERSION'];
    $build = $hash_machine['HARDWARE'][0]['BUILD'];
  }

  # block PC
  $general->set_var(array("PC_NAME" => IsEmpty($hash_machine['HARDWARE'][0]['COMPUTER_NAME'], "N/A"),
			  "PC_DESCRIPTION" => IsEmpty($hash_machine['BIOS'][0]['STAMP'], "N/A") ));
  
  $general->set_var(array( "OS_NAME" => IsEmpty($hash_machine['HARDWARE'][0]['OS'], "N/A"),
			   "OS_VERSION" => IsEmpty($version, "N/A"),
			   "OS_COMMENTS" => IsEmpty($build, "N/A")));

  # block manufacturer
  $general->set_var(array(  "MANUFACTURER_NAME" => IsEmpty($hash_machine['BIOS'][0]['BIOS_VENDOR'], "N/A"),
			    "MANUFACTURER_MODEL"=> IsEmpty($hash_machine['BIOS'][0]['CHIPSET'], "N/A"),
			    "MANUFACTURER_SERIAL_NUMBER" => IsEmpty($hash_machine['BIOS'][0]['SERIAL'], "N/A"),
			    "MANUFACTURER_TYPE" => IsEmpty($hash_machine['BIOS'][0]['TYPE_MACHINE'], "N/A"),
			    "MANUFACTURER_UUID" => "N/A",
			    ));

  # csv file
  $link = giveFileLink($nom_pc_csv, "BIOS");
  $general->set_var("CSV_LINK", $link); 

} else {
  initLbsConf($config['lbs_conf']);
  $names = etherLoad(1);

  $general->set_var(array("PC_NAME" => $names[$mac]["name"], 
			  "PC_DESCRIPTION" => "$mac"));
    
  $general->set_var(array( "OS_NAME" => "N/A", 
			   "OS_VERSION" => "N/A", 
			   "OS_COMMENTS" => "N/A" ));

  # block manufacturer

  $general->set_var(array(  "MANUFACTURER_NAME" => IsEmpty($hash_machine['BIOS'][0]['BIOS_VENDOR'], "N/A"), 
			    "MANUFACTURER_MODEL"=> IsEmpty($hash_machine['BIOS'][0]['CHIPSET'], "N/A"), 
			    "MANUFACTURER_SERIAL_NUMBER" => IsEmpty($hash_machine['BIOS'][0]['SERIAL'], "N/A"), 
			    "MANUFACTURER_TYPE" => IsEmpty($hash_machine['BIOS'][0]['TYPE_MACHINE'], "N/A"),
			    "MANUFACTURER_UUID" => "N/A",
			    ));

  # csv file
  $general->set_var("CSV_LINK", "N/A"); 

}

$general->set_var(array(  
			"BIOS_MANUFACTURER" => IsEmpty($hash_machine['BIOS'][0]['BIOS_VENDOR'], "N/A"),
			"BIOS_VERSION" => IsEmpty($hash_machine['BIOS'][0]['BIOS_VERSION'], "N/A"),
			"BIOS_DATE" => IsEmpty($hash_machine['BIOS'][0]['BIOS_DATE'], "N/A")
		       ));

if (isset($bootinfo)) 
  {
    $system = $bootinfo["MAIN"]["system"];
    list($man, $prodname, $ver, $sn, $uuid) = explode("|", $system);
    $general->set_var(array(  
			    "MANUFACTURER_NAME" => IsEmpty($man, "N/A"),
			    "MANUFACTURER_MODEL"=> IsEmpty("$prodname $ver", "N/A"),
			    "MANUFACTURER_SERIAL_NUMBER" => IsEmpty($sn, "N/A"),
			    "MANUFACTURER_UUID" => IsEmpty($uuid, "N/A"),
			   ));

    list($man, $ver, $date) = explode("|", $bootinfo["MAIN"]["bios"]);
    $general->set_var(array(  
			    "BIOS_MANUFACTURER" => IsEmpty($man, "N/A"),
			    "BIOS_VERSION"=> IsEmpty("$ver", "N/A"),
			    "BIOS_DATE" => IsEmpty($date, "N/A"),
			   ));
			    
  }


################################
#      Informations about      #
#     Warranty & Geographie    #
################################

### Warranty ###

$fichier_garantie = "$chemin_CSV/Info/Garantie/".$mac."_garantie.ini";

if (file_exists($fichier_garantie)) {
  if (!$ptr_fichier = fopen($fichier_garantie, "r")) {
    # can't open
    $general->set_var(array("GARANTIE_OPTIONS" => "?mac=" . $mac,
			    "GARANTIE_DATE_ACHAT" =>  "N/A",
			    "GARANTIE_CONSTRUCTEUR" => "N/A",
			    "GARANTIE_DUREE" => "N/A",
			    "GARANTIE_COMMENTAIRES" => "N/A" ) ) ;
  } else {
    // yes !! it's open
      # parse file
      $ini_file = parse_ini_file($fichier_garantie, true);
    $general->set_var(array("GARANTIE_OPTIONS" => "?mac=" . $mac,
			    "GARANTIE_DATE_ACHAT" =>  IsEmpty($ini_file["date_achat"], "-"),
			    "GARANTIE_CONSTRUCTEUR" => IsEmpty($ini_file["garantie_constructeur"], "-"),
			    "GARANTIE_DUREE" => IsEmpty($ini_file["duree"],"-"),
			    "GARANTIE_COMMENTAIRES" => IsEmpty($ini_file["commentaires"], "-") ) ) ;
  }
} else {
  # fill with 'N/A' because file doesn't exist
  $general->set_var(array("GARANTIE_OPTIONS" => "?mac=" . $mac,
			  "GARANTIE_DATE_ACHAT" =>  "N/A",
			  "GARANTIE_CONSTRUCTEUR" => "N/A",
			  "GARANTIE_DUREE" => "N/A",
			  "GARANTIE_COMMENTAIRES" => "N/A" ) ) ;
}


### Geo ###

$fichier_site = "$chemin_CSV/Info/Situation_Geo/".$mac."_site_geo.ini";
if ( file_exists($fichier_site) ) {
  if (! $ptr_fichier = fopen($fichier_site, "r") ) {
    # can't open.. sorry
    $general->set_var(array("GEO_OPTIONS" => "?mac=" . $mac,
			    "SITUATION_GEOGRAPHIQUE" =>  "-",
			    "NUMERO_TEL_PROCHE" => "-"  )) ;
  } else {
    // yes !! it's open !
      # parsing file
      $ini_file = parse_ini_file($fichier_site, true);
    $general->set_var(array("GEO_OPTIONS" => "?mac=" . $mac,
			    "SITUATION_GEOGRAPHIQUE" =>  IsEmpty($ini_file["situation_geographique"], "-"),
			    "NUMERO_TEL_PROCHE" => IsEmpty($ini_file["telephone_proche"], "-") ) ) ;
  }
} else {			# le fichier n'existe pas, afficher "N/A"
  $general->set_var(array("GEO_OPTIONS" => "?mac=" . $mac,
			  "SITUATION_GEOGRAPHIQUE" =>  "N/A",
			  "NUMERO_TEL_PROCHE" => "N/A"  )) ;
}
  
######################
#    Printing all    #
######################


$general->parse("pc_block", "pc", true);
$general->parse("manufacturer_block", "manufacturer", true);
$general->parse("garantie_block", "garantie", true);
$general->parse("geo_block", "geo", true);
$general->parse("csv_file_block", "csv_file", true);
$general->parse("os_block", "os", true);

# diplay

# header
echo perl_exec("lbs_header.cgi", array("inventory general", $text{'index_title'}, "general"));
	
# main
$general->pparse("out","general");
	
# footer
echo perl_exec("./lbs_footer.cgi", array("2"));
?>
