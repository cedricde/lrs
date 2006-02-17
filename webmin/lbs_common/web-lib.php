<?php
#
# $Id$
#
# Common functions and definitions for web admin programs
# Translated from web-lib.pl. Compatible with php >= 4.2.0
#
# Copyright (C) 2003 Free & ALter Soft, Linbox, Ludovic Drolez
#
# Distributed under the terms of the modified BSD license.
#
# Initial translation done by Nicolas FAURANT.
#

# Vital libraries

# Configuration and spool directories
$config_directory = getenv("WEBMIN_CONFIG");
//$webmin_path = getenv("PATH_TRANSLATED");
$webmin_path = getenv("SERVER_ROOT");
$var_directory = getenv("WEBMIN_VAR");
$module_name = getenv("SCRIPT_NAME");
list($nul,$module_directory,$_nul)=split("/",$module_name);
$base_remote_user = getenv("BASE_REMOTE_USER");
$remote_user = getenv("REMOTE_USER");
//__DATA__


/*---------------------------lib_PrintHeader($charset)----------------------------
Outputs the http header for HTML
*/  
function lib_PrintHeader($charset){
  $num_args=func_num_args(); //number of arguments passed to the function
  if($pragma_no_cache || $config[pragma_no_cache])
    Header("Pragma: no-cache\n");
  if($num_args>0)
    header("Content-type: text/html; Charset=$charset\n\n");
  else Header("Content-type: text/html\n\n");
}

/*--lib_header($title,$image,$help,$config,$nomodule,$nowebmin,$rightside,$header,$body)-----
Output a page header with some title and image. The header
may also include a link to help, and a link to the config
page.  The header will also have a link to the webmin index,
and a link to the module menu if there is no config link.
*/
function lib_header($title=undef,$image=undef,$help=undef,$config=undef,$nomodule=undef,
		    $nowebmin=undef,$rightside=undef,$header=undef,$body=undef){
global $gconfig;
global $text;
global $tconfig;
global $remote_user;
global $module_name;
global $module_info; 

	$num_args=func_num_args(); //number of arguments passed to the function
     
	# trouver le nom de la module presante
	if($gconfig["lang"]=="en")
		$tit = substr($title, 0, strpos($title, " "));
	else
		$tit = $title;
	
	if (function_exists('theme_header')) {
	    if (theme_header($tit, $rightside)) 
        	return;
	}
   
	$charset=$force_charset ? $force_charset : "iso-8859-1";
	lib_PrintHeader($charset);
	
	echo"<!doctype html public \"-//W3C//DTD HTML 3.2 Final//EN\">\n";
	echo"<html>\n";
	if($charset){
		echo"<meta http-equiv=\"Content-Type\" content=\"text/html; Charset=$charset\">\n";	
	}
    
	$os_type	=       $gconfig[real_os_type]  	? $gconfig[real_os_type]        : $gconfig[os_type];
	$os_version     =       $gconfig[real_os_version]       ? $gconfig[real_os_version]     : $gconfig[os_version];
	$hostname       = lib_get_system_hostname();
	$webmin_version = lib_get_webmin_version();
  
	echo"<head>\n"; 
   
	if($num_args > 0){

		if ($gconfig[sysinfo] == 1)
			echo"<title>$title: $remote_user on $hostname ($os_type $os_version)</title>\n";
		else
			echo"<title>$title</title>\n";

		if ($gconfig[sysinfo] == 0 && $remote_user) {
			$ssl_user=getenv("SSL_USER");
			$local_user=getenv("LOCAL_USER");		
			
			if($ssl_user)
				$_user="(SSL certified)";
			elseif($local_user)
				$_user="(Local user)";
			else
				$_user="";    
			echo "<SCRIPT LANGUAGE=\"JavaScript\">\n";
			echo "defaultStatus=\"$remote_user$_user logged into Webmin $webmin_version on $hostname ($os_type $os_version)\"\n";
			echo "</SCRIPT>\n";
		}
	}

	if ($tconfig[headhtml])
		echo"$tconfig[headhtml]\n";


	if ($tconfig[headinclude]) {
		$file=$module_name ? "../$gconfig[theme]/$tconfig[headinclude]" : "$gconfig[theme]/$tconfig[headinclude]";
		
		$INC=fopen($file,"r");
		
		while(!feof($INC)){
			$current_line=fgetss($INC,255);
			echo"$current_line";
		}
		
		fclose($INC);
	}
	
	echo"</head>\n";
	
	if ($tconfig[cs_page])
		$bgcolor=$tconfig[cs_page];
	elseif ($gconfig[cs_page])
		$bgcolor=$gconfig[cs_page];
	else
		$bgcolor="ffffff";
	
	if ($tconfig[cs_link])
		$link=$tconfig[cs_link];
	elseif ($gconfig[cs_link])
		$link=$gconfig[cs_link];
	else
		$link="0000ee";
		
	if ($tconfig[cs_text])
		$_text=$tconfig[cs_text];
	elseif ($gconfig[cs_text])
		$_text=$gconfig[cs_text];
	else
		$_text="000000";
		
	if ($tconfig[bgimage])
		$bgimage="background=$tconfig[bgimage]"; 
	else
		$bgimage="";
	
	# FIXME: vérifier que body n'est pas undef	
	echo "<body bgcolor=#$bgcolor link=#$link vlink=#$link text=#$_text $bgimage $tconfig[inbody] $body>\n";
	
    
	$hostname = lib_get_system_hostname();
	$version = lib_get_webmin_version();
	$prebody = $tconfig[prebody];
	
	if ($tconfig[prebodyinclude]) {
		$file= $module_name ? "../$gconfig[theme]/$tconfig[prebodyinclude]" : "$gconfig[theme]/$tconfig[prebodyinclude]";
		$INC=fopen($file,"r");
		
		while(!feof($INC)){
			$current_line=fgetss($INC,255);
			echo"$current_line";
		}
		
		fclose($INC);
	}
	
	if ($num_args > 1) {
	
		echo "<table width=100%><tr>\n";
		
		if ($gconfig[sysinfo] == 2 && $remote_user) {
			$ssl_user=getenv("SSL_USER");
			$local_user=getenv("LOCAL_USER");		
			
			if($ssl_user)
				$_user="(SSL certified)";
			elseif($local_user)
				$_user="(Local user)";
			else
			$_user="";
			
			echo "<td colspan=3 align=center>\n";
			echo "<tt>$remote_user</tt>$_user logged into Webmin $version on \"<tt>$hostname</tt>\" ($os_type $os_version)</td>\n";
			echo "</tr> <tr>\n";
		}
		
		echo"<td width=15% valign=top align=left>";
		
		$http_webmin_server=getenv("HTTP_WEBMIN_SERVERS");
		
		if ($http_webmin_server) {
			echo"<a href='$http_webmin_server'>$text[header_servers]</a><br>\n";
		}
		
		if ($nowebmin!=undef){
			echo"<a href=\"/?cat=$module_info[category]\">$text[header_webmin]</a><br>\n"; 
		}
		
		if ($nomodule!=undef) { 
			echo"<a href=\"./\">$text[header_module]</a><br>\n"; 	
		}
		
		if (is_array($help)) {
			echo lib_hlink($text[header_help], $help[0], $help[1]),"<br>\n";
		} elseif ($help!=undef) {
			echo lib_hlink($text[header_help], $help),"<br>\n";
		}
		
		if ($config!=undef) {
			$access = lib_get_module_acl();
			$mod_name = lib_get_module_name();
			
			if (!$access[noconfig]) {
				echo"<a href=\"/config.cgi?$mod_name\">",
				$text[header_config],"</a><br>\n";
			}
		}
		
		echo"</td>\n";
		
		ereg("s/&auml;/ä/g",$title); //	$title =~ s/&auml;/ä/g;
		ereg("s/&ouml;/ö/g",$title); //$title =~ s/&ouml;/ö/g;
		ereg("s/&uuml;/ü/g",$title); //$title =~ s/&uuml;/ü/g;
		ereg("s/&nbsp;/ /g",$title); //$title =~ s/&nbsp;/ /g;
		
		if (!empty($image)) {
			echo"<td align=center width=70%><img alt=\"$title\" src=\"$image\"></td>\n";
		} elseif (!$gconfig{'texttitles'} && !$tconfig{'texttitles'}) {
			print "<td align=center width=70%>";
			
			for ($i=0; $i < strlen($title); $i++) {
				$l = $title[$i];
				$ll = ord($l);
	
				if ($l == " ") {
					echo "<img src=/images/letters/$ll.gif alt=\"\&nbsp;\" align=bottom>";
				} else {
				  echo "<img src=/images/letters/$ll.gif alt=\"$l\" align=bottom>";
				}
			}
		} else {
			echo"<td align=center width=70%><h1>$title</h1></td>\n";
		}
		
		echo"<td width=15% valign=top align=right>";
		echo $rightside;
		echo"</td></tr></table>\n";
	
	}
}

/*------------------------------------lib_hlink($text,$page,$module)-------------------------
Returns HTML for alink to help page. The first parameter is the test of the 
link and the second the name of the help page.
*/
function lib_hlink($text,$page,$module=undef){
  $mod_name=lib_get_module_name();
  $mod=($module!=undef) ? $module : $mod_name;
  return "<a onClick='window.open(\"/help.cgi/$mod/$page\", \"help\", \"toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes\"); return false' href=\"/help.cgi/$mod/$page\">$text</a>";
}

/*------------------------------------lib_get_system_hostname()---------------------------------
Returns the hostname of this system
*/
function lib_get_system_hostname(){
  $hostname=`hostname`; //run a shell command
  return $hostname ;
}

/*------------------------------------lib_get_webmin_version()---------------------------------
Returns the version of Webmin currently being run
*/
function lib_get_webmin_version(){
  //$VERSION=fopen("../version","r") || VERSION=fopen("../version","r");
    
  //flose($VERSION);
  return 0.91;
}

/*------------------------------------lib_get_module_acl($user,$module)---------------------------------
Return an array containing acces control options for the given user 
*/
function lib_get_module_acl($user=undef,$module=undef){
  global $base_remote_user;
  global $remote_user;
  global $module_name;
  global $config_directory;
  global $gconfig; //associative array
    
  //    $u=($user!=undef) ? $user : $base_remote_user;
  //    $u=($user!=undef) ? $user : $remote_user;
  $u=($user!=undef) ? $user : "admin"; //admin par defaut		
  //echo"user:$u<br>";
  //echo"base_remote_user:$base_remote_user<br>";
  $mod_name=lib_get_module_name();    
  $m=($module!=undef) ? $module : $mod_name;
  //echo"module:$m:$module<br>";    
  $rv=lib_read_file($module_name ? "../$m/"."defaultacl" : ".$m"."defaultacl");
  if($gconfig["risk_$u"] && $m){
    $rf=$gconfig["risk_u"].'.risk';
    $rv=lib_read_file($module_name ? "../$m/$rf" : "./$m/$rf");
    $sf=$gconfig["skill_u"].'.skill';
    $rv=lib_read_file($module_name ? "../$m/$sf" : "./$m/$sf");
  }
  else $rv=lib_read_file("$config_directory/$m/$u.acl");
    
  return $rv;
}
/*------------------------------------lib_get_module_name()---------------------------------
Returns the name of the current module.This fonction is useful in php because 
if the script exemple.cgi is run module_name=/module_name/example.cgi.
*/
function lib_get_module_name(){
  global $module_name;
  list($nul,$mod_name,$_nul)=split("/",$module_name);
  return $mod_name;
}

/*------------------------------------lib_footer($page,$name)---------------------------------
Output a footer for returning to some page
*/
function lib_footer($page,$name){
  //Global variables used in this function
  global $text; //$text is an associative array initialised in init_config
  global $module_info; //associative array
  global $module_name;

  if (function_exists('theme_footer')) {
    if (theme_footer()) 
	return; 
  }
  
  $url=$page;
  if($url == "/"){
    $url="/?cat=$module_info[category]";
  }
  elseif($url == "" && $module_name){
    $url=" ";//return to the last page
  }
  elseif( ereg("?",$url) || ereg($module_name,$url) ){
    $url="/$module_name/$url";
  }
    
  $link=lib_text("main_return",$name);

  echo "<a href=\"$url\"><img alt=\"<-\" align=middle border=0 src=/images/left.gif></a>\n";
  echo "<a href=\"$url\">$link</a><br>\n";
}


/*--------------------------------------lib_read_file($file)----------------------------------
Fill an associative array with name=value pairs from a file
*/
function lib_read_file($file){
  $delimiter="=";
  if(is_dir($file))
    return -1;
  if (!file_exists($file))
	  return -1;
  if(!$fp=fopen($file,"r")) 
    return -1;
  while(!feof($fp)){
    $current_line=fgets($fp,255);
    $current_line=trim($current_line);
    //trim delete all space in the string, try chop() and ltrim()
    
    list($option,$value)=explode($delimiter,$current_line,2);
    $assoc_array[$option]=$value;
  }
  fclose($fp);
  return $assoc_array;
}
/*-------------------------------------lib_init_config()------------------------------------
set the following variables:
    $gconfig : Global configuration
    $config : module configuration
    $module_info
    $tconfig
    $tb - Background for table headers
    $cb - Background for table bodies
    $current_lang
    global $link_css;
    
*/     
function lib_init_config(){
  //Global variables used in this function
  global $config_directory;
  global $module_name;
  global $module_directory;
  global $webmin_path;
  global $cb, $tb;
  global $current_lang;
  global $gconfig, $tconfig;
  global $link_css;
  
  global $remote_user;
  $link_css = "./tmpl/presentation.css";

  //Read the webmin global config file and fill the associative array $gconfig
  $GLOBALS["gconfig"]=lib_read_file($config_directory."/config");
  
  //Set PATH and LD_LIBRARY_PATH
  //if($gconfig[path]) putenv(PATH=$gconfig[path]);
  //if($gconfig[ld_env]) putenv($gconfig[ld_env]=gconfig[ld_path]);

  list($nul,$m,$_nul)=split("/",$module_name);
  $GLOBALS["config"]=lib_read_file($config_directory."/".$m."/config");
  
  $GLOBALS["module_info"]=lib_read_file($webmin_path."/".$module_directory."/module.info");
  //Load language string into associative array named $text
  $GLOBALS["text"]=lib_load_language();
    
  $theme=lib_check_key_array($GLOBALS["gconfig"],theme);

  if($theme){
    $tconfig = lib_read_file($module_name ? $webmin_path . "/" . $theme . "/config"
				      : $webmin_path . "../" . $theme . "/config");
  }

  // set default table colors
  $tb = "bgcolor=#9999ff";
  if (isset ($gconfig['cs_header'])) $tb = "bgcolor=#".$gconfig['cs_header'];
  if (isset ($tconfig['cs_header'])) $tb = "bgcolor=#".$tconfig['cs_header'];

  $cb = "bgcolor=#cccccc";
  if (isset ($gconfig['cs_table'])) $cb = "bgcolor=#".$gconfig['cs_table'];
  if (isset ($tconfig['cs_table'])) $cb = "bgcolor=#".$tconfig['cs_table'];

  $current_lang = isset($gconfig["lang_$remote_user"]) ? $gconfig["lang_$remote_user"] : 
	    (isset($gconfig["lang"]) ? $gconfig["lang"] : "en");
    
  // $key=lib_array_to_keystring($GLOBALS["text"]);
  // $val=lib_array_to_valstring($GLOBALS["text"]);
  // echo"<br>$key<br>$val<br>";    

  //    echo"sans arg<br>";
  //    lib_ReadParse();
  //    echo"avec gconfig<br>";
  //    lib_ReadParse($GLOBALS["gconfig"]);
  //test_display_array($GLOBALS["gconfig"]); 
}

/*----------------------lib_check_key_array($assoc_array,$key)-----------------------------
check if the key passed to the function exist,return the corresponding value else return 0  
if(lib_check_key_array($GLOBALS["gconfig"],theme)){
	echo"existing key<br>"; 
    }
    else echo"this key is not in this array<br>";
}
*/     
function lib_check_key_array($assoc_array,$key){
  //test_display_array($assoc_array);  
  if($assoc_array[$key]) $rv=$assoc_array[$key];
  else $rv=0;
  return $rv; 
}

/*---------------------------lib_ReadParse($assoc_array,$method)----------------------------
fills the given associative array with cgi paramaters, or uses the globals $in
if none is given.
*/     
function lib_ReadParse($assoc_array=undef,$method=undef){

#### DON'T TRANSLATE ####
# php has got it's own code to get params
# so this isn't needeed
}
/*sub ReadParse
{
local $a = $_[0] ? $_[0] : \%in;
local $i;
local $meth = $_[1] ? $_[1] : $ENV{'REQUEST_METHOD'};
undef($in);
if ($meth eq 'POST') {
	read(STDIN, $in, $ENV{'CONTENT_LENGTH'});
	}
if ($ENV{'QUERY_STRING'}) {
	if ($in) { $in .= "&".$ENV{'QUERY_STRING'}; }
	else { $in = $ENV{'QUERY_STRING'}; }
	}
@in = split(/\&/, $in);
foreach $i (@in) {
	local ($k, $v) = split(/=/, $i, 2);
	$k =~ s/\+/ /g; $k =~ s/%(..)/pack("c",hex($1))/ge;
	$v =~ s/\+/ /g; $v =~ s/%(..)/pack("c",hex($1))/ge;
	$a->{$k} = defined($a->{$k}) ? $a->{$k}."\0".$v : $v;
	}
}*/
/*---------------------------lib_redirect($url)----------------------------
Output headers to redirect the browser to some page
*/     
function lib_redirect($url){
  global $module_info;
  $server_port=getenv("SERVER_PORT");
  $https=getenv("HTTPS");
  $server_name=getenv("SERVER_NAME");
  $script_name=getenv("SCRIPT_NAME ");
    
  if( ($server_port==443) && ($https=="ON")) $port="";
  elseif( ($server_port==80) && ($https!="ON")) $port="";
  else $port=$server_port;	    
  if($https=="ON") $prot="https";
  else $prot="http";
    
  if(ereg("http",$url) | ereg("https",$url) | ereg("ftp",$url) | ereg("gopher",$url)){
    Header("Location: $url");
  }
  elseif(ereg("/^\//",$url)){
    Header("Location: $prot://$server_name:$port$url");
  }
  elseif(ereg("/^(.*)\/[^\/]*$/",$sript_name)){
    Header("Location: $prot://$server_name:$port$1/$url");
  }
  elseif($url==""){//return to the current module category 
    Header("Location: $prot://$server_name:$port/$url/?cat=$module_info[category]");
  }
  else Header("Location: $prot://$server_name:$port/$url"); 
}

/*---------------------------lib_get_module_info($module)----------------------------

*/     
function lib_get_module_info($module){

}

/*---------------------------lib_load_language()----------------------------
Returns a hashtable mapping text codes to strings in the appropriate language
*/     
function lib_load_language(){
	//Global variables used in this module	
	global $webmin_path, $gconfig, $module_name, $remote_user, $module_directory;
	
	// should we backport webmin's @lang_order_list to phpwebmin ??
	$lang = $gconfig[lang];
	if ( $gconfig["lang_".$remote_user] != "")
		$lang = $gconfig["lang_".$remote_user];
	
	//fill the associative array $text with the correct language
	//firsty with general text codes: /path/to/webmin-0.91/lang/current_language
	if (!$lang) {
		$lang="en";
		$gconfig['lang']=$lang;
	}


	$text=lib_read_file($webmin_path."/lang/".$lang);

	//secondly with module text codes: /path/to/webmin-0.91/current_module/lang/current_language
	if($module_name){
		$text_mod=lib_read_file(realpath($webmin_path . "/" . $module_directory . "/lang/".$lang));
	
		//fill $text with the content of $text_mod
		if (is_array($text_mod))
			while(list($key,$value)=each($text_mod))
				$text[$key]=$value;
	}
	return $text;
}

/*------------------------lib_text($message,$substitute,$sub2,$sub3)--------------------------
Looks up the given message in the appropriate language translation file, replaces
the text $1, $2 and so on with the rest of the parameters, and returns the result.
I suppose there is only 3 substituted arguments passed to the function($1,$2,$3).
If an other substituted argument is added, you should add one for this function.
To check the number of substituted arguments open read this file: 
/path/to/webmin-0.91/lang/en     
*/     
function lib_text($message,$substitute,$sub2=nul,$sub3=nul){
  global $text; //$text is an associative array
    
  $rv=$text[$message];
  $num_args=func_num_args(); //number of arguments passed to the function
  $args_list=func_get_args(); //$args_list is an associative array
    
  for($i=1;$i<$num_args;$i++){
    $replace=func_get_arg($i);
    $rv=str_replace("\$$i",$replace,$rv);
  }
  return $rv;
}

/*-------------------------lib_array_to_keystring($assoc_array)--------------------------------
Push all key of an array into a string Instead of passing an array from
a script to an other one(it's not possible with php???), we could passed
a string.So this function built a string with all key of this array
*/
function lib_array_to_keystring($assoc_array){
  $separator=" |#| ";
  while(list($key,$value)=each($assoc_array)){
    if($key!="") $key_string=$key_string.$key.$separator;
  }    
  return $key_string;
}
/*---------------------------lib_array_to_valstring($assoc_array)--------------------------------
this function built a string with all value of an array 
*/
function lib_array_to_valstring($assoc_array){
  $val_string=implode(" |#| ",$assoc_array);
  return $val_string;
}
/*---------------------------lib_convert_str_to_array($keystr,$valstr)--------------------------------
This function built an associative array from 2 strings.
I didn't used explose because keys become numbers.   
*/
function lib_convert_str_to_array($keystr,$valstr){
  while(list($key,$value)=each($assoc_array)){
    
  }
}

/*--------------lib_read_env_file($file)----------------------------
Reads a file of /bin/sh variable assignments in key=value or 
key = "value" format into the given associative array.
*/
function lib_read_env_file($file) 
{
  $arr = array();

  $fd = fopen($file, "r");
  if (!$fd) return($arr);
  while (!feof ($fd)) {
    $buffer = fgets($fd, 4096);
    $buffer = preg_replace("/#.*$/","",$buffer);
    if (preg_match('/([A-Za-z0-9_\.]+)\s*=\s*"(.*)"/', $buffer, $m) ||
	preg_match("/([A-Za-z0-9_\.]+)\s*=\s*'(.*)'/", $buffer, $m) ||
	preg_match("/([A-Za-z0-9_\.]+)\s*=\s*(.*)/", $buffer, $m)) 
      {
	$arr[$m[1]] = $m[2];
      }
  }
  fclose($fd);

  return($arr);
}

######################### NEW FUNCTIONS BELOW ##########################

#
# Set the default templates path according to language settings
# Input: an optionnal array for setting initial templates files. (the array is
#        passed to )
# Return: a phplib template object
#
# Notes
# - Template files are in the tmpl directory. The 'en' subdirectory contains 
#   english templates, 'fr' french ones and so on...
# - $tb and $cb global variables are mapped to {TB} and {CB} template variables
#
function tmplInit($arr = array())
{
  global $gconfig, $tb, $cb, $remote_user;

  $l = $gconfig["lang"];
  // should we backport webmin's @lang_order_list to phpwebmin ??
  if ( $gconfig["lang_".$remote_user] != "") {
    $l = $gconfig["lang_".$remote_user];
  }
  
  $d = "./tmpl/$l";
  if (!is_dir($d) || $l == "") {
    $d = "./tmpl/en";
  }
  
  $tpl = new Template($d, "remove");
  $tpl->set_file($arr);
  $tpl->set_var(array(
		      "TB" => $tb,
		      "CB" => $cb
		      ));

  return ($tpl);
}

			       
?>
