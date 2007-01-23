<?
#
# $Id$
#

require_once(dirname(__FILE__) . "/web-lib.php");
require_once(dirname(__FILE__) . "/template.php");

# perl_exec function, to handle Perl/CGI scripts from PHP

function perl_exec($script, $args=array()) {

	global $webmin_path;
	
	$return='';
	$error=0;
	
	if ($webmin_path == "") {
		$path = "..";
	} else {
		$path = $webmin_path;
	}
	
	$handle = popen("cd ".$path."/lbs_common/;perl ".$script. ' "'.join('" "', $args).'" 2>&1', "r");
	
	if (!$handle)
		return;
	$output = '';
	while (!feof($handle)) {		# gather HTML output
		$output .= fread($handle, 1024);
	}

	$output=explode("\n", $output); 	# explode it
	
	foreach ($output as $line) {      	# we only keep pure HTML
		if (!preg_match("/content-type/i", $line))
			$return .= "$line\n";
		if (preg_match("/<\/html>/i", $line))
			$error = 1;
	}	
	# try to intercept ACL errors
	if ($error == 1 && strpos($script, "lbs_header.cgi") !== false) {
		print $return;
		exit(1);
	}
	return $return;
}


# int initLbsConf($file, $mandatory)
# Chargement de $file (/etc/lbs.conf) dans $lbsconf (hash global),
# et de lbs-lib.pl .
# attention: si $mandatory est à 0, on ne retourne pas d'erreur si le fichier
# n'est pas trouvé. Par contre on fixe le basedir en fonction de la conf.
# On effectue aussi quelques tests de verification: presence du parametre
# 'basedir', et existence du repertoire en question.
# Retourne 1 si OK, ou 0 si erreur.


function initLbsConf($file, $mandatory=0){
	global $lbsconf, $text, $config;
	
	if ( !(is_readable($file) || ($mandatory==0)) ) {
		LIB_message($text{'tit_error'}, LIB_text("err_confnf",$file)) ;
		return 0;
	}

	if (($mandatory==1) || (is_readable($file) )) {	
		$lbsconf = LIB_read_env_file($file) ;
	} else {
		$lbsconf['basedir']=$config['chemin_basedir'];
	}
	
	if (!isset($lbsconf['basedir'])) {
		LIB_message($text['tit_error'],
		LIB_text("err_paramnf", 'basedir', $file)) ;
		return 0;
	}
	
	if (!is_dir($lbsconf['basedir'])) {
		LIB_message($text['tit_error'],LIB_text("err_basedirnf", $lbsconf['basedir']));
		return 0;
	}
	
	return 1 ;
}

#
# Retourne un array qui contient le fichier /tftpboot/revoboot/etc/ether
# Il est indexé suivant la MAC ou le NOM
# Chaque entrée contient un sous-array avec les champs "ip", "name" ou "mac"
function etherLoad($bymac = 1){
  global $lbsconf;

  $ether = array();
  
  $fd = fopen ($lbsconf["basedir"]."/etc/ether", "r");
  if ($fd) while (!feof ($fd)) 
    {
      $buffer = trim(fgets($fd, 4096));
      $buffer = preg_replace("/#.*$/","",$buffer);
      $kw = preg_split("/[ \t]+/", $buffer, 3);
      if (count($kw) == 3) {
	  $mac = $kw[0];
	  $ip = $kw[1];
	  $name = $kw[2];
	  
	  if ($bymac) $ether[$mac] = array ("name" => $name, "ip" => $ip);
	  else $ether[$name] = array ("mac" => $mac, "ip" => $ip);
	}
    }

  fclose($fd);

  return $ether;

}

function etherLoadByName(){
  return etherLoad(0);
}

function etherLoadByMac(){
  return etherLoad(1);
}


#
# Affiche d'un message sur une page (utilisé pour les messages d'erreur)
# message($title, $message)
#
function LIB_message($title, $message){
#  LIB_header($title, "", "index", 1, 1, "", "");
  print "<p>$message</p>";
#  LIB_footer("","");
}


#
# New functions goes here:
#

# -------------------------------------
#
# this function simply remove the :
# from the mac address
#
function filterMac($mac){
	return str_replace(':','',$mac);
}


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
# This function is giving the link to the CSV file passed as the first argument;
# `$index` points the exact file
# modif du chemin d'acces au liens csv
function giveFileLink($nom_pc_csv, $index) {
  $address = "/lbs-inventory/dl.cgi?path=$index/$nom_pc_csv";
  return "<a href=$address>$nom_pc_csv</a><br>";
  # /lbs-transfert/transfert est un lien apache vers le repertoire contenant les uploads :)
  # /lbs-transfert = /usr/share/webmin/lbs-inventory/reception_agent
}

#
# Try to resolve the client's IP
#
function getIp($fichier){

	$f = file("$fichier","r"); # ouverture du fichier pointe par le lien dans Network
	foreach ($f as $line) $netip = split(';', $line); 
	return $netip[7]; # addresse mac ds le fichier csv
#return "$file";
	
}

#
# This function is searchnig the directory with the ETHERNET addreses
# and is giving back the array filled with this addresses 
#
function searchEtherInOCS()
{
	# list the ethernet mac address found in the OCS inventory dir
	$result=array();
	if ($dir = @opendir("$GLOBALS[chemin_CSV]/Network/")) {
                while (($file = readdir($dir)) != false){
                        $f = "$GLOBALS[chemin_CSV]/Network/$file";
                        if ( is_link($f) ){
				$ln = "true";
				$contenu = file($f,"r");
				foreach  ($contenu as $line) {
				    $linecontenu = split(";", $line);	
				    $f2 = array_reverse(split("/", $f));
				    # Remove -2005-03-16-19-15-50 at the end of the name (OCSv3)
				    $name = $linecontenu[0];
				    $name = ereg_replace("-[1-9][0-9][0-9][0-9]-[-0-9]+$", "", $name); 
				    
				    $f = $f2[0]; # on recupere l'addresse mac via le lien
				    if (str_replace(':', '', $linecontenu[5]) == $f){ 
					# et on compare a ce que le fichier contient			    
					$result[$file] = array("mac" => $linecontenu[5], 
								"name" => $name,
								"ip" => $linecontenu[7]);
		    		    }
	    			}
    			}
		}
		closedir($dir);
	}
	
	return $result;
}

# this function returns the localized timestamp of the last OCS inventory
function get_OCS_timestamp($nom_pc_csv) {
        global $chemin_CSV;
        if (file_exists("$chemin_CSV/Networks/$nom_pc_csv") && $nom_pc_csv != "") {
                return strftime("%c", filemtime("$chemin_CSV/Networks/$nom_pc_csv"));
        } else if (file_exists("$chemin_CSV/Network/$nom_pc_csv") && $nom_pc_csv != "") {
                return strftime("%c", filemtime("$chemin_CSV/Network/$nom_pc_csv"));
        } else {
                return "N/A";
        }
}


# this function returns the localized timestamp of the last LRS inventory
function get_LRS_timestamp($mac_address) {
        global $chemin_LBS;
        
        if (file_exists("$chemin_LBS/$mac_address.ini")) {
                return strftime("%c", filemtime("$chemin_LBS/$mac_address.ini"));
        } else {
                return "N/A";
        }
}

#
# Return the client list, filtered by group and/or profile
#
function filter_machines_names($profile, $group, &$ether)
{
	normalize_machine_names($ether);

	$keys = array_keys($ether);

	for ( $i=0 ; $i<count($keys) ; $i++ )
	{
		$name = $ether[ $keys[$i] ]['name'] ;

		if ( ! ( eregi("$profile:$group", $name)
			 || ( empty($profile) && eregi("(:|/)$group/", $name) )
			 || ( empty($group) && eregi("^$profile:", $name) )  ) )

			unset($ether[ $keys[$i] ]);

	}
}

#
# clean up the client list: 
#
function normalize_machine_names(&$ether)
{
	$keys = array_keys($ether);

	for ( $i=0 ; $i<count($keys) ; $i++ )
	{
		$name = & $ether[ $keys[$i] ]['name'] ;

		$profilepos = strpos($name, ':');

		if ( strpos($name, ':')===false )
		{
			$profilepos = 0;
			$name = ':'. $name;
		}

		if ( strpos($name, '/', $profilepos+1)===false )

			$name = substr($name,0,$profilepos+1) . '/' . substr($name,$profilepos+1);

	}

}

# 
# Return the string to source ssh-agent variables if available
#
function get_keychain()
{
	$out = "";
	exec("uname -n", $out);
	if (file_exists("/root/.keychain/$out[0]-sh")) {
		$lines = file("/root/.keychain/$out[0]-sh");
		$line = explode(";", $lines[0]);
		return("env $line[0]");
	}
	return("");
}

?>