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

use vars qw|%in %module_info $module_name $root_directory|;
# some init
init_config();

# get the good module
foreign_require("lbs_common", "lbs_common.pl");

# get HTTP args
ReadParse();

my $title = $in{'iso'};

$title =~ s/.iso//;
$title =~ y|[A-Za-z0-9]/+-||c;

my $category = "Linbox Rescue Server";
my $command = "/usr/bin/cdlabelgen";
my $options = " -c 'Linbox Rescue Server' -s '$title' -e '$root_directory/$module_name/logo.eps' --no-tray-plaque | ps2pdf - -";
return unless -x $command;

$command .= $options;

print "Content-type: application/pdf\n";
print "Content-Disposition: inline; filename=$title.pdf\n\n";

print `$command`;
