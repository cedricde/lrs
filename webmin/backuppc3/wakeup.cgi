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

include_once('../lbs_common/lbs_common.php');

#
# Show Main template
#
function showMain()
{
  global $t, $text;
# gather the configuration variables ---------------------
  if (!isset($_GET['start_hour']) && !isset($_GET['end_hour'])) {
    $start=25;
    $end=-1;
    //readGenConfFile($wakeup, $maxbackups, $blackoutbegin, $blackoutend, $blackoutdays, $dhcps);
  } else {
    $start=0;
    $end=24;
    if (isset($_GET['start_hour']) && $_GET['start_hour']<24)
      $start=$_GET['start_hour'];
    if(isset($_GET['end_hour']) && $_GET['end_hour']>-1)
      $end=$_GET['end_hour'];
  }

# set the configuration variables in the template ---------------------
 
  $t->set_block("widget", "wakeup_row","wakeup_rows");  
  for ($i=0; $i<24; $i++) {
  
    $t->set_var("HOUR", $i);
    $t->set_var("START_HOUR", $start);
    $t->set_var("END_HOUR", $end);
    if ($i>=$start && $i<=$end)
      $t->set_var("HOUR_CHECKED", "CHECKED");
    else
      $t->set_var("HOUR_CHECKED", "");    
      
    if ($i % 6 == 0)
      $t->set_var("NEW_COLUMN_START", "<TD>");
    else
      $t->set_var("NEW_COLUMN_START", "");
    
    if (($i+1) % 6 == 0) 
      $t->set_var("NEW_COLUMN_END", "</TD>");
    else
      $t->set_var("NEW_COLUMN_END", "");
    
    $t->parse("wakeup_rows", "wakeup_row", true);
  }
  
# --------------------------------------------

  $t->pparse("out", "widget");
}

# --------MAIN--------------------------------
LIB_init_config();

$t = tmplInit( array( "widget" => "widget.tpl" ) );

showMain();

?>
