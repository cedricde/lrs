#! /var/lib/lrs/php
<?
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


include_once( "./lbs-inventory.php");
include_once('./path.cgi');
include_once("fonctions.cgi");

########################
#   Declaring blocks   #
########################


lib_init_config();

$groups = tmplInit(array("groups" => "groups.tpl"));

$groups->set_block("groups", "no_file", "no_file_block");
$groups->set_block("groups", "inside", "inside_block");
$groups->set_block("groups", "section", "section_block");
$groups->set_block("groups", "vide", "vide_block");
$groups->set_block("groups", "csv_all", "csv_all_block");
$groups->set_block("groups", "csv", "csv_block");
$groups->set_block("groups", "no_param", "no_param_block");



#################################################################
#   creation of the array containig the files in a good order   #
#################################################################

$indice=0;
if($_GET['showcsv']) $display = "false";
else $display = "true";
if($_GET['group'] || $_GET['profile'] ){
	$group = $_GET['group'];
	$profile = $_GET['profile'];
	$chemin_lbs = $chemin_LBS . "/../etc/ether";
	$array_use = search_files($chemin_lbs, $group, $profile);
	$file_list = list_of_files($array_use);
	if(!empty($file_list)){
		foreach ($file_list as $name){
			exec("ls $GLOBALS[chemin_CSV]/*/$name", $test);
			$liste[] = $test;
		}
		$indice = 0;
		foreach($liste as $machine){
			foreach ($machine as $line){
				$line2 = array_reverse(split('/', $line));
				$array_grp["$line2[1]"][$indice] = $line;
				sort($array_grp["$line2[1]"]);
			}
		$indice++;
		}
	}
	else {
		$groups->parse("inside_block", "vide");
		$groups->parse("section_block", "vide");
		$groups->parse("csv_all_block", "vide");
		$groups->parse("csv_block", "vide");
		$groups->parse("no_param_block", "vide");
		$groups->parse("no_file_block", "no_file");
	}
}
else {
	$groups->parse("inside_block", "vide");
	$groups->parse("section_block", "vide");
	$groups->parse("csv_all_block", "vide");
	$groups->parse("csv_block", "vide");
	$groups->parse("no_file_block", "vide");
	$groups->parse("no_param_block", "no_param");
}

function search_files($file, $group, $profile){
	if (file_exists($file)){
		$array = file($file);
		if($group != "" && $profile !="") $search_param = $profile.':'.$group;
		else if($group !="") $search_param = $group;
		else if($profile != "") $search_param = $profile;
		
		foreach ($array as $line){
			
			if (eregi($search_param, $line)){
				$use = split(' ', $line);
				$use_array[] = str_replace(':', '', $use[0]);
			}
		}
	}
	return $use_array; // return mac address of the members of a group
}


function list_of_files($array_use){
        $cmd = "ls $GLOBALS[chemin_CSV]/Net*/*";
        exec($cmd, $result);
        foreach($array_use as $line){
                foreach($result as $line2){
                	if(eregi($line, $line2)){
                        	$net = array_reverse(split('/', $result[0]));
                                $net = $net[1];
                                if (file_exists("$GLOBALS[chemin_CSV]/$net/$line")){
                                	$tmpfile = readlink("$GLOBALS[chemin_CSV]/$net/$line") or die ("link does not exists");
                                        $tmpfile = array_reverse(split('/', $tmpfile));
                                        $listfiles[] = $tmpfile[0];
                                }
                        }       
                }
        }
        return $listfiles;
}

######################
#   filling blocks   #
######################

if ($_GET['group'] || $_GET['profile'] ){
$indice = 0;
$sizemax = 0;
if(!empty($array_grp)){
	foreach(array_keys($array_grp) as $key){
		if (count(array_keys($array_grp[$key])) > $sizemax) $sizemax = count(array_keys($array_grp[$key]));
	}

	foreach(array_keys($array_grp) as $key){
		$poursuit = false;
		$groups->set_var(array(	"SECTION" =>  $key,
					"SECT_LINK" => "groups.cgi?group=".$_GET['group']."&profile=".$_GET['profile']."&showcsv=$key"));
	
		for($indice=0; $indice < $sizemax; $indice++){
			
			$num = $indice +1;
			$color = class_couleur($indice);
										
			if($array_grp[$key][$indice] != ""){
				$ind_array = array_reverse(split('/', $array_grp[$key][$indice]));
				$link = giveFileLink($ind_array[0], $ind_array[1]); 
				$groups->set_var(array( "INSIDE" => $link,
							"NUMBER" => $num));
				if($ind_array[0] != "") $name_machine[$indice] = $ind_array[0];
				if ($array_grp[$key][$indice]!= "") $file_csv[$indice][] = file($array_grp[$key][$indice]);
				foreach($file_csv as $line);
			}
			else {
			        $groups->set_var(array(	"INSIDE" => "N/A",
							"NUMBER" => $num ));
			}
			$groups->parse("inside_block", "inside", true);
		}
		$groups->parse("section_block", "section", true);
		$groups->parse("inside_block", "vide");
	}
	$groups->parse("csv_block", "csv");
	$groups->parse("no_file_block", "vide");
	$groups->parse("csv_block", "vide");
	$groups->parse("no_param_block","vide");
	$groups->parse("csv_all_block", "vide");
}
}


####################
#   printing all   #
####################

if($display == "true"){
	$groups->parse("vide_block", "vide");
	echo perl_exec("./lbs_header.cgi", array("inventory groups", $text{'index_title'}, "software"));
	
	$groups->pparse("out", "groups");
	
        echo perl_exec("./lbs_footer.cgi", array("2"));
}
else {	
	$nb = $_GET['showcsv'];

	foreach($array_grp[$nb] as $line){
		$f = fopen($line, "r");	
		$content_len += (int) filesize($line);
		$content_file = $content_file . fread($f, $content_len);
		fclose($f);
	}
	
	header('Last-Modified: '.gmdate('D, d M Y H:i:s') . ' GMT');
	header('Cache-Control: no-store, no-cache, must-revalidate'); // HTTP/1.1
	header('Cache-Control: pre-check=0, post-check=0, max-age=0'); // HTTP/1.1
	header('Content-Transfer-Encoding: none');
	header('Content-Type: application/octetstream; name="' . $nb . '.csv"');
	header('Content-Type: application/octet-stream; name="' . $nb . '.csv"');
	header('Content-Disposition: inline; filename="' . $nb . '.csv"');
	header("Content-length: $content_len"); 
	echo $content_file; 
        echo perl_exec("./lbs_footer.cgi", array("2"));
}
?>
