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

# get some common functions ...
require "lbs.pl";

# ... and vars
ReadParse();
use vars qw (%in %text $VERSION $LRS_HERE %config);

# entete
lbs_common::print_header( $text{'tit_index'}, "index", $VERSION);

# tabs
lbs_common::print_html_tabs(['list_of_machines', 'status']);

# is LBS server running ?
lbs_common::checkfordaemon();

# free disk
lbs_common::show_free_disk($lbscommon::config{'free_disk_dir'});
print "<br />\n";

# some version
lbs_common::show_versions();
print "<br />\n";

print "<a href='getstats.cgi'>".text('lab_getstats')."</a>";
# end of tabs
lbs_common::print_end_menu();
lbs_common::print_end_menu();

# pied de page
footer("/", text('index'));