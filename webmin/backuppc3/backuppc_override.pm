#
# Custom BackupPC functions
#
# Linbox Rescue Server
# Copyright (C) 2007 Ludovic Drolez, Linbox FAS
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


sub myinit {

  require "../web-lib.pl";
  require "lbs-backuppc.pl";
  use vars qw(%text %lbsconf %access %in %gconfig $cb $tb $current_lang %module_info);

  my %einfo;
  my $etherfile = $lbs_common::lbsconf{'basedir'}."/etc/ether";
  &main::etherLoad( $etherfile, \%einfo ) or error( lbsGetError() );

  # reinject already processed post data by Webmin
  foreach my $key (keys %in) {
    if ($In{$key} eq "") {
      $In{$key} = $in{$key};
    }
  }

  # find host from macaddr
  if ( (!defined($In{mac}) || $In{mac} eq "" )
       && (!defined($In{host}) || $In{host} eq "") ) {
    $In{general} = 1;
  } elsif (defined($In{mac}) && $In{mac} ne "" ) {
    $In{host} = lc(&main::etherGetNameByMac(\%einfo, $In{mac}));
    # remove the group name
    $In{host} =~ s/^.*\///;
  } elsif (defined($In{host}) && $In{host} ne "" ) {
    $In{mac} = &main::etherGetMacByName(\%einfo, $In{host});
  }

  # override some configuration defaults
  $Conf{BackupPCUser} = 'root';
  $Conf{BackupPCUserVerify} = 0;
  $Conf{CgiAdminUserGroup} = 'root';
  $Conf{CgiAdminUsers}     = 'root';
  $Conf{CgiNavBarBgColor} = '#f5f5f5';
  $Conf{CgiHeaderBgColor} = '#e2e2e2';
  $Conf{CgiDir}       = $ENV{SERVER_ROOT}.'/backuppc';
  $Conf{CgiImageDirURL}="images/";
  $User	= "root";

  # language selection
  #$current_lang = "fr";
  my $langFile = $bpc->{InstallDir}."/lib/BackupPC/Lang/$current_lang.pm";
  if ( ! -f $langFile ) {
    $langFile = $bpc->{InstallDir}."/BackupPC/Lang/en.pm";
  }
  do $langFile or die("cannot read file $langFile");
  $bpc->{Lang} = \%Lang;
  $Lang = $bpc->Lang();

  # check for new hosts
  if ((! -f "/etc/backuppc/".lc($In{host}).".pl") && ($In{host} ne "")) {
    print redirect("host_config.cgi?mac=$In{mac}");
  }

}

sub myend
  {
    if ($In{action} eq "editConfig") {
      my $uid = getpwnam("backuppc");
      my $gid = getgrnam("backuppc");
      chown $uid, $gid, "/etc/backuppc/hosts", "/etc/backuppc/config.pl";
      chmod 0640, "/etc/backuppc/hosts", "/etc/backuppc/config.pl", "/etc/backuppc";
      chmod 02755, "/etc/backuppc";
      if (-f "/etc/backuppc/".lc($In{host}).".pl") {
	chown $uid, $gid, "/etc/backuppc/".lc($In{host}).".pl";
      }
    }
  }


#
# 
#
package BackupPC::CGI::Lib;

sub CheckPermission
  {
    $PrivAdmin = 1;
    return 1;
  }

sub Header
  {
    my($title, $content, $noBrowse, $contentSub, $contentPost) = @_;

    my @adminLinks = (
        { link => "",                      name => $Lang->{Status}},
        { link => "?action=summary",       name => $Lang->{PC_Summary}},
        { link => "?action=editConfig",    name => $Lang->{CfgEdit_Edit_Config},
                                           priv => 1},
        { link => "?action=editConfig&newMenu=hosts",
                                           name => $Lang->{CfgEdit_Edit_Hosts},
                                           priv => 1},
        { link => "?action=adminOpts",     name => $Lang->{Admin_Options},
                                           priv => 1},
        { link => "?action=view&type=LOG", name => $Lang->{LOG_file},
                                           priv => 1},
        { link => "?action=LOGlist",       name => $Lang->{Old_LOGs},
                                           priv => 1},
        { link => "?action=emailSummary",  name => $Lang->{Email_summary},
                                           priv => 1},
        { link => "?action=queue",         name => $Lang->{Current_queues},
                                           priv => 1},
        @{$Conf{CgiNavBarLinks} || []},
    );
    my $host = $In{host};

    my $no_tab = 1;
    my $label_tab = ['backuppc3', 'backuppc_machine'];

    if ($In{general} == 1) {
      if (!($In{action} eq "summary")) {
	$no_tab = 2;
	$label_tab = ['list_of_machines', 'status', 'files_backup3'];
      }
    } else {
      if ( $In{type} eq "LOG" ) {
	$no_tab = 3;
	$label_tab = ['backuppc3', 'log_file'];
      } elsif ( $In{type} eq "LOGlist" ) {
	$no_tab = 4;
	$label_tab = ['backuppc3', 'old_logs'];
      } elsif ( $In{action} eq "LOGlist" ) {
	$no_tab = 5;
	$label_tab = ['backuppc3', 'badxfer_log'];
      } elsif ( $In{action} eq "editConfig" ) {
	$no_tab = 6;
	$label_tab = ['backuppc3', 'adv_configuration'];
      }
    }

    if (length($title)>32) { # max 32 characters in header
      $title=substr($title, 0, 32)."...";
    }

    lbs_common::print_header("$title", "index", $main::module_info{version});
    lbs_common::print_html_tabs($label_tab, {'mac' => $In{mac}});

    #binmode(STDOUT, ":utf8");
    #print $Cgi->header(-charset => "utf-8");
    print <<EOF;
<link rel='StyleSheet' href='/backuppc3/tmpl/presentation.css' type='text/css' media='screen' />
EOF

    my $mstyle = "";
    if ($In{general} != 1) {
      $mstyle = "style=\"width:100%;\"";
    }
    print("<div id=\"Content\" $mstyle>\n");
    print("<table><tr>");

    if ($In{general} == 1) {
      print '<td style="vertical-align: top; border: 0px;"><div class="NavMenu" id="NavMenu">';
      NavSectionTitle($Lang->{NavSectionTitle_});
      foreach my $l ( @adminLinks ) {
        if ( $PrivAdmin || !$l->{priv} ) {
	  my $txt = $l->{lname} ne "" ? $Lang->{$l->{lname}} : $l->{name};
	  NavLink($l->{link}, $txt);
        }
      }
      print "<br/></div></td>";
    } 

    print("<td style=\"vertical-align: top; border: 0px;\">$content\n");
    if ( defined($contentSub) && ref($contentSub) eq "CODE" ) {
	while ( (my $s = &$contentSub()) ne "" ) {
	    print($s);
	}
    }
    print($contentPost) if ( defined($contentPost) );

    print "</td></tr></table></div>";
}

sub Trailer
{
#  print "</div>";
  lbs_common::print_end_menu();
  lbs_common::print_end_menu();
  main::footer( "", $text{'index'} );
}

package;

1;
