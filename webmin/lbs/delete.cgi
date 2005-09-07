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

# get some common functions ...
require "lbs.pl";
# ... and vars
use vars qw (%access %config %in %text $VERSION);

lbs_common::init_lbs_conf() or exit(0) ;

my %einfo ;
my $lbs_home = $lbs_common::lbsconf{'basedir'};
my $etherfile = $lbs_home . "/etc/ether" ;
my $syncommand = $lbs_home."/bin/check_add_host --sync" ;
my ($mac,$name) ;
my ($mesg, $warning) ;
my $result ;

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile)) if (not -f $etherfile) ;

ReadParse() ;
# L'utilisateur a t-il le droit d'effectuer des modifs?
error( $text{'acl_error'} ) if ($access{'modify'});

etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;

if (not exists $in{'mac'}) {
	error($text{'err_invalcgi_nomac'}) ;
} elsif (exists $in{'cancel'}) {
	redirect("index.cgi") ;
} elsif (exists $in{'apply'}) {

	$mac = $in{'mac'} ;
	$name = etherGetNameByMac(\%einfo, $mac) ;
	
	if (not defined $name) {
		error(text("err_mac_inval",$mac)) ;
	}
	
	if (not deleteEntry($lbs_home, $mac)) { # attempt to delete the image in the LRS
		error( lbsGetError() ) ;
	} else {                                # succeeded, now do some cleaning elsewhere
                
                # first cleaning: ocsinventory
                my $OCSDIR="/var/lib/ocsinventory";     # FIXME: hardcoded
                my $netfile="$OCSDIR/Network/".lbs_common::mac_remove_columns($mac);
                my $machine_name;
                open NETFILE, $netfile;
                while (<NETFILE>) {
                        if (m/^([^;]+)/) {
                                $machine_name="$1";
                                last;
                        }
                }
                close NETFILE;
                # build file-to-remove list
                my @toremove;
                push @toremove, $netfile;
                foreach my $dir (qw 'AccessLogs  Application  BIOS  Concatenations  Drivers  Graphics  Hardware  Info  LogicalDrives  Network  Printers  Results') {
                        foreach my $ext (qw 'csv csv.diff csv.old') {
                                push @toremove, "$OCSDIR/$dir/$machine_name.$ext" if (-e "$OCSDIR/$dir/$machine_name.$ext");
                        }
                }
                
                # second cleaning: backuppc
                my $BACKUPPCCONFDIR="/etc/backuppc";            # FIXME: hardcoded
                my $BACKUPPCFILESDIR="/var/lib/backuppc/pc";    # FIXME: hardcoded

                my $tmpname=$machine_name;
                push @toremove, "/etc/backuppc/$tmpname.pl"  if (-e "/etc/backuppc/$tmpname.pl");
#                `rm -fr $BACKUPPCFILESDIR/$tmpname`;
                $tmpname=lc($tmpname);
                push @toremove, "/etc/backuppc/$tmpname.pl"  if (-e "/etc/backuppc/$tmpname.pl");
#                `rm -fr $BACKUPPCFILESDIR/$tmpname`;
                $tmpname=uc($tmpname);
                push @toremove, "/etc/backuppc/$tmpname.pl"  if (-e "/etc/backuppc/$tmpname.pl");
#                `rm -fr $BACKUPPCFILESDIR/$tmpname`;
                
                `perl -i -ne "print unless m/^$machine_name\s+/i" $BACKUPPCCONFDIR/hosts`;
                
                #foreach my $file (@toremove) {
                #        unlink $file;
                #}
                
		$mesg = text("msg_delete_ok",$name,$mac);
		lbs_common::print_header( $text{'tit_delete'}, "index", $VERSION);
        	lbs_common::print_html_tabs(['system_backup', "delete_machine"]);
                
		print "<h2>$mesg</h2>\n" ;

		menuEnd();
		footer("", $text{'index'}) ;
	}

	# Sync dhcpd.conf with ether
	system($syncommand) == 0 or error("$!\n") ;

} else {
	# Affichage de la confirmation si pas de apply.
	
	$mac = $in{'mac'} ;
	$name = etherGetNameByMac(\%einfo, $mac) ;

	lbs_common::print_header( $text{'tit_delete'}, "index", $VERSION);

	lbs_common::print_html_tabs(['system_backup', "delete_machine"]);

	$mesg = text("msg_delete_confirm",$name,$mac) ;
	$warning = $text{'msg_delete_warn'} ;
	print_confirmation_form("delete.cgi", "<h2>$mesg<br><font color=#FF0000>$warning</font></h2>", "mac", $mac ) ;

	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		

	# end of page
	footer( "", $text{'index'} );
}