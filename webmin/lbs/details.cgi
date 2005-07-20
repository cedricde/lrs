#!/usr/bin/perl
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
use vars qw (%access %config %in %lbsconf %text $VERSION $POSTINST_PATH);
# get some common functions ...
require "lbs.pl";

lbs_common::init_lbs_conf() or exit(0) ;
ReadParse() ;

my $lbs_home = $lbs_common::lbsconf{'basedir'};
my $redir;
my $conf=$in{'conf'};

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;


# L'utilisateur a t-il le droit d'effectuer des modifs?
error( $text{'acl_error'} ) if ($access{'modify'});

# Affichage du formulaire de modif

redirect($redir) if (exists $in{'cancel'});

redirect("postinst.cgi?modify=$text{'but_edit'}&file=$POSTINST_PATH/$in{'postinst'}") if (exists $in{'editconfpost'} and $in{'postinst'} ne "NULL");
redirect("postinst.cgi") if (exists $in{'editconfpost'});

lbs_common::print_header( $text{'tit_details'}, "index", $VERSION);

if ($in{'conf'} =~ /imgbase/) {
	lbs_common::print_html_tabs(['system_backup', 'details']);
} else {
	lbs_common::print_html_tabs(['system_backup', 'details']);
	# tabs(1);    	# FIXME
}

bootmenu_save_edit_conf($conf, $lbs_home);
bootmenu_save_postinst($conf, $lbs_home);

$conf =~ m|([^/]+)/?$|;
print "<h1><center>$text{lab_image} $1</center></h1>\n";

if ( $in{'full'} && $in{'full'} == 1) {
	bootmenu_show_full_logs($conf, $lbs_home);
} else {
	&bootmenu_show_edit_conf($conf, $lbs_home);
	&bootmenu_show_postinst($conf, $lbs_home) if -x "$lbs_home/lib/util/captive/usr/bin/captive-lufsmnt";
	&bootmenu_show_logs($conf, $lbs_home);
}

# end of tabs
lbs_common::print_end_menu();
lbs_common::print_end_menu();

footer("", $text{'index'}) ;

######## functions #########

#
# showEditConf ( $desc )
#
sub bootmenu_show_edit_conf {
my ($conf, $lbs_home) = @_ ;
my ($ch, $type, $ll, $file);
my (@lol, @active, @desc, @view, %tabattr);
my @toprow = ("&nbsp;", $text{lab_datarestored});
my $lines = read_file_lines("$lbs_home/$conf/conf.txt");
my $i = -1;
my $lastsize = 0;
my $lrsgznbd = 0;


if ( -x "$lbs_home/bin/lrsgznbd" ) { $lrsgznbd = 1; }

if ($lrsgznbd) { push @toprow, "View"; }
	
	foreach my $line (@$lines) {
		$i++;
		if ($line =~ /\(hd.*?\) (\d+) (\d+)/) {
		  # save partition size
		  $lastsize = int(($2-$1)/2048);
		}

		if ($line =~ /partcopy \(hd(\d+),-?(\d+)\) (\d+) PATH\/(\w+) ?(\S*)/) {      	# PARTCOPY line
			my $disk = $1 + 1;
			my $part = $2 + 1;
			$file = $4;
			if ($1 >= 3968) {
				$part = "LVM";
				$disk = "$5";
				$disk =~ s/mapper\///;
				$type = "LVM"
			}
			push @desc, text("msg_conf_partcopy", $part, $disk, parttype($type))." &nbsp ".$lastsize." MiB";
		} elsif ($line =~ /ptabs \(hd([0-9]+)/) {       		# PTABS line
			push @desc, text("msg_conf_ptabs", $1+1);
		} else {        						# save partition type for later
			$type = $1 if ($line =~ /\# \(hd\d+,\d+\) \d+ \d+ (\w+)/);
			next;
		}

		if ($line =~ /^\#(DIS)?/) {
			$ch = ""
		} else {
			$ch = "checked"
		}

		push @active, "<input type='checkbox' name='line$i' value='1' $ch>";
		$ll .= "line$i ";
		
		if ($lrsgznbd) {
		    if ($type == 131 || $type == 7) {
			push @view, "<a href=\"mountpart.cgi?part=$in{conf}/$file\">View !</a>";
		    } else {
			push @view, "&nbsp;";
		    }
		}
		
		$type = "";

	}

        my ($siz, $dummy) = split ' ', `du -m $lbs_home/$conf`;
	print "<h3>$text{'tit_imagesize'} : $siz</h3>";
	print "<h3>$text{'tit_restorechoose'}</h3>";
	
	if ($lrsgznbd) { push @lol, [@active], [@desc], [@view]; }
	else  { push @lol, [@active], [@desc]; }
	lbs_common::lolRotate( \@lol );

	$tabattr{'center'} = 0;
	
	print "<form method=\"post\"><div align='left'>";
	print lbs_common::make_html_table("", \@toprow, \@lol, \%tabattr);
	print "<input type='hidden' name='lines' value='$ll'>";
	print "<input type='submit' name='saveconf' value='OK'>";
	print "</div></form>";
}

#
# showLogs ( $config_file_dir )
#
sub bootmenu_show_logs {
	my ($conf, $lbs_home) = @_ ;
	my ($ch, $type, $ll);
	my (@lol, @active, @desc);
	my $lines = read_file_lines("$lbs_home/$conf/log.txt");
	my $error = 0;
	
	print "<h3>$text{'tit_showlogs'}</h3>";
	
	if(@$lines < 10) { $error=1 };
	foreach my $l (@$lines) {       				# gather errors
		$error=1 if ($l =~ /^ERROR:/ || $l =~ /image_error/);
	}

	if ($error) {
		print<<EOF
	<font color="red">
	$text{'msg_save_error'}
	</font>
EOF
	} else {
		print<<EOF
		<font color="green">
		$text{'msg_save_noerror'}
		</font>
EOF
	}

print<<EOF
( <a href="details.cgi?conf=$in{'conf'}&full=1&mac=$in{'mac'}">$text{'msg_save_log'}</a> )
<br><br>
EOF

}
