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
use vars qw (%access %config %in %lbsconf %text $VERSION $cb $tb $WOL_EXTENSION);
# get some common functions ...
do "lbs.pl";

lbs_common::init_lbs_conf() or exit(0) ;

my ( @titles, @presel, @schedpresel, @desc, @menus, @schedmenus, @newmenus, @newschedmenus, @status, @schedstatus, @images);
my ( %einfo, %hdr, %schedhdr, %parm );
my ( $macaddr, $profile, $group, $umac, $macfile, $name, $defaultmenu, $scheddefaultmenu, $mesg, $mode);

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
lbs_common::InClean();

etherLoad( $etherfile, \%einfo ) or error( lbsGetError() );

# make sure to use the 'all' directory when any profile is requested
my $oprofile = $in{'profile'};
if (exists($in{'profile'}) && ($in{'profile'} eq "")) {
    $in{'profile'} = "all";
}

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
	error( $text{'err_bootmenu_atleastonesched'} ) if ( not exists( $in{'schedmenu'} ) );

	# Must define a default menu:
	error( $text{'err_bootmenu_mustdef'} ) if ( not exists( $in{'default'} ) );
	error( $text{'err_bootmenu_schedmustdef'} ) if ( not exists( $in{'scheddefault'} ) );

        # Mode Selection
        $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
        $mode = "MONO"  if (($in{'mac'}));
        
	# Get the computer (One Computer Mode)
        if ($mode eq "MONO") {
                $macaddr = $in{'mac'};
                $macfile = toMacFileName($macaddr);
                $name    = etherGetNameByMac( \%einfo, $macaddr );
        } else {
                $profile = $in{'profile'};
                $group = $in{'group'};
        }
        
	# Gather selected items
        # for information: $in{'menu'} is a scalar containing NULL-separated chains.
        # fixme: better use PACK in this context ?
	@newmenus       = split ( m/\x0/, $in{'menu'} );
	@newschedmenus  = split ( m/\x0/, $in{'schedmenu'} );

	# grab the information about our menu
        if ($mode eq "MONO") {
        	$cfgfile = "$lbs_home/images/$macfile/header.lst";
        } else {
                $cfgpath="$lbs_home/imgprofiles/$in{'profile'}/$in{'group'}";
                $cfgfile = "$cfgpath/header.lst";
        }
        # load the needed header.lst
	hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
	# and parse it
	@menus = hdrGetMenuNames( \%hdr );

        # load the needed header.lst.$WOL_EXTENSION (schedule mode), create it if needed (should'nt append here)
        system("cp -a $cfgfile $cfgfile.$WOL_EXTENSION") unless -f "$cfgfile.$WOL_EXTENSION";
	hdrLoad( "$cfgfile.$WOL_EXTENSION", \%schedhdr ) or error( lbsGetError() );
	# and parse it
	@schedmenus = hdrGetMenuNames( \%schedhdr );

	lbsClearError();

        # save the checked values for our group / profile menus
	foreach $i (@menus) {
	
                # for regular menu
		$visu_val = 'no';
		$visu_val = 'yes' if ( grep { $_ eq $i } @newmenus );
		hdrSetVal( \%hdr, $i, "visu", $visu_val );
		$def_val = "no";				
		$def_val = "yes" if ( $i eq $in{'default'} );
		hdrSetVal( \%hdr, $i, "def",  $def_val );
		# Default menu must be part of the selection:
		error( text( "err_bootmenu_baddef", $in{'default'} ) ) if ( ( $def_val eq "yes" ) and ( $visu_val ne "yes" ) );

                # for scheduled menu
		$visu_val = 'no';
		$visu_val = 'yes' if ( grep { $_ eq $i } @newschedmenus );
		hdrSetVal( \%schedhdr, $i, "visu", $visu_val );
		$def_val = "no";				
		$def_val = "yes" if ( $i eq $in{'scheddefault'} );
		hdrSetVal( \%schedhdr, $i, "def",  $def_val );
		# Default scheduled menu must be part of the selection:
		error( text( "err_bootmenu_schedbaddef", $in{'scheddefault'} ) ) if ( ( $def_val eq "yes" ) and ( $visu_val ne "yes" ) );
	}

        # and halt in case of error
	error( lbsGetError() ) if ( lbsErrorFlag() );
        # or save menus
	hdrSave( $cfgfile,       \%hdr );
	hdrSave( "$cfgfile.$WOL_EXTENSION", \%schedhdr );
        
        if ($mode eq "MULTI") {
                # to do this, we need the entire mac list to be loaded
                my $home=$lbs_common::lbsconf{'basedir'};
                my %ether;

                my $profile = $in{'profile'} or "";
                my $group   = $in{'group'}   or "";
                
		if ($profile eq "all") { $profile = ""; } # filter_machines_names does not like profile=all

                lbs_common::etherLoad("$home/etc/ether", \%ether);
                lbs_common::filter_machines_names($profile, $in{'group'}, \%ether);
                
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
                                my $cmd = "cp -a " . join " ", map "$origpath/$_", grep { -l "$origpath/$_" or $_ eq "header.lst" or $_ eq "header.lst.$WOL_EXTENSION" } readdir(ORIGPATH);
                                closedir CFGPATH;
                                $cmd .= " $cfgpath";
                                system($cmd);
				updateEntry( $lbs_home, $macaddr ) or error( lbsGetError() );
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
                print "<script>setTimeout(\"location='bootmenu.cgi?group=$in{'group'}&profile=$oprofile&random='+Math.random();\",2000)</script>";
                print "<p>$mesg</p>\n";
	        print "<a href=\"bootmenu.cgi?group=$in{'group'}&profile=$oprofile\">$but_return</a>";
        }
	print "<p>&nbsp;</p>\n";
	
	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
	
} elsif ( exists( $in{'sync'} ) ) {    		                # needs to sync sched menu on no-sched menu
        
        # Mode Selection
        $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
        $mode = "MONO"  if (($in{'mac'}));

	# grab the path of our menu
        if ($mode eq "MONO") {
                $macaddr = $in{'mac'};
                $macfile = toMacFileName($macaddr);
                $name    = etherGetNameByMac( \%einfo, $macaddr );
        	$cfgfile = "$lbs_home/images/$macfile/header.lst";
		$umac       = urlize($macaddr);
        } else {
                $profile = $in{'profile'};
                $group = $in{'group'};
                $cfgpath="$lbs_home/imgprofiles/$profile/$group";
                $cfgfile = "$cfgpath/header.lst";
        }

        # sync it
        system("cp -a $cfgfile $cfgfile.$WOL_EXTENSION");

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
                print "<script>setTimeout(\"location='bootmenu.cgi?group=$in{'group'}&profile=$oprofile&random='+Math.random();\",2000)</script>";
                print "<p>$mesg</p>\n";
	        print "<a href=\"bootmenu.cgi?group=$in{'group'}&profile=$oprofile\">$but_return</a>";
        }
	print "<p>&nbsp;</p>\n";

	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
        
} else {                                                        # draws the form

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

        $mode = "MULTI" if (($in{'group'}) or exists($in{'profile'}));
        $mode = "MONO"  if (($in{'mac'}) or ( $in{'name'}));
	$mode = "SKEL" if ($in{'skel'});
        
	# get the computer (One Computer Mode)
        if ($mode eq "MONO") {
                if ( exists ($in{'mac'}) ) {
                        $macaddr = $in{'mac'};
                        $name = etherGetNameByMac( \%einfo, $macaddr );
                        error( lbsGetError() ) if ( lbsErrorFlag() );
                } elsif ( exists ($in{'name'}) ) {
                        $name = html_escape($in{'name'});
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
        } elsif ($mode eq "SKEL") {
                $cfgpath="$lbs_home/images/imgskel";
                $cfgfile = "$cfgpath/header.lst";
	}

        # load the needed header.lst
	hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
	# and parse it
	@menus = hdrGetMenuNames( \%hdr );

        # load the needed header.lst.$WOL_EXTENSION (schedule mode), create it if needed
	$cfgfile =~ s/[^a-z0-9\.\/_-]//gi;
        system("cp -a $cfgfile $cfgfile.$WOL_EXTENSION") unless -f "$cfgfile.$WOL_EXTENSION";
	hdrLoad( "$cfgfile.$WOL_EXTENSION", \%schedhdr ) or error( lbsGetError() );
	# and parse it
	@schedmenus = hdrGetMenuNames( \%schedhdr );

	# and initialise some default vals
	@titles                 = ();
	@desc                   = ();
	@presel                 = ();
	@schedpresel            = ();
	@status                 = ();
	@schedstatus            = ();
	$defaultmenu            = '';
	$scheddefaultmenu       = '';
	@images			= ();
	foreach $i (@menus) {
                # gather params for regular entries
		if ( not hdrGetMenuInfo( \%hdr, $i, \%parm ) ) {
			push @titles, $i;
			push @desc,   lbsGetError();
			push @status, 2;
		} else {
                        push @titles, $parm{'title'};
                        push @desc,   $parm{'desc'};
                        push @presel, $i        if ( grep m/^y/i, $parm{'visu'} );
                        $defaultmenu = $i       if ( grep m/^y/i, $parm{'def'} );
                        push @status, 0;
			
			my $impath;
			if ($mode eq "MONO") {
				my $smac = $macaddr;
				$smac =~ s/://g;
				$impath = "images/".$smac;
			} else {
				$impath = "imgbase/";
			}
			push @images, $impath."/".$parm{'image'};
		}
                
                # gather params for scheduled entries
		if ( not hdrGetMenuInfo( \%schedhdr, $i, \%parm ) ) {
			push @schedstatus, 2;
		} else {
                        push @schedpresel, $i        if ( grep m/^y/i, $parm{'visu'} );
                        $scheddefaultmenu = $i       if ( grep m/^y/i, $parm{'def'} );
                        push @schedstatus, 0;
		}
	}
        
	# header
       	lbs_common::print_header( $text{'tit_bmenu'}, "bootmenu", $VERSION);
	# tabs
	lbs_common::print_html_tabs(['system_backup', 'boot_menu']);
	lbs_common::checkforspace();
	# boot menu, FIXME i18n
        if (($mode eq "MONO")) {          # only one client selected
	        print "<h2 align=center>Client $name ($macaddr)</h2>";
                print_bootmenu_form(
                        {'mac' => $macaddr},
                        $defaultmenu,
                        $scheddefaultmenu,
                        \@menus,
                        \@schedmenus,
                        \@titles,
                        \@presel,
                        \@schedpresel,
                        \@desc,
                        \@status,
                        \@schedstatus,
			\@images
                );
        } elsif (($mode eq "MULTI") or ($mode eq "SKEL")) {    # a group / profile selected
                my @local_title;
	        print "<h2 align=center>";
                push @local_title, "$text{'lab_group'} $in{'group'}" if $in{'group'};
                push @local_title, "$text{'lab_profile'} $in{'profile'}" if $in{'profile'};
                print join ', ', @local_title;
                print "</h2>";
                print_bootmenu_form(
                        {'group' => $in{'group'}, 'profile' => $in{'profile'}},
                        $defaultmenu,
                        $scheddefaultmenu,
                        \@menus,
                        \@schedmenus,
                        \@titles,
                        \@presel,
                        \@schedpresel,
                        \@desc,
                        \@status,
                        \@schedstatus,
			\@images
                );
        }

	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
}
