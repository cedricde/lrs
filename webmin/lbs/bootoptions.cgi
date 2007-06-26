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
use vars qw (%access %config %in %lbsconf %text $VERSION $POSTINST_PATH $tb $cb);
# get some common functions ...
require "lbs.pl";
lbs_common::init_lbs_conf() or exit(0) ;

sub save_bootmenu_options {
        my ($cfgfile, %ether)=@_;
        my %hdr;
        hdrLoad( $cfgfile, \%hdr ) or error( lbsGetError() );
        
        my @menus = hdrGetMenuNames( \%hdr );
        
        lbsClearError();
        error( lbsGetError() ) if ( lbsErrorFlag() );
        
        my ( $timeoutfound, $timeoutloc ) =     hdrFindMenuItem( \%hdr, 'header', 'timeout' );
        my ( $hiddenfound, $hiddenloc ) =       hdrFindMenuItem( \%hdr, 'header', 'hiddenmenu' );
        my ( $nosecufound, $noseculoc ) =       hdrFindMenuItem( \%hdr, 'header', 'nosecurity' );
        my $timeoutval  = hdrGetMenuItem( \%hdr, 'header', 'timeout' ) if ( $timeoutfound == 1 );
        my $ethnumval   = hdrGetVal( \%hdr, 'header', 'ethnum' );
        
        if ( $timeoutfound == 1 ) {     				# TIMEOUT entry
                if ( $in{'timeout'} ne "on" ) {
                        iniSet($hdr{'ini'}, 'header', $timeoutloc, "#item", "timeout $timeoutval");
                } elsif ( $in{'timeoutval'} ne $timeoutval ){
                        hdrSetMenuItem( \%hdr, 'header', 'timeout', $in{'timeoutval'} );
                }
        } elsif ( $in{'timeout'} eq "on" ) {
        
                # Créé une nouvelle entrée dans un #item, s'il n'y en a pas, il sera créé
                iniSetVal( $hdr{'ini'}, 'header', "#item", "#timeout" );
                
                # Recherche et modifie la nouvelle entrée
                my @clefs = iniGetKeys( $hdr{'ini'}, 'header' );
                my $i;
                for ( $i = 0 ; $i < scalar(@clefs) ; $i++ ) {
                        my ( $k, $v ) = iniGet( $hdr{'ini'}, 'header', $i );
                        if ( $k eq "#item" and $v eq "#timeout" ) {
                                iniSet( $hdr{'ini'}, 'header', $i, "item","timeout $in{'timeoutval'}" );
                                last;
                        }
                }
        }

        # HIDDEN entry
        if ( defined($hiddenfound) && $hiddenfound == 1 ) {      				
                if ( $in{'hidden'} ne "on" ) {
                        iniSet($hdr{'ini'}, 'header', $hiddenloc, "#item", "hiddenmenu");
                }
        } elsif ( $in{'hidden'} eq "on" ) {
                # Créé une nouvelle entrée dans un #item, s'il n'y en a pas, il sera créé
                iniSetVal( $hdr{'ini'}, 'header', "#item", "#hiddenmenu" );

                # Recherche et modifie la nouvelle entrée
                my @clefs = iniGetKeys( $hdr{'ini'}, 'header' );
                my $i;
                for ( $i = 0 ; $i < scalar(@clefs) ; $i++ ) {
                        my ( $k, $v ) = iniGet( $hdr{'ini'}, 'header', $i );
                        if ( $k eq "#item" and $v eq "#hiddenmenu" ) {
                                iniSet( $hdr{'ini'}, 'header', $i, "item", "hiddenmenu" );
                                last;
                        }
                }
        }

	# NOSECU entry
        if ( defined($nosecufound) && $nosecufound == 1 ) {
                if ( $in{'nosecu'} ne "on" ) {
                        iniSet($hdr{'ini'}, 'header', $noseculoc, "#item", "nosecurity");
                }
        } elsif ( $in{'nosecu'} eq "on" ) {
                # Créé une nouvelle entrée dans un #item, s'il n'y en a pas, il sera créé
                iniSetVal( $hdr{'ini'}, 'header', "#item", "#nosecurity" );
                
                # Recherche et modifie la nouvelle entrée
                my @clefs = iniGetKeys( $hdr{'ini'}, 'header' );
                my $i;
                for ( $i = 0 ; $i < scalar(@clefs) ; $i++ ) {
                        my ( $k, $v ) = iniGet( $hdr{'ini'}, 'header', $i );
                        if ( $k eq "#item" and $v eq "#nosecurity" ) {
                                iniSet( $hdr{'ini'}, 'header', $i, "item", "nosecurity");
                                last;
                        }
                }
        }

	# ETHNUM entry
        if ( defined($in{'ethnum'}) && $in{'ethnum'} eq "on" ) {
                if ( $in{'ethnumval'} ne $ethnumval ) {
                        hdrSetVal( \%hdr, 'header', 'ethnum', $in{'ethnumval'} );
                }
        } else {
                hdrSetVal( \%hdr, 'header', 'ethnum', "" );	    
        }

	# KERNEL options
	my $opts = "";
	for my $opt ("revonocomp", "revoraw", "revonospc", "revodebug", "revontblfix")
	  {
	    if ( defined($in{"kernel_".$opt}) && $in{"kernel_".$opt} eq "on" ) {
	      $opts .= "$opt ";
	    }
	  }
	hdrSetVal( \%hdr, 'header', 'kernelopts', $opts);

	# final save
        hdrSave( $cfgfile, \%hdr );

}

my ( @titles, @presel, @desc, @menus, @newmenus, @status );
my ( %einfo,   %hdr,  %parm );
my ( $macaddr, $umac, $macfile, $cfgfile, $cfgpath, $name, $defaultmenu, $mesg );

my $lbs_home = $lbs_common::lbsconf{'basedir'};
my $etherfile = $lbs_home . "/etc/ether";
my ( $def_val, $visu_val );
my $i;
my $but_return;

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
redirect("postinst.cgi?modify=$text{'but_edit'}&file=$POSTINST_PATH/$in{'postinst'}") if (exists $in{'editconfpost'} and $in{'postinst'} ne "NULL");
redirect("postinst.cgi") if (exists $in{'editconfpost'});

if ( exists( $in{'cancel'} ) ) {
    redirect("index.cgi");
} elsif ( exists( $in{'apply'} ) ) {    		# "apply" button

        my ($mode, $profile, $group);

	# Check user rights for writing:
	error( $text{'acl_error'} ) if ( $access{'modify'} );

	if ( exists( $in{'form2'} ) ) {
                $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
                $mode = "MONO"  if (($in{'mac'}));

                # get the computer (One Computer Mode)
                if ($mode eq "MONO") {
                        $macaddr = $in{'mac'};
                        $macfile = toMacFileName($macaddr);
                        $name    = etherGetNameByMac( \%einfo, $macaddr );
                } else {
                        $profile = $in{'profile'};
                        $group = $in{'group'};
                }

                # grab the information about our menu
                if ($mode eq "MONO") {
                        $cfgfile = "$lbs_home/images/$macfile/header.lst";
                } else {
                        $cfgpath = "$lbs_home/imgprofiles/$in{'profile'}/$in{'group'}";
                        $cfgfile = "$cfgpath/header.lst";
                }

                save_bootmenu_options($cfgfile, %einfo);
                if ($mode eq "MULTI") { # in multi mode we have to to the while thing once again for every client TODO: subfunction for this ?
                        # to do this, we need the entire mac list to be loaded
                        my $home=$lbs_common::lbsconf{'basedir'};
                        my %ether;

                        my $profile = $in{'profile'} or "";
                        my $group = $in{'group'} or "";

			if ($profile eq "all") {$profile = "";}
			
                        lbs_common::etherLoad("$home/etc/ether", \%ether);
                        lbs_common::filter_machines_names($profile, $group, \%ether);

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
                                        my $cmd = "cp -a " . join " ", map "\"$origpath/$_\"", grep { -l "$origpath/$_" or $_ eq "header.lst" } readdir(ORIGPATH);
                                        closedir CFGPATH;
                                        $cmd .= " $cfgpath";
                                        system($cmd);
                                }
                        }
        
#                        foreach my $name (etherGetNames(\%ether)) {
#                                if (    ($name =~ m/^$profile:$group/)
#                                        ||
#                                        (($profile eq "") and ($name =~ m|:?/?$group|))
#                                        ||
#                                        (($group eq "") and ($name =~ m/^$profile:/))
#                                   ) {
#                                        my $macaddr = etherGetMacByName (\%ether, $name);
#                                        my $macfile = toMacFileName($macaddr);
#                                        my $home = $lbs_common::lbsconf{'basedir'};
#                                        my $cfgfile = "$home/images/$macfile/header.lst";
#                                        save_bootmenu_options($cfgfile, %ether);
#                                }
#                        }
                }

                if ($mode eq "MONO") {
                        updateEntry( $lbs_home, $macaddr ) or error( lbsGetError() );

                        # EXCLUDE UPDATES
                        my $excludefile = $lbs_home . "/images/" . toMacFileName( $in{'mac'} ) . "/exclude" ;

                        open EXCLUDEFILE, ">", $excludefile || die "can't open $excludefile for writing !";

                        foreach (%in) {								# syntax: restore_<#disk> or restore_<#disk>_<#part>
                                next if not m/^restore/;					# we only keep the"restore_toto" fields ...
                                next if ($in{"do_$_"} =~ m/on/);				# whose checkboxes "do_restore_toto" are NOT checked
                                print EXCLUDEFILE "$1:$2\n" if (m/^restore_([0-9]+)_([0-9]+)$/);# case 1: part
                        }
                        
                        close EXCLUDEFILE;
                        $umac       = urlize($macaddr);
                }
                
                # Re-generation du bootmenu ok:
                if ($mode eq "MONO") {
		        redirect("bootoptions.cgi?mac=$umac") ;
                } elsif ($mode eq "MULTI") {
		        redirect("bootoptions.cgi?group=$in{'group'}&profile=$oprofile") ;
                }
		exit;
	}

	# Must choose one menu or more:
	error( $text{'err_bootmenu_atleastone'} ) if ( not exists( $in{'menu'} ) );

	# Must define a default menu:
	error( $text{'err_bootmenu_mustdef'} ) if ( not exists( $in{'default'} ) );

        $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
        $mode = "MONO"  if (($in{'mac'}));
        
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
	#
	@newmenus = split ( m/\x0/g, $in{'menu'} );

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

	foreach $i (@menus) {
	
		if ( grep { $_ eq $i } @newmenus ) {
			$visu_val = "yes";
		} else {
			$visu_val = "no";
		}
		hdrSetVal( \%hdr, $i, "visu", $visu_val );
		
		if ( $i eq $in{'default'} ) {
			$def_val = "yes";
		} else {
			$def_val = "no";
		}
		hdrSetVal( \%hdr, $i, "def",  $def_val );
		
		# Default menu must be part of the selection:
		if ( ( $def_val eq "yes" ) and ( $visu_val ne "yes" ) ) {
			error( text( "err_bootmenu_baddef", $in{'default'} ) );
		}
	}
        # halt in case of error
	error( lbsGetError() ) if ( lbsErrorFlag() );
        # or save it
	hdrSave( $cfgfile,      \%hdr );

        updateEntry( $lbs_home, $macaddr ) or error( lbsGetError() );
        
	$umac = urlize($macaddr);
	
	# header
	lbs_common::print_header( $text{'tit_bmenu'}, "bootoptions", $VERSION);
        
	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'list_of_clients']);
    
	$but_return = $text{'but_return'};
	$mesg       = text( "msg_bootmenu_writeok", $name, $macaddr );

	# Re-generation du bootmenu ok:
        if ($mode eq "MONO") {
                print "<p>$mesg</p>\n";
                print "<a href=\"bootoptions.cgi?mac=$umac\">$but_return</a>";
                print "<p>&nbsp;</p>\n";
        } elsif ($mode eq "MULTI") {
                print "<p>$mesg</p>\n";
                print "<a href=\"bootoptions.cgi?group=$in{'group'}&profile=$oprofile\">$but_return</a>";
                print "<p>&nbsp;</p>\n";
        }

	# end of tabs
	lbs_common::print_end_menu();		

	# end of page
	footer( "", $text{'index'} );

} else {        		# show form if no 'apply':

	my %tabattr = (
		'rotate'    => 0,
		'tr_header' => $tb,
		'tr_body'   => $cb,
		'center'=> 0
	);

        # describe how this cgi will handle the request
        my $mode = "";                                                  

	# halt if we can't found a corresponding computer / group / profile
	error( $text{'err_invalcgi_noenoughdata'} )
                if (
                        ( not exists( $in{'mac'} ) )
                    and ( not exists( $in{'name'} ) )
                    and ( not exists( $in{'group'} ) )
                    and ( not exists( $in{'profile'} ) )
                   );
	lbsClearError();

        $mode = "MULTI" if (($in{'group'}) or ( $in{'profile'}));
        $mode = "MONO"  if (($in{'mac'}) or ( $in{'name'}));
	
	# get the computer (One Computer Mode)
        if ($mode eq "MONO") {
                if ( exists( $in{'mac'} ) ) {
                        $macaddr = $in{'mac'};
                        $name = etherGetNameByMac( \%einfo, $macaddr );
                } else {
                        $name = $in{'name'};
                        $macaddr = etherGetMacByName( \%einfo, $name );
                }
                
                error( lbsGetError() ) if ( lbsErrorFlag() );
                
                $macfile = toMacFileName($macaddr);
                $cfgfile = "$lbs_home/images/$macfile/header.lst";
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
                        push @presel, $i if ( grep m/^y/i, $parm{'visu'} );
                        $defaultmenu = $i if ( grep m/^y/i, $parm{'def'} );
                        push @status, 0;
		}
	}        

	# header	
	lbs_common::print_header( $text{'tit_bmenu'}, "bootmenu", $VERSION);

	# tabs
	lbs_common::print_html_tabs(['system_backup', 'options']);
        
        # title
        
	# boot menu, FIXME i18n
        if ($mode eq "MONO") {
        	print "<h2 align='center'x>Client $name ($macaddr)</h2>";
        } elsif ($mode eq "MULTI") {
                my @local_title;
	        print "<h2 align=center>";
                push @local_title, "$text{'lab_group'} $in{'group'}" if $in{'group'};
                push @local_title, "$text{'lab_profile'} $in{'profile'}" if $in{'profile'};
                print join ', ', @local_title;
                print "</h2>";
        }
        
	print "<hr><form action=\"bootoptions.cgi\">";

        # partitions to exclude
        my @toprow = ($text{lab_disk}, $text{lab_partition}) ;
        my @subrow = qw(PartNum PartType PartLength) ;
        my @lol = () ;
        if ($mode eq "MONO") {
                my $infofile = $lbs_home . "/log/" . toMacFileName( $in{'mac'} ) . ".ini" ;
                my %ini;
		
		if (! -f $infofile) { system("touch $infofile"); }
                iniLoad($infofile, \%ini);

                my %excludes;

                my $excludefile = $lbs_home . "/images/" . toMacFileName( $in{'mac'} ) . "/exclude" ;
                if (open EXCLUDEFILE, $excludefile) {
                        while (<EXCLUDEFILE>) {
                                chomp;
                                $excludes{$_}=1 if m/^[0-9]+:[0-9]+$/;
                        }
                        close EXCLUDEFILE;
                }

                my $diskidx=0;		
                foreach $i (grep m/^DISK/gi, iniGetSections(\%ini)) {
                        my @sublol = ();
                        my @rows=iniGetValues(\%ini, $i, @toprow);
                        my $checked;

                        $excludes{$diskidx.":0"} = 0 unless exists ($excludes{$diskidx.":0"});
                        $checked="CHECKED " unless ($excludes{$diskidx.":0"} == 1);

                        $rows[0] = "<input type='checkbox' name='do_restore_$diskidx"."_0' $checked />&nbsp; ".($diskidx+1)." $rows[0]";
                        $rows[0] .= "<input type='hidden' name='restore_$diskidx"."_0' value='1' />\n";
                        # --- sub-table Partitions:
                        if ( get_part_params(\%ini, $i, \@subrow, \@sublol) ) {
                                my $parts;
                                foreach my $part (@sublol) {
                                        my @tbl=$part;
                                        $excludes{$diskidx.":".($tbl[0][0]+1)} = 0 unless exists ($excludes{$diskidx.":".($tbl[0][0]+1)});
                                        $checked="CHECKED"      unless ($excludes{$diskidx.":".($tbl[0][0]+1)}==1);
                                        $checked=""     	if ($excludes{$diskidx.":".($tbl[0][0]+1)}==1);
                                        $parts .= "<input type='checkbox' name='do_restore_$diskidx"."_".($tbl[0][0]+1)."' $checked />&nbsp;".($tbl[0][0]+1)." ($tbl[0][1]) &nbsp; $tbl[0][2] MiB<br>\n";
                                        $parts .= "<input type='hidden' name='restore_$diskidx"."_".($tbl[0][0]+1)."' value='1' />\n";
                                }
                                pop @rows;
                                push @rows, $parts;
                        }
                        push @lol, [ @rows ] ;
                        $diskidx++;
                }


                print lbs_common::make_html_table( $text{'lab_partitions_to_restore'} , \@toprow, \@lol, \%tabattr) ;
                print "<input type=submit name='apply' value=\"$text{but_apply}\">\n";

        }

        my @radio  = ();
        my @desc   = ();
        my @values = ();

	# TIMEOUT
	my ( $found, $loc ) = hdrFindMenuItem( \%hdr, 'header', 'timeout' );
	my ( $timeout, $checked ) = ( "", "" );
	if ( $found == 1 ) {
		$timeout = hdrGetMenuItem( \%hdr, 'header', 'timeout' );
		$checked = "checked";
	}
	push @radio,  "<input type=checkbox name=timeout $checked>";
	push @desc,   $text{lab_timeout};
	push @values, "<input type=text size=5 maxlength=3 name=timeoutval value=$timeout $timeout>";

	# HIDDENMENU
	( $found, $loc ) = hdrFindMenuItem( \%hdr, 'header', 'hiddenmenu' );
	my $desc;
	( $desc, $checked ) = ( "&nbsp;", "" );
	if ( $found == 1 ) {
		$checked = "checked";
		$desc = "Shift-Alt-Shift";
	}
	push @radio,  "<input type=checkbox name=hidden $checked>";
	push @desc,   $text{lab_hidden};
	push @values, $desc;

	# NOSECURITY
	( $found, $loc ) = hdrFindMenuItem( \%hdr, 'header', 'nosecurity' );
	( $desc, $checked ) = ( "&nbsp;", "" );
	if ( $found == 1 ) {
		$checked = "checked";
	}
	push @radio,  "<input type=checkbox name=nosecu $checked>";
	push @desc,   $text{lab_nosecurity};
	push @values, $desc;

	# ETHNUM
	my $ethnum;
	( $ethnum, $checked ) = ( 0, "" );
	$ethnum = hdrGetVal( \%hdr, 'header', 'ethnum' );
	if ($ethnum ne "") {
		$checked = "checked";
	}
	push @radio, "<input type=checkbox name=ethnum $checked>";
	push @desc,  $text{lab_ethnum};
	push @values, "<input type=text size=5 maxlength=1 name=ethnumval value=$ethnum $ethnum>";

	# KERNEL OPTS
	my $kopts = hdrGetVal( \%hdr, 'header', 'kernelopts');
	#for my $opt ("revonocomp", "revoraw", "revodebug")
	for my $opt ("revonospc" ,"revodebug", "revontblfix")
	  {
	    my $checked = "";
	    
	    if ($kopts =~ /$opt/) {
	      $checked = "checked";
	    }
	    push @radio, "<input type=checkbox name=kernel_$opt $checked>";
	    push @desc,  $text{"lab_kernel_".$opt};
	    push @values, "&nbsp;";
	  }

	@lol = ();
	@toprow = ( "", $text{lab_option}, $text{lab_value} );
	push @lol, [@radio], [@desc], [@values];
	lbs_common::lolRotate( \@lol );
	print "<br>";
	print "<br><div align='left'>";
	print lbs_common::make_html_table( $text{"lab_options"}, \@toprow, \@lol, \%tabattr );

        if ($mode eq "MONO") {
        	print "<input type=hidden name='mac' value=\"$macaddr\">\n";
        } elsif ($mode eq "MULTI") {
	        print "<input type=hidden name=group value=\"$in{'group'}\">\n";
	        print "<input type=hidden name=profile value=\"$oprofile\">\n";
        }

	print "<input type=hidden name='form2' value=\"bootoptions\">\n";
	print "<input type=submit name='apply' value=\"$text{but_apply}\">\n";
	print "</div>";
	
	print "</form>\n";

        if ($mode eq "MONO") {
                # postinstall
                my $conf = "images/$macfile";
                bootmenu_save_postinst($conf, $lbs_home);
                bootmenu_show_postinst($conf, $lbs_home) if -x "$lbs_home/lib/util/captive/usr/bin/captive-lufsmnt";
        }

	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		

	# end of page
	footer( "", $text{'index'} );
}
