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


#use strict;

BEGIN {
our $logrep="/var/lib/lbs";

	close STDERR;
	
	`mkdir -p $logrep` unless (-d $logrep);

	open STDERR, ">> /var/lib/lbs/webmin.log";     	# FIXME: faire du logrotate
}

# Including the common functions
do '../web-lib.pl';
do '../lbs_common/lbs_path.pl';
require 'lbs-lib.pl';

# some init
init_config();
ReadParse();
use vars qw($tb $cb @parttype);

# get the right module
foreign_require("lbs_common", "lbs_common.pl");

use vars qw/%module_info/;
our $VERSION='$Rev$';
$VERSION =~ s/\$Rev: (\d+) \$/$module_info{version} (r.$1)/;
