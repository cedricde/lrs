#! /var/lib/lrs/php
<?
# Configuration of BackupPC
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

include "gen_backupfun.php";

$lbs = isLBS();

include_once("lbs-backuppc.php");


function insertMenu($tmpl_file) {
  global $t, $chemin_menu, $tab_menu, $lbs;
  
# insertion of menu header
# pour l'instant les menus ne marchent pas - on fait un cadre et c'est tout
	$t->set_block($tmpl_file, "menu", "menu_block");
  
	$t->set_var("MENU", $tab_menu[0]); 
	//  $t->set_var("MENU", ""); 
	$t->parse("menu_block", "menu", true);
	
	# insertion of menu footer
	$t->set_block($tmpl_file, "fin_menu", "fin_menu_block");
	$t->set_var("FIN_MENU", ""); 
	$t->parse("fin_menu_block", "fin_menu", true);
}

#
# Show Main template
#
function showMain()
{
  global $t, $text, $lbs;

# gather the configuration variables ---------------------
  $opts = array();
  if (!isset($_POST["submitted"]))
    readGenConfFile($wakeup, $maxbackups, $blackoutbegin, $blackoutend, $blackoutdays, $dhcps, $opts);
  else {
    $wakeup=$_POST["wakeup"];
    $maxbackups=$_POST["maxbackups"];
    $blackoutbegin=$_POST["blackoutbegin"];
    $blackoutend=$_POST["blackoutend"];
    $blackoutdays=array();
    for ($i=0; $i<7; $i++) 
      $blackoutdays[$i] = (in_array($i, $_POST["blackout"]));
    
    $i=0;
    $dhcps=array();
    while (isset($_POST["dhcp_".$i])) {
      $dhcps[$i]=$_POST["dhcp_".$i];
      $i++;
    }
    
    if ($_POST["add_dhcp"]==1) {
      $dhcpbase=$_POST["dhcpbase1"].".".$_POST["dhcpbase2"].".".$_POST["dhcpbase3"];
      $dhcps[count($dhcps)]=$dhcpbase.".".$_POST["dhcpfirst"]."-".$_POST["dhcplast"];
    }
    if ($_POST["delete_dhcp"]==1) {
      if (in_array($_POST["dhcp"], $dhcps)) {
        $i = array_search($_POST["dhcp"], $dhcps);
        array_splice($dhcps, $i, 1);
      }
    }
  }
//echo "add " . $_POST['add'] ." dhcp1 " . $_POST['dhcpbase1'];
# set the configuration variables in the template ---------------------
 
  $t->set_var("WAKEUP", $wakeup);
  
  $t->set_var("MAXBACKUPS", $maxbackups);   
  
  $t->set_var("BLACKOUT_BEGIN", $blackoutbegin);   
  $t->set_var("BLACKOUT_END", $blackoutend);   
  
  for ($i=0; $i<7; $i++) {
    if ($blackoutdays[$i])
      $t->set_var("CHECKED_".$i, "CHECKED");     
    else
      $t->set_var("CHECKED_".$i, "");     
  }
  
  if ($_POST['affiche_dhcp']==1) {
    $dhcp=$_POST["dhcp"];
    $reg="/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\-([0-9]+)/";
    preg_match($reg, $dhcp, $m);
    $t->set_var("DHCP_BASE1", $m[1]);   
    $t->set_var("DHCP_BASE2", $m[2]);   
    $t->set_var("DHCP_BASE3", $m[3]);   
    $first = $m[4];
    $last = $m[5];
  } else {
    $t->set_var("DHCP_BASE1", "");
    $t->set_var("DHCP_BASE2", "");
    $t->set_var("DHCP_BASE3", "");
    $first=-1;
    $last=-1;
  }
  
  $first_select="";
  for ($i=0; $i<255; $i++) {
    if ($i==$first)
      $first_select.="<OPTION SELECTED>".$i."</OPTION>";
    else
      $first_select.="<OPTION>".$i."</OPTION>";
  }
  $t->set_var("DHCP_FIRST", $first_select);   
  $last_select="";
  for ($i=0; $i<255; $i++) {
    if ($i==$last)
      $last_select.="<OPTION SELECTED>".$i."</OPTION>";
    else
      $last_select.="<OPTION>".$i."</OPTION>";
  }
  $t->set_var("DHCP_LAST", $last_select);   

  $t->set_var("DHCPS_SIZE", count($dhcps));
  $t->set_block("gen_conf", "dhcp_row","dhcp_rows");  
  $t->set_block("gen_conf", "dhcp_hidden_row","dhcp_hidden_rows");  
  if (empty($dhcps)) {
    $t->set_var("dhcp_rows", "");
    $t->set_var("dhcp_hidden_rows", "");
  } else
    for ($i=0; $i<count($dhcps); $i++) {
      $t->set_var("DHCP_NAME", "dhcp_".$i);
      $t->set_var("DHCP_ADDR", $dhcps[$i]);
      if ($dhcps[$i] == $_POST["dhcp"]) 
        $t->set_var("DHCP_SELECTED", "SELECTED");
      else
        $t->set_var("DHCP_SELECTED", "");
      $t->parse("dhcp_rows", "dhcp_row", true);
      $t->parse("dhcp_hidden_rows", "dhcp_hidden_row", true);
    }

   # misc options
   foreach (array("FullKeepCnt", "IncrKeepCnt") as $o) {
	if (isset($opts[$o])) {
	  $t->set_var(strtoupper($o), $opts[$o]);
	}
   }

  
# --------------------------------------------


# output everything
	if ($lbs) {
		echo perl_exec("lbs_header.cgi", array("list_of_machines configuration backuppc_setup3", $text{'gen_conf_title'}, "index")); # FIXME: titre
		$t->pparse("out", "gen_conf");
		echo perl_exec("lbs_footer.cgi", array(2));
	} else {
		lib_header($text{gen_conf_title}, "", "", 1, 1, undef, "<A HREF='http:////backuppc.sourceforge.net//'><b>BackupPC</b></A><br>"); 
		$t->pparse("out", "gen_conf");
		lib_footer("/", $text{'index'});
	}

}

# --------MAIN--------------------------------

LIB_init_config();

$lbs = isLBS();

#---- FORM SUBMITTED -------------------------
if (isset($_POST['register']) && $_POST['register']==1) {  

  $t = tmplInit( array( "register" => "register.tpl" ) );
  insertMenu("register");
    
  $t->set_block("register", "std_conf","std_conf_full");  
  $t->set_block("register", "adv_conf","adv_conf_full");  
  if (isset($_POST['advanced'])) {
    $t->set_var("std_conf_full","");  
    $file_str = $_POST['conf_file'];
    
    $file_str = preg_replace("/\\\'/","'",$file_str);
    $file_str=preg_replace('/\\\"/', '"', $file_str);
    
    putConfFile($file_str);
    $t->set_var("CONFIG_PL", $file_str);
    $t->parse("adv_conf_full", "adv_conf", true);
  } else {
    $t->set_var("adv_conf_full","");  
    $wakeup=$_POST["wakeup"];
    $maxbackups=$_POST["maxbackups"];
    $blackoutbegin=$_POST["blackoutbegin"];
    $blackoutend=$_POST["blackoutend"];
    if (!empty($_POST['blackout'])) {
      $blackoutdays = $_POST['blackout'][0];
      for ($i=1; $i<count($_POST['blackout']); $i++) 
        $blackoutdays .= ",".$_POST["blackout"][$i];
    } else 
      $blackoutdays="";
    $opts['FullKeepCnt'] = $_POST["FullKeepCnt"];
    $opts['IncrKeepCnt'] = $_POST["IncrKeepCnt"];
    
    $i=0;
    $dhcps_str="";
    $reg="/([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)\-([0-9]+)/";
    while (isset($_POST["dhcp_".$i])) {
      $dhcp=$_POST["dhcp_".$i];
      preg_match($reg, $dhcp, $m);
      $dhcps_str.="   {\n      ipAddrBase => '".$m[1]."',\n";
      $dhcps_str.="      first => ".$m[2].",\n";
      $dhcps_str.="      last => ".$m[3].",\n      },\n   ";
      $i++;
    }
    if ($dhcps_str != "")
      $dhcps_str = "\n   ".$dhcps_str;
    writeGenConfFile($wakeup, $maxbackups, $blackoutbegin, $blackoutend, $blackoutdays, $dhcps_str,
    		$opts);
    
    // todo: remove this information
    $t->set_var("WAKEUP", $wakeup);
    $t->set_var("MAXBACKUPS", $maxbackups);
    $t->set_var("BLACKOUT_BEGIN", $blackoutbegin);
    $t->set_var("BLACKOUT_END", $blackoutend);
    $t->set_var("BLACKOUT_DAYS", $blackoutdays);
    $t->set_var("DHCPS", $dhcps_str);
    
    $t->parse("std_conf_full", "std_conf", true);
  }

# output everything
	if ($lbs) {
		echo perl_exec("lbs_header.cgi", array("list_of_machines configuration backuppc_setup3", $text{'gen_conf_title'}, "index")); # FIXME: titre
		$t->pparse("out", "register");
		echo perl_exec("lbs_footer.cgi");
	} else {
		lib_header($text{gen_conf_title}, "", "", 1, 1, undef, "<A HREF='http:////backuppc.sourceforge.net//'><b>BackupPC</b></A><br>"); 
		$t->pparse("out", "register");
		lib_footer("/", $text{'index'});
	}
  
  exit;
}
#---------------------------------------------

if ($lbs) {
	$t = tmplInit( array( "gen_conf" => "gen_conf_lbs.tpl" ) );
} else {
	$t = tmplInit( array( "gen_conf" => "gen_conf.tpl" ) );
	insertMenu("gen_conf");
}

showMain();

?>
