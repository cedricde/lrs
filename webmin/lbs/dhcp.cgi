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

my $lbs_home = $lbs_common::lbsconf{'basedir'};
my $etherfile = $lbs_home . "/etc/ether" ;
my $add_command = $lbs_home . "/bin/check_add_host" ;
my $add_logfile = $lbs_home . "/log/addhost.log" ;
my @add_args ;
my ($mac,$name,$ip,$passwd) ;
my $tail ;
my %einfo;

error(text("err_dnf",$lbs_home))        if (not -d $lbs_home) ;
error(text("err_cnf",$add_command))     if (not -f $add_command) ;
error(text("err_fnf",$add_logfile))     if (not -f $add_logfile) ;

ReadParse() ;

error( $text{'acl_error'} )     if ($access{'modify'});

etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;

if (exists $in{'cancel'}) {     				# user has flies
	redirect("index.cgi") ;
} elsif (exists $in{'apply'}) { 				# user click on the "add" button

	error($text{'err_invalcgi_toofewargs'})         if (not exists($in{'name'}) or not exists($in{'mac'}) or not exists($in{'ip'}) or not exists($in{'passwd'}));
	
	$name = $in{'name'} ;
	$mac = $in{'mac'} ;
	$ip = $in{'ip'} ;
	$passwd = $in{'passwd'} ;
	
	# some checks
	error($text{'err_name_mandat'}) 		if (not length($name)) ;
	error(text("err_name_inval",$name))     	if (not checkhostname($name)) ;
	error($text{'err_mac_mandat'})  		if (not length($mac)) ;
	error(text('err_mac_inval',$mac))       	if (not checkmac($mac)) ;
	error($text{'err_adminid_mandat'})      	if (not length($passwd)) ;
	error(text('err_ip_inval',$ip)) 		if (length($ip) and not checkip($ip)) ;
	$mac = uc($mac) ;
	@add_args = ($mac, $name, $passwd) ;

	# adress already in use
	error(text("err_name_usedby", $name, etherGetMacByName(\%einfo, $name)))  if (grep { $name eq $_ } etherGetNames(\%einfo));

	# auto adresse
	my $ipstr;
	if (length($ip)) {
		push(@add_args, $ip) ;
		$ipstr = $ip ;
	} else {
		$ipstr = "(auto)" ;
	}
	
	error("$!\n") if (system($add_command, @add_args));     # add command didn't succeed

	# header
	lbs_common::print_header( $text{'tit_dhcp'}, "dhcp", $VERSION);

	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'dhcp_form']);

	print "<h2>".$text{'msg_dhcp_addofentry'}.":</h2>\n" ;
	print "<b>".$text{'lab_name'}.":</b> $name<br>" ;
	print "<b>".$text{'lab_macaddr'}.":</b> $mac<br>" ;
	print "<b>".$text{'lab_ipaddr'}.":</b> $ipstr<br>" ;
	print "<h2>".$text{'lab_result'}.":</h2>\n" ;

	print "<pre>\n" ;
	$tail = `tail -1 $add_logfile` ;
	# Folding a long line:
	$tail =~ s/, /,<br>/g ;
	# Don't show the password:
	$tail =~ s/(password )(.+?) :/$1****** :/;
	print $tail ;
	print "</pre>\n" ;

	# end of tabs
	lbs_common::print_end_menu();		
	
	# and get out of here
	footer("", $text{'index'}) ;
	

} else {								# last choice: show the DHCP form

	lbs_common::print_header( $text{'tit_dhcp'}, "dhcp", $VERSION);

	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'dhcp_form']);

	# form	
	print_dhcp_form("dhcp.cgi", $lbs_common::lbsconf{'license'}, %einfo) ;
	
	# end of tabs
	lbs_common::print_end_menu();		
	# end of tabs
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
}