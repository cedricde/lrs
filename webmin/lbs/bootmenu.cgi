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
use vars qw (%access %config %in %lbsconf %text $VERSION $cb $tb);
# get some common functions ...
do "lbs.pl";

lbs_common::init_lbs_conf() or exit(0) ;

my ( @titles, @presel, @desc, @menus, @newmenus, @status );
my ( %einfo,   %hdr,  %parm );
my ( $macaddr, $profile, $group, $umac, $macfile, $name, $defaultmenu, $mesg, $mode);

my ($cfgfile, $cfgpath);                        # config files path and name

my $lbs_home  = $lbs_common::lbsconf{'basedir'};
my $etherfile = $lbs_home . "/etc/ether";
my ( $def_val, $visu_val );
my $i;
my $but_return;

my %tabattr = (
	'rotate'    => 0,
	'tr_header' => $tb,
	'tr_body'   => $cb,
);

error( text( "err_dnf", $lbs_home ) )  if ( not -d $lbs_home );
error( text( "err_fnf", $etherfile ) ) if ( not -f $etherfile );

# Resultat dans %in:
ReadParse();

etherLoad( $etherfile, \%einfo ) or error( lbsGetError() );

# On effectue une modif si presence du param cgi 'apply' (on ignore sa valeur). 
# Ou on redirige sur index.cgi si presence du param cgi 'cancel'.
# Ou sinon on affiche le formulaire du menu de boot.
# Exemple: menu: menu01 menu02, form:bootmenu, default:menu02, apply:appliquer,
#          name:jjmsi1
#
if ( exists( $in{'cancel'} ) ) {			# back to the main menu

	redirect("index.cgi");

} elsif ( exists( $in{'apply'} ) ) {    		# menu has changed: save it

	# Check user rights for writing:
	error( $text{'acl_error'} ) if ( $access{'modify'} );
	if ( exists( $in{'form2'} ) ) {
		
		# get the computer
		$macaddr = $in{'mac'};
		$macfile = toMacFileName($macaddr);
		$name    = etherGetNameByMac( \%einfo, $macaddr );
	
		# get it's informations
		$cfgfile = "$lbs_home/images/$macfile/header.lst";
		hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
		@menus = hdrGetMenuNames( \%hdr );
	
		lbsClearError();
		error( lbsGetError() ) if ( lbsErrorFlag() );
	
		# and save using the new informations
		hdrSave( $cfgfile,      \%hdr );
		updateEntry( $lbs_home, $macaddr ) or error( lbsGetError() );
	
		$umac       = urlize($macaddr);
		redirect("bootmenu.cgi?mac=$umac") ;
	}
	# Must choose one menu or more:
	error( $text{'err_bootmenu_atleastone'} ) if ( not exists( $in{'menu'} ) );

	# Must define a default menu:
	error( $text{'err_bootmenu_mustdef'} ) if ( not exists( $in{'default'} ) );

        $mode = "MONO"  if (($in{'mac'}));
        $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
        
	# get the computer (One Computer Mode)
        if ($mode eq "MONO") {
                $macaddr = $in{'mac'};
                $macfile = toMacFileName($macaddr);
                $name    = etherGetNameByMac( \%einfo, $macaddr );
        } else {
                $profile = $in{'profile'};
                $group = $in{'group'};
        }
	# Recup des items selectionnes
	# Rappel: $in{'menu'} est un scalaire contenant des chaines separes
	# par des caracteres nuls ('\0').
	@newmenus = split ( m/\x0/, $in{'menu'} );

	# grab the information about our menu
        if ($mode eq "MONO") {
        	$cfgfile = "$lbs_home/images/$macfile/header.lst";
        } else {
                $cfgpath="$lbs_home/imgprofiles/$in{'profile'}/$in{'group'}";
                $cfgfile = "$cfgpath/header.lst";
        }
	hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
	@menus = hdrGetMenuNames( \%hdr );

	lbsClearError();

        # save the checked values for our group / profile menus
	foreach $i (@menus) {
	
		$visu_val = 'no';
		$visu_val = 'yes' if ( grep { $_ eq $i } @newmenus );
		hdrSetVal( \%hdr, $i, "visu", $visu_val );

		$def_val = "no";				
		$def_val = "yes" if ( $i eq $in{'default'} );
		hdrSetVal( \%hdr, $i, "def",  $def_val );
		
		# Default menu must be part of the selection:
		error( text( "err_bootmenu_baddef", $in{'default'} ) ) if ( ( $def_val eq "yes" ) and ( $visu_val ne "yes" ) );
	}
        # and halt in case of error
	error( lbsGetError() ) if ( lbsErrorFlag() );
        # or save it
	hdrSave( $cfgfile,      \%hdr );
        
        if ($mode eq "MULTI") {
                # to do this, we need the entire mac list to be loaded
                my $home=$lbs_common::lbsconf{'basedir'};
                my %ether;

                my $profile = $in{'profile'} or "";
                my $group = $in{'group'} or "";
                
                lbs_common::etherLoad("$home/etc/ether", \%ether);
                lbs_common::filter_machines_names($in{'profile'}, $in{'group'}, \%ether);
                
                foreach my $name (etherGetNames(\%ether)) {
                        my $macaddr = etherGetMacByName (\%ether, $name);
                        my $macfile = toMacFileName($macaddr);
                        my $cfgpath = "$home/images/$macfile";
                        if (opendir CFGPATH, $cfgpath) {
                                unlink map "$cfgpath/$_", grep { -l "$cfgpath/$_"} readdir(CFGPATH);
                                closedir CFGPATH;
                        }
                        my $origpath = "$lbs_home/imgprofiles/$in{'profile'}/$in{'group'}";
                        if (opendir ORIGPATH, $origpath) {
                                my $cmd = "cp -a " . join " ", map "$origpath/$_", grep { -l "$origpath/$_" or $_ eq "header.lst" } readdir(ORIGPATH);
                                closedir CFGPATH;
                                $cmd .= " $cfgpath";
                                system($cmd);
                        }
                }
                
                
#                foreach my $name (etherGetNames(\%ether)) {
#                        my $macaddr = etherGetMacByName (\%ether, $name);
#                        $macfile = toMacFileName($macaddr);
#                        $cfgfile = "$home/images/$macfile/header.lst";
#                        hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
#                        @menus = hdrGetMenuNames( \%hdr );
#                        foreach $i (@menus) {
#                        
#                                $visu_val = 'no';
#                                $visu_val = 'yes' if ( grep { $_ eq $i } @newmenus );
#                                hdrSetVal( \%hdr, $i, "visu", $visu_val );
#                
#                                $def_val = "no";				
#                                $def_val = "yes" if ( $i eq $in{'default'} );
#                                hdrSetVal( \%hdr, $i, "def",  $def_val );
#                                
#                                # Default menu must be part of the selection:
#                                error( text( "err_bootmenu_baddef", $in{'default'} ) ) if ( ( $def_val eq "yes" ) and ( $visu_val ne "yes" ) );
#                                hdrSave( $cfgfile, \%hdr);
#                                updateEntry( $lbs_home, $macaddr ) or error( lbsGetError() );
#                        }
#                }
        } elsif ($mode eq "MONO") {
                updateEntry( $lbs_home, $macaddr ) or error( lbsGetError() );
        }
	$umac = urlize($macaddr);
    
        # header
	lbs_common::print_header( $text{'tit_bmenu'}, "bootmenu", $VERSION);
	
	# tabs
	lbs_common::print_html_tabs(['system_backup', 'boot_menu']);
	
        if ($mode eq "MONO") {
        	$mesg = text( "msg_bootmenu_macwriteok", $name, $macaddr );
                print "<script>setTimeout(\"location='bootmenu.cgi?mac=$umac&random='+Math.random();\",2000)</script>";
                print "<p>$mesg</p>\n";
	        print "<a href=\"bootmenu.cgi?mac=$umac\">$but_return</a>";
        } else {
        	$mesg = text( "msg_bootmenu_groupwriteok", "$in{'profile'}:$in{'group'}");
                print "<script>setTimeout(\"location='bootmenu.cgi?group=$in{'group'}&profile=$in{'profile'}&random='+Math.random();\",2000)</script>";
                print "<p>$mesg</p>\n";
	        print "<a href=\"bootmenu.cgi?group=$in{'group'}&profile=$in{'profile'}\">$but_return</a>";
        }
	print "<p>&nbsp;</p>\n";
	
	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
	
} else {        						# draws the form

my @radio  = ();
my @desc   = ();
my @values = ();

my @lol = ();
my @toprow = ( "", $text{lab_option}, $text{lab_value} );

my $mode = "";                                                  # describe how this cgi will handle the request

	# halt if we can't found a corresponding computer / group / profile
	error( $text{'err_invalcgi_noenoughdata'} )
                if (
                        ( not exists( $in{'mac'} ) )
                    and ( not exists( $in{'name'} ) )
                    and ( not exists( $in{'group'} ) )
                    and ( not exists( $in{'profile'} ) )
                   );
	lbsClearError();

        $mode = "MONO"  if (($in{'mac'}) or ( $in{'name'}));
        $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
        
	# get the computer (One Computer Mode)
        if ($mode eq "MONO") {
                if ( exists ($in{'mac'}) ) {
                        $macaddr = $in{'mac'};
                        $name = etherGetNameByMac( \%einfo, $macaddr );
                        error( lbsGetError() ) if ( lbsErrorFlag() );
                } elsif ( exists ($in{'name'}) ) {
                        $name = $in{'name'};
                        $macaddr = etherGetMacByName( \%einfo, $name );
                        error( lbsGetError() ) if ( lbsErrorFlag() );
                }
                $macfile = toMacFileName($macaddr);
                $cfgpath = "$lbs_home/images/$macfile/";
                $cfgfile = "$cfgpath/header.lst";
        } elsif ($mode eq "MULTI") {
                $cfgpath="$lbs_home/imgprofiles/$in{'profile'}/$in{'group'}";
                $cfgfile = "$cfgpath/header.lst";
                create_group_dir($cfgpath);
        }

        # load the needed header.lst
	hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
	# parse it
	@menus = hdrGetMenuNames( \%hdr );

	# and initialise some default vals
	@titles      = ();
	@desc        = ();
	@presel      = ();
	@status      = ();
	$defaultmenu = '';
	foreach $i (@menus) {
		if ( not hdrGetMenuInfo( \%hdr, $i, \%parm ) ) {
			push @titles, $i;
			push @desc,   lbsGetError();
			push @status, 2;
		}
		else {
                        push @titles, $parm{'title'};
                        push @desc,   $parm{'desc'};
                        push @presel, $i        if ( grep m/^y/i, $parm{'visu'} );
                        $defaultmenu = $i       if ( grep m/^y/i, $parm{'def'} );
                        push @status, 0;
		}
	}
        
	# header
       	lbs_common::print_header( $text{'tit_bmenu'}, "bootmenu", $VERSION);

	# tabs
	lbs_common::print_html_tabs(['system_backup', 'boot_menu']);
  
	# boot menu, FIXME i18n
        if ($mode eq "MONO") {
	        print "<h2 align=center>Client $name ($macaddr)</h2>";
                print_bootmenu_form(
                        {'mac' => $macaddr},
                        $defaultmenu,
                        \@menus,
                        \@titles,
                        \@presel,
                        \@desc,
                        \@status
                );
        } elsif ($mode eq "MULTI") {
                my @local_title;
	        print "<h2 align=center>";
                push @local_title, "$text{'lab_group'} $in{'group'}" if $in{'group'};
                push @local_title, "$text{'lab_profile'} $in{'profile'}" if $in{'profile'};
                print join ', ', @local_title;
                print "</h2>";
                print_bootmenu_form(
                        {'group' => $in{'group'}, 'profile' => $in{'profile'}},
                        $defaultmenu,
                        \@menus,
                        \@titles,
                        \@presel,
                        \@desc,
                        \@status
                );
        }

	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
}