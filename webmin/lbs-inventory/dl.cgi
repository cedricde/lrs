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

# MAIN
lib_init_config();

global $config;

# read the file
$path = preg_replace("/^[^a-z]*/i", "", $path);
$file = $config[chemin_CSV]."/".$path;
$f = fopen($file, "rb");
$content_len = (int) filesize($file);
$content_file = fread($f, $content_len);
fclose($f);

$output_file = basename($file); 

#
#header('Content-Type: application/octetstream; name="' . $output_file . '"');
#header('Content-Type: application/octet-stream; name="' . $output_file . '"');
#header('Content-Disposition: inline; filename="' . $output_file . '"');
#header("Content-length: $content_len");

echo $content_file; 
?>
