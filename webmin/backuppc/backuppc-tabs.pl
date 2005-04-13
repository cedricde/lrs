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
#
# use vars qw(%text %lbsconf %access %in %gconfig $cb $tb);
sub non_lbs_tabs
{
  my $hi2= shift; # which tab to highlight on the submenu
  my $host = shift;  # 
  my $general = shift;
  my $lbs = shift;
  my $bg, $t, $i = 1;

  $unselected = "bouton_unselect";
  $selected = "bouton_select";
  $empty_link  = "";
         

   if ($general == 1) {
#-----------------------------------------------------------------------------------------------------
     %links = (
       "LOF" => "<a href=\"./index.cgi?action=summary\">%LOF%</a>",
       "BPC" => "<a href=\"./index.cgi?general=1\">%BPC%</a>",
       "GCF" => "<a href=\"./gen_conf.cgi\">%GCF%</a>",
      );

      %link_tabs = (
        "LOF" => "%LOF_link%",
        "BPC" => "%BPC_link%",
        "GCF" => "%GCF_link%",
      );

      %en_top_names = (
        "LOF" => "Computers",
        "BPC" => "Files backup",
        "GCF" => "Backup configuration",
      );
      %en_bottom_names = (
      );
            
      %fr_top_names = (
        "LOF" => "Liste de Machines",
        "BPC" => "Sauvegarde de Fichiers",
        "GCF" => "Configuration de la Sauvegarde",
      );
      %fr_bottom_names = (
      );
#-----------------------------------------------------------------------------------------------------
      } else {
       # keys of these association tables MUST be the same 
        %links = (
          "LOF" => "<a href=\"./index.cgi?action=summary\">%LOF%</a>",
          "MCR" => "<a href=\"./index.cgi?host=%host%\">%MCR%</a>",
        );

        %link_tabs = (
          "LOF" => "%LOF_link%",
          "MCR" => "%MCR_link%",
        );

        # Top menu names 
        %en_top_names = (
          "LOF" => "Computers",
          "MCR" => "Current computer",
        );
            
        %en_bottom_names = (
           "HST" => "Computer",
           "CNF" => "Configuration",
           "LOG" => "LOG file",
           "OLD" => "Old LOGs",
           "LAST" => "Last bad XferLOG",
           "ERR" => "Last errors"
       );
            
       %fr_top_names = (
          "LOF" => "Liste de Machines",
          "MCR" => "Machine Courante",
       );
            
       %fr_bottom_names = (
          "HST" => "Machine",
          "CNF" => "Configuration",
          "LOG" => "Fichier journal",
          "OLD" => "Journaux précédents",
          "LAST" => "Dernier Mauvais XferLOG",
          "ERR" => "Journal des erreurs"
       );
   }
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
      if ($general == 1) {
        $top_level_menu_string=<<EOFTOPLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%1%"><font color="#0000ee"> 
			%LOF_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%2%"><font color="#0000ee"> 
			%BPC_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%3%"><font color="#0000ee"> 
			%GCF_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
	</tr>
	</table>
	<div class="cadre">
EOFTOPLEVELMENUSTRING

	$bottom_level_menu_string=<<EOFBOTTOMLEVELMENUSTRING;
EOFBOTTOMLEVELMENUSTRING
      } else {
	$top_level_menu_string=<<EOFTOPLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#0000ee"> 
			%LOF_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_select"><font color="#0000ee"> 
			%MCR_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th bgcolor="#ffffff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
	</tr>
	</table>
	<div class="cadre">
EOFTOPLEVELMENUSTRING

	$bottom_level_menu_string=<<EOFBOTTOMLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%1%"><font color="#FF0000"> 
		 	<a href="index.cgi?host=%host%">%HST%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%2%"><font color="#FF0000"> 
			<a href="host_config.cgi?host=%host%">%CNF%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%3%"><font color="#FF0000"> 
		 	<a href="index.cgi?action=view&type=LOG&host=%host%">%LOG%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%4%"><font color="#FF0000"> 
			<a href="index.cgi?action=view&type=LOGlist&host=%host%">%OLD%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%5%"><font color="#FF0000"> 
		 	<a href="index.cgi?action=view&type=XferLOGbad&host=%host%">%LAST%</a></font></th>
	        <th bgcolor="#ffffff">&nbsp;</th>
		<th class="%6%"><font color="#FF0000"> 
			<a href="index.cgi?action=view&type=XferErrbad&host=%host%">%ERR%</a></font></th>

	</tr>
	</table>

	<div class="cadre">
EOFBOTTOMLEVELMENUSTRING

      }

        # check the language
 	if ($gconfig{'lang'} eq "") {
 	  $langVar = "en";
        }
        else {
	  $langVar = $gconfig{'lang'};
	}
	
        # parse our cute strings: 
	
          foreach $i (keys %links) {
	    $top_level_menu_string =~ s/$link_tabs{$i}/$links{$i}/;
	  }
	         
	if ($langVar eq "fr") {
	  foreach $i (keys %fr_bottom_names) {
	    $bottom_level_menu_string =~ s/%$i%/$fr_bottom_names{$i}/;
	  }
	}
	else {
	  foreach $i (keys %en_bottom_names) {
	    $bottom_level_menu_string =~ s/%$i%/$en_bottom_names{$i}/;
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
	if ($general == 1) {
	  for ($i = 1; $i <= 3; $i++) {
	    if ($i == $hi2) {
	      $top_level_menu_string =~ s/%$i%/$selected/;
	    }
	    else {
	      $top_level_menu_string =~ s/%$i%/$unselected/;
	    }
	  }

	} else {
  	  for ($i = 1; $i <= 6; $i++) {
	    if ($i == $hi2) {
	      $bottom_level_menu_string =~ s/%$i%/$selected/;
	    }
	    else {
	      $bottom_level_menu_string =~ s/%$i%/$unselected/;
	    }
	  }

	  # put the MAC addres
  	  $top_level_menu_string =~ s/%host%/$host/g;
	  $bottom_level_menu_string =~ s/%host%/$host/g;
	}

        # print the menu
	print $style_string;
	print $top_level_menu_string;
	print $bottom_level_menu_string;

}
#
# Show tabs. Takes one integer as input
#
sub backuppc_tabs
{
	my $hi2= shift; # which tab to highlight on the submenu
	my $mac = shift;  # added by P.D.: MAC address
	my $general = shift;
	my $lbs = shift;
	my $bg, $t, $i = 1;

        if ($lbs != 1) {
	  &non_lbs_tabs($hi2, $mac, $general, $lbs);
	  return;
        }
          
          # declaration of some useful variables:
          $unselected = "bouton_unselect";
          $selected = "bouton_select";
          $empty_link  = "";
         

	 if ($general == 1) {
#-----------------------------------------------------------------------------------------------------
            %links = (
              "LOF" => "<a href=\"/lbs/index.cgi?mac=%mac%\">%LOF%</a>",
            );

             %link_tabs = (
              "LOF" => "%LOF_link%",
            );

            %en_top_names = (
              "LOF" => "Computers",
            );
            %en_bottom_names = (
              "LOC" => "Clients list",
              "IMB" => "Shared images",
              "BDP" => "Band-width",
              "DHCP" => "DHCP Form",
              "WOL" => "WOL tasks",
#	      "CSV" => "CSV",
	      "BPC" => "Files backup",
	      "BCF" => "BackupPC Configuration"
            );
            
	    %fr_top_names = (
              "LOF" => "Liste des Machines",
            );
            %fr_bottom_names = (
              "LOC" => "Liste des clients",
              "IMB" => "Images partagées",
              "BDP" => "Bande passante",
              "DHCP" => "Formulaire DHCP",
              "WOL" => "Tâches WOL",
#       	      "CSV" => "CSV",
       	      "BPC" => "Sauvegarde fichier",
	      "BCF" => "Conf. de BackupPC"
            );
#-----------------------------------------------------------------------------------------------------
        } else {
          # keys of these association tables MUST be the same 
            %links = (
              "LOF" => "<a href=\"/lbs/index.cgi?mac=%mac%\">%LOF%</a>",
              "SB" => "<a href=\"/lbs/bootmenu.cgi?mac=%mac%\">%SB%</a>",
              "IL" => "<a href=\"/lbs-inventory/general.cgi?mac=%mac%\">%IL%</a>",
              "RC" => "<a href=\"/lbs-vnc/index.cgi?mac=%mac%\">%RC%</a>",
              "BPC" => "<a href=\"/backuppc/index.cgi\">%BPC%</a>"
            );

            %link_tabs = (
              "LOF" => "%LOF_link%",
              "SB" => "%SB_link%",
              "IL" => "%IL_link%",
              "RC" => "%RC_link%",
	      "BPC" => "%BPC_link%"
            );

            # Top menu names 
            %en_top_names = (
              "LOF" => "Computers",
              "SB" => "System Backup",
              "IL" => "Inventory",
              "RC" => "Remote Control",
	      "BPC" => "Files Backup"
            );
            
            %en_bottom_names = (
              "HST" => "Computer",
              "CNF" => "Configuration",
              "LOG" => "LOG File",
              "OLD" => "Old LOGs",
              "LAST" => "Last Bad XferLOG",
              "ERR" => "Last Errors"
            );
            
            %fr_top_names = (
              "LOF" => "Liste des Machines",
              "SB" => "Système de Sauvegarde",
              "IL" => "Inventaire",
              "RC" => "Contrôle distant",
              "BPC" => "Sauvegarde de Fichiers"
            );
            
            %fr_bottom_names = (
              "HST" => "Machine",
              "CNF" => "Configuration",
              "LOG" => "Fichier journal",
              "OLD" => "Journaux précédents",
              "LAST" => "Dernier Mauvais XferLOG",
              "ERR" => "LOG d'Erreurs"
            );
	  }
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
      if ($general == 1) {
        $top_level_menu_string=<<EOFTOPLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_select"><font color="#0000ee"> 
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

	$bottom_level_menu_string=<<EOFBOTTOMLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#FF0000"> 
		 	<a href="/lbs/index.cgi">%LOC%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#FF0000"> 
			<a href="/lbs/imgbase.cgi">%IMB%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#FF0000"> 
		 	<a href="/lbs/tc.cgi">%BDP%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#FF0000"> 
			<a href="/lbs/dhcp.cgi">%DHCP%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#FF0000"> 
			<a href="/at/">%WOL%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
<!--		<th class="bouton_unselect"><font color="#FF0000"> 
			<a href="../lbs-inventory/csv_files.cgi">%CSV%</a></font></th>-->
 	        <th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_select"><font color="#FF0000"> 
			<a href="../backuppc/index.cgi">%BPC%</a></font></th>
 	        <th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#FF0000"> 
			<a href="gen_conf.cgi">%BCF%</a></font></th>
	</tr>
	</table>

	<div class="cadre">
EOFBOTTOMLEVELMENUSTRING
      } else {
	$top_level_menu_string=<<EOFTOPLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="#0000ee"> 
			%LOF_link%
		</font>
		</th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="bouton_unselect"><font color="##0000ee"> 
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
		<th class="bouton_select"><font color="##0000ee"> 
		        %BPC_link%
		</font>
		</th>
        </tr>
	</table>

	<div class="cadre">
EOFTOPLEVELMENUSTRING

	$bottom_level_menu_string=<<EOFBOTTOMLEVELMENUSTRING;
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%1%"><font color="#FF0000"> 
		 	<a href="index.cgi?mac=%mac%">%HST%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%2%"><font color="#FF0000"> 
			<a href="host_config.cgi?mac=%mac%">%CNF%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%3%"><font color="#FF0000"> 
		 	<a href="index.cgi?action=view&type=LOG&mac=%mac%">%LOG%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%4%"><font color="#FF0000"> 
			<a href="index.cgi?action=view&type=LOGlist&mac=%mac%">%OLD%</a></font></th>
		<th bgcolor="#ffffff">&nbsp;</th>
		<th class="%5%"><font color="#FF0000"> 
		 	<a href="index.cgi?action=view&type=XferLOGbad&mac=%mac%">%LAST%</a></font></th>
	        <th bgcolor="#ffffff">&nbsp;</th>
		<th class="%6%"><font color="#FF0000"> 
			<a href="index.cgi?action=view&type=XferErrbad&mac=%mac%">%ERR%</a></font></th>

	</tr>
	</table>

	<div class="cadre">
EOFBOTTOMLEVELMENUSTRING

      }

        # check the language
 	if ($gconfig{'lang'} eq "") {
 	  $langVar = "en";
        }
        else {
	  $langVar = $gconfig{'lang'};
	}
	
        # parse our cute strings: 
	
          foreach $i (keys %links) {
	    $top_level_menu_string =~ s/$link_tabs{$i}/$links{$i}/;
	  }
	         
	if ($langVar eq "fr") {
	  foreach $i (keys %fr_bottom_names) {
	    $bottom_level_menu_string =~ s/%$i%/$fr_bottom_names{$i}/;
	  }
	}
	else {
	  foreach $i (keys %en_bottom_names) {
	    $bottom_level_menu_string =~ s/%$i%/$en_bottom_names{$i}/;
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
	if ($general != 1) {
  	  for ($i = 1; $i <= 6; $i++) {
	    if ($i == $hi2) {
	      $bottom_level_menu_string =~ s/%$i%/$selected/;
	    }
	    else {
	      $bottom_level_menu_string =~ s/%$i%/$unselected/;
	    }
	  }

	  # put the MAC addres
  	  $top_level_menu_string =~ s/%mac%/$mac/g;
	  $bottom_level_menu_string =~ s/%mac%/$mac/g;
	  # and the host name
	  $bottom_level_menu_string =~ s/%host%/$host/g;
	}

        # print the menu
	print $style_string;
	print $top_level_menu_string;
	print $bottom_level_menu_string;

} #~~

#
# Print the end of the menu
#

sub menuEnd {
  my $general = shift;
  my $lbs = shift;

  if ($lbs == 1 || $general != 1) {
    print <<EOFFENDMENU;
    </div>
    </div>
EOFFENDMENU
  } else {
    print <<EOFFENDMENU;
    </div>
EOFFENDMENU
  }
} 

1;
