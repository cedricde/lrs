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

# ... and vars
use vars qw (%access %config %in %lbsconf %text $VERSION);
# get some common functions ...
require "lbs.pl";

lbs_common::init_lbs_conf() or exit(0) ;

my %einfo ;
my $lbs_home = $lbs_common::lbsconf{'basedir'};
my $etherfile = $lbs_home . "/etc/ether" ;
my ($mac,$name) ;
my $hdrname ;
my $menu ;
my %hdr ;
my %minfo ;
my $title ;
my $redir = "";
my $wake = $config{"wake"};

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile)) if (not -f $etherfile) ;

ReadParse() ;

etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;

$redir = "at/index.cgi?";

if (exists $in{'mac'}) {

	$mac = $in{'mac'};

	$name = etherGetNameByMac(\%einfo, $mac) ;
	
	if (not defined $name) {
	    error(text("err_mac_inval",$mac)) ;
	}

	$redir .= "ext_cmd=".urlize("$in{mac}");
	
	redirect($redir) ;
	exit(0) ;
}
elsif (exists $in{'group'}) {
	my $macs = "";

	foreach my $k (etherGetMacs(\%einfo)) {
	    my $n = $einfo{$k}[1];
	    if ( $n =~ m|:?([^:]+)/([^/]+)$| ) {
		# group found
		system("echo $1 >>/tmp/st");
		if (index ($1,$in{'group'}) != 0) { next; }
		$macs .=  $k." ";
	    }
	}
	$redir .= "ext_cmd=".urlize("$macs");
	
	redirect($redir) ;
} else {
	error($text{'err_invalcgi_nomac'}) ;
}

# DEBUG
#&showConfig() ;

