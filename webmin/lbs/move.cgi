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
use vars qw (%access %config %in %lbsconf %text $VERSION $WOL_EXTENSION);
# get some common functions ...
require "lbs.pl";

lbs_common::init_lbs_conf() or exit(0) ;

my $decor = 'style="text-decoration:none"' ;

my $lbs_home  = $lbs_common::lbsconf{'basedir'};
my $etherfile = $lbs_home . "/etc/ether" ;

my (@localimages, @localtitles, @localdescs) ;
my (@baseimages, @basetitles, @basedescs) ;
my (@flags_h2l,@flags_l2h, @flags_l2b, @flags_b2h) ;
my (@titles, @desc, @menus, @usedimages, @hostdirs) ;

my %hlinks ;
my (%einfo, %hdr, %parm) ;

my ($macaddr, $umac, $name, $op, $img, $macfile, $cfgfile) ;
my ($i, $t, $d, $f, $buf) ;

my $mode;       # cgi running mode
my $cfgpath;    # the path to header.lst
my $cfgfile;    # the path of header.lst

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;
error(text("err_fnf",$etherfile)) if (not -f $etherfile) ;

# Resultat dans %in:
ReadParse() ;

# make sure to use the 'all' directory when any profile is requested
my $oprofile = $in{'profile'};
if (exists($in{'profile'}) && ($in{'profile'} eq "")) {
    $in{'profile'} = "all";
}

$mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
$mode = "MONO"  if (($in{'mac'}) or ( $in{'name'}));

if ($mode eq "MONO") {
        if (not exists($in{'mac'})) {
                error($text{'err_invalcgi_nomac'}) ;
                die ;
        }
        
        etherLoad($etherfile, \%einfo) or error( lbsGetError() ) ;
        $macaddr = $in{'mac'} ;
        $macfile = toMacFileName($macaddr) ;
        $umac = urlize($macaddr) ;
        $name = etherGetNameByMac(\%einfo, $macaddr) ;
}

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

if (exists($in{'cancel'})) {
	redirect("bootmenu.cgi?mac=$umac") ;
} elsif (exists($in{'imgbase'})) {
	redirect("imgbase.cgi") ;
} elsif (exists($in{'op'}) and $in{'op'} ne "none") {   	# operation needeed

	# L'utilisateur a t-il le droit d'effectuer des modifs?
	error( $text{'acl_error'} )     	if ($access{'modify'});
	error($text{'err_invalcgi_noimg'})      if (not exists($in{'img'}));

	lbsClearError() ;
	
	$op = $in{'op'} ;
	$img = $in{'img'} ;
	
	if ($op eq "h2l") {     				# from host to local
                if ($mode eq "MONO") {
        		moveHdr2Local($lbs_home, $macaddr, $img);
	        	# check if it's a base image, delete this link/base image if needeed
		        unlink("$lbs_home/images/$macfile/$img") if (-l "$lbs_home/images/$macfile/$img"); 
                } elsif ($mode eq "MULTI") {
		        moveHdr2Local_Multi($lbs_home, $cfgpath, $img);
                }
	} elsif ($op eq "l2h") {				# from local to host
		moveLocal2Hdr($lbs_home, $macaddr, $img) ;
	} elsif ($op eq "l2b") {				# from local to base
		moveLocal2Base($lbs_home, $macaddr, $img) ;
	} elsif ($op eq "b2h") {				# from base to host
                if ($mode eq "MONO") {
		        moveBase2Hdr($lbs_home, $macaddr, $img) ;
                } elsif ($mode eq "MULTI") {
		        moveBase2Hdr_Multi($lbs_home, $cfgpath, $img);
                }
	} elsif ($op eq "del") {				# deletion
		redirect("delimg.cgi?from=move&mac=$umac&img=$img") ;
	} else {						# bad operation
		error($text{'err_invalcgi_badop'}) ;
	}

	error( lbsGetError() )  if (lbsErrorFlag()) ;   	# halt on every error

        if ($mode eq "MONO") {                  # local images are only in mono mode
        	redirect("move.cgi?mac=$umac") ;
        } elsif ($mode eq "MULTI") {
        	redirect("move.cgi?group=$in{'group'}&profile=$oprofile") ;
        }
	
} else { # Affichage du formulaire si pas de 'apply':

	# halt if we can't found a corresponding computer / group / profile
	error( $text{'err_invalcgi_noenoughdata'} )
                if (
                        ( not exists( $in{'mac'} ) )
                    and ( not exists( $in{'name'} ) )
                    and ( not exists( $in{'group'} ) )
                    and ( not exists( $in{'profile'} ) )
                   );
	lbsClearError();
        
        # load the needed header.lst
	hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );

	@menus 		= hdrGetMenuNames(\%hdr) ;
	@usedimages 	= hdrSelectMenuKey(\%hdr, "image") ;
	@hostdirs 	= read_subdirs_nolink($cfgpath) ;
	@localimages 	= listExclude(\@hostdirs, \@usedimages) ;
	@baseimages 	= readSubDirs("$lbs_home/imgbase") ;

	@titles         = () ;
	@desc           = () ;
	@flags_h2l      = () ;
	@flags_l2h      = () ;
	@flags_l2b      = () ;
	@flags_b2h      = () ;
	
	foreach $i (@hostdirs) {        	# Determining which local subdirs are actually symlinks:
		$hlinks{$i} = 0;
		$hlinks{$i} = 1 if (-l "$cfgpath/$i");
	}

	foreach $i (@menus) {   		# start menu infos
		hdrGetMenuInfo(\%hdr, $i, \%parm) ;
		push @titles, "$parm{'title'}" ;
		push @desc, $parm{'desc'} ;
	}

	foreach $i (@usedimages) {      	# boot menu flag
                if ($mode eq "MONO") {
                        if (moveHdr2Local($lbs_home,$macaddr,$i,1)) {
                                push @flags_h2l, 1 ;
                        } else {
                                push @flags_h2l, 0 ;
                        }
                } elsif ($mode eq "MULTI") {
                        if (moveHdr2Local_Multi($lbs_home, $cfgpath, $i, 1)) {
                                push @flags_h2l, 1 ;
                        } else {
                                push @flags_h2l, 0 ;
                        }
                }

	}

        if ($mode eq "MONO") {                  # local images are only in mono mode
                foreach $i (@localimages) {     	# for local images
                        my $f = "$lbs_home/images/$macfile/$i/conf.txt" ;
                        my $ff = urlize("images/$macfile/$i");
        
                        if (-f $f) {    		# if the file exists
                                fileLoad($f,\$buf) ;
                                $t = itemGetVal($buf,"title") || $text{'lab_notitle'} ;
                                $d = itemGetVal($buf,"desc") || $text{'lab_nodesc'} ;

                                addBackupProgressInfo($f, \$d);

                                push @localtitles, "<a href='title2.cgi?mac=$umac&conf=$ff' $decor>$t</a>" ;
                                push @localdescs, "<a href='desc2.cgi?mac=$umac&conf=$ff' $decor>$d</a>" ;
                        } else {
                                push @localtitles, "(server read error?)" ;
                                push @localdescs, "(server read error?)" ;
                        }
                        
                        if (moveLocal2Hdr($lbs_home,$macaddr,$i,1)) {
                                push @flags_l2h, 1 ;
                        } else {
                                push @flags_l2h, 0 ;
                        }
        
                        if (moveLocal2Base($lbs_home,$macaddr,$i,1)) {
                                push @flags_l2b, 1 ;
                        } else {
                                push @flags_l2b, 0 ;
                        }
                }
        }

	@baseimages = sort(@baseimages);
	foreach $i (@baseimages) {      	# for base images
		my $f = "$lbs_home/imgbase/$i/conf.txt";
		my $ff = "imgbase/$i";

                if ($mode eq "MONO") {
                        if (-f $f) {    		# if the file exists
                                fileLoad($f,\$buf) ;
                                $t = itemGetVal($buf,"title") || $text{'lab_notitle'} ;
                                $d = itemGetVal($buf,"desc") || $text{'lab_nodesc'} ;
                                
                                addBackupProgressInfo($f, \$d);

                                push @basetitles, "<a href='title2.cgi?mac=$umac&conf=$ff' $decor>$t</a>";
                                push @basedescs, "<a href='desc2.cgi?mac=$umac&conf=$ff' $decor>$d</a>" ;
                        } else {
                                push @basetitles, "(storage?)" ;
                                push @basedescs, "(storage?)" ;
                        }

                        if (moveBase2Hdr($lbs_home,$macaddr,$i,1)) {
                                push @flags_b2h, 1 ;
                        } else {
                                push @flags_b2h, 0 ;
                        }
                } elsif ($mode eq "MULTI") {
                        if (-f $f) {    		# if the file exists
                                fileLoad($f,\$buf) ;
                                $t = itemGetVal($buf,"title") || $text{'lab_notitle'} ;
                                $d = itemGetVal($buf,"desc") || $text{'lab_nodesc'} ;
                                
                                addBackupProgressInfo($f, \$d);

                                push @basetitles, "<a href='title2.cgi?group=$in{'group'}&profile=$oprofile&conf=$ff' $decor>$t</a>";
                                push @basedescs, "<a href='desc2.cgi?group=$in{'group'}&profile=$oprofile&conf=$ff' $decor>$d</a>" ;
                        } else {
                                push @basetitles, "(storage?)" ;
                                push @basedescs, "(storage?)" ;
                        }

                        if (moveBase2Hdr_Multi($lbs_home, $cfgpath, $i, 1)) {
                                push @flags_b2h, 1 ;
                        } else {
                                push @flags_b2h, 0 ;
                        }
                }
	}
	
	# headers	
	lbs_common::print_header( $text{'tit_move'}, "move", $VERSION);

	# tabs
	lbs_common::print_html_tabs(['system_backup', 'shared_images']);
	
        if ($mode eq "MONO") {
	        print "<h2 align=center>Client $name ($macaddr)</h2>";
        } elsif ($mode eq "MULTI") {
                my @local_title;
	        print "<h2 align=center>";
                push @local_title, "$text{'lab_group'} $in{'group'}"            if $in{'group'};
                push @local_title, "$text{'lab_profile'} $in{'profile'}"        if $in{'profile'};
                print join ', ', @local_title;
                print "</h2>";
        }
        
	print_move_header_form(
                {
                        'mac'         => $macaddr,
                        'group'       => $in{'group'},
                        'profile'     => $in{'profile'}
                },
                \@usedimages,
                \@titles,
                \@desc,
                \@usedimages,
                \@flags_h2l,
                \%hlinks,
                \@menus
        ) ;
                                
        if ($mode eq "MONO") {                  # local images are only in mono mode
                print_move_local_form(
                                        $macaddr,
                                        \@localimages,
                                        \@localtitles,
                                        \@localdescs,
                                        \@localimages,
                                        \@flags_l2h,
                                        \@flags_l2b,
                                        \%hlinks
                                      );
        }
        
	print_move_base_form(
                {
                        'mac'         => $macaddr,
                        'group'       => $in{'group'},
                        'profile'     => $in{'profile'}
                },
                \@baseimages,
                \@basetitles,
                \@basedescs,
                \@baseimages,
                \@flags_b2h
        );
	
	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		

	# end of page
	footer( "", $text{'index'} );
	
}


# moveBase2Hdr ($home,$path,$image [, $test])
#
#
sub moveBase2Hdr_Multi {
        my ($home, $hostdir, $image) = @_ ;
        my $test = $_[3] || 0 ;
        my $donotdie = $_[4] || 0 ;
        my $imgbase = $home . "/imgbase" ;
        my $hostconf = $hostdir . "/header.lst" ;
        my %hdr ;
        my ($menu,$include,$newlink) ;

        if (not -d "$imgbase/$image") {                                 # image's dir can't be found ?
                $donotdie or lbsError("moveBase2Hdr","IMG_NF","$imgbase/$image") ;
                return 0 ;
        }
        
        if (-e "$hostdir/$image") {                                     # image's dir doesn't exists ?
                $donotdie or lbsError("moveBase2Hdr","IMG_EXISTS", "$hostdir/$image") ;
                return 0 ;
        }
        
        if (not hdrLoad($hostconf, \%hdr)) {                            # current header can't be read ?
                $donotdie or lbsError("moveBase2Hdr","FILE_LOAD",$hostconf) ;
                return 0 ;
        }

        $menu = hdrFindMenu(\%hdr,"image",$image) ;                     # current image already used ?
        if (defined($menu)) {
                $donotdie or lbsError("moveBase2Hdr","IMG_USEDBYMENU",$image,$menu) ;
                return 0 ;
        }
        
        return 1 if ($test) ;                                           # don't go further if test mode
        
        if (not symlink("$imgbase/$image","$hostdir/$image")) {         # can't establish symlink ?
                $donotdie or lbsError("moveBase2Hdr","RAW","'$hostdir/$image': $!") ;
                return 0 ;
        }
        
        if (-f "$hostdir/$image/conf.txt") {
                $include = "$image/conf.txt" ;
        } else {
                $include = "" ;
        }
        
        $menu = hdrUniqueName(\%hdr) ;
        if (not hdrAddMenu(\%hdr, $menu)) {
                $donotdie or lbsError("moveBase2Hdr","MENU_CANTAPPEND",$menu) ;
                return 0 ;
        }
        
        hdrSetVal(\%hdr, $menu, "def", "no") ;
        hdrSetVal(\%hdr, $menu, "visu", "no") ;
        hdrSetVal(\%hdr, $menu, "image", $image) ;
        hdrSetVal(\%hdr, $menu, "include", $include) if (length($include)) ;
        hdrSave($hostconf,\%hdr) ;
        
        # regular and scheduled menus should be sync before entering this menu
        # so either we should copy regular to scheduled, or
        # we commit the previous changes to the existing file
        if (-f "$hostconf.$WOL_EXTENSION") {
                my %schedhdr;
                hdrLoad("$hostconf.$WOL_EXTENSION", \%schedhdr);
                hdrAddMenu(\%schedhdr, $menu);
                hdrSetVal(\%schedhdr, $menu, "def", "no") ;
                hdrSetVal(\%schedhdr, $menu, "visu", "no") ;
                hdrSetVal(\%schedhdr, $menu, "image", $image) ;
                hdrSetVal(\%schedhdr, $menu, "include", $include) if (length($include)) ;
                hdrSave("$hostconf.$WOL_EXTENSION",\%schedhdr) ;
        } else {
                system("cp -a $hostconf $hostconf.$WOL_EXTENSION") ;
        }
       
}

sub moveHdr2Local_Multi {
        my ($home, $hostdir, $image) = @_ ;
        my $test = $_[3] || 0 ;
        my $donotdie = $_[4] || 0 ;

        my $imgbase = $home . "/imgbase" ;
        my $hostconf = $hostdir . "/header.lst" ;
        my $menu ;
        my %hdr ;
        if (not hdrLoad($hostconf, \%hdr)) {
                $donotdie or lbsError("moveHdr2Local","FILE_LOAD",$hostconf) ;
                return 0 ;
        }
        
        $menu = hdrFindMenu(\%hdr, "image", $image) ;
        if (not defined($menu) or not length($menu)) {
                $donotdie or lbsError("moveHdr2Local","IMG_NF",$image) ;
                return 0 ;
        }
        
        return 1 if ($test) ;
         
        hdrDeleteMenu(\%hdr, $menu) ;
        hdrSave($hostconf,\%hdr) ;

        # regular and scheduled menus should be sync before entering this menu
        # so either we should copy regular to scheduled, or
        # we commit the previous changes to the existing file
        if (-f "$hostconf.$WOL_EXTENSION") {
                hdrLoad("$hostconf.$WOL_EXTENSION", \%hdr);
                hdrDeleteMenu(\%hdr, $menu) ;
                hdrSave("$hostconf.$WOL_EXTENSION",\%hdr) ;
        } else {
                system("cp -a $hostconf $hostconf.$WOL_EXTENSION") ;
        }

        unlink("$hostdir/$image") if (-l "$hostdir/$image"); 
}

