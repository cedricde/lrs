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

if ($lbs) {
	include_once("lbs-backuppc.php");
} else {
	include_once( "fonctions.cgi" );
	include_once( "lbs-common.php" );
	include_once('../lbs_common/web-lib.php');
	include_once("templates/template.inc");
}

function insertMenu($tmpl_file) {
  global $t, $chemin_menu, $tab_menu, $lbs;
  
# insertion of menu header
  $t->set_block($tmpl_file, "menu", "menu_block");

  $t->set_var("MENU", ""); 
  
  $t->parse("menu_block", "menu", true);

# insertion of menu footer
  $t->set_block($tmpl_file, "fin_menu", "fin_menu_block");
//  $t->set_var("FIN_MENU", Fin_Menu($tab_menu[1])); 
  $t->set_var("FIN_MENU", ""); 
  $t->parse("fin_menu_block", "fin_menu", true);
}

#
# Show Main template
#
function showMain()
{
  global $t, $text;

LIB_init_config();

$lbs = isLBS();
  
# gather the configuration variables ---------------------
  $file_str = getConfFile();

# set the configuration variables in the template ---------------------
 
  $t->set_var("CONFIG_PL", $file_str);
  
# --------------------------------------------


# output everything
	if ($lbs) {
		echo perl_exec("lbs_header.cgi", array("list_of_machines configuration backuppc_setup", $text{'gen_conf_title'}, "index")); # FIXME: titre
		$t->pparse("out", "adv_conf");
		echo perl_exec("lbs_footer.cgi");
	} else {
		lib_header($text{gen_conf_title}, "", "", 1, 1, undef, "<A HREF='http:////backuppc.sourceforge.net//'><b>BackupPC</b></A>"); 
		$t->pparse("out", "adv_conf");
		lib_footer("/", $text{'index'});
	}
}

# --------MAIN--------------------------------

if ($lbs) {
	$t = tmplInit( array( "adv_conf" => "adv_conf_lbs.tpl" ) );
} else {
	$t = tmplInit( array( "adv_conf" => "adv_conf.tpl" ) );
	insertMenu("adv_conf");
}

showMain();

?>
