#! /var/lib/lrs/php
<?
#
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

include_once('lbs-vnc.php');

initLbsConf($config['lbs_conf'], 1);

# show header
echo perl_exec("lbs_header.cgi", array("remote_control logs", $text{'tit_logs'}, "index"));

$lines = file("/var/log/daemon.log");
$proxy = preg_grep("/proxy.pl /", $lines);
print( join("<br>",array_reverse($proxy)));

#$t = tmplInit(array("main" => "main.tpl", "erreur" => "erreur.tpl"));
#t->pparse("out", "erreur");

echo perl_exec("lbs_footer.cgi", array("2"));

?>