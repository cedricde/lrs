#! /var/lib/lrs/php
<?
#
# $Id$
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


include_once('lbs-inventory.php');

# get the MAC address
if (in_array("mac", array_flip($_GET)) )
 	$mac = $_GET["mac"];
else 
	{
  	 echo "general: No MAC address available <br>";
	 exit();
 	}

# new template
$site_geo = tmplInit(array("site_geo" => "site_geo.tpl"));

# OPTIONS: give the the address MAC
$site_geo->set_block("site_geo", "options", "options_block");
$site_geo->set_var("OPTIONS", "?mac=".$mac);
$site_geo->parse("options_block", "options");

# set the block
$site_geo->set_block("site_geo", "initialisation", "initialisation_block");

# create the name file
$filename = "$chemin_CSV/Info/Situation_Geo/".$mac."_site_geo.ini";

# check if file exist
if (file_exists($filename)) {
        # parsing file
        $ini_file = parse_ini_file($filename, true);
        
        # setting up html carateres
        $sit = $ini_file["situation_geographique"];
        $sit = ereg_replace("&lt;", "<", $sit);
        $sit = ereg_replace("&amp;", "&", $sit);
        $sit = ereg_replace("<br>", "\n", $sit);
        
        $tel = $ini_file["telephone_proche"];
        $tel = ereg_replace("&lt;", "<", $tel);
        $tel = ereg_replace("&amp;", "&", $tel);
        $tel = ereg_replace("<br>", "\n", $tel);
        
        # set all variables
        $site_geo->set_var(
                                array(
                                "INIT_SITE_GEO" => "\"" . $sit . "\"",
                                "INIT_TEL" => "\"". $tel  . "\"",)
                                );
        
        # parse and display
        $site_geo->parse("initialisation_block", "initialisation");
        
        echo perl_exec("lbs_header.cgi", array("inventory ", $text{'index_title'}, "index"));
        
        $site_geo->pparse("out","site_geo");
        
        echo perl_exec("lbs_footer.cgi");  
        
} else {
   # file doesn't exist, fill data manualy
        $site_geo->set_var(
                        array(
                                "INIT_SITE_GEO" => "\"" . $sit . "\"",
                                "INIT_TEL" => "\"". $tel  . "\"",)
                                );
        
        $site_geo->parse("initialisation_block", "initialisation");
        
        echo perl_exec("lbs_header.cgi", array("inventory ", $text{'index_title'}, "index"));
        
        $site_geo->pparse("out","site_geo");
        
        echo perl_exec("lbs_footer.cgi", array("2"));   
}

?>
