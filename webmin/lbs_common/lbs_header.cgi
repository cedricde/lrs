#!/usr/bin/perl -w
#
# LBS Webmin Module
#
# $Id$

use strict;

# get the right path
BEGIN {
	push @INC, "../lbs_common/";
}

# get some common functions ...
require "lbs_perl_gw.pl";
# ... and vars
use vars qw (%in %text $VERSION);

my ($tabs, $title, $help)=@ARGV;
my @tabs=split(' ', $tabs);

# header
lbs_common::print_header($title, $help, $VERSION);
# tabs
lbs_common::print_html_tabs(\@tabs);