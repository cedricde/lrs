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
use vars qw (%text);

my ($bottomrepeat)=@ARGV;

do {
        lbs_common::print_end_menu();		
} while $bottomrepeat--;

footer( "/", $text{'index'} );