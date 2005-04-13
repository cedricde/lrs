#! /var/lib/lrs/php
<?
#
# Choosing shared folders to backup
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

#
# Show choix template - host information and share folders to choose
#
function showMain($get_data)
{
  global $t, $text, $lbs;

  if ($lbs)
    $get_data = "?mac=".$_GET['mac']."&host=".$_GET['host'];
  else {
    $host=$_GET['host'];
    $get_data = "?host=".$_GET['host'];
  }
  
# configuration variables ---------------------
  if ( isset($_GET['xfermethod']) ) { // transport method was changed
   $xfermethod = $_GET['xfermethod'];
   $get_data = $get_data . "&xfermethod=$xfermethod";
  }

  $t->set_var("GET_DATA_BREF", $get_data);  // needed for the cancel button

  if (isset($_GET['username']) && isset($_GET['passwd'])) { // needed for smbclient
    $username = $_GET['username'];
    $get_data = $get_data . "&username=$username";
    $passwd = $_GET['passwd'];
    $get_data = $get_data . "&passwd=$passwd"; 
  }
 
  if (isset($_GET['shares']) && $_GET['shares'] != "") { // shares after multiple modifications
    $str = $_GET['shares'];
    if ($str != "") {
      $shares = explode("|", $str);
      if ($shares[count($shares) - 1] == "")
        array_splice($shares, count($shares) - 1, 1);
    }
  } else
    $shares = array();
 
  // now read the missing data
  readConfFile($_GET['host'], $xfermethod, $shares, $username, $passwd, $full, $incr, $blackout_begin, $blackout_end, $blackout_days);

  if (isset($_GET['delete']))          // delete a share from the list
    if (in_array($_GET['delete'], $shares)) {
      $i = array_search($_GET['delete'], $shares);
      array_splice($shares, $i, 1);
    }
  if (isset($_GET['found_name']) && ($_GET['found_change']) == "false") {
    if (in_array($_GET['found_name'], $shares)) {
      $i = array_search($_GET['found_name'], $shares);
      array_splice($shares, $i, 1);
    }
  }
 // add shares to $_GET array  
  $get_data = $get_data . "&shares="; 
  for ($i=0; $i<count($shares); $i++) 
    if ($shares[$i] != "")
      $get_data = $get_data . $shares[$i] . "|";

  if ( isset($_GET['add']) && $_GET['add'] != "") { // rsync - eventually add another folder
    array_push($shares, $_GET['add']);
    $get_data = $get_data . $_GET['add'] . "|"; 
  }
  if (isset($_GET['found_name']) && ($_GET['found_change'] == "true")) {
    array_push($shares, $_GET['found_name']);
    $get_data = $get_data . $_GET['found_name'];   
  }
 
  $t->set_var("GET_DATA", $get_data);  
  
  $t->set_var("HOST", $_GET['host']);
  $t->set_var("XFERMETHOD_NAME", $text{$xfermethod."_name"});

    if ($xfermethod == 'smb') 
      $shares_all = getSmbShares($_GET['host'], $username, $passwd);
    else if ($xfermethod == 'tar') 
      $shares_all = getTarShares($_GET['host']);
    else
      $shares_all = array();
 
    $warning = "";
    if ($xfermethod == 'smb' && empty($shares_all)) {
      $warning = $text{backup_empty_share}; //"The shares list is empty. Check once again the username and password.";
      $t->set_var("EMPTY_LIST", $warning);
    } else {
      $t->set_block("choix", "warning_row","warning_full_row");  
      $t->set_var("warning_full_row", "");
    }
    
    
    $t->set_block("choix", "found_share_row","found_share_rows");  
    if (empty($shares_all))
      $t->set_var("found_share_rows", "");
    else
      foreach ($shares_all as $share) {
        $t->set_var("SHARE", $share);
        if ( in_array($share, $shares) )
          $t->set_var("SHARE_CHECKED", "CHECKED");
        else  
          $t->set_var("SHARE_CHECKED", "");
        $t->parse("found_share_rows", "found_share_row", true);
      }

    $i=0;
    $t->set_block("choix", "added_share_row","added_share_rows");  
    foreach ($shares as $share) {
      if (!in_array($share, $shares_all)) {
        $t->set_var("SHARE", $share);
        $t->parse("added_share_rows", "added_share_row", true);
	$i++;
      }
    }
    $t->set_var("SHARE_SIZE", $i);

    # output everything
        
    echo perl_exec("lbs_header.cgi", array("backuppc host_configuration", $text{'tit_conf'}, "index"));
    $t->pparse("out", "choix");
    echo perl_exec("lbs_footer.cgi");
}

# --------MAIN--------------------------------

LIB_init_config();

$lbs = isLBS();

$t = tmplInit( array( "choix" => "choix.tpl" ) );

showMain($get_data);

?>
