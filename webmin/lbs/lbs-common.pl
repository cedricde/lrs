#!/usr/bin/perl
#
# Part of LBS Webmin module
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

do '../web-lib.pl';
do './lbs-part.pl';


#use strict;
use vars qw(%text %lbsconf %access %in %gconfig $cb $tb);


$|=1;
&init_config();

%access = &get_module_acl() ;

# Titres en lettres antialiasees
# (A partir de Webmin 0.88)
#
$gconfig{'texttitles'} = 0 ;


# Hash du fichier lbs.conf
# Doit etre rempli avec initLbsConf() depuis le CGI.
#
%lbsconf = () ;


#/////////////////////////////////////////////////////////////////////////////
# CONFIG
#/////////////////////////////////////////////////////////////////////////////

# message($title, $message)
#
sub message {
 &header($_[0], "", "index", 1, 1, undef, undef);
 print "<p>" . $_[1] . "</p>" ;
 &footer(undef,undef) ;
}


# int initLbsConf($file)
# Chargement de $file (/etc/lbs.conf) dans %lbsconf (hash global),
# et de lbs-lib.pl .
# On effectue aussi quelques tests de verification: presence du parametre
# 'basedir', et existence du repertoire en question.
# Retourne 1 si OK, ou 0 si erreur.
#
sub initLbsConf
{
my $file = shift ;

 if (not -f $file) {
 	message($text{'tit_error'},text("err_confnf",$file)) ;
 	return 0 ;
 }

 read_env_file($file, \%lbsconf) ;

 # strip \r characters
 #while ((my $k,my $v) = each(%lbsconf)) {
 #    $lbsconf{$k} =~ s/\r//g;
 #}


 if (not exists $lbsconf{'basedir'}) {
 	message($text{'tit_error'},
 	        text("err_paramnf", $lbsconf{'basedir'},$file)) ;
	return 0 ;
 }

 if (not -d $lbsconf{'basedir'}) {
 	message($text{'tit_error'},text("err_basedirnf", $lbsconf{'basedir'}));
 	return 0 ;
 }

 require "lbs-lib.pl" ;

 if (exists $gconfig{'lang'}) {
 	lbsSetLang($gconfig{'lang'}) or lbsSetLang('default') ;
 }
 else {
 	lbsSetLang('default') ;
 }

 return 1 ;
}


# int checkLinks(void)
# Retourne 1 si OK, ou 0 si erreur.
sub checkLinks
{

my $src1 = $lbsconf{'basedir'} . "/bin/lbs-lib.pl" ;
my $link1 = "lbs-lib.pl" ;
my $src2 = $lbsconf{'basedir'} . "/bin/inifile.pl" ;
my $link2 = "inifile.pl" ;

 if (not -f $link1) {
 	unlink($link1) if (-l $link1) ;
 	if (not symlink($src1, $link1)) {
 		message($text{'tit_error'},text("err_cantlink",$link1,$src1));
 		return 0 ;
 	}
 }
 
 if (not -f $link2) {
 	unlink($link2) if (-l $link2) ;
 	if (not symlink($src2, $link2)) {
 		message($text{'tit_error'},text("err_cantlink",$link2,$src2));
 		return 0 ;
  	}
 }

1;
}

#/////////////////////////////////////////////////////////////////////////////
# DEBUG
#/////////////////////////////////////////////////////////////////////////////

# showConfig(void)
#
sub showConfig {
	print "<p><pre>\n" ;
	
	my ($i, $j, $k, $v) ;

	# Arguments CGI
	# (%in est une var globale. cf ReadParse()).
	#
	print "<b>arguments CGI (\%in):</b>\n" ;
	while (($k,$v) = each(%in)) {
		# Les sous-champs sont separes par des carac nuls (0x00).
		# Ce qui pose un pb d'affichage:
		$v =~ s/\x0/ /g ;

		print "  $k: $v\n" ;
	}
	print "  (none)\n" if (not scalar(%in)) ;
	print "\n" ;

	# LBSCONFIG
	print "<b>lbsconf (lbs module):</b>\n" ;
	if (defined(%lbsconf)) {
		while (($k,$v) = each(%lbsconf)) {
			 print "  $k: $v\n" ;
		}
	}
	print "\n" ;


	# ACCESS
	print "<b>access:</b>\n" ;
	if (defined(%access)) {
		while (($k,$v) = each(%access)) {
			 print "  $k: $v\n" ;
		}
	}
	print "\n" ;


	# CONFIG
	print "<b>config:</b>\n" ;
	while (($k,$v) = each(%config)) {
		print "  $k: $v\n" ;
	}
	print "\n" ;

	# GCONFIG
	print "<b>gconfig:</b>\n" ;
	while (($k,$v) = each(%gconfig)) {
		print "  $k: $v\n" ;
	}
	print "\n" ;
	
	# MODULE_NAME
	print "<b>module_name:</b>\n" ;
	print "  $module_name\n\n" ;
	
	# MODULE_CONFIG_DIRECTORY
	print "<b>module_config_directory:</b>\n" ;
	print " $module_config_directory\n\n" ;
	
	# TB
	print "<b>background colour for table headers (tb):</b>\n" ;
	print "  $tb\n\n" ;
	
	# CB
	print "<b>background colour for table bodies (cb):</b>\n" ;
	print "  $cb\n\n" ;
	
	# SCRIPTNAME
	print "<b>scriptname:</b>\n" ;
	print "  $scriptname\n\n" ;
	
	# ENV
	print "<b>ENV:</b>\n" ;
	while (($k,$v) = each(%ENV)) {
		print "  $k: $v\n" ;
	}
	print "\n" ;
	
	print "</pre>\n" ;
}

# printLOL (\@lol)
#
sub printLOL {
my $lol =   shift ;
my $row ;
	print "<pre>\n" ;
	foreach $row (@$lol) {
		print join(" ", @$row) ;
		print "\n" ;
	}
	print "</pre>\n" ;
}

#/////////////////////////////////////////////////////////////////////////////
# DIVERS
#/////////////////////////////////////////////////////////////////////////////

# lolRotate(\@lol )
# Rotation d'un tableau 2D. Les lignes deviennent des colonnes, ou inversement.
# Argument: la ref d'une LoL (List of Lists).
# Retourne toujours 1.
# Note: toutes les lignes (ou colonne) doivent avoir le meme nombre d'elements.
#
sub lolRotate {
my $out = $_[0] ;
my @lol = ( @{$_[0]} ) ;  # Copie reelle de l'argument.
my @row ;
my ($x, $y) ;

	@{$out} = () ;

	for ($x=0; $x<scalar(@{$lol[0]}); $x++) {
		@row = () ;

		for ($y=0; $y<scalar(@lol) ; $y++) {
			push @row, $lol[$y][$x] ;
		}

		push @{$out}, [ @row ] ;
	}

1;
}


#/////////////////////////////////////////////////////////////////////////////
# ACL
#/////////////////////////////////////////////////////////////////////////////



#/////////////////////////////////////////////////////////////////////////////
# HMTL
#/////////////////////////////////////////////////////////////////////////////

# colorStatus($status,$text)
# Change an HTML text color depending the $status value (0,1 or 2).
#
sub colorStatus
{
 my $status = shift ;
 my $msg = join(" ",@_) ;
 my $c ;
 
 if    ($status == 0) { $c = "#000000" ;}
 elsif ($status == 1) { $c = "#cc7000" ;}
 else  { $c = "#BB0000" ;}
 
 return "<font color=$c>$msg</font>" ;
}

# $table mkHtmlTable ($title, \@top, \@lol, [ \%attribs ])
#
# TODO: Travailler sur des copies de @top et @lol, plutot que leur ref.
#
sub mkHtmlTable {
my $title = $_[0] ;
my $top = $_[1] ;
my $lol = $_[2] ;
my %attr ;

 if (defined($_[3])) {
 	%attr = ( %{$_[3]} ) ; # Copie integrale.
 }

# Valeurs par defaut:		
my $att_rotate 		= 0 ;
my $att_tr_header 	= $tb ;
my $att_tr_body 	= $cb ;
my $att_border 		= 'border' ;
my $att_center		= 1;

$att_rotate     = $attr{'rotate'}    if (exists($attr{'rotate'})) ;
$att_tr_header  = $attr{'tr_header'} if (exists($attr{'tr_header'})) ;
$att_tr_body    = $attr{'tr_body'}   if (exists($attr{'tr_body'})) ;
$att_border     = $attr{'border'}    if (exists($attr{'border'})) ;
$att_center     = $attr{'center'}    if (exists($attr{'center'})) ;

my $out = "" ;
my $row ;
my $t ;

	foreach $row (@{$lol}) {
		map { $_ = "<td $att_tr_body>$_</td>" } @{$row} ;
	}

	map { $_ = "<td $att_tr_header><b>$_</b></td>" } @{$top} ;	
	unshift @{$lol}, $top ;


	$att_rotate && lolRotate($lol) ;


	# Construction de la table dans $out:
	#
	if ($att_center) { $out .= "<center>"; }
	$out .= "<dt><b>$title</b></dt><table $att_border>\n" ;
	foreach $row (@{$lol}) {
		$out .= "<tr>\n" ;
		$out .= join("", @{$row} ) ;
		$out .= "</tr>\n" ;
	}
	$out .= "</table>" ;
	if ($att_center) { $out .= "</center>"; }


return $out ;
}

sub showFreeDisk
{
	my @list;
	my @header;
	my @lol=();
	my $i;

	@header=($text{lab_disk}, "Total", $text{lab_used}, $text{lab_free}, "%", $text{lab_mount});
	@list=split ' ',`df -Ph /tftpboot/revoboot | tail -1`;
	push @lol,[@list];
	print mkHtmlTable($text{lab_space},\@header,\@lol);


}

sub lbsheader
{
    my $title = shift;
    my $image = shift;
    my $help = shift;
    my $config = shift;
    

#    header(title, image, [help], [config], [noindex], [noroot], [text], [header], [body], [below])
}

#
# Show tabs. Takes one integer as input
#
sub tabs
{
	my $hi1= shift; # which tab to highlight on the toplevel menu
	my $hi2= shift; # which tab to highlight on the submenu
	my $mac = shift;  # added by P.D.: MAC address
	my $bg, $t, $i = 1;
	my @tab = ( "&nbsp;",
		    "<a href=\"index.cgi\">$text{'lnk_index'}</a>",
		    "<a href=\"imgbase.cgi\">$text{'lnk_imgbase'}</a>",
		    "<a href=\"tc.cgi\">$text{'lnk_tc'}</a>",
		    "<a href=\"dhcp.cgi\">".$text{'lnk_dhcp'}."</a>",
		    "<a href=\"/at/\">$text{lab_woltasks}</a>",
   		    "<a href=\"../lbs-inventory/csv_files.csv\">$text{lnk_csv_files}</a>",
		    "&nbsp;"
		    );
		    #print "<p align='center'>\n" ;
		    #print "<table width=100%><tr>";
		    #foreach $t (@tab) {
		    #if ($i == $hi1+1) {
		    #$bg = "#9999ff";
		    #} else {
		    #$bg = "#cccccc";
		    #}
		    #print "<td bgcolor=\"$bg\"> &nbsp; $t &nbsp; </td>";
		    #$i++;
		    #}
	#print "</tr></table>";
	#print "</p>\n" ;

        #--------------------------------------------------
        # ADDED by P.D.
        #
        # code below is so stupid and ugly that it MUST be changed.
        # nevertheless it works quite well.
        #
          
          # declaration of some useful variables:
          $unselected = "bouton_unselect";
          $selected = "bouton_select";
          $empty_link  = "";
          
          # keys of these association tables MUST be the same 
          %links = (
              "LOF" => "<a href=\"/lbs/?mac=%mac%\">%LOF%</a>",
              "SB" => "<a href=\"/lbs/bootmenu.cgi?mac=%mac%\">%SB%</a>",
              "IL" => "<a href=\"/lbs-inventory/general.cgi?mac=%mac%\">%IL%</a>",
              "RC" => "<a href=\"/lbs-vnc/index.cgi?mac=%mac%\">%RC%</a>",
	      "BPC" => "<a href=\"/backuppc/index.cgi?mac=%mac%\">%BPC%</a>",
	      "BCF" => "<a href=\"/backuppc/gen_conf.cgi\">%BCF%</a>"
            );

          %empty_links = (
              "LOF" => "<a href=\"/lbs/\">%LOF%</a>",
              "SB" => "%SB%",
              "IL" => "%IL%",
              "RC" => "%RC%",
	      "BPC" => "%BPC%",
	      "BCF" => "%BCF%"
            );
            
            %link_tabs = (
              "LOF" => "%LOF_link%",
              "SB" => "%SB_link%",
              "IL" => "%IL_link%",
              "RC" => "%RC_link%",
	      "BPC" => "%BPC_link%",
	      "BCF" => "%BCF_link%"
            );

            # Top menu names 
            %en_top_names = (
              "LOF" => "Computers",
              "SB" => "System backup",
              "IL" => "Inventory",
              "RC" => "Remote control",
	      "BPC" => "Files backup",
	      "BCF" => "BackupPC setup"
            );
            
            %en_list_of_mach_names = (
              "LOC" => "Clients list",
              "IMB" => "Shared images",
              "BDP" => "Band-width",
              "DHCP" => "DHCP form",
              "WOL" => "WOL tasks",
	      "BPC" => "Files backup",
	      "BCF" => "BackupPC Configuration",
            );
            
            %en_system_backup = (
              "BM" => "Boot menu",
              "BO" => "Options",			      
              "IM" => "Images management",
              "RMAC" => "Rename MAC",
              "RN" => "Rename",
              "DEL" => "Remove"
	    );
            
            %fr_top_names = (
              "LOF" => "Liste des Machines",
              "SB" => "Système de Sauvegarde",
              "IL" => "Inventaire",
              "RC" => "Contrôle distant",
	      "BPC" => "Sauvegarde Fichiers",
	      "BCF" => "Conf. de BackupPC"
            );
            
            %fr_list_of_mach_names = (
              "LOC" => "Liste des clients",
              "IMB" => "Images partagées",
              "BDP" => "Bande passante",
              "DHCP" => "Formulaire DHCP",
              "WOL" => "Tâches WOL",
    	      "BPC" => "Sauvegarde fichier",
	      "BCF" => "Conf. de BackupPC"
            );

            %fr_system_backup = (
              "BM" => "Menu de boot",
              "IM" => "Gestion des images",
              "BO" => "Options",
              "RMAC" => "Changer @ MAC",
              "RN" => "Renommer",
              "DEL" => "Supprimer"
	    );

	  #
	  # style sheet string
	  #
	  $style_string=<<EOFSTYLESTRING;
	  <style type="text/css">
	  	<!-- 
		.cadre {
		border-style : solid; 
		border-top-width : 1px; 
		border-right-width : 1px; 
		border-bottom-width : 1px; 
		border-left-width : 1px;
		border-color: #35b4c3;
		padding: 5px;
		}

		.bouton_select
		{
		border-style: solid;

		border-top-width:0px;
		border-right-width:0px;
		border-left-width:0px;
		border-bottom-width:0px;

		border-top-color:#35b4c3;
		border-bottom-color:#35b4c3;
		border-left-color:#35b4c3;
		border-right-color:#35b4c;

		background-color : #35b4c3;
		}

		.bouton_unselect
		{
		border-style: solid;
		border-top-width:0px;
		border-right-width:0px;
		border-left-width:0px;
		border-bottom_width:0px;

		border-top-color:#e2e2e2;
		border-bottom-color:#e2e2e2;
		border-left-color:#e2e2e2;
		border-right-color:#e2e2e2;
		background-color : #e2e2e2;
		}

		-->
	</style>
EOFSTYLESTRING
        
	$top_level_menu_string=<<EOFTOPLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%button_LOF%"><font color="#0000ee"> 
			%LOF_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%button_SB%"><font color="##0000ee"> 
		 	%SB_link%
		 </font>
		 </th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="##0000ee"> 
			%IL_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="##0000ee"> 
			%RC_link%
		</font>
		</th>
                <th bgcolor="#ffffff">&nbsp;</th> 	 
		<th class="bouton_unselect"><font color="##0000ee"> 	 
		       %BPC_link% 	 
                <th bgcolor="#ffffff">&nbsp;</th> 	 
		<th class="bouton_unselect"><font color="##0000ee"> 	 
		       %BCF_link% 	 
		</font> 	 
		</th>		
	</tr>
	</table>

	<div class="cadre">
EOFTOPLEVELMENUSTRING

	$top_level_menu_string_list_of_machines=<<EOFTOPLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%button_LOF%" width="20%"><font color="#0000ee"> 
			%LOF_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
	</tr>
	</table>

	<div class="cadre">
EOFTOPLEVELMENUSTRING

	$listofmachines_menu_string=<<EOFLISTOFMACHINESMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%1%"><font color="#FF0000"> 
		 	<a href="/lbs/index.cgi">%LOC%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%2%"><font color="#FF0000"> 
			<a href="/lbs/imgbase.cgi">%IMB%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%3%"><font color="#FF0000"> 
		 	<a href="tc.cgi">%BDP%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%4%"><font color="#FF0000"> 
			<a href="dhcp.cgi">%DHCP%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%5%"><font color="#FF0000"> 
			<a href="/at/">%WOL%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%6%"><font color="#FF0000"> 	 
		        <a href="../backuppc/index.cgi?general=1">%BPC%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%7%"><font color="#FF0000"> 	 
		        <a href="../backuppc/gen_conf.cgi?">%BCF%</a></font></th>

	</tr>
	</table>

	<div class="cadre">
EOFLISTOFMACHINESMENUSTRING

	$sysbackup_menu_string=<<EOFSYSBACKUPMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%1%"><font color="#FF0000"> 
		 	<a href="bootmenu.cgi?mac=%mac%&">%BM%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%3%"><font color="#FF0000"> 
			<a href="move.cgi?mac=%mac%&Form=move">%IM%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%2%"><font color="#FF0000"> 
		 	<a href="bootoptions.cgi?mac=%mac%&">%BO%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%4%"><font color="#FF0000"> 
			<a href="renamemac.cgi?mac=%mac%&Form=renamemac">%RMAC%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%5%"><font color="#FF0000"> 
			<a href="rename.cgi?mac=%mac%&Form=rename">%RN%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%6%"><font color="#FF0000"> 
			<a href="delete.cgi?mac=%mac%&Form=delete">%DEL%</a></font></th>
	</tr>
	</table>
	<div class="cadre">
EOFSYSBACKUPMENUSTRING

        # check the language
 	if ($gconfig{'lang'} eq "") {
 	  $langVar = "en";
        }
        else {
	  $langVar = $gconfig{'lang'};
	}
	if ($gconfig{"lang_$remote_user"} ne "") {
 	  $langVar = $gconfig{"lang_$remote_user"};	
	}
	
        # parse our cute strings: 
	if ($hi1 == 1) {
	  $top_level_menu_string = $top_level_menu_string_list_of_machines;
          $top_level_menu_string =~ s/%button_LOF%/$selected/;
          $top_level_menu_string =~ s/%button_SB%/$unselected/;
          
          $sub_menu_string = $listofmachines_menu_string;

	  if ($langVar eq "fr") {
	    foreach $i (keys %fr_list_of_mach_names) {
	      $sub_menu_string =~ s/%$i%/$fr_list_of_mach_names{$i}/;
	    }
	  }
	  else {
	    foreach $i (keys %en_list_of_mach_names) {
	      $sub_menu_string =~ s/%$i%/$en_list_of_mach_names{$i}/;
	    }
	  }
 	           
            foreach $i (keys %links) {
	      if ($mac eq "") {  # put the EMPTY links:
		$top_level_menu_string =~ s/$link_tabs{$i}/$empty_links{$i}/;
	      }
	      else {
	        $top_level_menu_string =~ s/$link_tabs{$i}/$links{$i}/;
	      } 
	    }
	
        }
        elsif ($hi1 == 2) {
          $top_level_menu_string =~ s/%button_LOF%/$unselected/;
          $top_level_menu_string =~ s/%button_SB%/$selected/;
    
          $sub_menu_string = $sysbackup_menu_string;

	  if ($langVar eq "fr") {
	    foreach $i (keys %fr_system_backup) {
	      $sub_menu_string =~ s/%$i%/$fr_system_backup{$i}/;
	    }
	  }
	  else {
	    foreach $i (keys %en_system_backup) {
	      $sub_menu_string =~ s/%$i%/$en_system_backup{$i}/;
	    }
	  }
        
          # put the links:
          foreach $i (keys %links) {
            $top_level_menu_string =~ s/$link_tabs{$i}/$links{$i}/;
          }
        }

	# putting the top-menu in the appropriate language
	if ($langVar eq "fr") {
	  foreach $i (keys %fr_top_names) {
	    $top_level_menu_string =~ s/%$i%/$fr_top_names{$i}/;
	  }
	}
	else {
	  foreach $i (keys %en_top_names) {
	    $top_level_menu_string =~ s/%$i%/$en_top_names{$i}/;	    
	  }
	}

	# highlight the propper sub-menu
	for ($i = 1; $i <= 7; $i++) {
	  if ($i == $hi2) {
	    $sub_menu_string =~ s/%$i%/$selected/;
	  }
	  else {
	    $sub_menu_string =~ s/%$i%/$unselected/;
	  }
	}

	# put the MAC addres
	$top_level_menu_string =~ s/%mac%/$mac/g;
	$sub_menu_string =~ s/%mac%/$mac/g;
	
	# print the menu
	print $style_string;
	print $top_level_menu_string;
	print $sub_menu_string;

} #~~

#
# Print the end of the menu
#

sub menuEnd {

 print <<EOFFENDMENU;
  <!-- <div class="cadre"> -->
  </div>
  </div>
EOFFENDMENU
} 


# END OF MODULE //////
1;
#/////////////////////