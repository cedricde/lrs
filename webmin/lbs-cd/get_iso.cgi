#!/usr/bin/perl -w
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

use strict;

do '../web-lib.pl';

use vars qw|%in %config|;
# some init
init_config();

# get the good module
foreign_require("lbs_common", "lbs_common.pl");

# get HTTP args
ReadParse();

if (!$in{'iso'}) {
        error(text("err_NoIsoSelected"));
        die();
}

if (! open ISO, "$config{'StoreDir'}/$in{'iso'}") {
        error(text("err_CantReadIso", $in{'iso'}));
        die();
}

print "Content-type: application/octet-stream\nContent-Disposition: inline; filename=$in{'iso'}\n\n";
print while (<ISO>);
close ISO;
