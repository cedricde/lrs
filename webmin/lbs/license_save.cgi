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


require '../web-lib.pl';
require './config-lib.pl';
&init_config();
&ReadParse();
$m = $in{'module'};
&read_acl(\%acl);
&error_setup($text{'config_err'});
$acl{$base_remote_user,$m} || &error($text{'config_eaccess'});
%access = &get_module_acl(undef, $m);
$access{'noconfig'} && &error($text{'config_ecannot'});

&lock_file("/etc/lbs.conf");

&parse_config(\%conf, "license.info");

local $lref = &read_file_lines("/etc/lbs.conf");
foreach $l (@$lref) {
    if ($l =~ /^iface\s*=/i && defined ($conf{'iface'}) ) {
	$l = "iface=$conf{'iface'}";
    }
    if ($l =~ /^hwmac\s*=/i && defined ($conf{'hwmac'}) ) {
	$l = "hwmac=$conf{'hwmac'}";
    }
    if ($l =~ /^license\s*=/i && defined ($conf{'license'}) ) {
	$l = "license=$conf{'license'}";
    }
    if ($l =~ /^key\s*=/i && defined ($conf{'key'}) ) {
	$l = "key=$conf{'key'}";
    }

}
&flush_file_lines();

&unlock_file("/etc/lbs.conf");
&redirect("restart.cgi");
