#!/usr/bin/perl -w
#
# $Id$

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
use vars qw (%access %config %in %lbsconf %text $VERSION $current_lang);
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

ReadParse() ;
# L'utilisateur a t-il le droit d'effectuer des modifs?
if ($access{'modify'}) {
	error( $text{'acl_error'} ) ;
}


if (exists $in{'cancel'}) {
	redirect($redir) ;
	exit(0) ;
} elsif (exists $in{'apply'} or exists $in{'title'}) {

	$title = $in{'title'} ;

#	$data = itemChangeVal($data, "title", $in{'title'});
#	fileSave($hdrname, \$data) or error( lbsGetError() ) ;

	redirect($redir) ;
} else {# Affichage du formulaire de modif si pas de apply

	# header
	lbs_common::print_header( $text{'tit_mountpart'}, "index", $VERSION);

	# tabs
	lbs_common::print_html_tabs(['list_of_machines', '']);


	# form
	my $ret = system("$lbs_home/bin/lrsgznbd.sh $lbs_home/$in{part} >/dev/null");

	if ($ret != 0) {

	}

	my $template = new Qtpl("./tmpl/$current_lang/mountpart.tpl");
	$template->parse('all');
	$template->out('all');

	# end of tabs
	lbs_common::print_end_menu();
	lbs_common::print_end_menu();
	# footer
	lbs_common::footer("", $text{'index'}) ;
}
