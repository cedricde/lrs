<?php

# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

include_once("path.cgi");

## Fonction d'affichage
	function affichage($valeur)
	{
		echo $valeur."<br>";
	}

## Fonction qui retourne le nombre de caractère dans la ligne du fichier CSV ou 0 en cas d'erreur d'ouverture du fichier
function size_CSV($chemin_fichier)
{
 $size = 0;
 if ( file_exists($chemin_fichier) )
 {
   if ( $fichier = fopen($chemin_fichier, "r") )
 	{ 
	 while (!(feof($fichier)))
 	  {
	   fgetc($fichier);
	   $size++;
 	  }
 	 fclose($fichier);
	 return $size;
	}
   else return 0;
 }
 else return 0;
}

## Fonction qui donne le nom du PC à partir de l'@ MAC 
function MacToName($mac_address)
{
	$mac_address = filterMac($mac_address); // ADDED by P.D.

	$fichier = "$GLOBALS[chemin_network]" . "/" . $mac_address;

	$size = size_CSV("$GLOBALS[chemin_network]" . "/" . $mac_address);
	
	$nb_ligne = Nb_ligne($fichier);

	$ptr_fichier = fopen($fichier, "r") or die("fonction.cgi[MacToName]: impossible d'ouvrir $fichier");
	for ($i=0; $i <$nb_ligne; $i++)
		{
		 $tab = fgetcsv($ptr_fichier, $size, ";");
		 $mac = eregi_replace(":","",$tab[5]);
		 if ($mac == $mac_address)
		 		return $tab[0];
		}
}


## Fonction qui compte le nombre de lignes d'un fichier
function Nb_ligne($file)
{
 if(file_exists($file))
 {
  $table = file($file);
  return count($table);
 }
}




## Fonction qui permet d'alterner les couleur de ligne
# elle prend en entrée le numéro de la ligne courante, et renvoie la couleur adéquate
function couleur($num_ligne)
{
 // il suffit de changer les couleurs ici pour que ça se répercute sur toutes les pages
 // #e2e2e2 = gris clair
 // #e2d1f9 = mauve clair
 $color = ($num_ligne % 2) ? "#e2e2e2" : "#e2d1f9" ;
 return "\"" . $color . "\"";
}


## Fonction équivalente à couleur, mais renvoie le nom de la classe CSS de la couleur 
function class_couleur($num_ligne)
{
 $color = ($num_ligne % 2) ? "fond_normal" : "fond_normal2";
return "\"" . $color . "\"";
}


## Analyse des fichiers ini générés par le LBS 
function AnalyzeIniFile($IniFile)
{ # prend l'adresse d'un fichier ini, et sort une structure tabulaire des informations

 # on va décomposer $tab qui n'est pas bien formé (MAIN.lowmem ---> pas pratique) 
 # mieux: MAIN => lowmem => ...  ---> exploitable facilement 

 $conf = New ConfigFile("$IniFile");
 $tab= $conf->get_array();

 #$old_type ;  sert à retenir le type de la partition
 # le tableau final se nomme $tab_res
foreach ( $tab as $key => $value)
 {
  $partie = explode(".", $key);
  switch ($partie[0])
  {
   case "MAIN": # on est dans la section MAIN du fichier
  	$tab_res[$partie[0]][$partie[1]] = $value;
	break;
   default: # on est dans une section PCI# ou  DISK#
	if ( ereg("PCI[0-9]", $key) ) # recherche du nom suivi du numéro
		{
	 	 $ss_partie = split("PCI",$partie[0]);
	 	 $tab_res["PCI"][$ss_partie[1]][$partie[1]] = $value;
		}
	else if (ereg("DISK[0-9]", $key)) # inutile de refaire le test, sauf si des sections seront rajoutées
		{
		 $ss_partie = split("DISK",$partie[0]);
		 if ( ereg("partlength", $partie[1]) )
			{
			 $val_part = split("partlength", $partie[1]);
     			 $tab_res["DISK"][$ss_partie[1]]["PartNum"][$val_part[1]]["Part Number"] = $old_number;
			 $tab_res["DISK"][$ss_partie[1]]["PartNum"][$val_part[1]]["Type"] = $old_type;
			 $tab_res["DISK"][$ss_partie[1]]["PartNum"][$val_part[1]]["Length"] = $value;
			}
		 else	{
		 	 if (ereg("parttype", $partie[1]))
				{
				 $old_type = $value;
				}
			 else
			 	if (ereg("partnum", $partie[1]))
					{
					 $old_number = $value;
					}
				else
					{
				 	 $tab_res["DISK"][$ss_partie[1]][$partie[1]] = $value;
					}
			}
		} # fin if partlength
  } # fin switch partie[0]
 } # fin foreach

 return $tab_res;
}




## Fonction de tri, QUE pour software, triant sur 1 critère
function insert_sort($tab, $col_name)
{
 if ($col_name != "Size")
 	{
	  for ($i=1; $i<sizeof($tab); $i++)
  		{
	 	 $v = $tab[$i];
	 	 $j = $i;
         	 while ( ($j>0) && (strcasecmp($tab[$j-1][$col_name], $v[$col_name]) >0) )
			{
		  	 $tab[$j] = $tab[$j-1];
		  	 $j = $j-1;
			}
          	 $tab[$j] = $v;
		}
	}
 else
 	{
	 for ($i=1; $i<sizeof($tab); $i++)
  		{
	 	 $v = $tab[$i];
	 	 $j = $i;
         	 while ( ($j>0) && ($tab[$j-1] [$col_name] > $v[$col_name]) )
			{
		  	 $tab[$j] = $tab[$j-1];
		  	 $j = $j-1;
			}
          	 $tab[$j] = $v;
		}
	}

  	return $tab;
}


## Fonction de tri, QUE pour software, sur 3 critères
function insert_sort2($tab, $critere)
{
 if ($critere == "")
  {
   for ($i=1; $i<sizeof($tab); $i++)
	 {
	   $v = $tab[$i];
	   $j = $i;
	   
	   # on trie suivant le critère 1 
	   while ( ($j>0) && (strcasecmp($tab[$j-1]["Application"], $v["Application"]) >0)  )               
	   	{
		 $tab[$j] = $tab[$j-1];
		 $j = $j-1;
		}
           
	   # on trie suivant le critère 2
	   while ( ($j>0) 
	         && ( (strcasecmp($tab[$j-1]["Application"], $v["Application"]) >0) or (strcasecmp($tab[$j-1]["Application"], $v["Application"])==0) )
		 && (strcasecmp($tab[$j-1]["Path"], $v["Path"]) >0)  )
		{
		 $tab[$j] = $tab[$j-1];
		 $j = $j-1;
		}
	  
	  # on trie suivant le critère 3
	  while ( ($j>0) 
                 && ( (strcasecmp($tab[$j-1]["Application"], $v["Application"]) >0)  or (strcasecmp($tab[$j-1]["Application"], $v["Application"])==0) )
		 && ( (strcasecmp($tab[$j-1]["Path"], $v["Path"]) >0) or (strcasecmp($tab[$j-1]["Path"], $v["Path"])==0) )	
		 && (strcasecmp($tab[$j-1]["File_Name"], $v["File_Name"]) >0) )
		{
		 $tab[$j] = $tab[$j-1];
		 $j = $j-1;
		}
	  $tab[$j] = $v;
	}
  return $tab;
 }
 else return insert_sort($tab, $critere);
 }

## Convertit en multiple d'octets
function Convert($size, $precision)
{
 if ($size >1024*1024 )
	 $size = round( ( ($size / 1024) / 1024), $precision) . "&nbsp;MB";
 else	if ($size > 1024)
		$size = round( ($size / 1024), $precision) . "&nbsp;kB";
	else $size = $size . "&nbsp;b";

 return $size;
}





## Type d'une partition à partir de son type en hexa
function HexaToType($hexa)
{
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
 
 return Est_Vide($parttype["0x".strtolower($hexa)],"N/A");
}


## VERIFIE SI L'ARGUMENT EST VIDE, ET REMPLIT PAR &nbsp; LE CAS OÙ
function Est_Vide ($string, $none)
{
	if ($string =="")
		return $none;
	else	return $string;
}




## EXPLORATION D'UN RÉPERTOIRE ET DE SES SOUS-RÉPERTOIRES 
function make_menu($path)
{ # génère un tableau contenant l'arborescence à partir d'un répertoire
  $ptr_dir = opendir($path);

  while ( $file = readdir($ptr_dir) )
	{
	if ( ($file!=".") && ($file!="..") )
		{
	 	 if ( is_dir("$path/$file") )
	 		{
			 $menu_arborescent[basename("$path/$file")] = make_menu("$path/$file", $count);
			}
	 	 else
	 		{
		 	 $tab = parse_ini_file("$path/$file");
		 	 $menu_arborescent[basename("$path/$file")] = $tab;
			}
		}
	}
  closedir($ptr_dir);
  return $menu_arborescent;
}


## POSITION D'UNE CASE D'UN MENU
function Position_Menu($case)
{ # retourne le numéro de position contenu dans description.ini de la case pointée par $case
  return $case["description.ini"]["position_number"];
}


## TRI DES ENTREES DU MENU
function Tri_Menu($tableau)
{
 for ($i=2; $i<sizeof($tableau); $i++)
  		{
	 	 $v = $tableau[$i];
	 	 $j = $i;
         	 while ( (Position_Menu($tableau[$j-1])> Position_Menu($v)) && ($j>-1) )
			{
		  	 $tableau[$j] = $tableau[$j-1];
		  	 $j = $j-1;
			}
          	 $tableau[$j] = $v;
		}
 return $tableau;
}


## RECDUCTION TABLE HACHAGE
function Reduction_Tableau($tableau)
{ # enlève le niveau le plus élevé d'une table de hachage
 $tab_res = array();
 foreach($tableau as $key => $value)
	{
	 $tab_res = $value;
	}
 return $tab_res;
}


## TRI PAR POSITION
function Tri_Position($table)
{ # prend une table de menu et renvoie un tableau trié selon la position des éléments dans le menu
 $tab_res = array();
 foreach ($table as $key => $value)
	{
	 if ($key != "description.ini")
	 	$tab_res[Position_Menu($value)][$key] = $value;
	}

 for($i=0; $i<sizeof($tab_res);$i++)
 	{
	 $tab_final[] = $tab_res[$i+1];
	}
 return $tab_final;
}


## AFFICHAGE DU MENU DANS LE CODE HTML
function Menu_Out($table_menu, $tab_init, $get_url=array())
{

 global $gconfig;
 
#
# if (in_array("lang", array_flip($get_url)) )
# 	$LANG = $get_url["lang"];
# else   $LANG="fr";
#
 
 if ($gconfig["lang"] == "")
   $LANG = "en";
 else
      $LANG = $gconfig["lang"];
 
 if (in_array("mac", array_flip($get_url)) )
 	$mac = $get_url["mac"];
//else {
	//echo "Aucune adresse MAC disponible <br>";
	//exit();
//}
 
 $menu = new Template($GLOBALS["chemin_templates"], "keep");
 $menu->set_file("menu_file", "menu_inventaire.tpl");
 $menu->set_block("menu_file","case_selectionnee","case_selectionnee_block");
 $menu->set_block("menu_file", "case_normale", "case_normale_block");
 $menu->set_block("menu_file", "case", "case_block");
 $menu->set_block("menu_file","vide","vide_block");
 $menu->set_block("menu_file","ligne", "ligne_block");
 $menu->set_block("menu_file", "section_menu", $section_menu_block);
 
 $i=0;
 $nb_div=0;
 $tab_tri_position = $table_menu;
 while ((sizeof($tab_tri_position)>0) && ($i<sizeof($tab_init)) )
  { # on a 1 ou plusieurs sous-menus, sinon il n'y aurait que description.ini, donc taille minimale vaut 1
	$menu->parse("case_selectionnee_block", "vide");
	$menu->parse("case_normale_block","vide");
	$menu->parse("case_block", "vide");
	$tab_tri_position = Tri_Position($tab_tri_position);
	
	foreach($tab_tri_position as $key => $index)
	  {
	   foreach ($index as $k => $value)
		{
		 if ($value != "description.ini") # sinon on est au + profond de l'arborescence
			{
			
			 // ADDED by P.D.
			 // check if the address is already in ":" notation
			 $aux = strstr($mac, ":");
			 if (!$aux)  {
			   $dotMac = addDublePoint($mac);
			   $notDotMac = $mac;
			 }
			 else  {
			   $dotMac = $mac;
			   $notDotMac = filterMac($mac);
			 }
	   
			 // check if the addres in the 'ini' file should be replaced by the ":" notation or not
			 $dotNotation = strstr($value["description.ini"]["link_$LANG"], "%mac_with_dot%");
			 if ($dotNotation) { // someone wants the address with ":" notation
			   $newMac = $dotMac;
			   $repValue = "%mac_with_dot%";
			 }
			 else {
			    $repValue = "%mac%";
			    $newMac = $notDotMac;
			 }
			 //~~
			
			 if ($value["description.ini"]["position_number"] == $tab_init[$i]) # c'est la case sélectionnée
			 {
			  	  
			   $menu->set_var(array("URL_SELECT" => "\"" .ereg_replace($repValue, $newMac,$value["description.ini"]["link_$LANG"]) . "\"",
						"NOM_LIEN_SELECT" => $value["description.ini"]["screen_name_$LANG"]));

			  //$menu->parse("case_selectionnee_block", "case_selectionnee",true);
			  $menu->parse("case_block", "case_selectionnee",true);
			 
			 } else	{
		  
			   $menu->set_var(array("URL" => "\"" .ereg_replace($repValue, $newMac,$value["description.ini"]["link_$LANG"]) . "\"",
						"NOM_LIEN" => $value["description.ini"]["screen_name_$LANG"]));
			  
			  //$menu->parse("case_normale_block", "case_normale",true);
			  $menu->parse("case_block", "case_normale", true);
			  			  
		  	 }
	 	 	 			  
			} # fin du if
		} # fin foreach interne
	  } # fin foreach externe
	
	$menu->parse("ligne_block", "ligne",true);
	$nb_div++;
	$menu->parse("vide_block","vide");
	$menu->parse("case", "vide");
	
	$tab_tri_position = $tab_tri_position[$tab_init[$i]-1];
	$tab_tri_position = Reduction_Tableau($tab_tri_position);
	$i++;

  } # fin while
 $menu->parse("vide_block","vide");
 $menu->parse($section_menu_block, "section_menu");
 return array($menu->subst($section_menu_block), $nb_div);
 
}

## Ajoute la fin du menu, qui consiste en la mise en place des balise </DIV> manquantes
function Fin_Menu($nb_div_ouvert)
{
 $menu = new Template($GLOBALS["chemin_templates"], "keep");
 $menu->set_file("menu_file", "menu_inventaire.tpl");
 $menu->set_block("menu_file","fin_menu", $fin_menu_block);
 $div = "";
 
 for($i=0; $i<$nb_div_ouvert; $i++)
 {
	$div .= "</div> " ;
 }

 return $div;	
}


?>
