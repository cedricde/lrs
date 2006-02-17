#!/usr/bin/perl -w
#
# LBS Webmin Module
#
# $Id$

BEGIN {
our $logrep="/var/lib/lbs";

	close STDERR;
	
	`mkdir -p $logrep` unless (-d $logrep);
	
	open STDERR, ">> /var/lib/lbs/webmin.log";     	# FIXME: faire du logrotate
}

use strict;
use vars qw(%module_info);

# Including the common functions
require '../web-lib.pl';
use vars qw(%text);

init_config();
ReadParse();

our $VERSION='$Rev$';
$VERSION =~ s/\$Rev: (\d+) \$/$module_info{'version'}/;

foreign_require("lbs_common", "lbs_common.pl");
