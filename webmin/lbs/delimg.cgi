#!/usr/bin/perl
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
require "lbs.pl";
lbs_common::init_lbs_conf() or exit(0) ;

#require "lbs-lib.pl" ;

#/////////////////////////////////////////////////////////////////////////////
# FONCTIONS
#/////////////////////////////////////////////////////////////////////////////

# printConfirmationForm ($action, $mesg, [$hidden_name1, $hidden_val1, ...] )
#
sub printConfirmationForm {
my $action = shift ;
my $mesg = shift ;
my $buf = "" ;

 while (defined($_[0]) and defined($_[1])) {
 	$buf .= sprintf "   <input type=hidden name=\"%s\" value=\"%s\">\n",
 	       shift(@_), shift(@_) ;
 }

my $but_apply = $text{'but_apply'} ;
my $but_cancel = $text{'but_cancel'} ;

print <<EOF ;
$mesg
<p>
 <form action="$action">
   $buf
   <input type=hidden name=form value="confirm">
   <input type=submit name=apply value="$but_apply">
   <input type=submit name=cancel value="$but_cancel">
 </form>
</p>
EOF

}


#/////////////////////////////////////////////////////////////////////////////
# MAIN
#/////////////////////////////////////////////////////////////////////////////

my %einfo ;
my $lbs_home = $lbs_common::lbsconf{'basedir'} ;
my $etherfile = $lbs_home . "/etc/ether" ;
my ($mac,$umac,$macfile,$name) ;
my $result ;
my $image ;
my $warning ;
my $mesg ;

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile)) if (not -f $etherfile) ;

ReadParse() ;
lbs_common::InClean();

# L'utilisateur a t-il le droit d'effectuer des modifs?
if ($access{'modify'}) {
	error( $text{'acl_error'} ) ;
}

if (not exists $in{'mac'}) {
	error($text{'err_invalcgi_nomac'}) ;
}


etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;
$mac = $in{'mac'} ;
$macfile = toMacFileName($mac) ;
$umac = urlize($mac) ;
$name = etherGetNameByMac(\%einfo, $mac) ;

if (exists $in{'cancel'}) {
	redirect("move.cgi?mac=$umac") ;
	exit(0) ;
}
elsif (exists $in{'apply'}) {
	$image = $in{'img'} ;
	$image =~ s/[^a-z0-9_-]//gi;
	
	imgDeleteLocal($lbs_home,$mac,$image) or error( lbsGetError() ) ;
	redirect("move.cgi?mac=$umac") ;
	exit(0) ;

	#&header("debug", "", "index", 1, 1, undef,undef) ;
	#showConfig() ;
	#&footer("", $text{'index'}) ;
}
else {
	# Affichage de la confirmation si pas de apply.
	
	$image = $in{'img'} ;

	$mesg = "<h2>Client $name ($mac)</h2>"
		."<h2>". text("msg_delimg_confirm",$image) ."</h2>" ;

	if (-l "$lbs_home/images/$macfile/$image") {
		$warning = "<h2>".$text{'msg_delimg_symlink'}."</h2>" ;
	}
	else {
		$warning = "<h2><font color=#FF0000>"
	           .$text{'msg_delimg_warn'}."</font></h2>" ;
	}

	lbs_common::print_header( $text{'tit_delete'}, "index", $VERSION);
	lbs_common::print_html_tabs(['system_backup', 'details']);
	
	printConfirmationForm("delimg.cgi", $mesg . $warning ,
		                      "mac", $mac, "img", $image ) ;
	&footer("", $text{'index'}) ;
}


