#!/usr/bin/perl
#============================================================= -*-perl-*-w
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001  Craig Barratt
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#========================================================================
#
# Version 2.0.2, released 6 Oct 2003.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

# LRS VERSION TODO
# We must use the original cgi code and have tests wether we are or not
# in the webmin case. DO NOT BREAK THE CODE, IT WILL ALLOW TO CONTRIBUTE
# IT TO THE BACKUPPC communauty.
# Using the tabs for getting one choice or the other.
# I propose the following strategy. In this case, the list of machine
# within the left panel is no more interesting. In fact all elements
# for a machine : Home, LOG file, Old LOGs, Last bad XferLOG,
# Last bad XferLOG (errors only), Config file can be shown in tabs.
# In fact all are not interesting Home, Log file, are important,
# the rest may be reached from an other window with links to the
# remaining.
# Concerning the language, we can get the language from Webmin and use it
# instead of using the language of conf file of Backuppc.
# The tabs function from Piotr must be used (in lbs/lbs-common.pl). But
# the name of the machine must be used instead of the mac address. There
# are functions to get the name from the mac and the reverse. To be used.
#  => etherLoad et etherGetNameByMac in lbs-lib.pl
use strict;
no  utf8;
use CGI;
use lib "/usr/share/backuppc/lib";
use BackupPC::Lib;
use BackupPC::FileZIO;
use BackupPC::Attrib qw(:all);
use BackupPC::View;
use Data::Dumper;

use vars qw($Cgi %In $MyURL $User %Conf $TopDir $BinDir $bpc);
use vars qw(%Status %Info %Jobs @BgQueue @UserQueue @CmdQueue
            %QueueLen %StatusHost);
use vars qw($Hosts $HostsMTime $ConfigMTime $PrivAdmin);
use vars qw(%UserEmailInfo $UserEmailInfoMTime %RestoreReq);

use vars qw($Lang);

$Cgi = new CGI;
%In = $Cgi->Vars;

# Check our environment
use vars qw($InLBS $InWebmin %module_info);
if ( -f "/etc/lbs.conf" ) {
    $InLBS = 1;
}
if ( $ENV{"MINISERV_CONFIG"} ne "" ) {
    $InWebmin = 1;
}

if ( !defined($bpc) ) {
    ErrorExit($Lang->{BackupPC__Lib__new_failed__check_apache_error_log})
	if ( !($bpc = BackupPC::Lib->new(undef, undef, 1)) );
    $TopDir = $bpc->TopDir();
    $BinDir = $bpc->BinDir();
    %Conf   = $bpc->Conf();

    # Webmin Architecture - force the language
    if ($InWebmin == 1) {
	require "../web-lib.pl";
	use vars qw(%gconfig $current_lang %Lang);
	init_config();
	my $langFile = $bpc->{LibDir}."/BackupPC/Lang/$current_lang.pm";
	if ( ! -f $langFile ) {
	    $langFile = $bpc->{LibDir}."/BackupPC/Lang/en.pm";
	}
	do $langFile or die("cannot read file $langFile");
	$bpc->{Lang} = \%Lang;
    }

    $Lang   = $bpc->Lang();
    $ConfigMTime = $bpc->ConfigMTime();
} elsif ( $bpc->ConfigMTime() != $ConfigMTime ) {
    $bpc->ConfigRead();
    %Conf   = $bpc->Conf();
    $ConfigMTime = $bpc->ConfigMTime();
    $Lang   = $bpc->Lang();
}


#
# We require that Apache pass in $ENV{SCRIPT_NAME} and $ENV{REMOTE_USER}.
# The latter requires .ht_access style authentication.  Replace this
# code if you are using some other type of authentication, and have
# a different way of getting the user name.
#
$ENV{REMOTE_USER} = $Conf{BackupPCUser} if ( $ENV{REMOTE_USER} eq "" );
$MyURL  = $ENV{SCRIPT_NAME};
$User   = $ENV{REMOTE_USER};

# Force some global conf options
if ( $InWebmin == 1 ) {
    $Conf{BackupPCUser} = 'root';
    $Conf{BackupPCUserVerify} = 0;
    $Conf{CgiAdminUserGroup} = 'root';
    $Conf{CgiAdminUsers}     = 'root';
    $Conf{CgiNavBarBgColor} = '#f5f5f5';
    $Conf{CgiHeaderBgColor} = '#e2e2e2';
    $Conf{CgiDir}       = $ENV{SERVER_ROOT}.'/backuppc';
    $User	= "root";
}

#
# Clean up %ENV for taint checking
#
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
$ENV{PATH} = $Conf{MyPath};

#
# Verify we are running as the correct user
#
if ( $Conf{BackupPCUserVerify}
        && $> != (my $uid = (getpwnam($Conf{BackupPCUser}))[2]) ) {
    ErrorExit(eval("qq{$Lang->{Wrong_user__my_userid_is___}}"), <<EOF);
This script needs to run as the user specified in \$Conf{BackupPCUser},
which is set to $Conf{BackupPCUser}.
<p>
This is an installation problem.  If you are using mod_perl then
it appears that Apache is not running as user $Conf{BackupPCUser}.
If you are not using mod_perl, then most like setuid is not working
properly on BackupPC_Admin.  Check the permissions on
$Conf{CgiDir}/BackupPC_Admin and look at the documentation.
EOF
}

if ( !defined($Hosts) || $bpc->HostsMTime() != $HostsMTime ) {
    $HostsMTime = $bpc->HostsMTime();
    $Hosts = $bpc->HostInfoRead();

    # turn moreUsers list into a hash for quick lookups
    foreach my $host (keys %$Hosts) {
       $Hosts->{$host}{moreUsers} =
           {map {$_, 1} split(",", $Hosts->{$host}{moreUsers}) }
    }
}

my %ActionDispatch = (
    "summary"             	 => \&Action_Summary,
    $Lang->{Start_Incr_Backup}   => \&Action_StartStopBackup,
    $Lang->{Start_Full_Backup}   => \&Action_StartStopBackup,
    $Lang->{Stop_Dequeue_Backup} => \&Action_StartStopBackup,
    "queue"               	 => \&Action_Queue,
    "view"                	 => \&Action_View,
    "LOGlist"             	 => \&Action_LOGlist,
    "emailSummary"        	 => \&Action_EmailSummary,
    "browse"              	 => \&Action_Browse,
    $Lang->{Restore}        	 => \&Action_Restore,
    "RestoreFile"         	 => \&Action_RestoreFile,
    "hostInfo"		       	 => \&Action_HostInfo,
    "generalInfo"         	 => \&Action_GeneralInfo,
    "restoreInfo"         	 => \&Action_RestoreInfo,
);

my $lbs ;
if ($InLBS == 1) {
    $lbs = 1;
} else {
    $lbs = 0;
}

# Adaptation for LRS architecture
if ($InWebmin == 1) {
        if ($lbs == 1) {
	# get some common functions ...
	require "lbs-backuppc.pl";
	
#-------------------------------------------------------
	my %einfo;
	my $etherfile = "/tftpboot/revoboot/etc/ether";

    etherLoad( $etherfile, \%einfo ) or error( lbsGetError() );
#-------------------------------------------------------

    use vars qw(%text %lbsconf %access %in %gconfig $cb $tb);
  
    if ( (!defined($In{mac}) || $In{mac} eq "" ) 
       && (!defined($In{host}) || $In{host} eq "") ) {
       $In{general} = 1;  
    } elsif (defined($In{mac}) && $In{mac} ne "" ) {
      $In{host} = lc(etherGetNameByMac(\%einfo, $In{mac}));
      # remove the group name
      $In{host} =~ s/^.*\///;
    } elsif (defined($In{host}) && $In{host} ne "" ) {
      $In{mac} = etherGetMacByName(\%einfo, $In{host});
    }
  } elsif (!defined($In{host}) || $In{host} eq "") {
    $In{general} = 1;  
  }
  $Conf{CgiImageDirURL}="images/";
}

# ------------------ LRS end ---------------------------

#
# Set default actions, then call sub handler
#

$In{action} ||= "hostInfo"    if ( defined($In{host}) );
$In{action}   = "generalInfo" if ( !defined($ActionDispatch{$In{action}}) );
$ActionDispatch{$In{action}}();
exit(0);

###########################################################################
# Action handling subroutines
###########################################################################

sub Action_Summary
{
    my($fullTot, $fullSizeTot, $incrTot, $incrSizeTot, $str,
       $strNone, $strGood, $hostCntGood, $hostCntNone);

    $hostCntGood = $hostCntNone = 0;
    GetStatusInfo("hosts");
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_PC_summaries} );
    }
    foreach my $host ( sort(keys(%Status)) ) {
        my($fullDur, $incrCnt, $incrAge, $fullSize, $fullRate, $reasonHilite);
	my($shortErr);
        my @Backups = $bpc->BackupInfoRead($host);
        my $fullCnt = $incrCnt = 0;
        my $fullAge = $incrAge = -1;
        for ( my $i = 0 ; $i < @Backups ; $i++ ) {
            if ( $Backups[$i]{type} eq "full" ) {
                $fullCnt++;
                if ( $fullAge < 0 || $Backups[$i]{startTime} > $fullAge ) {
                    $fullAge  = $Backups[$i]{startTime};
                    $fullSize = $Backups[$i]{size} / (1024 * 1024);
                    $fullDur  = $Backups[$i]{endTime} - $Backups[$i]{startTime};
                }
                $fullSizeTot += $Backups[$i]{size} / (1024 * 1024);
            } else {
                $incrCnt++;
                if ( $incrAge < 0 || $Backups[$i]{startTime} > $incrAge ) {
                    $incrAge = $Backups[$i]{startTime};
                }
                $incrSizeTot += $Backups[$i]{size} / (1024 * 1024);
            }
        }
        if ( $fullAge < 0 ) {
            $fullAge = "";
            $fullRate = "";
        } else {
            $fullAge = sprintf("%.1f", (time - $fullAge) / (24 * 3600));
            $fullRate = sprintf("%.2f",
                                $fullSize / ($fullDur <= 0 ? 1 : $fullDur));
        }
        if ( $incrAge < 0 ) {
            $incrAge = "";
        } else {
            $incrAge = sprintf("%.1f", (time - $incrAge) / (24 * 3600));
        }
        $fullTot += $fullCnt;
        $incrTot += $incrCnt;
        $fullSize = sprintf("%.2f", $fullSize / 1000);
	$incrAge = "&nbsp;" if ( $incrAge eq "" );
	$reasonHilite = $Conf{CgiStatusHilightColor}{$Status{$host}{reason}}
		      || $Conf{CgiStatusHilightColor}{$Status{$host}{state}};
	$reasonHilite = " bgcolor=\"$reasonHilite\"" if ( $reasonHilite ne "" );
        if ( $Status{$host}{state} ne "Status_backup_in_progress"
		&& $Status{$host}{state} ne "Status_restore_in_progress"
		&& $Status{$host}{error} ne "" ) {
	    ($shortErr = $Status{$host}{error}) =~ s/(.{48}).*/$1.../;
	    $shortErr = " ($shortErr)";
	}

        $str = <<EOF;
<tr$reasonHilite><td> ${HostLink($host)} </td>
    <td align="center"> ${UserLink(defined($Hosts->{$host})
				    ? $Hosts->{$host}{user} : "")} </td>
    <td align="center"> $fullCnt </td>
    <td align="center"> $fullAge </td>
    <td align="center"> $fullSize </td>
    <td align="center"> $fullRate </td>
    <td align="center"> $incrCnt </td>
    <td align="center"> $incrAge </td>
    <td align="center"> $Lang->{$Status{$host}{state}} </td>
    <td> $Lang->{$Status{$host}{reason}}$shortErr </td></tr>
EOF
        if ( @Backups == 0 ) {
            $hostCntNone++;
            $strNone .= $str;
        } else {
            $hostCntGood++;
            $strGood .= $str;
        }
    }
    $fullSizeTot = sprintf("%.2f", $fullSizeTot / 1000);
    $incrSizeTot = sprintf("%.2f", $incrSizeTot / 1000);
    my $now      = timeStamp2(time);

    Header($Lang->{BackupPC__Server_Summary});
    print eval ("qq{$Lang->{BackupPC_Summary}}");

    Trailer();
}

sub Action_StartStopBackup
{
    my($str, $reply);

    my $start = 1 if ( $In{action} eq $Lang->{Start_Incr_Backup}
                       || $In{action} eq $Lang->{Start_Full_Backup} );
    my $doFull = $In{action} eq $Lang->{Start_Full_Backup} ? 1 : 0;
    my $type = $doFull ? "full" : "incremental";
    my $host = $In{host};
    my $Privileged = CheckPermission($host);

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_stop_or_start_backups}}"));
    }
    ServerConnect();

    if ( $In{doit} ) {
        if ( $start ) {
	    if ( $Hosts->{$host}{dhcp} ) {
		$reply = $bpc->ServerMesg("backup $In{hostIP} ${EscURI($host)}"
				    . " $User $doFull");
		$str = eval("qq{$Lang->{Backup_requested_on_DHCP__host}}");
	    } else {
		$reply = $bpc->ServerMesg("backup ${EscURI($host)}"
				    . " ${EscURI($host)} $User $doFull");
		$str = eval("qq{$Lang->{Backup_requested_on__host_by__User}}");
	    }
        } else {
            $reply = $bpc->ServerMesg("stop ${EscURI($host)} $User $In{backoff}");
            $str = eval("qq{$Lang->{Backup_stopped_dequeued_on__host_by__User}}");
        }

        Header(eval ("qq{$Lang->{BackupPC__Backup_Requested_on__host}}") );
        print (eval ("qq{$Lang->{REPLY_FROM_SERVER}}"));

        Trailer();
    } else {
        if ( $start ) {
	    my $ipAddr = ConfirmIPAddress($host);

            Header(eval("qq{$Lang->{BackupPC__Start_Backup_Confirm_on__host}}"));
            print (eval("qq{$Lang->{Are_you_sure_start}}"));
        } else {
            my $backoff = "";
            GetStatusInfo("host(${EscURI($host)})");
            if ( $StatusHost{backoffTime} > time ) {
                $backoff = sprintf("%.1f",
                                  ($StatusHost{backoffTime} - time) / 3600);
            }
            Header($Lang->{BackupPC__Stop_Backup_Confirm_on__host});
            print (eval ("qq{$Lang->{Are_you_sure_stop}}"));
        }
        Trailer();
    }
}

sub Action_Queue
{
    my($strBg, $strUser, $strCmd);

    GetStatusInfo("queues");
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
	ErrorExit($Lang->{Only_privileged_users_can_view_queues_});
    }

    while ( @BgQueue ) {
        my $req = pop(@BgQueue);
        my($reqTime) = timeStamp2($req->{reqTime});
        $strBg .= <<EOF;
<tr><td> ${HostLink($req->{host})} </td>
    <td align="center"> $reqTime </td>
    <td align="center"> $req->{user} </td></tr>
EOF
    }
    while ( @UserQueue ) {
        my $req = pop(@UserQueue);
        my $reqTime = timeStamp2($req->{reqTime});
        $strUser .= <<EOF;
<tr><td> ${HostLink($req->{host})} </td>
    <td align="center"> $reqTime </td>
    <td align="center"> $req->{user} </td></tr>
EOF
    }
    while ( @CmdQueue ) {
        my $req = pop(@CmdQueue);
        my $reqTime = timeStamp2($req->{reqTime});
        (my $cmd = $req->{cmd}[0]) =~ s/$BinDir\///;
        $strCmd .= <<EOF;
<tr><td> ${HostLink($req->{host})} </td>
    <td align="center"> $reqTime </td>
    <td align="center"> $req->{user} </td>
    <td> $cmd $req->{cmd}[0] </td></tr>
EOF
    }
    Header($Lang->{BackupPC__Queue_Summary});

    print ( eval ( "qq{$Lang->{Backup_Queue_Summary}}") );

    Trailer();
}

sub Action_View
{
    my $Privileged = CheckPermission($In{host});
    my $compress = 0;
    my $fh;
    my $host = $In{host};
    my $num  = $In{num};
    my $type = $In{type};
    my $linkHosts = 0;
    my($file, $comment);
    my $ext = $num ne "" ? ".$num" : "";

    ErrorExit(eval("qq{$Lang->{Invalid_number__num}}")) if ( $num ne "" && $num !~ /^\d+$/ );
    if ( $type eq "XferLOG" ) {
        $file = "$TopDir/pc/$host/SmbLOG$ext";
        $file = "$TopDir/pc/$host/XferLOG$ext" if ( !-f $file && !-f "$file.z");
    } elsif ( $type eq "XferLOGbad" ) {
        $file = "$TopDir/pc/$host/SmbLOG.bad";
        $file = "$TopDir/pc/$host/XferLOG.bad" if ( !-f $file && !-f "$file.z");
    } elsif ( $type eq "XferErrbad" ) {
        $file = "$TopDir/pc/$host/SmbLOG.bad";
        $file = "$TopDir/pc/$host/XferLOG.bad" if ( !-f $file && !-f "$file.z");
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $type eq "XferErr" ) {
        $file = "$TopDir/pc/$host/SmbLOG$ext";
        $file = "$TopDir/pc/$host/XferLOG$ext" if ( !-f $file && !-f "$file.z");
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $type eq "RestoreLOG" ) {
        $file = "$TopDir/pc/$host/RestoreLOG$ext";
    } elsif ( $type eq "RestoreErr" ) {
        $file = "$TopDir/pc/$host/RestoreLOG$ext";
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $host ne "" && $type eq "config" ) {
        $file = "$TopDir/pc/$host/config.pl";
        $file = "/etc/backuppc/$host.pl"
                    if ( $host ne "config" && -f "/etc/backuppc/$host.pl"
                                           && !-f $file );
    } elsif ( $type eq "docs" ) {
        $file = "/usr/share/doc/backuppc/BackupPC.html";
        if ( open(LOG, $file) ) {
	    binmode(LOG);
            Header($Lang->{BackupPC__Documentation});
            print while ( <LOG> );
            close(LOG);
            Trailer();
        } else {
            ErrorExit(eval("qq{$Lang->{Unable_to_open__file__configuration_problem}}"));
        }
        return;
    } elsif ( $type eq "config" ) {
        $file = "/etc/backuppc/config.pl";
    } elsif ( $type eq "hosts" ) {
        $file = "/etc/backuppc/hosts";
    } elsif ( $host ne "" ) {
        $file = "$TopDir/pc/$host/LOG$ext";
    } else {
        $file = "$TopDir/log/LOG$ext";
        $linkHosts = 1;
    }
    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_log_or_config_files});
    }
    if ( !-f $file && -f "$file.z" ) {
        $file .= ".z";
        $compress = 1;
    }
    Header(eval("qq{$Lang->{Backup_PC__Log_File__file}}")  );
    print( eval ("qq{$Lang->{Log_File__file__comment}}"));
    if ( defined($fh = BackupPC::FileZIO->open($file, 0, $compress)) ) {
        my $mtimeStr = $bpc->timeStamp((stat($file))[9], 1);

	print ( eval ("qq{$Lang->{Contents_of_log_file}}"));

        print "<pre>";
        if ( $type eq "XferErr" || $type eq "XferErrbad"
				|| $type eq "RestoreErr" ) {
	    my $skipped;
            while ( 1 ) {
                $_ = $fh->readLine();
                if ( $_ eq "" ) {
		    print(eval ("qq{$Lang->{skipped__skipped_lines}}"))
						    if ( $skipped );
		    last;
		}
                if ( /smb: \\>/
                        || /^\s*(\d+) \(\s*\d+\.\d kb\/s\) (.*)$/
                        || /^tar: dumped \d+ files/
                        || /^\s*added interface/i
                        || /^\s*restore tar file /i
                        || /^\s*restore directory /i
                        || /^\s*tarmode is now/i
                        || /^\s*Total bytes written/i
                        || /^\s*Domain=/i
                        || /^\s*Getting files newer than/i
                        || /^\s*Output is \/dev\/null/
                        || /^\([\d\.]* kb\/s\) \(average [\d\.]* kb\/s\)$/
                        || /^\s+directory \\/
                        || /^\s*Timezone is/
			|| /^\s*creating lame (up|low)case table/i
                        || /^\.\//
                        || /^   /
			    ) {
		    $skipped++;
		    next;
		}
		print(eval("qq{$Lang->{skipped__skipped_lines}}"))
						     if ( $skipped );
		$skipped = 0;
                print ${EscHTML($_)};
            }
        } elsif ( $linkHosts ) {
            while ( 1 ) {
                $_ = $fh->readLine();
                last if ( $_ eq "" );
                my $s = ${EscHTML($_)};
                $s =~ s/\b([\w-]+)\b/defined($Hosts->{$1})
                                        ? ${HostLink($1)} : $1/eg;
                print $s;
            }
        } elsif ( $type eq "config" ) {
            while ( 1 ) {
                $_ = $fh->readLine();
                last if ( $_ eq "" );
                # remove any passwords and user names
                s/(SmbSharePasswd.*=.*['"]).*(['"])/$1$2/ig;
                s/(SmbShareUserName.*=.*['"]).*(['"])/$1$2/ig;
                s/(RsyncdPasswd.*=.*['"]).*(['"])/$1$2/ig;
                s/(ServerMesgSecret.*=.*['"]).*(['"])/$1$2/ig;
                print ${EscHTML($_)};
            }
        } else {
            while ( 1 ) {
                $_ = $fh->readLine();
                last if ( $_ eq "" );
                print ${EscHTML($_)};
            }
        }
        $fh->close();
    } else {
	printf( eval("qq{$Lang->{_pre___Can_t_open_log_file__file}}"));
    }
    print <<EOF;
</pre>
EOF
    Trailer();
}

sub Action_LOGlist
{
    my $Privileged = CheckPermission($In{host});

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_log_files});
    }
    my $host = $In{host};
    my($url0, $hdr, $root, $str);
    if ( $host ne "" ) {
        $root = "$TopDir/pc/$host/LOG";
        $url0 = "&host=${EscURI($host)}";
        $hdr = "for host $host";
    } else {
        $root = "$TopDir/log/LOG";
        $url0 = "";
        $hdr = "";
    }
    for ( my $i = -1 ; ; $i++ ) {
        my $url1 = "";
        my $file = $root;
        if ( $i >= 0 ) {
            $file .= ".$i";
            $url1 = "&num=$i";
        }
        $file .= ".z" if ( !-f $file && -f "$file.z" );
        last if ( !-f $file );
        my $mtimeStr = $bpc->timeStamp((stat($file))[9], 1);
        my $size     = (stat($file))[7];
        $str .= <<EOF;
<tr><td> <a href="$MyURL?action=view&type=LOG$url0$url1"><tt>$file</tt></a> </td>
    <td align="right"> $size </td>
    <td> $mtimeStr </td></tr>
EOF
    }
    Header($Lang->{BackupPC__Log_File_History});
    print (eval("qq{$Lang->{Log_File_History__hdr}}"));
    Trailer();
}

sub Action_EmailSummary
{
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_email_summaries});
    }
    GetStatusInfo("hosts");
    ReadUserEmailInfo();
    my(%EmailStr, $str);
    foreach my $u ( keys(%UserEmailInfo) ) {
        next if ( !defined($UserEmailInfo{$u}{lastTime}) );
        my $emailTimeStr = timeStamp2($UserEmailInfo{$u}{lastTime});
        $EmailStr{$UserEmailInfo{$u}{lastTime}} .= <<EOF;
<tr><td>${UserLink($u)} </td>
    <td>${HostLink($UserEmailInfo{$u}{lastHost})} </td>
    <td>$emailTimeStr </td>
    <td>$UserEmailInfo{$u}{lastSubj} </td></tr>
EOF
    }
    foreach my $t ( sort({$b <=> $a} keys(%EmailStr)) ) {
        $str .= $EmailStr{$t};
    }
    Header($Lang->{Email_Summary});
    print (eval("qq{$Lang->{Recent_Email_Summary}}"));
    Trailer();
}

sub Action_Browse
{
    my $Privileged = CheckPermission($In{host});
    my($i, $dirStr, $fileStr, $attr);
    my $checkBoxCnt = 0;

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_browse_backup_files}}"));
    }
    my $host  = $In{host};
    my $num   = $In{num};
    my $share = $In{share};
    my $dir   = $In{dir};

    ErrorExit($Lang->{Empty_host_name}) if ( $host eq "" );
    #
    # Find the requested backup and the previous filled backup
    #
    my @Backups = $bpc->BackupInfoRead($host);
    for ( $i = 0 ; $i < @Backups ; $i++ ) {
        last if ( $Backups[$i]{num} == $num );
    }
    if ( $i >= @Backups ) {
        ErrorExit("Backup number $num for host ${EscHTML($host)} does"
	        . " not exist.");
    }
    my $backupTime = timeStamp2($Backups[$i]{startTime});
    my $backupAge = sprintf("%.1f", (time - $Backups[$i]{startTime})
                                    / (24 * 3600));
    my $view = BackupPC::View->new($bpc, $host, \@Backups);

    if ( $dir eq "" || $dir eq "." || $dir eq ".." ) {
	$attr = $view->dirAttrib($num, "", "");
	if ( keys(%$attr) > 0 ) {
	    $share = (sort(keys(%$attr)))[0];
	    $dir   = '/';
	} else {
            ErrorExit(eval("qq{$Lang->{Directory___EscHTML}}"));
	}
    }
    $dir = "/$dir" if ( $dir !~ /^\// );
    my $relDir  = $dir;
    my $currDir = undef;
    if ( $dir =~ m{(^|/)\.\.(/|$)} ) {
        ErrorExit($Lang->{Nice_try__but_you_can_t_put});
    }

    #
    # Loop up the directory tree until we hit the top.
    #
    my(@DirStrPrev);
    while ( 1 ) {
        my($fLast, $fLastum, @DirStr);

	$attr = $view->dirAttrib($num, $share, $relDir);
        if ( !defined($attr) ) {
            ErrorExit(eval("qq{$Lang->{Can_t_browse_bad_directory_name2}}"));
        }

        my $fileCnt = 0;          # file counter
        $fLast = $dirStr = "";

        #
        # Loop over each of the files in this directory
        #
	foreach my $f ( sort(keys(%$attr)) ) {
            my($dirOpen, $gotDir, $imgStr, $img, $path);
            my $fURI = $f;                             # URI escaped $f
            my $shareURI = $share;                     # URI escaped $share
	    if ( $relDir eq "" ) {
		$path = "/$f";
	    } else {
		($path = "$relDir/$f") =~ s{//+}{/}g;
	    }
	    if ( $shareURI eq "" ) {
		$shareURI = $f;
		$path  = "/";
	    }
            $path =~ s{^/+}{/};
            $path     =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
            $fURI     =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
            $shareURI =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
            $dirOpen  = 1 if ( defined($currDir) && $f eq $currDir );
            if ( $attr->{$f}{type} == BPC_FTYPE_DIR ) {
                #
                # Display directory if it exists in current backup.
                # First find out if there are subdirs
                #
		my($bold, $unbold, $BGcolor);
		$img |= 1 << 6;
		$img |= 1 << 5 if ( $attr->{$f}{nlink} > 2 );
		if ( $dirOpen ) {
		    $bold = "<b>";
		    $unbold = "</b>";
		    $img |= 1 << 2;
		    $img |= 1 << 3 if ( $attr->{$f}{nlink} > 2 );
		}
		my $imgFileName = sprintf("%07b.gif", $img);
		$imgStr = "<img src=\"$Conf{CgiImageDirURL}/$imgFileName\" align=\"absmiddle\" width=\"9\" height=\"19\" border=\"0\">";
		if ( "$relDir/$f" eq $dir ) {
		    $BGcolor = " bgcolor=\"$Conf{CgiHeaderBgColor}\"";
		} else {
		    $BGcolor = "";
		}
		my $dirName = $f;
		$dirName =~ s/ /&nbsp;/g;
		push(@DirStr, {needTick => 1,
			       tdArgs   => $BGcolor,
			       link     => <<EOF});
<a href="$MyURL?action=browse&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$imgStr</a><a href="$MyURL?action=browse&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path" style="font-size:13px;font-family:arial;text-decoration:none;line-height:15px">&nbsp;$bold$dirName$unbold</a></td></tr>
EOF
                $fileCnt++;
                $gotDir = 1;
		if ( $dirOpen ) {
		    my($lastTick, $doneLastTick);
		    foreach my $d ( @DirStrPrev ) {
			$lastTick = $d if ( $d->{needTick} );
		    }
		    $doneLastTick = 1 if ( !defined($lastTick) );
		    foreach my $d ( @DirStrPrev ) {
			$img = 0;
			if  ( $d->{needTick} ) {
			    $img |= 1 << 0;
			}
			if ( $d == $lastTick ) {
			    $img |= 1 << 4;
			    $doneLastTick = 1;
			} elsif ( !$doneLastTick ) {
			    $img |= 1 << 3 | 1 << 4;
			}
			my $imgFileName = sprintf("%07b.gif", $img);
			$imgStr = "<img src=\"$Conf{CgiImageDirURL}/$imgFileName\" align=\"absmiddle\" width=\"9\" height=\"19\" border=\"0\">";
			push(@DirStr, {needTick => 0,
				       tdArgs   => $d->{tdArgs},
				       link     => $imgStr . $d->{link}
			});
		    }
		}
            }
            if ( $relDir eq $dir ) {
                #
                # This is the selected directory, so display all the files
                #
                my $attrStr;
                if ( defined($a = $attr->{$f}) ) {
                    my $mtimeStr = $bpc->timeStamp($a->{mtime});
		    # UGH -> fix this
                    my $typeStr  = BackupPC::Attrib::fileType2Text(undef,
								   $a->{type});
                    my $modeStr  = sprintf("0%o", $a->{mode} & 07777);
                    $attrStr .= <<EOF;
    <td align="center">$typeStr</td>
    <td align="center">$modeStr</td>
    <td align="center">$a->{backupNum}</td>
    <td align="right">$a->{size}</td>
    <td align="right">$mtimeStr</td>
</tr>
EOF
                } else {
                    $attrStr .= "<td colspan=\"5\" align=\"center\"> </td>\n";
                }
		(my $fDisp = "${EscHTML($f)}") =~ s/ /&nbsp;/g;
                if ( $gotDir ) {
                    $fileStr .= <<EOF;
<tr bgcolor="#ffffcc"><td><input type="checkbox" name="fcb$checkBoxCnt" value="$path">&nbsp;<a href="$MyURL?action=browse&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$fDisp</a></td>
$attrStr
</tr>
EOF
                } else {
                    $fileStr .= <<EOF;
<tr bgcolor="#ffffcc"><td><input type="checkbox" name="fcb$checkBoxCnt" value="$path">&nbsp;<a href="$MyURL?action=RestoreFile&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$fDisp</a></td>
$attrStr
</tr>
EOF
                }
                $checkBoxCnt++;
            }
        }
	@DirStrPrev = @DirStr;
        last if ( $relDir eq "" && $share eq "" );
        # 
        # Prune the last directory off $relDir, or at the very end
	# do the top-level directory.
        #
	if ( $relDir eq "" || $relDir eq "/" || $relDir !~ /(.*)\/(.*)/ ) {
	    $currDir = $share;
	    $share = "";
	    $relDir = "";
	} else {
	    $relDir  = $1;
	    $currDir = $2;
	}
    }
    $share = $currDir;
    my $dirDisplay = "$share/$dir";
    $dirDisplay =~ s{//+}{/}g;
    $dirDisplay =~ s{/+$}{}g;
    $dirDisplay = "/" if ( $dirDisplay eq "" );
    my $filledBackup;

    if ( (my @mergeNums = @{$view->mergeNums}) > 1 ) {
	shift(@mergeNums);
	my $numF = join(", #", @mergeNums);
        $filledBackup = eval("qq{$Lang->{This_display_is_merged_with_backup}}");
    }
    Header(eval("qq{$Lang->{Browse_backup__num_for__host}}"));

    foreach my $d ( @DirStrPrev ) {
	$dirStr .= "<tr><td$d->{tdArgs}>$d->{link}\n";
    }

    ### hide checkall button if there are no files
    my ($topCheckAll, $checkAll, $fileHeader);
    if ( $fileStr ) {
    	$fileHeader = eval("qq{$Lang->{fileHeader}}");

	$checkAll = $Lang->{checkAll};

    	# and put a checkall box on top if there are at least 20 files
	if ( $checkBoxCnt >= 20 ) {
	    $topCheckAll = $checkAll;
	    $topCheckAll =~ s{allFiles}{allFilestop}g;
	}
    } else {
	$fileStr = eval("qq{$Lang->{The_directory_is_empty}}");
    }
    my @otherDirs;
    foreach my $i ( $view->backupList($share, $dir) ) {
        my $path = $dir;
        my $shareURI = $share;
        $path =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;
        $shareURI =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;
        push(@otherDirs, "<a href=\"$MyURL?action=browse&host=${EscURI($host)}&num=$i"
                       . "&share=$shareURI&dir=$path\">$i</a>");

    }
    if ( @otherDirs ) {
	my $otherDirs  = join(",\n", @otherDirs);
        $filledBackup .= eval("qq{$Lang->{Visit_this_directory_in_backup}}");
    }
    print (eval("qq{$Lang->{Backup_browse_for__host}}"));
    Trailer();
}

sub Action_Restore
{
    my($str, $reply);
    my $Privileged = CheckPermission($In{host});
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_restore_backup_files}}"));
    }
    my $host  = $In{host};
    my $num   = $In{num};
    my $share = $In{share};
    my(@fileList, $fileListStr, $hiddenStr, $pathHdr, $badFileCnt);
    my @Backups = $bpc->BackupInfoRead($host);

    ServerConnect();
    if ( !defined($Hosts->{$host}) ) {
        ErrorExit(eval("qq{$Lang->{Bad_host_name}}"));
    }
    for ( my $i = 0 ; $i < $In{fcbMax} ; $i++ ) {
        next if ( !defined($In{"fcb$i"}) );
        (my $name = $In{"fcb$i"}) =~ s/%([0-9A-F]{2})/chr(hex($1))/eg;
        $badFileCnt++ if ( $name =~ m{(^|/)\.\.(/|$)} );
	if ( @fileList == 0 ) {
	    $pathHdr = $name;
	} else {
	    while ( substr($name, 0, length($pathHdr)) ne $pathHdr ) {
		$pathHdr = substr($pathHdr, 0, rindex($pathHdr, "/"));
	    }
	}
        push(@fileList, $name);
        $hiddenStr .= <<EOF;
<input type="hidden" name="fcb$i" value="$In{'fcb' . $i}">
EOF
        $fileListStr .= <<EOF;
<li> ${EscHTML($name)}
EOF
    }
    $hiddenStr .= "<input type=\"hidden\" name=\"fcbMax\" value=\"$In{fcbMax}\">\n";
    $hiddenStr .= "<input type=\"hidden\" name=\"share\" value=\"${EscHTML($share)}\">\n";
    $badFileCnt++ if ( $In{pathHdr} =~ m{(^|/)\.\.(/|$)} );
    $badFileCnt++ if ( $In{num} =~ m{(^|/)\.\.(/|$)} );
    if ( @fileList == 0 ) {
        ErrorExit($Lang->{You_haven_t_selected_any_files__please_go_Back_to});
    }
    if ( $badFileCnt ) {
        ErrorExit($Lang->{Nice_try__but_you_can_t_put});
    }
    if ( @fileList == 1 ) {
	$pathHdr =~ s/(.*)\/.*/$1/;
    }
    $pathHdr = "/" if ( $pathHdr eq "" );
    if ( $In{type} != 0 && @fileList == $In{fcbMax} ) {
	#
	# All the files in the list were selected, so just restore the
	# entire parent directory
	#
	@fileList = ( $pathHdr );
    }
    if ( $In{type} == 0 ) {
        #
        # Tell the user what options they have
        #
        Header(eval("qq{$Lang->{Restore_Options_for__host}}"));
	print(eval("qq{$Lang->{Restore_Options_for__host2}}"));

	#
	# Verify that Archive::Zip is available before showing the
	# zip restore option
	#
	if ( eval { require Archive::Zip } ) {
	    print (eval("qq{$Lang->{Option_2__Download_Zip_archive}}"));
	} else {
	    print (eval("qq{$Lang->{Option_2__Download_Zip_archive2}}"));
	}
	print (eval("qq{$Lang->{Option_3__Download_Zip_archive}}"));
        Trailer();
    } elsif ( $In{type} == 1 ) {
        #
        # Provide the selected files via a tar archive.
	#
	my @fileListTrim = @fileList;
	if ( @fileListTrim > 10 ) {
	    @fileListTrim = (@fileListTrim[0..9], '...');
	}
	$bpc->ServerMesg("log User $User downloaded tar archive for $host,"
		       . " backup $num; files were: "
		       . join(", ", @fileListTrim));

        my @pathOpts;
        if ( $In{relative} ) {
            @pathOpts = ("-r", $pathHdr, "-p", "");
        }
	print(STDOUT <<EOF);
Content-Type: application/x-gtar
Content-Transfer-Encoding: binary
Content-Disposition: attachment; filename=\"restore.tar\"

EOF
	#
	# Fork the child off and manually copy the output to our stdout.
	# This is necessary to ensure the output gets to the correct place
	# under mod_perl.
	#
	$bpc->cmdSystemOrEval(["$BinDir/BackupPC_tarCreate",
		 "-h", $host,
		 "-n", $num,
		 "-s", $share,
		 @pathOpts,
		 @fileList
	    ],
	    sub { print(@_); }
	);
    } elsif ( $In{type} == 2 ) {
        #
        # Provide the selected files via a zip archive.
	#
	my @fileListTrim = @fileList;
	if ( @fileListTrim > 10 ) {
	    @fileListTrim = (@fileListTrim[0..9], '...');
	}
	$bpc->ServerMesg("log User $User downloaded zip archive for $host,"
		       . " backup $num; files were: "
		       . join(", ", @fileListTrim));

        my @pathOpts;
        if ( $In{relative} ) {
            @pathOpts = ("-r", $pathHdr, "-p", "");
        }
	print(STDOUT <<EOF);
Content-Type: application/zip
Content-Transfer-Encoding: binary
Content-Disposition: attachment; filename=\"restore.zip\"

EOF
	$In{compressLevel} = 5 if ( $In{compressLevel} !~ /^\d+$/ );
	#
	# Fork the child off and manually copy the output to our stdout.
	# This is necessary to ensure the output gets to the correct place
	# under mod_perl.
	#
	$bpc->cmdSystemOrEval(["$BinDir/BackupPC_zipCreate",
		 "-h", $host,
		 "-n", $num,
		 "-c", $In{compressLevel},
		 "-s", $share,
		 @pathOpts,
		 @fileList
	    ],
	    sub { print(@_); }
	);
    } elsif ( $In{type} == 3 ) {
        #
        # Do restore directly onto host
        #
	if ( !defined($Hosts->{$In{hostDest}}) ) {
	    ErrorExit(eval("qq{$Lang->{Host__doesn_t_exist}}"));
	}
	if ( !CheckPermission($In{hostDest}) ) {
	    ErrorExit(eval("qq{$Lang->{You_don_t_have_permission_to_restore_onto_host}}"));
	}
        $fileListStr = "";
        foreach my $f ( @fileList ) {
            my $targetFile = $f;
	    (my $strippedShare = $share) =~ s/^\///;
	    (my $strippedShareDest = $In{shareDest}) =~ s/^\///;
            substr($targetFile, 0, length($pathHdr)) = $In{pathHdr};
            $fileListStr .= <<EOF;
<tr><td>$host:/$strippedShare$f</td><td>$In{hostDest}:/$strippedShareDest$targetFile</td></tr>
EOF
        }
        Header(eval("qq{$Lang->{Restore_Confirm_on__host}}"));
	print(eval("qq{$Lang->{Are_you_sure}}"));
        Trailer();
    } elsif ( $In{type} == 4 ) {
	if ( !defined($Hosts->{$In{hostDest}}) ) {
	    ErrorExit(eval("qq{$Lang->{Host__doesn_t_exist}}"));
	}
	if ( !CheckPermission($In{hostDest}) ) {
	    ErrorExit(eval("qq{$Lang->{You_don_t_have_permission_to_restore_onto_host}}"));
	}
	my $hostDest = $1 if ( $In{hostDest} =~ /(.+)/ );
	my $ipAddr = ConfirmIPAddress($hostDest);
        #
        # Prepare and send the restore request.  We write the request
        # information using Data::Dumper to a unique file,
        # $TopDir/pc/$hostDest/restoreReq.$$.n.  We use a file
        # in case the list of files to restore is very long.
        #
        my $reqFileName;
        for ( my $i = 0 ; ; $i++ ) {
            $reqFileName = "restoreReq.$$.$i";
            last if ( !-f "$TopDir/pc/$hostDest/$reqFileName" );
        }
        my %restoreReq = (
	    # source of restore is hostSrc, #num, path shareSrc/pathHdrSrc
            num         => $In{num},
            hostSrc     => $host,
            shareSrc    => $share,
            pathHdrSrc  => $pathHdr,

	    # destination of restore is hostDest:shareDest/pathHdrDest
            hostDest    => $hostDest,
            shareDest   => $In{shareDest},
            pathHdrDest => $In{pathHdr},

	    # list of files to restore
            fileList    => \@fileList,

	    # other info
            user        => $User,
            reqTime     => time,
        );
        my($dump) = Data::Dumper->new(
                         [  \%restoreReq],
                         [qw(*RestoreReq)]);
        $dump->Indent(1);
        if ( open(REQ, ">$TopDir/pc/$hostDest/$reqFileName") ) {
	    binmode(REQ);
            print(REQ $dump->Dump);
            close(REQ);
        } else {
            ErrorExit(eval("qq{$Lang->{Can_t_open_create}}"));
        }
	$reply = $bpc->ServerMesg("restore ${EscURI($ipAddr)}"
			. " ${EscURI($hostDest)} $User $reqFileName");
	$str = eval("qq{$Lang->{Restore_requested_to_host__hostDest__backup___num}}");
        Header(eval("qq{$Lang->{Restore_Requested_on__hostDest}}"));
	print (eval("qq{$Lang->{Reply_from_server_was___reply}}"));
        Trailer();
    }
}

sub Action_RestoreFile
{
    restoreFile($In{host}, $In{num}, $In{share}, $In{dir});
}

sub restoreFile
{
    my($host, $num, $share, $dir, $skipHardLink, $origName) = @_;
    my($Privileged) = CheckPermission($host);

    #
    # Some common content (media) types from www.iana.org (via MIME::Types).
    #
    my $Ext2ContentType = {
	'asc'  => 'text/plain',
	'avi'  => 'video/x-msvideo',
	'bmp'  => 'image/bmp',
	'book' => 'application/x-maker',
	'cc'   => 'text/plain',
	'cpp'  => 'text/plain',
	'csh'  => 'application/x-csh',
	'csv'  => 'text/comma-separated-values',
	'c'    => 'text/plain',
	'deb'  => 'application/x-debian-package',
	'doc'  => 'application/msword',
	'dot'  => 'application/msword',
	'dtd'  => 'text/xml',
	'dvi'  => 'application/x-dvi',
	'eps'  => 'application/postscript',
	'fb'   => 'application/x-maker',
	'fbdoc'=> 'application/x-maker',
	'fm'   => 'application/x-maker',
	'frame'=> 'application/x-maker',
	'frm'  => 'application/x-maker',
	'gif'  => 'image/gif',
	'gtar' => 'application/x-gtar',
	'gz'   => 'application/x-gzip',
	'hh'   => 'text/plain',
	'hpp'  => 'text/plain',
	'h'    => 'text/plain',
	'html' => 'text/html',
	'htmlx'=> 'text/html',
	'htm'  => 'text/html',
	'iges' => 'model/iges',
	'igs'  => 'model/iges',
	'jpeg' => 'image/jpeg',
	'jpe'  => 'image/jpeg',
	'jpg'  => 'image/jpeg',
	'js'   => 'application/x-javascript',
	'latex'=> 'application/x-latex',
	'maker'=> 'application/x-maker',
	'mid'  => 'audio/midi',
	'midi' => 'audio/midi',
	'movie'=> 'video/x-sgi-movie',
	'mov'  => 'video/quicktime',
	'mp2'  => 'audio/mpeg',
	'mp3'  => 'audio/mpeg',
	'mpeg' => 'video/mpeg',
	'mpg'  => 'video/mpeg',
	'mpp'  => 'application/vnd.ms-project',
	'pdf'  => 'application/pdf',
	'pgp'  => 'application/pgp-signature',
	'php'  => 'application/x-httpd-php',
	'pht'  => 'application/x-httpd-php',
	'phtml'=> 'application/x-httpd-php',
	'png'  => 'image/png',
	'ppm'  => 'image/x-portable-pixmap',
	'ppt'  => 'application/powerpoint',
	'ppt'  => 'application/vnd.ms-powerpoint',
	'ps'   => 'application/postscript',
	'qt'   => 'video/quicktime',
	'rgb'  => 'image/x-rgb',
	'rtf'  => 'application/rtf',
	'rtf'  => 'text/rtf',
	'shar' => 'application/x-shar',
	'shtml'=> 'text/html',
	'swf'  => 'application/x-shockwave-flash',
	'tex'  => 'application/x-tex',
	'texi' => 'application/x-texinfo',
	'texinfo'=> 'application/x-texinfo',
	'tgz'  => 'application/x-gtar',
	'tiff' => 'image/tiff',
	'tif'  => 'image/tiff',
	'txt'  => 'text/plain',
	'vcf'  => 'text/x-vCard',
	'vrml' => 'model/vrml',
	'wav'  => 'audio/x-wav',
	'wmls' => 'text/vnd.wap.wmlscript',
	'wml'  => 'text/vnd.wap.wml',
	'wrl'  => 'model/vrml',
	'xls'  => 'application/vnd.ms-excel',
	'xml'  => 'text/xml',
	'xwd'  => 'image/x-xwindowdump',
	'z'    => 'application/x-compress',
	'zip'  => 'application/zip',
        %{$Conf{CgiExt2ContentType}},       # add site-specific values
    };
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_restore_backup_files2}}"));
    }
    ServerConnect();
    ErrorExit($Lang->{Empty_host_name}) if ( $host eq "" );

    $dir = "/" if ( $dir eq "" );
    my @Backups = $bpc->BackupInfoRead($host);
    my $view = BackupPC::View->new($bpc, $host, \@Backups);
    my $a = $view->fileAttrib($num, $share, $dir);
    if ( $dir =~ m{(^|/)\.\.(/|$)} || !defined($a) ) {
        ErrorExit("Can't restore bad file ${EscHTML($dir)}");
    }
    my $f = BackupPC::FileZIO->open($a->{fullPath}, 0, $a->{compress});
    my $data;
    if ( !$skipHardLink && $a->{type} == BPC_FTYPE_HARDLINK ) {
	#
	# hardlinks should look like the file they point to
	#
	my $linkName;
        while ( $f->read(\$data, 65536) > 0 ) {
            $linkName .= $data;
        }
	$f->close;
	$linkName =~ s/^\.\///;
	my $share = $1 if ( $dir =~ /^\/?(.*?)\// );
	restoreFile($host, $num, $share, $linkName, 1, $dir);
	return;
    }
    $bpc->ServerMesg("log User $User recovered file $host/$num:$share/$dir ($a->{fullPath})");
    $dir = $origName if ( defined($origName) );
    my $ext = $1 if ( $dir =~ /\.([^\/\.]+)$/ );
    my $contentType = $Ext2ContentType->{lc($ext)}
				    || "application/octet-stream";
    my $fileName = $1 if ( $dir =~ /.*\/(.*)/ );
    $fileName =~ s/"/\\"/g;
    print "Content-Type: $contentType\n";
    print "Content-Transfer-Encoding: binary\n";
    print "Content-Disposition: attachment; filename=\"$fileName\"\n\n";
    while ( $f->read(\$data, 1024 * 1024) > 0 ) {
        print STDOUT $data;
    }
    $f->close;
}

sub Action_HostInfo
{
    my $host = $1 if ( $In{host} =~ /(.*)/ );
    my($statusStr, $startIncrStr);

    $host =~ s/^\s+//;
    $host =~ s/\s+$//;
    return Action_GeneralInfo() if ( $host eq "" );
    $host = lc($host)
                if ( !-d "$TopDir/pc/$host" && -d "$TopDir/pc/" . lc($host) );
    if ( $host =~ /\.\./ || !-d "$TopDir/pc/$host" ) {
        #
        # try to lookup by user name
        #
        if ( !defined($Hosts->{$host}) ) {
            foreach my $h ( keys(%$Hosts) ) {
                if ( $Hosts->{$h}{user} eq $host
                        || lc($Hosts->{$h}{user}) eq lc($host) ) {
                    $host = $h;
                    last;
                }
            }
            CheckPermission();
#           ErrorExit(eval("qq{$Lang->{Unknown_host_or_user}}"))
#            print "Location : host_config.cgi"
            print redirect("host_config.cgi?mac=$In{mac}")
                                if ( !defined($Hosts->{$host}) );
        }
        $In{host} = $host;
    }
    GetStatusInfo("host(${EscURI($host)})");
    $bpc->ConfigRead($host);
    %Conf = $bpc->Conf();
    
    # Force some global conf options
    if ( $InWebmin == 1 ) {
	$Conf{BackupPCUser} = 'root';
	$Conf{BackupPCUserVerify} = 0;
	$Conf{CgiAdminUserGroup} = 'root';
	$Conf{CgiAdminUsers}     = 'root';
	$Conf{CgiNavBarBgColor} = '#f5f5f5';
	$Conf{CgiHeaderBgColor} = '#e2e2e2';
	$Conf{CgiDir}       = $ENV{SERVER_ROOT}.'/backuppc';
    }

    my $Privileged = CheckPermission($host);
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_view_information_about}}"));
    }
    ReadUserEmailInfo();

    my @Backups = $bpc->BackupInfoRead($host);
    my($str, $sizeStr, $compStr, $errStr, $warnStr);
    for ( my $i = 0 ; $i < @Backups ; $i++ ) {
        my $startTime = timeStamp2($Backups[$i]{startTime});
        my $dur       = $Backups[$i]{endTime} - $Backups[$i]{startTime};
        $dur          = 1 if ( $dur <= 0 );
        my $duration  = sprintf("%.1f", $dur / 60);
        my $MB        = sprintf("%.1f", $Backups[$i]{size} / (1024*1024));
        my $MBperSec  = sprintf("%.2f", $Backups[$i]{size} / (1024*1024*$dur));
        my $MBExist   = sprintf("%.1f", $Backups[$i]{sizeExist} / (1024*1024));
        my $MBNew     = sprintf("%.1f", $Backups[$i]{sizeNew} / (1024*1024));
        my($MBExistComp, $ExistComp, $MBNewComp, $NewComp);
        if ( $Backups[$i]{sizeExist} && $Backups[$i]{sizeExistComp} ) {
            $MBExistComp = sprintf("%.1f", $Backups[$i]{sizeExistComp}
                                                / (1024 * 1024));
            $ExistComp = sprintf("%.1f%%", 100 *
                  (1 - $Backups[$i]{sizeExistComp} / $Backups[$i]{sizeExist}));
        }
        if ( $Backups[$i]{sizeNew} && $Backups[$i]{sizeNewComp} ) {
            $MBNewComp = sprintf("%.1f", $Backups[$i]{sizeNewComp}
                                                / (1024 * 1024));
            $NewComp = sprintf("%.1f%%", 100 *
                  (1 - $Backups[$i]{sizeNewComp} / $Backups[$i]{sizeNew}));
        }
        my $age = sprintf("%.1f", (time - $Backups[$i]{startTime}) / (24*3600));
        my $browseURL = "$MyURL?action=browse&host=${EscURI($host)}&num=$Backups[$i]{num}";
        my $filled = $Backups[$i]{noFill} ? $Lang->{No} : $Lang->{Yes};
        $filled .= " ($Backups[$i]{fillFromNum}) "
                            if ( $Backups[$i]{fillFromNum} ne "" );
	my $ltype;
	if ($Backups[$i]{type} eq "full") { $ltype = $Lang->{full}; }
	else { $ltype = $Lang->{incremental}; }
        $str .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="center"> $filled </td>
    <td align="right">  $startTime </td>
    <td align="right">  $duration </td>
    <td align="right">  $age </td>
    <td align="left">   <tt>$TopDir/pc/$host/$Backups[$i]{num}</tt> </td></tr>
EOF
        $sizeStr .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="right">  $Backups[$i]{nFiles} </td>
    <td align="right">  $MB </td>
    <td align="right">  $MBperSec </td>
    <td align="right">  $Backups[$i]{nFilesExist} </td>
    <td align="right">  $MBExist </td>
    <td align="right">  $Backups[$i]{nFilesNew} </td>
    <td align="right">  $MBNew </td>
</tr>
EOF
	my $is_compress = $Backups[$i]{compress} || $Lang->{off};
	if (! $ExistComp) { $ExistComp = "&nbsp;"; }
	if (! $MBExistComp) { $MBExistComp = "&nbsp;"; }
        $compStr .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="center"> $is_compress </td> 
    <td align="right">  $MBExist </td>
    <td align="right">  $MBExistComp </td> 
    <td align="right">  $ExistComp </td>   
    <td align="right">  $MBNew </td>
    <td align="right">  $MBNewComp </td>
    <td align="right">  $NewComp </td>
</tr>
EOF
        $errStr .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="center"> <a href="$MyURL?action=view&type=XferLOG&num=$Backups[$i]{num}&host=${EscURI($host)}">$Lang->{XferLOG}</a>,
                      <a href="$MyURL?action=view&type=XferErr&num=$Backups[$i]{num}&host=${EscURI($host)}">$Lang->{Errors}</a> </td>
    <td align="right">  $Backups[$i]{xferErrs} </td>
    <td align="right">  $Backups[$i]{xferBadFile} </td>
    <td align="right">  $Backups[$i]{xferBadShare} </td>
    <td align="right">  $Backups[$i]{tarErrs} </td></tr>
EOF
    }

    my @Restores = $bpc->RestoreInfoRead($host);
    my $restoreStr;

    for ( my $i = 0 ; $i < @Restores ; $i++ ) {
        my $startTime = timeStamp2($Restores[$i]{startTime});
        my $dur       = $Restores[$i]{endTime} - $Restores[$i]{startTime};
        $dur          = 1 if ( $dur <= 0 );
        my $duration  = sprintf("%.1f", $dur / 60);
        my $MB        = sprintf("%.1f", $Restores[$i]{size} / (1024*1024));
        my $MBperSec  = sprintf("%.2f", $Restores[$i]{size} / (1024*1024*$dur));
	my $Restores_Result = $Lang->{failed};
	if ($Restores[$i]{result} ne "failed") { $Restores_Result = $Lang->{success}; }
	$restoreStr  .= <<EOF;
<tr><td align="center"><a href="$MyURL?action=restoreInfo&num=$Restores[$i]{num}&host=${EscURI($host)}">$Restores[$i]{num}</a> </td>
    <td align="center"> $Restores_Result </td>
    <td align="right"> $startTime </td>
    <td align="right"> $duration </td>
    <td align="right"> $Restores[$i]{nFiles} </td>
    <td align="right"> $MB </td>
    <td align="right"> $Restores[$i]{tarCreateErrs} </td>
    <td align="right"> $Restores[$i]{xferErrs} </td>
</tr>
EOF
    }
    if ( $restoreStr ne "" ) {
	$restoreStr = eval("qq{$Lang->{Restore_Summary}}");
    }
    if ( @Backups == 0 ) {
        $warnStr = $Lang->{This_PC_has_never_been_backed_up};
    }
    if ( defined($Hosts->{$host}) ) {
        my $user = $Hosts->{$host}{user};
	my @moreUsers = sort(keys(%{$Hosts->{$host}{moreUsers}}));
	my $moreUserStr;
	foreach my $u ( sort(keys(%{$Hosts->{$host}{moreUsers}})) ) {
	    $moreUserStr .= ", " if ( $moreUserStr ne "" );
	    $moreUserStr .= "${UserLink($u)}";
	}
	if ( $moreUserStr ne "" ) {
	    $moreUserStr = " ($Lang->{and} $moreUserStr).\n";
	} else {
	    $moreUserStr = ".\n";
	}
        if ( $user ne "" ) {
            $statusStr .= eval("qq{$Lang->{This_PC_is_used_by}$moreUserStr}");
        }
        if ( defined($UserEmailInfo{$user})
                && $UserEmailInfo{$user}{lastHost} eq $host ) {
            my $mailTime = timeStamp2($UserEmailInfo{$user}{lastTime});
            my $subj     = $UserEmailInfo{$user}{lastSubj};
            $statusStr  .= eval("qq{$Lang->{Last_email_sent_to__was_at___subject}}");
        }
    }
    if ( defined($Jobs{$host}) ) {
        my $startTime = timeStamp2($Jobs{$host}{startTime});
        (my $cmd = $Jobs{$host}{cmd}) =~ s/$BinDir\///g;
        $statusStr .= eval("qq{$Lang->{The_command_cmd_is_currently_running_for_started}}");
    }
    if ( $StatusHost{BgQueueOn} ) {
        $statusStr .= eval("qq{$Lang->{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon}}");
    }
    if ( $StatusHost{UserQueueOn} ) {
        $statusStr .= eval("qq{$Lang->{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon}}");
    }
    if ( $StatusHost{CmdQueueOn} ) {
        $statusStr .= eval("qq{$Lang->{A_command_for_host_is_on_the_command_queue_will_run_soon}}");
    }
    my $startTime = timeStamp2($StatusHost{endTime} == 0 ?
                $StatusHost{startTime} : $StatusHost{endTime});
    my $reason = "";
    if ( $StatusHost{reason} ne "" ) {
        $reason = " ($Lang->{$StatusHost{reason}})";
    }
    $statusStr .= eval("qq{$Lang->{Last_status_is_state_StatusHost_state_reason_as_of_startTime}}");

    if ( $StatusHost{state} ne "Status_backup_in_progress"
	    && $StatusHost{state} ne "Status_restore_in_progress"
	    && $StatusHost{error} ne "" ) {
        $statusStr .= eval("qq{$Lang->{Last_error_is____EscHTML_StatusHost_error}}");
    }
    my $priorStr = "Pings";
    if ( $StatusHost{deadCnt} > 0 ) {
        $statusStr .= eval("qq{$Lang->{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times}}");
        $priorStr = $Lang->{Prior_to_that__pings};
    }
    if ( $StatusHost{aliveCnt} > 0 ) {
        $statusStr .= eval("qq{$Lang->{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times}}");

        if ( $StatusHost{aliveCnt} >= $Conf{BlackoutGoodCnt}
		&& $Conf{BlackoutGoodCnt} >= 0 && $Conf{BlackoutHourBegin} >= 0
		&& $Conf{BlackoutHourEnd} >= 0 ) {
            my(@days) = qw(Sun Mon Tue Wed Thu Fri Sat);
            my($days) = join(", ", @days[@{$Conf{BlackoutWeekDays}}]);
            my($t0) = sprintf("%d:%02d", $Conf{BlackoutHourBegin},
                            60 * ($Conf{BlackoutHourBegin}
                                     - int($Conf{BlackoutHourBegin})));
            my($t1) = sprintf("%d:%02d", $Conf{BlackoutHourEnd},
                            60 * ($Conf{BlackoutHourEnd}
                                     - int($Conf{BlackoutHourEnd})));
            $statusStr .= eval("qq{$Lang->{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___}}");
        }
    }
    if ( $StatusHost{backoffTime} > time ) {
        my $hours = sprintf("%.1f", ($StatusHost{backoffTime} - time) / 3600);
        $statusStr .= eval("qq{$Lang->{Backups_are_deferred_for_hours_hours_change_this_number}}");

    }
    if ( @Backups ) {
        # only allow incremental if there are already some backups
        $startIncrStr = <<EOF;
<input type="submit" value="\$Lang->{Start_Incr_Backup}" name="action">
EOF
    }

    $startIncrStr = eval ("qq{$startIncrStr}");

    Header(eval("qq{$Lang->{Host__host_Backup_Summary}}"));
    print(eval("qq{$Lang->{Host__host_Backup_Summary2}}"));
    Trailer();
}

sub Action_GeneralInfo
{
    GetStatusInfo("info jobs hosts queueLen");
    my $Privileged = CheckPermission();

    my($jobStr, $statusStr);
    foreach my $host ( sort(keys(%Jobs)) ) {
        my $startTime = timeStamp2($Jobs{$host}{startTime});
        next if ( $host eq $bpc->trashJob
                    && $Jobs{$host}{processState} ne "running" );
        $Jobs{$host}{type} = $Status{$host}{type}
                    if ( $Jobs{$host}{type} eq "" && defined($Status{$host}));
        (my $cmd = $Jobs{$host}{cmd}) =~ s/$BinDir\///g;
        (my $xferPid = $Jobs{$host}{xferPid}) =~ s/,/, /g;
        $jobStr .= <<EOF;
<tr><td> ${HostLink($host)} </td>
    <td align="center"> $Jobs{$host}{type} </td>
    <td align="center"> ${UserLink(defined($Hosts->{$host})
					? $Hosts->{$host}{user} : "")} </td>
    <td> $startTime </td>
    <td> $cmd </td>
    <td align="center"> $Jobs{$host}{pid} </td>
    <td align="center"> $xferPid </td>
EOF
        $jobStr .= "</tr>\n";
    }
    foreach my $host ( sort(keys(%Status)) ) {
        next if ( $Status{$host}{reason} ne "Reason_backup_failed"
		    && $Status{$host}{reason} ne "Reason_restore_failed"
		    && (!$Status{$host}{userReq}
			|| $Status{$host}{reason} ne "Reason_no_ping") );
        my $startTime = timeStamp2($Status{$host}{startTime});
        my($errorTime, $XferViewStr);
        if ( $Status{$host}{errorTime} > 0 ) {
            $errorTime = timeStamp2($Status{$host}{errorTime});
        }
        if ( -f "$TopDir/pc/$host/SmbLOG.bad"
                || -f "$TopDir/pc/$host/SmbLOG.bad.z"
                || -f "$TopDir/pc/$host/XferLOG.bad"
                || -f "$TopDir/pc/$host/XferLOG.bad.z"
                ) {
            $XferViewStr = <<EOF;
<a href="$MyURL?action=view&type=XferLOGbad&host=${EscURI($host)}">$Lang->{XferLOG}</a>,
<a href="$MyURL?action=view&type=XferErrbad&host=${EscURI($host)}">$Lang->{Errors}</a>
EOF
        } else {
            $XferViewStr = "";
        }
        (my $shortErr = $Status{$host}{error}) =~ s/(.{48}).*/$1.../;   
        $statusStr .= <<EOF;
<tr><td> ${HostLink($host)} </td>
    <td align="center"> $Status{$host}{type} </td>
    <td align="center"> ${UserLink(defined($Hosts->{$host})
					? $Hosts->{$host}{user} : "")} </td>
    <td align="right"> $startTime </td>
    <td> $XferViewStr </td>
    <td align="right"> $errorTime </td>
    <td> ${EscHTML($shortErr)} </td></tr>
EOF
    }
    my $now          = timeStamp2(time);
    my $nextWakeupTime = timeStamp2($Info{nextWakeup});
    my $DUlastTime   = timeStamp2($Info{DUlastValueTime});
    my $DUmaxTime    = timeStamp2($Info{DUDailyMaxTime});
    my $numBgQueue   = $QueueLen{BgQueue};
    my $numUserQueue = $QueueLen{UserQueue};
    my $numCmdQueue  = $QueueLen{CmdQueue};
    my $serverStartTime = timeStamp2($Info{startTime});
    my $poolInfo     = genPoolInfo("pool", \%Info);
    my $cpoolInfo    = genPoolInfo("cpool", \%Info);
    if ( $Info{poolFileCnt} > 0 && $Info{cpoolFileCnt} > 0 ) {
        $poolInfo = <<EOF;
<li>Uncompressed pool:
<ul>
$poolInfo
</ul>
<li>Compressed pool:
<ul>
$cpoolInfo
</ul>
EOF
    } elsif ( $Info{cpoolFileCnt} > 0 ) {
        $poolInfo = $cpoolInfo;
    }

    Header($Lang->{H_BackupPC_Server_Status});
    print (eval ("qq{$Lang->{BackupPC_Server_Status}}"));
    Trailer();
}

sub Action_RestoreInfo
{
    my $Privileged = CheckPermission($In{host});
    my $host = $1 if ( $In{host} =~ /(.*)/ );
    my $num  = $In{num};
    my $i;

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_restore_information});
    }
    #
    # Find the requested restore
    #
    my @Restores = $bpc->RestoreInfoRead($host);
    for ( $i = 0 ; $i < @Restores ; $i++ ) {
        last if ( $Restores[$i]{num} == $num );
    }
    if ( $i >= @Restores ) {
        ErrorExit(eval("qq{$Lang->{Restore_number__num_for_host__does_not_exist}}"));
    }

    %RestoreReq = ();
    do "$TopDir/pc/$host/RestoreInfo.$Restores[$i]{num}"
	    if ( -f "$TopDir/pc/$host/RestoreInfo.$Restores[$i]{num}" );

    my $startTime = timeStamp2($Restores[$i]{startTime});
    my $reqTime   = timeStamp2($RestoreReq{reqTime});
    my $dur       = $Restores[$i]{endTime} - $Restores[$i]{startTime};
    $dur          = 1 if ( $dur <= 0 );
    my $duration  = sprintf("%.1f", $dur / 60);
    my $MB        = sprintf("%.1f", $Restores[$i]{size} / (1024*1024));
    my $MBperSec  = sprintf("%.2f", $Restores[$i]{size} / (1024*1024*$dur));

    my $fileListStr = "";
    foreach my $f ( @{$RestoreReq{fileList}} ) {
	my $targetFile = $f;
	(my $strippedShareSrc  = $RestoreReq{shareSrc}) =~ s/^\///;
	(my $strippedShareDest = $RestoreReq{shareDest}) =~ s/^\///;
	substr($targetFile, 0, length($RestoreReq{pathHdrSrc}))
					= $RestoreReq{pathHdrDest};
	$fileListStr .= <<EOF;
<tr><td>$RestoreReq{hostSrc}:/$strippedShareSrc$f</td><td>$RestoreReq{hostDest}:/$strippedShareDest$targetFile</td></tr>
EOF
    }

    Header(eval("qq{$Lang->{Restore___num_details_for__host}}"));
    print(eval("qq{$Lang->{Restore___num_details_for__host2 }}"));
    Trailer();
}
    
###########################################################################
# Miscellaneous subroutines
###########################################################################

sub timeStamp2
{
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
              = localtime($_[0] == 0 ? time : $_[0] );
    $year += 1900;
    $mon++;
    if ( $Conf{CgiDateFormatMMDD} ) {
        return sprintf("$mon/$mday %02d:%02d", $hour, $min);
    } else {
        return sprintf("$mday/$mon %02d:%02d", $hour, $min);
    }
}

sub HostLink
{
    my($host) = @_;
    my($s);
    if ( defined($Hosts->{$host}) || defined($Status{$host}) ) {
        $s = "<a href=\"$MyURL?host=${EscURI($host)}\">$host</a>";
    } else {
        $s = $host;
    }
    return \$s;
}

sub UserLink
{
    my($user) = @_;
    my($s);

    return \$user if ( $user eq ""
                    || $Conf{CgiUserUrlCreate} eq "" );
    if ( $Conf{CgiUserHomePageCheck} eq ""
            || -f sprintf($Conf{CgiUserHomePageCheck}, $user, $user, $user) ) {
        $s = "<a href=\""
             . sprintf($Conf{CgiUserUrlCreate}, $user, $user, $user)
             . "\">$user</a>";
    } else {
        $s = $user;
    }
    return \$s;
}

sub EscHTML
{
    my($s) = @_;
    $s =~ s/&/&amp;/g;
    $s =~ s/\"/&quot;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/</&lt;/g;
    $s =~ s{([^[:print:]])}{sprintf("&\#x%02X;", ord($1));}eg;
    return \$s;
}

sub EscURI
{
    my($s) = @_;
    $s =~ s{([^\w.\/-])}{sprintf("%%%02X", ord($1));}eg;
    return \$s;
}

sub ErrorExit
{
    my(@mesg) = @_;
    my($head) = shift(@mesg);
    my($mesg) = join("</p>\n<p>", @mesg);
    $Conf{CgiHeaderFontType} ||= "arial"; 
    $Conf{CgiHeaderFontSize} ||= "3";  
    $Conf{CgiNavBarBgColor}  ||= "#ddeeee";
    $Conf{CgiHeaderBgColor}  ||= "#99cc33";

    if ( !defined($ENV{REMOTE_USER}) ) {
	$mesg .= <<EOF;
<p>
Note: \$ENV{REMOTE_USER} is not set, which could mean there is an
installation problem.  BackupPC_Admin expects Apache to authenticate
the user and pass their user name into this script as the REMOTE_USER
environment variable.  See the documentation.
EOF
    }

    $bpc->ServerMesg("log User $User (host=$In{host}) got CGI error: $head")
                            if ( defined($bpc) );
    if ( !defined($Lang->{Error}) ) {
	Header("BackupPC: Error");
        if ( !defined($mesg) ) {
$mesg = <<EOF                 
There is some problem with the BackupPC installation.
Please check the permissions on BackupPC_Admin.
EOF
        }

	print <<EOF;
${h1("Error: Unable to read config.pl or language strings!!")}
<p>$mesg</p>
EOF
	Trailer();
    } else {
	Header(eval("qq{$Lang->{Error}}"));
	print (eval("qq{$Lang->{Error____head}}"));
	Trailer();
    }
    exit(1);
}

sub ServerConnect
{
    #
    # Verify that the server connection is ok
    #
    return if ( $bpc->ServerOK() );
    $bpc->ServerDisconnect();
    if ( my $err = $bpc->ServerConnect($Conf{ServerHost}, $Conf{ServerPort}) ) {
        ErrorExit(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"));
    }
}

sub GetStatusInfo
{
    my($status) = @_;
    ServerConnect();
    my $reply = $bpc->ServerMesg("status $status");
    $reply = $1 if ( $reply =~ /(.*)/s );
    eval($reply);
    # ignore status related to admin and trashClean jobs
    if ( $status =~ /\bhosts\b/ ) {
        delete($Status{$bpc->adminJob});
        delete($Status{$bpc->trashJob});
    }
}

sub ReadUserEmailInfo
{
    if ( (stat("$TopDir/log/UserEmailInfo.pl"))[9] != $UserEmailInfoMTime ) {
        do "$TopDir/log/UserEmailInfo.pl";
        $UserEmailInfoMTime = (stat("$TopDir/log/UserEmailInfo.pl"))[9];
    }
}

#
# Check if the user is privileged.  A privileged user can access
# any information (backup files, logs, status pages etc).
#
# A user is privileged if they belong to the group
# $Conf{CgiAdminUserGroup}, or they are in $Conf{CgiAdminUsers}
# or they are the user assigned to a host in the host file.
#
sub CheckPermission
{
    my($host) = @_;
    my $Privileged = 0;

    return 0 if ( $User eq "" && $Conf{CgiAdminUsers} ne "*"
	       || $host ne "" && !defined($Hosts->{$host}) );
    if ( $Conf{CgiAdminUserGroup} ne "" ) {
        my($n,$p,$gid,$mem) = getgrnam($Conf{CgiAdminUserGroup});
        $Privileged ||= ($mem =~ /\b$User\b/);
    }
    if ( $Conf{CgiAdminUsers} ne "" ) {
        $Privileged ||= ($Conf{CgiAdminUsers} =~ /\b$User\b/);
        $Privileged ||= $Conf{CgiAdminUsers} eq "*";
    }
    $PrivAdmin = $Privileged;
    $Privileged ||= $User eq $Hosts->{$host}{user};
    $Privileged ||= defined($Hosts->{$host}{moreUsers}{$User});

    return $Privileged;
}

#
# Returns the list of hosts that should appear in the navigation bar
# for this user.  If $Conf{CgiNavBarAdminAllHosts} is set, the admin
# gets all the hosts.  Otherwise, regular users get hosts for which
# they are the user or are listed in the moreUsers column in the
# hosts file.
#
sub GetUserHosts
{
    if ( $Conf{CgiNavBarAdminAllHosts} && CheckPermission() ) {
       return sort keys %$Hosts;
    }

    return sort grep { $Hosts->{$_}{user} eq $User ||
                       defined($Hosts->{$_}{moreUsers}{$User}) } keys(%$Hosts);
}

#
# Given a host name tries to find the IP address.  For non-dhcp hosts
# we just return the host name.  For dhcp hosts we check the address
# the user is using ($ENV{REMOTE_ADDR}) and also the last-known IP
# address for $host.  (Later we should replace this with a broadcast
# nmblookup.)
#
sub ConfirmIPAddress
{
    my($host) = @_;
    my $ipAddr = $host;

    if ( defined($Hosts->{$host}) && $Hosts->{$host}{dhcp}
	       && $ENV{REMOTE_ADDR} =~ /^(\d+[\.\d]*)$/ ) {
	$ipAddr = $1;
	my($netBiosHost, $netBiosUser) = $bpc->NetBiosInfoGet($ipAddr);
	if ( $netBiosHost ne $host ) {
	    my($tryIP);
	    GetStatusInfo("host(${EscURI($host)})");
	    if ( defined($StatusHost{dhcpHostIP})
			&& $StatusHost{dhcpHostIP} ne $ipAddr ) {
		$tryIP = eval("qq{$Lang->{tryIP}}");
		($netBiosHost, $netBiosUser)
			= $bpc->NetBiosInfoGet($StatusHost{dhcpHostIP});
	    }
	    if ( $netBiosHost ne $host ) {
		ErrorExit(eval("qq{$Lang->{Can_t_find_IP_address_for}}"),
		          eval("qq{$Lang->{host_is_a_DHCP_host}}"));
	    }
	    $ipAddr = $StatusHost{dhcpHostIP};
	}
    }
    return $ipAddr;
}

sub genPoolInfo
{
    my($name, $info) = @_;
    my $poolSize   = sprintf("%.2f", $info->{"${name}Kb"} / (1000 * 1024));
    my $poolRmSize = sprintf("%.2f", $info->{"${name}KbRm"} / (1000 * 1024));
    my $poolTime   = timeStamp2($info->{"${name}Time"});
    $info->{"${name}FileCntRm"} = $info->{"${name}FileCntRm"} + 0;
    return eval("qq{$Lang->{Pool_Stat}}");
}

###########################################################################
# HTML layout subroutines
###########################################################################

sub Header
{
    my($title) = @_;
    my @adminLinks = (
        { link => "",                          name => $Lang->{Status},
                                               priv => 1},
        { link => "?action=summary",           name => $Lang->{PC_Summary} },
        { link => "?action=view&type=LOG",     name => $Lang->{LOG_file} },
        { link => "?action=LOGlist",           name => $Lang->{Old_LOGs} },
        { link => "?action=emailSummary",      name => $Lang->{Email_summary} },
        { link => "?action=view&type=config",  name => $Lang->{Config_file} },
        { link => "?action=view&type=hosts",   name => $Lang->{Hosts_file} },
        { link => "?action=queue",             name => $Lang->{Current_queues} },
        { link => "?action=view&type=docs",    name => $Lang->{Documentation},
                                               priv => 1},
        { link => "http://backuppc.sourceforge.net/faq", name => "FAQ",
                                               priv => 1},
        { link => "http://backuppc.sourceforge.net", name => "SourceForge",
                                               priv => 1},
    );
    
	if ($InWebmin == 1) {
		use vars qw/$VERSION/;
		
		my $customtitle=$title;
		$customtitle =~ s|^Backuppc: (.*)|LRS : $1|i;			# shorter title
		$customtitle =~ s|([^/]*).*/(.*)|$1 $2|;			# shorter title
		if (length($customtitle)>30) {  				# max 30 characters in header
			$customtitle=substr($customtitle, 0, 30)." ...";
		}
		
		lbs_common::print_header($customtitle, "index", $VERSION);
		
		require "backuppc-tabs.pl";
		# determine the tab to be highlighted
		my $no_tab = 1;
		my $label_tab = ['backuppc', 'backuppc_machine'];

		if ($In{general} == 1) {
			if (!($In{action} eq "summary")) {
				$no_tab = 2;
				$label_tab = ['list_of_machines', 'files_backup'];
			}
		} else {
			if ( $In{type} eq "LOG" ) {
				$no_tab = 3;
				$label_tab = ['backuppc', 'log_file'];
			} elsif ( $In{type} eq "LOGlist" ) {
				$no_tab = 4;
				$label_tab = ['backuppc', 'old_logs'];
			} elsif ( $In{type} eq "XferLOGbad" ) {
				$no_tab = 5;
				$label_tab = ['backuppc', 'badxfer_log'];
			} elsif ( $In{type} eq "XferErrbad" ) {
				$no_tab = 6;
				$label_tab = ['backuppc', 'error_log'];
			}
		}

		if ($lbs) { # print the tabs
			lbs_common::print_html_tabs($label_tab, {'mac' => $In{mac}});
		} else {
			&backuppc_tabs($no_tab, $In{host}, $In{general}, $lbs);
		}
	} else {
 print $Cgi->header();
    print <<EOF;
<!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>$title</title>
$Conf{CgiHeaders}
</head><body bgcolor="$Conf{CgiBodyBgColor}">
<table cellpadding="0" cellspacing="0" border="0">
<tr valign="top"><td valign="top" bgcolor="$Conf{CgiNavBarBgColor}" width="10%">
EOF
   }
if ($In{general} == 1 || $InWebmin != 1) {
    print <<EOF;
<table cellpadding="0" cellspacing="0" border="0">
<tr valign="top">
<td valign="top" bgcolor="$Conf{CgiNavBarBgColor}" width="10%">
EOF
    NavSectionTitle("BackupPC");
  if ($InWebmin != 1) {
    print "&nbsp;\n";
    if ( defined($In{host}) && defined($Hosts->{$In{host}}) ) {
        my $host = $In{host};
        NavSectionTitle( eval("qq{$Lang->{Host_Inhost}}") );
        NavSectionStart();
        NavLink("?host=${EscURI($host)}", $Lang->{Home});
        NavLink("?action=view&type=LOG&host=${EscURI($host)}", $Lang->{LOG_file});
        NavLink("?action=LOGlist&host=${EscURI($host)}", $Lang->{Old_LOGs});
        if ( -f "$TopDir/pc/$host/SmbLOG.bad"
                    || -f "$TopDir/pc/$host/SmbLOG.bad.z"
                    || -f "$TopDir/pc/$host/XferLOG.bad"
                    || -f "$TopDir/pc/$host/XferLOG.bad.z" ) {
            NavLink("?action=view&type=XferLOGbad&host=${EscURI($host)}",
                                $Lang->{Last_bad_XferLOG});
            NavLink("?action=view&type=XferErrbad&host=${EscURI($host)}",
                                $Lang->{Last_bad_XferLOG_errors_only});
        }
        if ( -f "$TopDir/pc/$host/config.pl" || -f "/etc/backuppc/$host.pl" ) {
            NavLink("?action=view&type=config&host=${EscURI($host)}", $Lang->{Config_file});
        }
        NavSectionEnd();
    }
    NavSectionTitle($Lang->{Hosts});
    if ( defined($Hosts) && %$Hosts > 0 ) {
        NavSectionStart(1);
        foreach my $host ( GetUserHosts() ) {
            NavLink("?host=${EscURI($host)}", $host);
        }
        NavSectionEnd();
    }
    print <<EOF;
<table cellpadding="2" cellspacing="0" border="0" width="100%">
    <tr><td>$Lang->{Host_or_User_name}</td>
    <tr><td><form action="$MyURL" method="get"><small>
    <input type="text" name="host" size="10" maxlength="64">
    <input type="hidden" name="action" value="hostInfo"><input type="submit" value="$Lang->{Go}" name="ignore">
    </small></form></td></tr>
</table>
EOF
  }
    NavSectionTitle($Lang->{NavSectionTitle_});
    NavSectionStart();
    foreach my $l ( @adminLinks ) {
        if ( $PrivAdmin || $l->{priv} ) {
            NavLink($l->{link}, $l->{name});
        } else {
            NavLink(undef, $l->{name});
       }
    }
    NavSectionEnd();
    print <<EOF;
</td><td valign="top" width="5">&nbsp;&nbsp;</td>
<td valign="top" width="90%">
EOF
  }
}

sub Trailer
{
  if ($InWebmin == 1) {
     print <<EOF;
</td></table>
EOF
#  if ($InLBS == 1) {
     menuEnd($In{general}, $lbs);
#  }
   &footer("/",$text{'index'});
 } else {
   print <<EOF;
</td></table>
</body></html>
EOF
  }
}


sub NavSectionTitle
{
    my($head) = @_;
    print <<EOF;
<table cellpadding="2" cellspacing="0" border="0" width="100%">
<tr><td bgcolor="$Conf{CgiHeaderBgColor}"><font face="$Conf{CgiHeaderFontType}"
size="$Conf{CgiHeaderFontSize}"><b>$head</b>
</font></td></tr>
</table>
EOF
}

sub NavSectionStart
{
    my($padding) = @_;

    $padding = 1 if ( !defined($padding) );
    print <<EOF;
<table cellpadding="$padding" cellspacing="0" border="0" width="100%">
EOF
}

sub NavSectionEnd
{
    print "</table>\n";
}

sub NavLink
{
    my($link, $text) = @_;
    print "<tr><td width=\"2%\" valign=\"top\"><b>&middot;</b></td>";
    if ( defined($link) ) {
        $link = "$MyURL$link" if ( $link eq "" || $link =~ /^\?/ );
        print <<EOF;
<td width="98%"><a href="$link"><small>$text</small></a></td></tr>
EOF
    } else {
        print <<EOF;
<td width="98%"><small>$text</small></td></tr>
EOF
    }
}

sub h1
{
    my($str) = @_;
    return \<<EOF;
<table cellpadding="2" cellspacing="0" border="0" width="100%">
<tr>
<td bgcolor="$Conf{CgiHeaderBgColor}">&nbsp;<font face="$Conf{CgiHeaderFontType}"
    size="$Conf{CgiHeaderFontSize}"><b>$str</b></font>
</td></tr>
</table>
EOF
}

sub h2
{
    my($str) = @_;
    return \<<EOF;
<table cellpadding="2" cellspacing="0" border="0" width="100%">
<tr>
<td bgcolor="$Conf{CgiHeaderBgColor}">&nbsp;<font face="$Conf{CgiHeaderFontType}"
    size="$Conf{CgiHeaderFontSize}"><b>$str</b></font>
</td></tr>
</table>
EOF
}
