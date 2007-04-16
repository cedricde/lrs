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
use vars qw (%access %config %in %lbsconf %text $VERSION $tb $cb);
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
my $error = "";

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile)) if (not -f $etherfile) ;

ReadParse();
lbs_common::InClean();

# L'utilisateur a t-il le droit d'effectuer des modifs?
error( $text{'acl_error'} ) if ($access{'modify'});
etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;

error($text{'err_invalcgi_nomac'}) if (not exists $in{'mac'});

# redirect to the good page
$mac = $in{'mac'};
$redir = "/lbs_common/";

$name = etherGetNameByMac(\%einfo, $mac) ;
error(text("err_mac_inval",$mac)) if (not defined $name);

$menu = $in{'menu'} ;     # Un nom de section '[menuXX]'

if (exists $in{'cancel'}) {
	redirect($redir) ;
} elsif (exists $in{'apply'}) {
	my $mac = uc("$in{mac1}:$in{mac2}:$in{mac3}:$in{mac4}:$in{mac5}:$in{mac6}");
	my $smac = uc("$in{mac1}$in{mac2}$in{mac3}$in{mac4}$in{mac5}$in{mac6}");
	
	$smac =~ s/[^0-9A-F]//gi;
	
	if (length($smac) != 12) {
		$error = text("err_mac_inval", $mac);
	} else {
		$name = etherGetNameByMac(\%einfo, $mac) ;
		$error = text("err_mac_inval",$mac).": $text{err_mac_used}" if (defined $name);
	}

	if ($error eq "") {
		# tout est ok, on renomme !
		my $oldsmac = uc($in{mac});
		my $oldmac = uc($in{mac});
		$oldsmac =~ s/[^0-9A-F]//gi;
		
		# renommer le rep images
		rename ("$lbs_home/images/$oldsmac/","$lbs_home/images/$smac/");
		# renommer dans logs
		rename ("$lbs_home/log/$oldsmac.inf","$lbs_home/log/$smac.inf");
		rename ("$lbs_home/log/$oldsmac.ini","$lbs_home/log/$smac.ini");
		# renommer dans cfg
		rename ("$lbs_home/cfg/$oldsmac","$lbs_home/cfg/$smac");
		# renommer dans ether
		$einfo{$mac} = [ $einfo{$oldmac}[0], $einfo{$oldmac}[1] ];
		delete $einfo{$oldmac};
		etherSave($etherfile, \%einfo);
		
		$redir = "/lbs_common/";
		
		redirect($redir);
	}
	
}
# Affichage du formulaire de modif si pas de apply
$title = $minfo{'title'} ;
lbs_common::print_header( $text{'tit_renamemac'}, "index", $VERSION);

# tabs
lbs_common::print_html_tabs(['list_of_machines', "clients_list"]);

print "<h2><font color=\"red\">$error</font></h2>" if ($error ne "");

print_mac_desc_form("renamemac.cgi", "<h2>Client $name ($mac)</h2>", $mac, $menu, $name ) ;

# end of tabs
lbs_common::print_end_menu();		
lbs_common::print_end_menu();		

# end of page
footer( "", $text{'index'} );

