#! /var/lib/lrs/php
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

include "backupfun.php";

$lbs = isLBS();

if ($lbs) {
	include_once("lbs-backuppc.php");
} else {
	include_once( "fonctions.cgi" );
	include_once( "lbs-common.php" );
	include_once('../lbs_common/web-lib.php');
	include_once("templates/template.inc");
}

function showMain()
{
  global $t, $text, $lbs;
 
# variables to write in file ------------------------
  if ($lbs)
    $get_data = "?mac=".$_GET['mac']."&host=".$_GET['host']; 
  else
    $get_data = "?host=".$_GET['host']; 
    
  $t->set_var("GET_DATA_BREF", $get_data); 
  
  $host=$_GET['host'];
  $xfermethod=$_POST['xfermethod'];
  if (!isset($_GET['shares']))
    readConfFile($_GET['host'], $xfermethod, $shares, $username, $passwd, $full, $incr);
  else 
    $shares=explode("|" ,$_GET['shares']);

  $shares_str="[ '$shares[0]' ";
  for ($i=1; $i < count($shares); $i++) 
    if ($shares[$i] != '')
      $shares_str = $shares_str . ", '$shares[$i]'";
  $shares_str = $shares_str . "]";
 
  if ( $xfermethod == "smb" || $xfermethod == "rsyncd") {  
    $username=$_POST['username'];
    $passwd=$_POST['passwd'];
  }
  
  $full=$_POST['full'];
  $incr=$_POST['incr'];
 
  $blackout_begin=$_POST["blackout_begin"];
  $blackout_end=$_POST["blackout_end"];
  if (!empty($_POST['blackout_days'])) {
    $blackout_days = $_POST['blackout_days'][0];
    for ($i=1; $i<count($_POST['blackout_days']); $i++) 
      $blackout_days .= ",".$_POST["blackout_days"][$i];
  } else 
    $blackout_days="";
  
# save file

  saveBackupFile($_GET['host'], $xfermethod, $shares_str, $username, $passwd, $full, $incr,
                 $blackout_begin, $blackout_end, $blackout_days);
  

# and show it 
 
  $t->set_var("HOST", $host);
  if ($xfermethod == "tarssh")
    $t->set_var("XFERMETHOD", "tar");
  else
    $t->set_var("XFERMETHOD", $xfermethod);
  $t->set_var("SHARES_STR", $shares_str);
  $t->set_var("USERNAME", $username);
  $t->set_var("PASSWD", "********");

  $t->set_block("affiche", "smb", "smb_full");
  if ($xfermethod == "smb" ) {

    $t->parse("smb_full", "smb");
  } else {
    $t->set_var("smb_full", "");
  }
  
  $t->set_block("affiche", "tar", "tar_full");
  if ($xfermethod == "tar" ) {
//    $t->set_var("SHARES_STR", $shares_str);
    $t->parse("tar_full", "tar");
  } else {
    $t->set_var("tar_full", "");
  }
 
  $t->set_block("affiche", "tarssh", "tarssh_full");
  if ($xfermethod == "tarssh" ) {
//    $t->set_var("SHARES_STR", $shares_str);
    $t->parse("tarssh_full", "tarssh");
  } else {
    $t->set_var("tarssh_full", "");
  }
  
  $t->set_block("affiche", "rsync", "rsync_full");
  if ($xfermethod == "rsync" ) {
//    $t->set_var("SHARES_STR", $shares_str);
    $t->parse("rsync_full", "rsync");
  } else {
    $t->set_var("rsync_full", "");
  }
  
  $t->set_block("affiche", "rsyncd", "rsyncd_full");
  if ($xfermethod == "rsyncd") {
  /*  $t->set_var("SHARES_STR", $shares_str);
    $t->set_var("USERNAME", $username);
    $t->set_var("PASSWD", $passwd);*/
    $t->parse("rsyncd_full", "rsyncd");
  } else {
    $t->set_var("rsyncd_full", "");
  }
 
  $t->set_var("FULL", $full);
  $t->set_var("INCR", $incr);
 
  $t->set_var("BLACKOUT_BEGIN", $blackout_begin);
  $t->set_var("BLACKOUT_END", $blackout_end);
  $t->set_var("BLACKOUT_DAYS", $blackout_days);
 

  # output everything
  
  echo perl_exec("lbs_header.cgi", array("backuppc host_configuration", $text{'tit_conf'}, "index")); 
  $t->pparse("out", "affiche");
  echo perl_exec("lbs_footer.cgi");

}


# --------MAIN--------------------------------

LIB_init_config();

$t = tmplInit( array( "affiche" => "affiche.tpl" ) );

showMain();


?>
