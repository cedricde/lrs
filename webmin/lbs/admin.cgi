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

$redir = "";

if (exists $in{'mac'}) {

	$mac = $in{'mac'};

	$name = etherGetNameByMac(\%einfo, $mac) ;
	
	if (not defined $name) {
	    error(text("err_mac_inval",$mac)) ;
	}

	$redir .= "ext_cmd=".urlize("$in{mac}")."&mac=".urlize("$in{mac}");
	
	#redirect($redir) ;
}
elsif ($in{'group'}) {
	my $macs = "";

	foreach my $k (etherGetMacs(\%einfo)) {
	    my $n = $einfo{$k}[1];
	    if ( $n =~ m|([^:]*:)?/?([^:]+)/([^/]+)$| ) {
		# group found
		if (index ($2,$in{'group'}) != 0) { next; }
		if (exists $in{'profile'} && index ($1,$in{'profile'}) != 0) { next; }
		$macs .=  $k." ";
	    }
	}
	$redir .= "ext_cmd=".urlize("$macs")."&group=".urlize($in{'group'})."&profile=".urlize($in{'profile'});
	
} elsif (exists $in{'profile'}) {
	my $macs = "";

	my $filt = $in{'profile'}.":";
	if ($filt eq ":") { $filt = "" };

	foreach my $k (etherGetMacsFilterName(\%einfo, $filt)) {
	    my $n = $einfo{$k}[1];
	    if ( $n =~ m|^([^:]+):| ) {
		# prof found
		if (index ($1,$in{'profile'}) != 0) { next; }
		$macs .=  $k." ";
	    } elsif ( $filt eq "" ) {
		$macs .=  $k." ";	    
	    }
	}
	$redir .= "ext_cmd=".urlize("$macs")."&group=".urlize($in{'group'})."&profile=".urlize($in{'profile'});	

} else {
	error($text{'err_invalcgi_nomac'}) ;
}

lbs_common::print_header( $text{'tit_wol'}, "imgbase", "");
lbs_common::print_html_tabs(['list_of_machines', "clients_list"]);

if (exists $in{'mac'}) {
    print <<EOF
    <h2 align="center">Client $name ($mac)</h2>
    <h2><img src="images/admin.gif" align="center"> $text{'lab_administrative_tasks'} :</h2>
    <ul><li><a href='rename.cgi?$redir'>$text{'but_rename'}</a>
    <li><a href='renamemac.cgi?$redir'>$text{'but_renamemac'}</a>
    <li><a href='delete.cgi?$redir'>$text{'but_delete'}</a>
    </ul>
EOF
} else {
    print "<h2 align=\"center\">";
    my @local_title;
    push @local_title, "$text{'lab_group'} $in{'group'}" if $in{'group'};
    push @local_title, "$text{'lab_profile'} $in{'profile'}" if $in{'profile'};
    print join ', ', @local_title;
    print "</h2>";
}

print <<EOF;
    <h2><img src="images/wake.gif" align="center"> $text{'lab_wol2'} :</h2>
    <ul><li><a href='at/index.cgi?$redir'>$text{'lab_wol_one'}</a>
    <li><a href='cron/edit_cron.cgi?new=1&$redir'>$text{'lab_wol_per'}</a>
    </ul>
EOF

lbs_common::print_end_menu();		
lbs_common::print_end_menu();		

footer("/lbs_common/", $text{'index'});

# DEBUG
#&showConfig() ;

