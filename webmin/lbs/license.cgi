#!/usr/bin/perl
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

#require '../web-lib.pl';
require "lbs.pl";
require './config-lib.pl';

lbs_common::init_lbs_conf() or exit(0) ;

$m = "lbs";
%access = &get_module_acl(undef, $m);
$access{'noconfig'} &&
	&error($text{'config_ecannot'});
%module_info = &get_module_info($m);


lbs_common::print_header( $text{'config_title'}, "index", $VERSION);
lbs_common::print_html_tabs(['list_of_machines', '']);

print "<center><font size=+2>$text{'config_title'} ",&text('config_dir', $module_info{'desc'}),
      "</font></center>\n";
print "<hr>\n";

print "<form action=\"license_save.cgi\" method=post>\n";
print "<input type=hidden name=module value=\"$m\">\n";
print "<table border>\n";
print "<tr $tb> <td><b>",&text('config_header', $module_info{'desc'}),
      "</b></td> </tr>\n";
print "<tr $cb> <td><table width=100%>\n";

&read_file("/etc/lbs.conf", \%conf);
&generate_config(\%conf, "license.info");

print "</table></td></tr></table>\n";
print "<input type=submit value=\"$text{'save'}\"></form>\n";
print "<h4>$text{lab_allmacs}</h4>";
print `/sbin/ifconfig|grep HWaddr|awk '{print \$1,":",\$5,"<br>"}'`;
print "<hr>\n";

# end of tabs                                                                   
lbs_common::print_end_menu();                                                   
lbs_common::print_end_menu(); 

&footer("/lbs_common/", $text{'index'});
