#! /var/lib/lrs/php
<?
# Configuration of BackupPC hosts
#
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

include_once("lbs-backuppc.php");
LIB_init_config();

#
# Show Main template
#
function showMain($ether)
{
  global $t, $text, $lbs;
  
  if ($lbs) {
    $host = $ether[$_GET['mac']]['name'];
    # remove the group name
    $host = preg_replace("/(.*\/)/", "", $host);
    $host = strtolower($host);
    
    $ip = $ether[$_GET['mac']]['ip'];
    $get_data = "?mac=".$_GET['mac']."&host=".$host;
  } else {
    $host=$_GET['host'];
    $get_data = "?host=".$_GET['host'];
  }
# GET_DATA_BREF for the onChange event of the transport method selection
  $t->set_var("GET_DATA_BREF", $get_data);  
  
# -- intermediate screen if the machine is not registered in the backuppc  -- 

  if (isset($_GET['dhcp'])) {
    changeDHCP($host, $_GET['dhcp']);
  } else {
    if (!hostBackuped($host))
      if ($_POST['confirm'] != "") {
	addBackuppcHost($host);
      } else {
	# show a confirmation form
	$t->set_file("confirm", "confirm_new.tpl");
	echo perl_exec("lbs_header.cgi", array("backuppc3 host_configuration", $text{'tit_conf'}, "index"));
	$t->pparse("out", "confirm");
	echo perl_exec("lbs_footer.cgi");
	return;
      }
    
  }
  
  if (isset($_GET['ssh_key'])) {
    if ($_GET['ssh_key'] == "download") {
      $file = "/var/lib/backuppc/.ssh/BackupPC_id_rsa.pub";
      header("Content-type: application/force-download");
      header("Content-Transer-Encoding: Binary");
      header("Content-length: " . filesize($file));
      header("Content-disposition: attachment; filename=".basename($file));
      readfile("$file");
    } else
    if ($_GET['ssh_key'] == "generate") {
      generateSshKey();
    }
  }
    
# gather the configuration variables ---------------------
 
  if ( isset($_GET['restore']) ) { // restore button was pushed - read everything from the file
    unset($xfermethod);
    unset($shares);
  } else {
    if ( isset($_GET['xfermethod']) ) { // transport method was changed
      $xfermethod = $_GET['xfermethod'];
      $get_data = $get_data . "&xfermethod=$xfermethod";
    }
    if (isset($_REQUEST['username']) && isset($_REQUEST['passwd'])) { // needed by smbclient in choix.php
      $username = $_REQUEST['username'];
      $passwd = $_REQUEST['passwd'];
    }
    if (isset($_REQUEST['selshares'])) { // got share from rsync or from multiple changes
      $shares = split("\|", $_REQUEST['selshares']);
      if ($shares[count($shares) - 1] == "")
        array_splice($shares, count($shares) - 1, 1);
    } 
  }
  // now read the file for the missing variables
  readConfFile($host, $xfermethod, $shares, $username, $passwd, $full, $incr, $blackout_begin, $blackout_end, $blackout_days);
  $get_data = $get_data . "&shares=";
  $fshares = "";
  for ($i=0; $i<count($shares); $i++) 
    if ($shares[$i] != "") {
      $get_data = $get_data . $shares[$i] . "|";
      $fshares .= $shares[$i] . "|";
    }
 
# set the configuration variables in the template ---------------------
  $t->set_var("GET_DATA", $get_data);  
  $t->set_var("HOST", $host);
  $t->set_var("MAC", $_REQUEST['mac']);
  $t->set_var("SHARES", $fshares);
 
  if (getDHCP($host) == 1) {
    $t->set_var("0_SELECTED", "");
    $t->set_var("1_SELECTED", "CHECKED");
  }
  else {
    $t->set_var("1_SELECTED", "");
    $t->set_var("0_SELECTED", "CHECKED");
  } 
  $t->set_block("main", "share_row","share_rows");  
  if (empty($shares)) {
    $t->set_var("SHARE", "Aucun");
    $t->parse("share_rows", "SHARE", true);
 }
  else
    foreach ($shares as $share) {
      $t->set_var("SHARE", $share);
      $t->parse("share_rows", "share_row", true);
    }
  
  if ($xfermethod == "smb") {
    $t->set_block("main", "auth_ssh", "auth_ssh_full");
    $t->set_var("auth_ssh_full");
  }
  $t->set_block("main", "ssh_key", "ssh_key_full");
  $t->set_block("main", "ssh_key_gen", "ssh_key_gen_full");
  if ($xfermethod == "tarssh") {
    if (sshKeyExists()) {
      $t->parse("ssh_key_full", "ssh_key");
      $t->set_var("ssh_key_gen_full", "");
    } else {
      $t->parse("ssh_key_gen_full", "ssh_key_gen");
      $t->set_var("ssh_key_full", "");
    }
  } else {
    $t->set_var("ssh_key_full", "");
    $t->set_var("ssh_key_gen_full", "");
  }
 
  $t->set_block("main", "user_pass", "user_pass_full");
  if ($xfermethod == "smb" || $xfermethod == "rsyncd") {
    $t->set_var("USERNAME", $username);
    $t->set_var("PASSWD", $passwd);
    $t->parse("user_pass_full", "user_pass");
  } else {
    $t->set_var("user_pass_full", "");
  }

  $t->set_var("FULL", $full);
  $t->set_var("INCR", $incr);
 
  if ( $xfermethod == "smb" ) 
    $t->set_var("SMBSELECTED", "SELECTED");  
  else
    $t->set_var("SMBSELECTED", "");
  if ( $xfermethod == "tar" )
    $t->set_var("TARSELECTED", "SELECTED");
  else
    $t->set_var("TARSELECTED", "");	
  if ( $xfermethod == "tarssh" )
    $t->set_var("TARSSHSELECTED", "SELECTED"); 
  else
    $t->set_var("TARSSHSELECTED", "");
  if ( $xfermethod == "rsync" ) 
    $t->set_var("RSYNCSELECTED", "SELECTED");
  else
    $t->set_var("RSYNCSELECTED", "");
  if ( $xfermethod == "rsyncd" ) 
    $t->set_var("RSYNCDSELECTED", "SELECTED");  
  else
    $t->set_var("RSYNCDSELECTED", "");
  $t->set_var("BLACKOUT_BEGIN", $blackout_begin);   
  $t->set_var("BLACKOUT_END", $blackout_end);   
  
  for ($i=0; $i<7; $i++) {
    if ($blackout_days[$i])
      $t->set_var("CHECKED_".$i, "CHECKED");     
    else
      $t->set_var("CHECKED_".$i, "");     
  }
 

  # output everything
  echo perl_exec("lbs_header.cgi", array("backuppc3 host_configuration", $text{'tit_conf'}, "index"));
  $t->pparse("out", "main");
  echo perl_exec("lbs_footer.cgi");

}

# --------MAIN--------------------------------

if ($lbs) {
  initLbsConf($config['lbs_conf']);

  if ( !isset($_GET['mac']) || $_GET['mac'] == "" ) {
    header("Location: ../lbs/");
    exit;
  }
}

$t = tmplInit( array("main" => "main.tpl" ) );

# insertion of menu header
$t->set_block("main", "menu", "menu_block");

if ($lbs)
  $ether = etherLoadByMac();

showMain($ether);

?>
