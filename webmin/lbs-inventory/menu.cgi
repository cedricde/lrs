#! /var/lib/lrs/php
<?php
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

include_once("./path.cgi");
include_once("$chemin/templates/template.inc");
include_once("./fonctions.cgi");
include_once("./lbs-common.php");

//function aa($x, $y) {
// set the text color for the menu:
lib_init_config();
lib_header();

# create template
$hardware = new Template ("$chemin/templates/", "keep");
$hardware->set_file(array("menu_file" => "menu.tpl"));

# insert the begging of menu
$hardware->set_block("menu_file", "menu", "menu_block");
$tab_menu = Menu_Out(make_menu("$chemin/Menus"),array(1, 1),$_GET);
$hardware->set_var("MENU", $tab_menu[0]); 
$hardware->parse("menu_block", "menu", true);


# insert the end of menu
$hardware->set_block("menu_file", "fin_menu", "fin_menu_block");
$hardware->set_var("FIN_MENU", Fin_Menu($tab_menu[1])); 
$hardware->parse("fin_menu_block", "fin_menu", true);

// MODIFIED by P.D. moved from the bottom
## continuation
$hardware->set_block("menu_file", "vide", "vide_block");

# delete empty
$hardware->parse("vide_block", "vide"); 
//~~

# display it
$hardware->pparse("out", "menu_file");

# footer of LBS for webmin
//include_once("lbs_footer.cgi");
//}

//aa(1,1);
?>
