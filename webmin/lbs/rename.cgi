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

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile)) if (not -f $etherfile) ;

ReadParse() ;

# L'utilisateur a t-il le droit d'effectuer des modifs?
if ($access{'modify'}) {
	error( $text{'acl_error'} ) ;
}

etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;

if (not exists $in{'mac'}) {
	error($text{'err_invalcgi_nomac'}) ;
}

# redirect to the good page
$mac = $in{'mac'};
$redir = "bootmenu.cgi?mac=$mac";

$name = etherGetNameByMac(\%einfo, $mac) ;
	
if (not defined $name) {
    error(text("err_mac_inval",$mac)) ;
}

$menu = $in{'menu'} ;     # Un nom de section '[menuXX]'

if (exists $in{'cancel'}) {
    redirect($redir) ;
    exit(0) ;
} elsif (exists $in{'apply'}) {

        my $t = $in{'title'};
        my $g = "$in{'pregroup'}/$in{'group'}";
        my $p = $in{'profile'} || $in{'preprofile'};
        
        # title parsing:
        chomp($t);                      # remove leading and trailing spaces
        $t =~ s|^/+(.*)$|$1|;           # remove leading "/"
        $t =~ s|^(.*)/$|$1|gi;          # remove trailing "/"
        $t =~ s|[^a-z0-9\.\-\+]|_|gi;   # translate unauthorized characters into underscores

        # group parsing:
        chomp($g);                      # remove leading and trailing spaces
        $g =~ s|^/+(.*)$|$1|;           # remove leading "/"
        $g =~ s|^(.*)/$|$1|gi;          # remove trailing "/"
        $g =~ s|[^a-z0-9\.\-/\+]|_|gi;  # translate unauthorized characters into underscores

        # profile parsing:
        chomp($p);                      # remove leading and trailing spaces
        $p =~ s|^/+(.*)$|$1|;           # remove leading "/"
        $p =~ s|^(.*)/$|$1|gi;          # remove trailing "/"
        $p =~ s|[^a-z0-9\.\-/\:\+]|_|gi;# translate unauthorized characters into underscores

        $t = "$p:$g/$t";
	$t =~ s/^:\/?//;

        $einfo{$mac}[1] = $t ;
        etherSave($etherfile, \%einfo) ;
    
        # update the hostname file
        open(HOST,">$lbs_home/images/".toMacFileName($mac)."/hostname") ;
        print HOST $t;
        close(HOST) ;    
        
        redirect($redir) ;
        exit(0) ;
} else {
        # Affichage du formulaire de modif si pas de apply

	$title = $minfo{'title'} ;
	lbs_common::print_header( $text{'tit_name'}, "index", $VERSION);
	
	#tabs
	lbs_common::print_html_tabs(['system_backup', 'rename']);
	
	print_name_desc_form("rename.cgi", "<h2>Client $name ($mac) </h2>", $mac, $menu, $name, $redir) ;

	lbs_common::print_end_menu();
	lbs_common::print_end_menu();
        
	footer("", $text{'index'}) ;
}