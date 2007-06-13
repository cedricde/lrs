<?
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


include_once ("./web-lib.php");

# int initLbsConf($file)
# Chargement de $file (/etc/lbs.conf) dans $lbsconf (hash global),
# et de lbs-lib.pl .
# On effectue aussi quelques tests de verification: presence du parametre
# 'basedir', et existence du repertoire en question.
# Retourne 1 si OK, ou 0 si erreur.

function initLbsConf($file)
{
  global $lbsconf, $text;

  if (!is_readable($file)) {
    LIB_message($text{'tit_error'}, LIB_text("err_confnf",$file)) ;
    return 0;
  }

  $lbsconf = LIB_read_env_file($file) ;

# strip \r characters
#while ((my $k,my $v) = each(%lbsconf)) {
#    $lbsconf{$k} =~ s/\r//g;
#}


 if (!isset($lbsconf['basedir'])) {
   LIB_message($text['tit_error'],
	       LIB_text("err_paramnf", 'basedir', $file)) ;
   return 0;
 }

 if (!is_dir($lbsconf['basedir'])) {
   LIB_message($text['tit_error'],LIB_text("err_basedirnf", $lbsconf['basedir']));
   return 0;
 }

# require "lbs-lib.pl" ;

# if (exists $gconfig{'lang'}) {
# 	lbsSetLang($gconfig{'lang'}) or lbsSetLang('default') ;
# }
# else {
# 	lbsSetLang('default') ;
# }

 return 1 ;
}

#
# Retourne un array qui contient le fichier /tftpboot/revoboot/etc/ether
# Il est indexé suivant la MAC ou le NOM
# Chaque entrée contient un sous-array avec les champs "ip", "name" ou "mac"
function etherLoad($bymac = 1)
{
global $lbsconf;
$ether = array();
  
        if ($fd = @fopen ($lbsconf["basedir"]."/etc/ether", "r")) {
                while (!feof ($fd)) {
                        $buffer = trim(fgets($fd, 4096));
                        $buffer = preg_replace("/#.*$/","",$buffer);
                        $kw = preg_split("/[ \t]+/", $buffer, 3);
                        if (count($kw) == 3) {
                                $mac = $kw[0];
                                $ip = $kw[1];
                                $name = $kw[2];
                                if ($bymac)
                                        $ether[$mac] = array ("name" => $name, "ip" => $ip);
                                else
                                        $ether[$name] = array ("mac" => $mac, "ip" => $ip);
                        }
                }
                
                fclose($fd);
        }

        return $ether;

}

function etherLoadByName()
{
  return etherLoad(0);
}

function etherLoadByMac()
{
  return etherLoad(1);
}


#
# Affiche d'un message sur une page (utilisé pour les messages d'erreur)
# message($title, $message)
#
function LIB_message($title, $message)
{
  LIB_header($title, "", "index", 1, 1, "", "");
  print "<p>$message</p>";
  LIB_footer("","");
}


#
# New functions goes here:
#

# -------------------------------------
#
# this function simply remove the :
# from the mac address
#
function filterMac($mac)
{

	return str_replace(':','',$mac);
} #~~


#
# convert the MAC from NO-duble point notation to duble point notation
#
function addDublePoint($mac) {
  $newMac = chunk_split($mac, 2, ":");
  $newMac = rtrim($newMac, ":");

return $newMac;
} #~~

#
# Execute a perl function responsable for printinig-out a HEADER of applied theme
#
function theme_header ($subModName, $author) {
  $HEAD_SCRIPT = "/usr/libexec/webmin/lbs/header.cgi";
  $SCRIPT_DIR = "/usr/libexec/webmin/lbs";

  if (!file_exists($HEAD_SCRIPT)) # rien a fair
    return false;

  $currDir = getcwd();
  chdir($SCRIPT_DIR);

  $script = "$HEAD_SCRIPT"." ".$subModName." "."\"$author\"";
  
  print("<!"); # ne pas supprimer cette ligne !
  system($script, $return_val);
  chdir($currDir);

  if($return_val >= 0)
    return true;
  else
    return false;
} #~~

#
# Execute a perl function responsable for printinig-out a FOOTER of applied theme
#
function theme_footer () {
  $FOOTER_SCRIPT = "/usr/libexec/webmin/lbs/footer.cgi";
  $SCRIPT_DIR = "/usr/libexec/webmin/lbs";

  if (!file_exists($FOOTER_SCRIPT))  # rien a fair
    return false;

  $currDir = getcwd();
  chdir($SCRIPT_DIR);

  system($FOOTER_SCRIPT, $return_val);
  chdir($currDir);
    
  if($return_val >= 0)
    return true;
  else
    return false;
} #~~

#
# This function is going down the directory structure with the root in `$rooDir`
# and is searching for the files with the CSV extension. 
# It returnes a table of strings which represents a direct path to a files. 
# This path must be modified if the files should be downloadable.
#
function getFiles($rootDir, $ext) {
 
  $res = array();
  $names = array();

  #
  # fill names with directory stuff
  #
  if ($handle = opendir($rootDir)) {
    while (false !== ($file = readdir($handle)))
	array_push ($names, $file);

    closedir($handle); 
  }

  # on verifie si le fichier est un repertoire ou non
  foreach($names as $name) {
    if ((is_dir("$rootDir/$name"))&&
    	($name != "")&&
    	($name != ".")&&
    	($name != "..")) { # it's a directory, we search there for other files..
        $res = array_merge ($res, getFiles("$rootDir/$name", $ext)); # merge 2 arrays with the names of files
    }
    else { # it's a file, so we can add it to the array
      if (strstr($name, $ext)) 
        array_push($res, "$rootDir/$name");
    }
  }

return $res;
} #~~

#
# This function is giving as the result an associative array with paths to files
# indexed by the names of directories where they (files) were found.
# Now if we're looking for BIOS files, they could be found in the result table
# under the index 'BIOS'
#
function giveTableWithFiles($rootDir, $ext) {
  $tabPom = getFiles($rootDir, $ext); # array of CVS files

  #
  # create array of arrays; keys in this associative arrays
  # are the names of directories witch CSV files
  #
  foreach(split(' ', $GLOBALS['liste_dossier']) as $dos)
    $tab[$dos] = array();

  #
  # put every link under a propriate index
  #

  foreach($tab as $key => $value) {
    for ($i=0; $i<count($tabPom); $i++)  { 
          
      if(strstr($tabPom[$i], $key)) {
        array_push($tab[$key], $tabPom[$i]);
        $tabPom[$i] = -1; # unique value putted to ommit reinsertion 
                                # of this file under the 'REST' index
      }
    }
  }
  
  #
  # here will be placed the CSV files which were found directly in the 
  # root directory
  #
  $tab['REST'] = array(); 

  #
  # insert the rest of the files under the 'REST' index
  #
  for ($i=0; $i<count($tabPom); $i++)  {
    if ($tabPom[$i] != -1)
      array_push($tab['REST'], $tabPom[$i]);
  }

  return $tab;
}

#
# This function is printing out the links to all of the CSV files
#
function giveLinksToAllCSV($tab, $baseDir) {
  foreach($tab as $key => $value)  {
    echo $key."<br>";
    for ($i=0; $i<count($tab[$key]); $i++)  {   
      $tab[$key][$i] = str_replace($baseDir, "", $tab[$key][$i]); # delete the baseDir path from the path
      $address = "/lbs-inventory".$tab[$key][$i]; # file addres
      $arr = explode("/", $tab[$key][$i]); # split the table

      if (count($arr) == 3)
        $name = $arr[2];
      else
        $name = $arr[3];

      echo "<a href=$address><b>$name</b></a><br>"; # current file is the file which is not in the sub-directory 
    }
  }
}

#
# This function is giving the link to the CSV file passed as the first argumenr;
# `$index` points the exact file
#
function giveFileLink($nom_pc_csv, $index) {
  $address = "/lbs-inventory/reception_agent/".$index."/".$nom_pc_csv;

  return "<a href=$address>$nom_pc_csv</a><br>";
}

#
# Try to resolve the client's name 
#
function getIp($fichier)
{
	return "TODO";
}

#
# This function is searchnig the directory with the ETHERNET addreses
# and is giving back the array filled with this addresses 
#
function searchEtherInOCS()
{
	# list the ethernet mac address found in the OCS inventory dir
	$chemin_network=$GLOBALS['chemin_network'];
	$result=array();
	if ($dir = @opendir($chemin_network)) {
                while (($file = readdir($dir)) !== false)
                {	
                        $f = $chemin_network . '/'.$file;
                        if ( is_link($f) )
                        {
                                #TODO completer l'ip
			        $ip=getIp($f);
			        $result[$file]=array("mac" => $file, "name" => $f, "ip" => $ip);
		        }
	        }
		closedir($dir);
        }

	return $result;
}

?>
