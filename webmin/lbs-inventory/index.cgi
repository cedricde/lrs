#! /var/lib/lrs/php
<?
# $Id$
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

include_once('lbs-inventory.php');

#
# List LBS clients
#
function showMainByName($ether){
	
	global $text;

	$t = tmplInit(array("main" => "main.tpl"));

	if (count($ether)>0 && is_array($ether)) {
		$key = array_keys($ether);
		
		sort($key);
		$t->set_block("main", "main_row", "main_rows");
		
		foreach ($key as $k) {
			$dublePointMac = addDublePoint($k);
			
			$t->set_var(array(
			"NAME" => $ether[$k]['name'],
			"MAC" => "$dublePointMac", 
			"IP" => $ether[$k]['ip'],
			"HTTP_LINK" => "<a href='general.cgi?mac=".urlencode(filterMac($ether[$k]['mac']))."'><img border=1 src='images/icon_inventory_lbs.gif'></a>"
			));
			
			$t->parse("main_rows", "main_row", true);
		}
		
		# output everything
		$t->pparse("out", "main");
		
	} else {
		print '<h1> <font size = 5>' . $text{'err_no_machine_recorded'} . '</h1> </font><br>';
	}
}

# MAIN

if ( isset($_GET["mac"]))
{
	$mac = $_GET["mac"]; 
	echo "<html><head><meta http-equiv=\"refresh\" content=\"0;url=./general.cgi?mac=" .$mac. "\"></head></html>";
} else {

	# show header
	echo perl_exec("lbs_header.cgi", array("inventory ", $text{'index_title'}, "index"));
	
	$ether = searchEtherInOCS();
	showMainByName($ether);

	echo perl_exec("lbs_footer.cgi");
	
}

?>
