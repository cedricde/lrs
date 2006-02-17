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

# stay strict
use strict;

# get some common functions ...
require 'lbs_common.pl';
require 'lbs_common_priv.pl';

# ... and vars
ReadParse();
use vars qw (%in %text $root_directory %gconfig $VERSION $LRS_HERE @LRS_MODULES %config);

# cookies
cookie_send_group(%in);

# entete
print_header( $text{'tit_index'}, "index", $VERSION);

# tabs
print_html_tabs(['list_of_machines', 'clients_list']);

cookie_get_group(\%in);

# lbs daemon check
checkfordaemon();

# lbs daemon check
checkforspace();

# machine list
my (@labelfunctions, @bodyfunctions);
foreach my $module (@LRS_MODULES) {
        if (-r "$root_directory/$module/lrs-export.pl") {
                foreign_require($module, "lrs-export.pl");
                push @labelfunctions, foreign_call($module, "mainlist_label_callback");
                push @bodyfunctions, foreign_call($module, "mainlist_content_callback");
        }
}

print_machines_list     (
                                {
                                        'baseuri'       => "/lbs_common/index.cgi",
                                        'nowrap'        => 1,
                                        'width'         => "100%",
                                        'searchform'    => $LRS_HERE
                                },
                                \@labelfunctions,
                                \@bodyfunctions, %in
                        );

# end of tabs
print_end_menu();
print_end_menu();

# pied de page
footer("/", text('index'));
