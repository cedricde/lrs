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
use vars qw (%access %config %in %lbsconf %text $VERSION $cb $config_directory $current_lang $tb);
# get some common functions ...
require "lbs.pl";

lbs_common::init_lbs_conf() or exit(0) ;

foreign_require("proc", "proc-lib.pl");

my %einfo ;
my $lbs_home    = $lbs_common::lbsconf{'basedir'};
my $etherfile   = $lbs_home . "/etc/ether" ;
my $add_command = $lbs_home . "/bin/check_add_host" ;
my $add_logfile = $lbs_home . "/log/addhost.log" ;
my @add_args ;
my ($mac,$name,$ip,$passwd) ;
my $tail ;

error(text("err_dnf",$lbs_home))        if (not -d $lbs_home) ;
error(text("err_cnf",$add_command))     if (not -f $add_command) ;
error(text("err_fnf",$add_logfile))     if (not -f $add_logfile) ;

ReadParse() ;

# can the user do mods ?
error( $text{'acl_error'} ) if ($access{'modify'});

etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;

if (exists $in{'cancel'}) {     			# go to the main page if the user is freightened
	redirect("index.cgi") ;
} elsif (exists $in{'apply'}) { 			# apply the modifications
my $m = "lbs";

	# check TC exists
	error($text{'err_invalcgi_toofewargs'}) if (not exists($in{'tc_limit'}) or not exists($in{'tc_iface'}) or not exists($in{'tc_rate'}));
	
	# grab the config
	lock_file("$config_directory/$m/config");
	read_file("$config_directory/$m/config", \%config);
	
	# change it
	$config{'tc_iface'} = $in{'tc_iface'};
	$config{'tc_limit'} = $in{'tc_limit'};
	$config{'tc_rate'} = $in{'tc_rate'};	
	
	# and save it
	write_file("$config_directory/$m/config", \%config);
	unlock_file("$config_directory/$m/config");

	# then reload it
	system("./wshaper start");
	
	redirect('tc.cgi');
} else { # Affichage du formulaire de modif si pas de apply
	
my %info;
my @info_order;	

	lbs_common::print_header( $text{'tit_tc'}, "tc", $VERSION);
	
	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'configuration', 'band_width']);

	# grab the config
	read_file("config.info", \%info, \@info_order);
	read_file("config.info.$current_lang", \%info, \@info_order);
	
	# and parse it
	my @txt_iface = split(/,/, $info{tc_iface});
	my @txt_rate = split(/,/, $info{tc_rate});
	my @txt_limit = split(/,/, $info{tc_limit});
	
	# print settings
	print <<EOF;
		<center>
		<table><form method=post>
		<h2>$text{lab_tc_setup}</h2>
			<center>
				<tr>
                                        <td class="noborder" align="right">$txt_iface[0]:</td>
                                        <td class="noborder"><input name='tc_iface' value="$config{'tc_iface'}" size=8></td>
                                </tr>

				<tr>
                                        <td class="noborder" align="right">$txt_rate[0]: </td>
                                        <td class="noborder"><input name='tc_rate' value="$config{'tc_rate'}" size=8><br></td>
                                </tr>

				<tr>
                                        <td class="noborder" align="right">$txt_limit[0]: </td>
                                        <td class="noborder"><input name='tc_limit' value="$config{'tc_limit'}" size=8></td>
                                </tr>

				<tr>
                                        <td class="noborder">&nbsp;</td>
                                        <td class="noborder">
                                                <input type=hidden name="apply" value="apply">
                                                <input type=submit value="$text{but_apply}">
				        </td>
                                </tr>
			</table>
		</form>
EOF

	# print status
	print "<hr>";
	print "<h2>$text{lab_tc_status}</h2>";
	print "<table border=1><tr><td><pre>";
	if (foreign_call("proc", "safe_process_exec", "./wshaper status 2>&1", 0, 0, 'STDOUT', undef, 1, 1)==0) { # wshaper exited prematuraly
		print text('lab_tc_notavailable');
	}
	print "</pre></td></tr></table></center><br>";
	
	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
}