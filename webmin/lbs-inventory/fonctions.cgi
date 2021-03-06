<?php
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


include_once("path.cgi");
include_once("site.cgi");

## display function
	function affichage($valeur){
		echo $valeur."<br>";
	}
## returns numbers of carateres in the CSV file, 0 if can't open file
function size_CSV($file){
 $size = 0;
 if ( file_exists($file) ) {
   if ( $f = fopen($file, "r") ) { 
	 while (!(feof($f))) {
	   fgetc($f);
	   $size++;
 	  }
 	 fclose($f);
	 return $size;
	}
   else return 0;
 }
 else return 0;
}

## return computer's name from a MAC adress
function MacToName($mac_address){
	$mac_address = filterMac($mac_address); // ADDED by P.D.

 	$file = "$GLOBALS[chemin_CSV]/Network/$mac_address";

	$size = size_CSV("$GLOBALS[chemin_CSV]/Network/$mac_address");
	
	$nb_lign = nb_lign($fichier);

	$f = fopen($file, "r") or die("fonction.cgi[MacToName]: can't open $file");

	for ($i=0; $i <$nb_lign; $i++)	{
		 $tab = fgetcsv($f, $size, ";");
		 $mac = eregi_replace(":","",$tab[5]);
		 if ($mac == $mac_address) {
		   fclode($f);
		   return $tab[0];
		 }
	}
	fclose($f);
}


## return numbers lign of a file
function nb_lign($file){
 if(file_exists($file)) {
  $table = file($file);
  return count($table);
 }
}

## This function is used to alternate a row color
# It takes the current lign number and return the correct color
function couleur($num_ligne){
 // Change it in the function to change all row color in the web page
 // #e2e2e2 = light gray
 // #e2d1f9 = light purple
 $color = ($num_ligne % 2) ? "#e2e2e2" : "#e2d1f9" ;
 return "\"" . $color . "\"";
}

## This function is usedd to alternate a row color
# It takes the current lign number and return the corret CSS class
function class_couleur($num_ligne){
 $color = ($num_ligne % 2) ? "fce6e0" : ""; # corporate back color
return $color;
}


## Analyse 'ini' file generated by LBS 
# It takes a 'ini' file path ; return sorted data struct
function AnalyzeIniFile($IniFile){

 # $tab is going to be arrange like this :
 # (MAIN.lowmem ---> 'value') will be :
 # (MAIN => lowmem => 'value')

 $conf = New ConfigFile("$IniFile");
 $tab= $conf->get_array();

 #$old_type ; keep the partition type
 #  final tab name : $tab_res
  foreach ( $tab as $key => $value) {
  $parts = explode(".", $key);
    switch ($parts[0])  {
   case "MAIN": # We are in the MAIN section of the file
  	$tab_res[$parts[0]][$parts[1]] = $value;
	break;
   default: # We are in the  PCI# or DISK# section of the file
  	if ( ereg("PCI[0-9]", $key) ) { # find name followed by a number
	 	 $sub_parts = split("PCI",$parts[0]);
	 	 $tab_res["PCI"][$sub_parts[1]][$parts[1]] = $value;
		}
  	else if (ereg("DISK[0-9]", $key)) { # don't do the test again, except some section are added
		 $sub_parts = split("DISK",$parts[0]);
		 if ( ereg("partlength", $parts[1]) ) {
			 $val_part = split("partlength", $parts[1]);
     			 $tab_res["DISK"][$sub_parts[1]]["PartNum"][$val_part[1]]["Part Number"] = $old_number;
			 $tab_res["DISK"][$sub_parts[1]]["PartNum"][$val_part[1]]["Type"] = $old_type;
			 $tab_res["DISK"][$sub_parts[1]]["PartNum"][$val_part[1]]["Length"] = $value;
			}
		 else	{
		 	 if (ereg("parttype", $parts[1])) $old_type = $value;
				else
			 	if (ereg("partnum", $parts[1])) $old_number = $value;
				else $tab_res["DISK"][$sub_parts[1]][$parts[1]] = $value;
			}
		} # fin if partlength
  } # end switch parts[0]
 } # end foreach

 return $tab_res;
}




## sort function, ONLY for software, using one input sort data
function insert_sort($tab, $col_name){
 if ($col_name != "Size") {
	  for ($i=1; $i<sizeof($tab); $i++) {
	 	 $v = $tab[$i];
	 	 $j = $i;
         	 while ( ($j>0) && (strcasecmp($tab[$j-1][$col_name], $v[$col_name]) >0) ) {
		  	 $tab[$j] = $tab[$j-1];
		  	 $j = $j-1;
			}
          	 $tab[$j] = $v;
		}
	}
 else 	{
	 for ($i=1; $i<sizeof($tab); $i++) {
	 	 $v = $tab[$i];
	 	 $j = $i;
         	 while ( ($j>0) && ($tab[$j-1] [$col_name] > $v[$col_name]) ) {
		  	 $tab[$j] = $tab[$j-1];
		  	 $j = $j-1;
			}
          	 $tab[$j] = $v;
		}
	}

  	return $tab;
}


## sort function, ONLY for software, use 3 input sort data
function insert_sort2($tab, $critere) {
 if ($critere == "") {
   for ($i=1; $i<sizeof($tab); $i++) {
	   $v = $tab[$i];
	   $j = $i;
	   
	   # use the first input sort data
	   while ( ($j>0) && (strcasecmp($tab[$j-1]["Application"], $v["Application"]) >0)  ) {
		 $tab[$j] = $tab[$j-1];
		 $j = $j-1;
		}
           
	   # use the second input sort data
	   while ( ($j>0) 
	         && ( (strcasecmp($tab[$j-1]["Application"], $v["Application"]) >0) or (strcasecmp($tab[$j-1]["Application"], $v["Application"])==0) )
	   && (strcasecmp($tab[$j-1]["Path"], $v["Path"]) >0)  )	{
		 $tab[$j] = $tab[$j-1];
		 $j = $j-1;
		}
	  
	  # use the third input sort data
	  while ( ($j>0) 
                 && ( (strcasecmp($tab[$j-1]["Application"], $v["Application"]) >0)  or (strcasecmp($tab[$j-1]["Application"], $v["Application"])==0) )
		 && ( (strcasecmp($tab[$j-1]["Path"], $v["Path"]) >0) or (strcasecmp($tab[$j-1]["Path"], $v["Path"])==0) )	
		 && (strcasecmp($tab[$j-1]["File_Name"], $v["File_Name"]) >0) ) {
		 $tab[$j] = $tab[$j-1];
		 $j = $j-1;
		}
	  $tab[$j] = $v;
	}
  return $tab;
 }
 else return insert_sort($tab, $critere);
} 

## convert in a multiple of bytes
function Convert($size, $precision){
 if ($size >1024*1024 ) $size = round( ( ($size / 1024) / 1024), $precision) . "&nbsp;MB";
 else if ($size > 1024) $size = round( ($size / 1024), $precision) . "&nbsp;kB";
	else $size = $size . "&nbsp;b";

 return $size;
}





## Give a partition type with an hexadecimal type
function HexaToType($hexa){

 $parttype["0x0"]="Empty";
 $parttype["0x1"]="FAT12";
 $parttype["0x2"]="XENIX root";
 $parttype["0x3"]="XENIX usr";
 $parttype["0x4"]="FAT16 <32M";
 $parttype["0x5"]="Extended";
 $parttype["0x6"]="FAT16"; 
 $parttype["0x7"]="HPFS/NTFS";
 $parttype["0x8"]="AIX";
 $parttype["0x9"]="AIX bootable";
 $parttype["0xa"]="OS/2 Boot Manager";
 $parttype["0xb"]="Win95 FAT32";
 $parttype["0xc"]="Win95 FAT32 (LBA)";
 $parttype["0xe"]="Win95 FAT16 (LBA)";
 $parttype["0xf"]="Win95 Ext'd (LBA)";
 $parttype["0x10"]="OPUS";
 $parttype["0x11"]="Hidden FAT12";
 $parttype["0x12"]="Compaq diagnostics";
 $parttype["0x14"]="Hidden FAT16 <32M";
 $parttype["0x16"]="Hidden FAT16";
 $parttype["0x17"]="Hidden HPFS/NTFS";
 $parttype["0x18"]="AST SmartSleep";
 $parttype["0x1b"]="Hidden Win95 FAT32";
 $parttype["0x1c"]="Hidden Win95 FAT32 (LBA)"; 
 $parttype["0x1e"]="Hidden Win95 FAT16 (LBA)";
 $parttype["0x24"]="NEC DOS";
 $parttype["0x39"]="Plan 9";
 $parttype["0x3c"]="PartitionMagic recovery";
 $parttype["0x40"]="Venix 80286";
 $parttype["0x41"]="PPC PReP Boot";
 $parttype["0x42"]="SFS";
 $parttype["0x4d"]="QNX4.x";
 $parttype["0x4e"]="QNX4.x 2nd part";
 $parttype["0x4f"]="QNX4.x 3rd part";
 $parttype["0x50"]="OnTrack DM";
 $parttype["0x51"]="OnTrack DM6 Aux1";
 $parttype["0x52"]="CP/M";
 $parttype["0x53"]="OnTrack DM6 Aux3";
 $parttype["0x54"]="OnTrackDM6";
 $parttype["0x55"]="EZ-Drive";
 $parttype["0x56"]="Golden Bow";
 $parttype["0x5c"]="Priam Edisk";
 $parttype["0x61"]="SpeedStor";
 $parttype["0x63"]="GNU HURD or SysV";
 $parttype["0x64"]="Novell Netware 286";
 $parttype["0x65"]="Novell Netware 386";
 $parttype["0x70"]="DiskSecure Multi-Boot";
 $parttype["0x75"]="PC/IX";
 $parttype["0x80"]="Old Minix";
 $parttype["0x81"]="Minix / old Linux";
 $parttype["0x82"]="Linux swap";
 $parttype["0x83"]="Linux";
 $parttype["0x84"]="OS/2 hidden C: drive";
 $parttype["0x85"]="Linux extended";
 $parttype["0x86"]="NTFS volume set";
 $parttype["0x87"]="NTFS volume set";
 $parttype["0x8e"]="Linux LVM";
 $parttype["0x93"]="Amoeba";
 $parttype["0x94"]="Amoeba BBT";
 $parttype["0x9f"]="BSD/OS";
 $parttype["0xa0"]="IBM Thinkpad hibernation";
 $parttype["0xa5"]="FreeBSD";
 $parttype["0xa6"]="OpenBSD";
 $parttype["0xa7"]="NeXTSTEP";
 $parttype["0xa9"]="NetBSD";
 $parttype["0xb7"]="BSDI fs";
 $parttype["0xb8"]="BSDI swap";
 $parttype["0xbb"]="Boot Wizard hidden";
 $parttype["0xc1"]="DRDOS/sec (FAT-12)";
 $parttype["0xc4"]="DRDOS/sec (FAT-16 < 32M)";
 $parttype["0xc6"]="DRDOS/sec (FAT-16)";
 $parttype["0xc7"]="Syrinx";
 $parttype["0xda"]="Non-FS data";
 $parttype["0xdb"]="CP/M / CTOS / ...";
 $parttype["0xde"]="Dell Utility";
 $parttype["0xdf"]="BootIt";
 $parttype["0xe1"]="DOS access";
 $parttype["0xe3"]="DOS R/O";
 $parttype["0xe4"]="SpeedStor";
 $parttype["0xeb"]="BeOS fs";
 $parttype["0xee"]="EFI GPT";
 $parttype["0xef"]="EFI (FAT-12/16/32)";
 $parttype["0xf0"]="Linux/PA-RISC boot";
 $parttype["0xf1"]="SpeedStor";
 $parttype["0xf4"]="SpeedStor";
 $parttype["0xf2"]="DOS secondary";
 $parttype["0xfd"]="Linux raid autodetect";
 $parttype["0xfe"]="LANstep";
 $parttype["0xff"]="BBT";
 
 return IsEmpty($parttype["0x".strtolower($hexa)],"N/A");
}


## Check $string, if empty, return $none, else return $string
function IsEmpty ($string, $none) {
	if (!isset($string) or $string == "" or preg_match("/^ *$/", $string)) return $none;
	else	return $string;
}




## explorer a directory and its subdirectories
# return a tab from a given directory
function make_menu($path){
  $ptr_dir = opendir($path);

  while ( $file = readdir($ptr_dir) ) {
	if ( ($file!=".") && ($file!="..") && ($file != ".svn") && ($file != "CVS") ) {
	 	 if ( is_dir("$path/$file") ){
			 $menu[basename("$path/$file")] = make_menu("$path/$file", $count);
			}
	 	 else	{
		 	 $tab = parse_ini_file("$path/$file");
		 	 $menu[basename("$path/$file")] = $tab;
			}
		}
	}
  closedir($ptr_dir);
  return $menu;
}


## give the position of a menu entry
# return the position of $case given in 'description.ini'
function Position_Menu($case){
  return $case["description.ini"]["position_number"];
}


## sort menu entry
function MenuSort($tab){
 for ($i=2; $i<sizeof($tab); $i++) {
	 	 $v = $tab[$i];
	 	 $j = $i;
         	 while ( (Position_Menu($tab[$j-1])> Position_Menu($v)) && ($j>-1) ){
		  	 $tab[$j] = $tab[$j-1];
		  	 $j = $j-1;
			}
          	 $tab[$j] = $v;
		}
 return $tab;
}


## clear hash table
function Clear_Table($tab) {
 $tab_res = array();
 foreach($tab as $key => $value) $tab_res = $value;
 return $tab_res;
}


## sort function according to the position
# It Takes a menu table; return a sorted table according to the menu entry position
function PositionSort($table){
 $tab_res = array();
 foreach ($table as $key => $value)
 if ($key != "description.ini") $tab_res[Position_Menu($value)][$key] = $value;

 for($i=0; $i<sizeof($tab_res);$i++) $tab_final[] = $tab_res[$i+1];
 return $tab_final;
}

## Create a table for a computer
function HashComputer($computer){
# its name is $nom_pc_csv in all.cgi
  $command = "ls $GLOBALS[chemin_CSV]/*/" .$computer ;
  exec($command, $list_file);
 
  $command = "ls $GLOBALS[chemin_CSV]/Net*/$computer ";
  exec($command, $result);

  if($result[0] != ""){  
    $net_file = file($result[0]);
    $VERSION = 'V2';
    if(ereg('Networks', "$result[0]") || ereg('Networks', "$result[1]")) 
      $VERSION = 'V3';

    foreach($list_file as $line){
      $list = array_reverse(split('/', $line));
      $list_dir[] = $list[1];
    }

    foreach($net_file as $line){
      $net_array = split(';', $line);
      $ETHER[] = $net_array[5];
      $IP[] = $net_array[7];
    }

    foreach ($list_dir as $var){
      if (file_exists("$GLOBALS[chemin_CSV]/$var/$computer")){
	$tmp = file("$GLOBALS[chemin_CSV]/$var/$computer");
	$var = ucfirst(strtolower($var));
	$$var = $tmp; 
      }
      if (count($$var) == 1) $tmp[0] = split(';', $tmp[0]);
      else {
	for ($num=0; $num < count($$var); $num = $num +1){
	  $tmp[$num] = split(';', $tmp[$num]);
	}
      }
      $$var=$tmp;
    }
# create a variables list witch have the diretories' name.
# Variables' value : .csv content

    if ($VERSION == "V2") {
      $Networks = $Network;
      $Videos = $Graphics;
      $Drives = $Logicaldrives;
      $Softwares = $Results;
    } 

    for($num=0; $num < count($Bios); $num++){
      $BIOS[$num] = array(
			  'STAMP' => $Bios[$num][0],
			  'SERIAL' => $Bios[$num][1],
			  'CHIPSET' => $Bios[$num][2],
			  'BIOS_VERSION' => $Bios[$num][3],
			  'CHIP_SERIAL' => $Bios[$num][4],
			  'CHIP_VENDOR' => $Bios[$num][5],
			  'BIOS_VENDOR' => $Bios[$num][6],
			  'TYPE_MACHINE' => $Bios[$num][7],
			  'BIOS_DATE' => $Bios[$num][4]
			  );
    }
 
    for($num=0; $num < count($Controllers); $num++){
      $CONTROLLERS[$num] = array(
				 'VENDOR' => $Controllers[$num][1],
				 'EXP_TYPE' => $Controllers[$num][2],
				 'STD_TYPE' => $Controllers[$num][6],
				 'HARD_VERSION' => $Controllers[$num][4]
				 );
    }

    for($num=0; $num < count($Modems); $num++){
      $MODEMS[$num] = array(
			    'VENDOR' => $Modems[$num][1],
			    'EXP_DESC' => $Modems[$num][2],
			    'TYPE' => $Modems[$num][3]
			    );
    }

    for($num=0; $num < count($Monitors); $num++){
      $MONITORS[$num] = array(
			      'STAMP' => $Monitors[$num][1],
			      'MODEL' => $Monitors[$num][2],
			      'DESC' => $Monitors[$num][3],
			      'TYPE' => $Monitors[$num][4]
			      );
    }
			
    for($num=0; $num < count($Drives); $num++){
      $DRIVES[$num] = array(
			    'STAMP' => $Drives[$num][0],
			    'DRIVE_LETTER' => $Drives[$num][1],
			    'DRIVE_TYPE' => $Drives[$num][2],
			    'TOTAL_SPACE' => $Drives[$num][3],
			    'FREE_SPACE' => $Drives[$num][4],
			    'VOLUME_NAME' => $Drives[$num][5],
			    'FILE_SYSTEM' => $Drives[$num][6],
			    'NUMBER_FILES' => $Drives[$num][7]
			    );
    }

    for($num=0; $num < count($Hardware); $num++){
      $HARDWARE[$num] = array(
			      'COMPUTER_NAME' => $Hardware[$num][0],
			      'OS' => $Hardware[$num][1],
			      'VERSION' => $Hardware[$num][2],
			      'BUILD' => $Hardware[$num][3],
			      'PROC_TYPE' => $Hardware[$num][4],
			      'PROC_FREQ' => $Hardware[$num][5],
			      'PROC_NB' => $Hardware[$num][6],
			      'RAM' => $Hardware[$num][7],
			      'SWAP' => $Hardware[$num][8],
			      'IP' => $Hardware[$num][9],
			      'DATE' => $Hardware[$num][11],
			      'USER' => $Hardware[$num][12],
			      'WORKGROUP' => $Hardware[$num][16],
			      'REGISTER_NAME' => $Hardware[$num][17],
			      'REGISTER_COMPANY' => $Hardware[$num][18],
			      'OS_SERIAL' => $Hardware[$num][19]
			      );
    }

    for($num=0; $num < count($Inputs); $num++){  
      $INPUTS[$num] = array(
			    'TYPE' => $Inputs[$num][1],
			    'VENDOR' => $Inputs[$num][2],
			    'STD_DESC' => $Inputs[$num][3],
			    'EXP_DESC' => $Inputs[$num][4],
			    'CONNECTOR' => $Inputs[$num][6]
			    );
    }
 
    for($num=0; $num < count($Memories); $num++){
      $MEMORIES[$num] = array(
			      'TYPE' => $Memories[$num][2],
			      'EXT_DESC' => $Memories[$num][3],
			      'SIZE' => $Memories[$num][4],
			      'CHIP_TYPE' => $Memories[$num][5],
			      'FREQ' => $Memories[$num][6],
			      'NB_SLOTS' => $Memories[$num][7]
			      );
    }
			
    for($num=0; $num < count($Networks); $num++){
      $NETWORKS[$num] = array(
			      'NAME_CARD' => $Networks[$num][0],
			      'CARD_TYPE' => $Networks[$num][1],
			      'NETWORK_TYPE' => $Networks[$num][2],
			      'MIB' => $Networks[$num][3],
			      'BANDWIDTH' => $Networks[$num][4],
			      'ETHER' => $Networks[$num][5],
			      'STATE' => $Networks[$num][6],
			      'IP' => $Networks[$num][7],
			      'BROADCAST' => $Networks[$num][8],
			      'GW' => $Networks[$num][9],
			      'DNS' => $Networks[$num][10]
			      );
    }

    for($num=0; $num < count($Ports); $num++){
      $PORTS[$num] = array(
			   'STAMP' => $Ports[$num][1],
			   'TYPE' => $Ports[$num][4]
			   );
    }

    for($num=0; $num < count($Printers); $num++){
      $PRINTERS[$num] = array(
			      'STAMP' => $Printers[$num][0],
			      'NAME' => $Printers[$num][1],
			      'DRIVER' => $Printers[$num][2],
			      'PORT' => $Printers[$num][3]
			      );
    }
			
    for($num=0; $num < count($Slots); $num++){
      $SLOTS[$num] = array(
			   'CONNECTOR' => $Slots[$num][1],
			   'PORT_TYPE' => $Slots[$num][3],
			   'AVAILABILITY' => $Slots[$num][4],
			   'STATE' => $Slots[$num][5]
			   );
    }

    if($VERSION == "V3"){
      for($num=0; $num < count($Softwares); $num++){   
	$SOFTWARES[$num] = array(
				 'COMPANY' => $Softwares[$num][1],
				 'PRODUCT_NAME' => $Softwares[$num][2],
				 'PRODUCT_VERSION' => $Softwares[$num][3],
				 'PRODUCT_PATH' => $Softwares[$num][4]
				 );	
   
      }
    }
    else {
      for($num=0; $num < count($Softwares); $num++){
	$SOFTWARES[$num] = array(
				 'PRODUCT_PATH' => $Softwares[$num][2],
				 'PRODUCT_NAME' => $Softwares[$num][3],
				 'SIZE' => $Softwares[$num][4],
				 'COMPANY' => $Softwares[$num][5],
				 'APPLICATION' => $Softwares[$num][6],
				 'TYPE' => $Softwares[$num][7],
				 'PRODUCT_VERSION' => $Softwares[$num][8]
				 );      
      }       
    }

    for($num=0; $num < count($Storages); $num++){
      $STORAGES[$num] = array(
			      'EXT_TYPE' => $Storages[$num][1],
			      'MODEL' => $Storages[$num][2],
			      'VOL_NAME' => $Storages[$num][3],
			      'MEDIA' => $Storages[$num][4],
			      'STD_TYPE' => $Storages[$num][5]
			      );
    }

    for($num=0; $num < count($Videos); $num++){
      $VIDEOS[$num] = array(
			    'STAMP' => $Videos[$num][0],
			    'MODEL' => $Videos[$num][1],
			    'CHIP' => $Videos[$num][2],
			    'VRAM_SIZE' => $Videos[$num][3],
			    'RESOLUTION' => $Videos[$num][4]			
			    );
    }
		
# set the array
    $table_machine = array(
			   'IP' => $IP,
			   'ETHER' => $ETHER,
			   'VERSION' => $VERSION,
			   'BIOS' => $BIOS,
			   'CONTROLLERS' => $CONTROLLERS,
			   'DRIVES' => $DRIVES,
			   'HARDWARE' => $HARDWARE,
			   'INPUTS' => $INPUTS,
			   'MEMORIES' => $MEMORIES,
			   'MODEMS' => $MODEMS,
			   'MONITORS' => $MONITORS,
			   'NET' => $NETWORKS,
			   'PORTS' => $PORTS,
			   'PRINTERS' => $PRINTERS,
			   'REGISTRY' => $REGISTRY,
			   'SLOTS' => $SLOTS,
			   'SOFTWARES' => $SOFTWARES,
			   'SOUNDS' => $SOUNDS,
			   'STORAGES' => $STORAGES,
			   'VIDEOS' => $VIDEOS
			   );

    return $table_machine;
  }
}
?>
