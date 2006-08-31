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
my ($name) ;
my $hdrname ;
my $menu ;
my %hdr ;
my %minfo ;
my $title ;
my $redir = "";

error(text("err_dnf",$lbs_home))        if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile))       if (not -f $etherfile) ;

ReadParse();
lbs_common::InClean();

# L'utilisateur a t-il le droit d'effectuer des modifs?
if ($access{'modify'}) {
	error( $text{'acl_error'} ) ;
}

# redirect to the good page
my $mac = $in{'mac'} ;
my $redir_flag = $in{'redir_flag'};     $redir_flag = "" unless ($redir_flag);

if ( $ENV{'HTTP_REFERER'} =~ "/move.cgi" or $redir_flag eq "move" ) {
    $redir_flag = "move";
    $redir = "move.cgi?mac=$mac&form=move&group=$in{'group'}&profile=$in{'profile'}";
} elsif ( $ENV{'HTTP_REFERER'} =~ "/bootmenu.cgi" or $redir_flag eq "boot" ) {
    $redir_flag = "boot";
    $redir = "bootmenu.cgi?mac=$mac&group=$in{'group'}&profile=$in{'profile'}";
} else {
    $redir_flag = "imgbase";
    $redir = "imgbase.cgi";
}

error($text{'err_invalcgi_nomenu'}) if (not exists $in{'conf'});

$in{'conf'} =~ s/^\.[\.]+//g;
$hdrname = $lbs_home . "/" . $in{'conf'} . "/conf.txt" ;
	
my $data;
fileLoad($hdrname, \$data) or error( lbsGetError() ) ;

if (exists $in{'cancel'}) {
	redirect($redir) ;
	exit(0) ;
} elsif (exists $in{'apply'} or exists $in{'title'}) {

	$title = $in{'title'} ;

	$data = itemChangeVal($data, "title", $in{'title'});
	fileSave($hdrname, \$data) or error( lbsGetError() ) ;

	redirect($redir) ;
} else {# Affichage du formulaire de modif si pas de apply

	# header
	$title = itemGetVal($data, "title") ;
	lbs_common::print_header( $text{'tit_title'}, "index", $VERSION);

	# form
	print_description_form("title2.cgi", "<h2></h2>", $mac, $in{'conf'}, $title, $redir_flag, 'tit_title') ;

	# footer
	footer("", $text{'index'}) ;
}
