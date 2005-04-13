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
# --------MAIN--------------------------------
LIB_init_config();

initLbsConf($config['lbs_conf']);

$t = tmplInit( array( "help" => "help.tpl" ) );

$topic=$_GET['topic'];

$text_help="";
$i=1;
while ( isset($text{$topic."_$i"}) ) {
  $text_help .= $text{$topic.'_'.$i} . "<BR>";
  $i++;
}

$t->set_var("TEXT_HELP", $text_help);

$t->pparse("out", "help");

?>
