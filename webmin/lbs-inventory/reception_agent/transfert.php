<?php // -*- Mode: PHP; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 8 -*- -->
#
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

//
// OCS client to server transfer script 
//
// $Id$
//

//sorry, no error reporting to the client, and so no php log :(
error_reporting(0);
$debug = 1;

include_once('../../lbs_common/web-lib.php'); # FIXME: file exist ...
include_once('config.php'); # FIXME: file exist  ...

$assocTable = lib_read_file("/etc/webmin/lbs-inventory/config"); 
$chemin_CSV = $assocTable['chemin_CSV'];

$listpath = "$chemin_CSV/listing";
$logpath = "$chemin_CSV/log";

function verif_nom_fichier($nom_fichier){
    return ereg($GLOBALS['regex_fichier'],$nom_fichier);
}
	
function tronquer_nom($nom_fichier){ 
    //print("file= ".$nom_fichier); 
    $tab=array_reverse(split('/',$nom_fichier));
    // return the .csv file and its directory (BIOS/TEST.csv)
    if ( $tab[1] )
	$tab[1] .= '/';
    return $tab[1] . $tab[0];
}
	
function creer_repertoire_si_necessaire($nom){
    if ( ! is_dir($nom) ){
	$folder_list = split("/",$nom);
	$len = count($folder_list);
	for($i=0; $i<$len; $i++){
	    $tmp .= $folder_list[$i] . '/';
	    @mkdir($tmp,$GLOBALS['mode_dossier_default']); # <==> @mkdir($tmp,0777) apache write in
	}
    }
}

function extraire_addresse_mac($fichier){
    $f_contenu = @file($fichier);
    // if file doesn't exist or is empty
    // returns an empty tab
    if ( ! $f_contenu ) return array(); 
			
    // else, 1 network interface per lign
    foreach( $f_contenu as $ligne ) {
	// exclude ppp adapters
	if (eregi("ppp adapter", $ligne)) continue; 
	// get data
	$t=split(';',$ligne);
	// keep the MAC addresse (the 5 position)
	$tab[]=str_replace(':','',$t[5]);
    }
    return $tab;
}
	
// returns the name and MAC address of client using nmblookup
function nmblook($ip){
    $command = "nmblookup -A $ip";
    $name_nmb = exec($command, $name);
    if(!is_array($name)) return FALSE; // don't have name AND MAC address)
    else{
	$array_name = split(' ', trim($name[1]));
	$name_nmb[0] = $array_name[0];  // nmb name
	$array_name = split('=', trim($name[(count($name) -2)]));
	$name_nmb[1] = ereg_replace('-', ':', trim($array_name[1])); // replace '-' by ':',  nmblookup give the MAC address like this (!)
	return $name_nmb;
    }
}

// check if, using a name, the MAC address correspond with one of the file
function check_client($tab_name_mac, $chemin_CSV){ 
    $name = $tab_name_mac[0];
    $mac = $tab_name_mac[1];
    $command = "ls $chemin_CSV/Network*/" . $name . ".csv |grep csv";
    // get an array about file concerned
    exec($command, $files);
    if(empty($files)) return TRUE;
    if(count($files) > 1) return FALSE; 
    // if we have more that 2 times the name in a directory Network(s), then there is too much
    else {
	$inside = file($files[0]);
	foreach($inside as $line){	
	    if(eregi($mac, $line))	return TRUE;
	}
	return FALSE;
    }
}

// simple debug function	
function debug($str) {
    global $debug, $debug_fd;
    
    if ($debug != 1) return;
    
    fwrite($debug_fd, "[" .  date(r) . '] ' . $str);
}

system('rm -f $chemin_CSV/Results/FAS-CONVERTER.csv.diff');
	
$IP = $_SERVER['REMOTE_ADDR'];

if ($debug == 1) {
    $debug_fd = fopen($logpath, a);
    $HOST = $_SERVER['REMOTE_HOST'];
    $PORT = $_SERVER['REMOTE_PORT'];
    $SERVER = $_SERVER['SERVER_NAME'];
    $QUERY = $_SERVER['QUERY_STRING'];

    $QUERY = str_replace('%2F', '/', str_replace('%5C', '\\',  str_replace('%3A', ':', $QUERY))); // more readable log
    debug(" IP client = " . $IP . $HOST . ":" . $PORT . " - server name = " . $SERVER . "\n" . '[' .  date(r) . ']' . " query_string = \"" . $QUERY . "\" \n");
}
else if (is_file($logpath)) unlink($logpath); // don't need any more
	
if ($_GET['md5_calc']==1 and $_GET['fichier'] )	{ 
    // use 'tronquer_nom', because we only need the end of it.
    $nom = tronquer_nom($_GET['fichier']);

    $s = @implode('',@file("$chemin_CSV/" . $nom));

    // if file is empty or doesn't exist, returns  a random md5 output
    // so, the file will be transfer (exept there is a fucking bug in
    // the md5 algo !)
    print(md5($s));	

    $nom1 = split('/', $nom); // dir/name.csv
    if(eregi(Network, $nom1[0])){
	$listnewdate = "ls -l $chemin_CSV/*/$nom[1]";
	exec($litsnewdate, $array_list);
	foreach($array_list as $line) touch($line);
	debug ("all files touched \n");
    }
    debug (tronquer_nom($_GET['fichier']) . " - md5 on server = " . md5($s) . "\n"); 

}
elseif ($_POST['md5'] and $_FILES['filename'])	{
    // For old agent compatibility
    if ($_POST['fullpath'])
	$n = tronquer_nom($_POST['fullpath']);
    else	
	$n = tronquer_nom($_FILES['filename']['name']);
    debug ("$n\n");

    $tab = array(split('/', $n));
    $nv = $tab[0][0]; # dirname
		
    $s = implode("",file($_FILES['filename']['tmp_name']));
    $n = "$chemin_CSV/$n"; # = /var/lib/lbs/$n
    debug ("post = " . $_POST['md5'] . " - file = " . $_FILES['filename']['name'] ."\n" );
    // FIXED keep the complet name of directory where to copy the file, NOT in the current directory
    // OCS3

    // this is directory list (v2, v3, ad common)
    // needed to have a good transfert
    // use split to split (of course !!) and use space like separator, and create directories

    $array_dossierv2 = split(' ', $GLOBALS['liste_dossierv2']);
    $array_dossierv3 = split(' ', $GLOBALS['liste_dossierv3']);
    if (in_array($nv, $array_dossierv2)) {
	$array_file = $array_dossierv2; 
	debug ("V2 directories \n");
    }
    else if (in_array($nv, $array_dossierv3)) {
	$array_file = $array_dossierv3;
	debug("V3 directories \n");
    }
    else {
	$array_file = split(' ', $GLOBALS['liste_dossier_commun']); 
	debug("common directories \n");
    }
    foreach ($array_file as $a) creer_repertoire_si_necessaire("$chemin_CSV/$a");

    if (! verif_nom_fichier($n)) {
        // to prevent some guys try to put some php scripts or others executable files
	$rep = 'err - transfer denied, incorrect extension';
	debug("$n : transfer denied, incorrect extension \n");
    }
    elseif ( md5($s) == $_POST['md5'] ){
	debug("md5 of sent file and md5 calculated by the client are the same, OK \n");
	$ok = true;
	if (eregi('Network',$n)) #^Network
	    {// network must have a particular work
		$ok = false;
				
		$tableau_addresse_mac_avant = extraire_addresse_mac($n);
		// keep that in the pocket
		debug("$n : mac address kept \n");

		// check if MAC address is OK with the file
		// buggy ! should add other checks
		$tab_name_mac = nmblook($IP);
		//$ok = check_client($tab_name_mac, $chemin_CSV);
		$ok = true;
		if ($ok == true) $rep = 'ok';
		//else $rep = $GLOBALS['error_mac'];
		$rep = 'ok';
		debug("Name Client = " . $tab_name_mac[0] . " - IP Client = " . $IP . " MAC Client = " . $tab_name_mac[1] . "\n" );
	    }
        // make a diff with the old and the new -> .csv.diff
        // send it to the master of the world (root) by mail 
	$txt = "";
	if ($ok == true and file_exists($n)){ 
	    if (!copy($n, $n.".old")) debug("copy problem \n");
	    else debug ("file $n copied to ". $n . ".old \n");

	    if (!strstr($n, "Hardware")) {
		// do not diff Network*: contains random data and the current date
		$txt = shell_exec('diff '.$n.'.old '.$_FILES['filename']['tmp_name']);
		system('diff '.$n.'.old '.$_FILES['filename']['tmp_name'].' > '.$n.'.diff'); # diff instead of csvdiff
		debug("diff of the files $n $n.old \n");
	    }
	}
	if($txt != "") {
	    mail($assocTable["adresse_mail"], "Inventory config changes ($n)", $txt);
	    debug("sent diff file via email to ".$assocTable['adresse_mail']."\n");	
	}

	if ($ok == true and copy($_FILES['filename']['tmp_name'], $n))  { 
	    $rep = 'ok' ;
	    debug("copied in file $n \n");
	    if (eregi('Network',$n))
		{// Network need a special work
		    debug("network file treatment in progress \n");
		    // delete the link, create new one. TODO
		    $tableau_addresse_mac_apres  = extraire_addresse_mac($n);
					
		    // merge 2 tabs, this element need to be sort
		    // ex $tab = merge ( (1, 2) , (2,3) ) => (1, 2 , 3).
		    $tab_fus = array_merge($tableau_addresse_mac_apres, $tableau_addresse_mac_avant);
				
                    // make some stuff, hard to explain :	
		    // ex : (1, 2 ,3) -  ( 2 ,3 ) => (1 )
		    $tableau_addresse_mac_change_1 = array_diff($tab_fus, $tableau_addresse_mac_apres);
		    // ex : (1, 2 ,3) -  ( 1,2 ) => (3 )
		    $tableau_addresse_mac_change_2 = array_diff($tab_fus, $tableau_addresse_mac_avant);
		    // merge all ( 1 ) and ( 3 )
		    $tableau_addresse_mac_change = array_merge($tableau_addresse_mac_change_2, $tableau_addresse_mac_change_1);
		    if(is_dir("$chemin_CSV/Network")) {
			$net = "Network";
		    }	
		    else {
			$net = "Networks/";
		    }

		    $status = check_client($tab_name_mac, $chemin_CSV);
		    // buggy check, needs to be fixed
		    $status = true;
		    if ($status == false) {
			$rep = $GLOBALS['error_mac'];
			$ok = false;
			debug("Result of the copy on server " . $GLOBALS['error_mac'] . "\n");
			unlink($chemin_CSV . '/' . $net . '/' . $tab_name_mac[0] . '.csv');
			// block it when no file correpond it.
		    }
		    else {
			debug("Result of the copy on the server = OK \n"); 
			$ok = true;
		    }
                    // check if Network file has the good MAC address
		    // send log error to the client
		    if ($ok == true) {
			foreach($tableau_addresse_mac_change as $i){
			// new MAC address ?? new link !!
			    if (in_array($i,$tableau_addresse_mac_apres)) {
				if (!symlink("$n", "$chemin_CSV/$net/$i")) 
				    debug("$n linking problem \n");
			       
				if ($i != 0) 
				    debug("$n creation of $chemin_CSV/$net/$i link\n");
				else 
				    debug("link cannot be created, no mac address.\n");
				
				// IP, MAC, name of file ine the list
				foreach (file($n) as $line){
				    //$tmp_i = rtrim(chunk_split($i, 2, ":"), ":");
				    if (eregi(rtrim(chunk_split($i, 2, ":"), ":"), $line)){ 
					$contenu = split(";", $line);
					if (is_file($listpath)) $array_list = file($listpath);
					$array_list[] = $contenu[5] . ' ' . $contenu[7] . ' ' . $contenu[0];
					// add the lign to the end of tab, so at the end of file
					debug("Mac address = $contenu[5] \n");
				    }
				}//end foreach			
			    } //fi
			    else  { 
				// ADDED
				//$numline = 0;
				//$tmp_i = rtrim(chunk_split($i, 2, ":"), ":");
				//foreach($array_list as $line){
				//        if (eregi($tmp_i, $line)){           
				//        	unset($array_list[$numline]); // delete the lign
				//		$numline = $numline - 1;
				//        }
				//	$numline = $numline +1;
				//} //end foreach
				// end the list of PC to add
				if (!unlink( "$chemin_CSV/$net/$i")) debug("$n unlink problem $i \n");
			    }
			}
			if(is_file($listpath)) unlink($listpath); 
			$listfile=fopen($listpath, a); 
			foreach ($array_list as $contend) fwrite($listfile, rtrim($contend) . "\n");
			// create again the list
		    } // fi $ok
		}
	}
	else {	 
	    $rep = " err - cannot copy the file " + htmlentities($n); 
	    if ($ok==false) $rep = "An error occured when copying the file, check the MAC Address in the csv file of the server";
	    else if($rep == 0) $rep = "Error, verify accessibility of the directories";
	    debug("cannot copy the file ".$_FILES['filename']['tmp_name']." to $n (size=".$_FILES['filename']['size'].", error=".$_FILES['filename']['error'].")\n");
	}
    }
    else $rep = 'err - md5 check incorrect ' . md5("$s") . ' -' . $_POST['md5'] . ' - ' . md5($s2) ;
		
    // the aswer is  'err -' if there is an error, ok if all is.. OK :). this test it
    print $rep;
    debug('result = ' . $rep . "\n\n");
}
else {
    echo $GLOBALS['message_page_vide'];
    debug("page_accessible \n");


    //	$nom = $_FILES['tmp_name'];
    //	print $nom;
    //	print_r($s);

    if($debug == 1) fclose($debug_fd);
    fclose($listpath);
    // close all
}
?>
