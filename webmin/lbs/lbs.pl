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
# Including the common functions
require '../web-lib.pl';
require './lbs-lib.pl';
require './lbs-part.pl';

# some init
init_config();

use vars qw($tb $cb @parttype %module_info %text %in);

our $VERSION='$Rev$';
$VERSION =~ s/\$Rev: (\d+) \$/$module_info{version} (r.$1)/;

our $POSTINST_PATH='images/templates';

# get the good module
foreign_require("lbs_common", "lbs_common.pl");

#
# Convert a partition number to a string
#
sub parttype {
    my $n = shift;
    return $n if ($n == 0);
    return $parttype[$n];
}

# printBaseForm(\%busage, \%btitle, \%bdesc, \%bstat)
# %busage: clefs=noms des images, vals=noms des postes (type liste).
# %btitle: clefs=noms des images, vals=titre
# %bdesc:  clefs=noms des images, vals=description
# %bstat:  clefs=noms des images, vals=status (0,1 ou 2)
sub images_base_usage {
my $lbs_home = $lbs_common::lbsconf{"basedir"} ;
my $img_base = $lbs_home."/imgbase";
my ($busage,$btitle,$bdesc,$bstat,$imgdir) = @_ ;
my (@lol, @lsdel, @lsused, @lsdesc, @lstitle,@sizes,@burn,@details) ;
my %tabattr ; 

my $delicon;    							# « delete » icon
my @images;
my @toprow = (
	$text{'lab_baseimg'},
	$text{'lab_title'},
	$text{'lab_desc'},
	$text{'lab_usedby'},
	$text{'lab_size'},
	$text{'lab_rm'},
	$text{'lab_burn'},
	$text{'lab_details'},
	);

	foreach my $k (sort(keys %{$busage})) { # for each usage
		my @ls = @{$$busage{$k}} ;
		my $size = scalar(@ls);
		my @uls=();
		
		push @images, $k ;
	
		if (not $size) {					# if there are no images attached
			$delicon = "trash.gif";
			@uls = ( $text{"lab_none"} ) ;
		} else {						# else we built an anchor list
			$delicon = "cross.gif";
			foreach my $i (@ls) {
				$i = "<a href=\"bootmenu.cgi?name=".urlize($i) ."\" style=\"text-decoration:none\">$i</a>" ;
				push @uls,$i ;
			}
		}
	
		push @lsused, "<small>" . join("<br>", @uls) . "</small>" ;# which we attach with som "<br>" between each

		push @lsdel,
			"<center>"
			."<a href=\"imgbase.cgi?imgbase="
			.urlize($k)
			."\">"
			."<img src=\"images/$delicon\" "
			."border=no alt=\""
			.$text{'lab_rm'}
			." $k\"></a></center>" ;

		push @lstitle, $$btitle{$k} ;
		
		push @lsdesc, lbs_common::colorStatus($$bstat{$k},$$bdesc{$k});
		
		my ($siz, $dummy) = split ' ', `du -h $imgdir/$k`;

		if ( ($siz =~ m/\d+k/i) || ($siz =~ m/\d+o/i)) {	# images below 1 MB aren't shown
			push @burn, "<center>&nbsp;</center>";
			push @details, "<center>&nbsp;</center>";	    
		} else {
			push @burn, "<center><a href='/lbs-cd/?dir=".urlize($lbs_home."/imgbase/$k/")."'><img border=1 src='images/burn.gif'></a></center>";
			push @details, "<center><a href='details.cgi?conf=".urlize("/imgbase/$k/")."&mac=".urlize($in{'mac'})."'><img border=1 src='images/detail.gif'></a></center>";	    
		}

		$siz="<div align=right>$siz</div>";
		push @sizes, $siz ;
	}

        push @lol, [ @images ],[ @lstitle ],[ @lsdesc ],[ @lsused ], [@sizes],[ @lsdel ], [@burn], [@details] ;
        lbs_common::lolRotate(\@lol) ;
  
	%tabattr = (
		"rotate"	=> 0 ,
		"tr_header"	=> $tb ,
		"tr_body"	=> $cb ,
	) ;
        print lbs_common::make_html_table("", \@toprow, \@lol, \%tabattr) ;
		
}

# print_confirmation_form ($action, $mesg, [$hidden_name1, $hidden_val1, ...] )
#
sub print_confirmation_form {
my $action = shift ;
my $mesg = shift ;
my $buf = "" ;

my $but_apply = $text{'but_apply'} ;
my $but_cancel = $text{'but_cancel'} ;

while (defined($_[0]) and defined($_[1])) {
	$buf .= sprintf "   <input type=hidden name=\"%s\" value=\"%s\">\n", shift(@_), shift(@_) ;
}

print <<EOF ;
	$mesg
	<p>
	<form action="$action">
		$buf
		<input type=hidden name=form value="confirm">
		<input type=submit name=apply value="$but_apply">
		<input type=submit name=cancel value="$but_cancel">
	</form>
	</p>
EOF

}

# print_description_form ($action, $mesg, $mac, $conf, $title )
#
sub print_description_form {
my ($action, $mesg, $mac, $conf, $title, $redir_flag, $label) = @_ ;

$title = html_escape($title) ;

my $but_apply = $text{'but_apply'} ;
my $but_cancel = $text{'but_cancel'} ;
my $lab_title = $text{$label} ;

print <<EOF;
<p>$mesg</p>
<form action="$action">
   <input type=hidden name=mac value="$mac">
   <input type=hidden name=conf value="$conf">
   <input type=hidden name=form value="title">
   <input type=hidden name=redir_flag value="$redir_flag">
   <b>$lab_title:</b> <input name=title size=50 value="$title"><br><br>
   <input type=submit name=apply value="$but_apply">
   <input type=submit name=cancel value="$but_cancel">
</form>
EOF

}


#
# comment/uncomment conf.txt lines
#
sub bootmenu_save_edit_conf {
my ($conf, $lbs_home)=@_;

my $lines = read_file_lines("$lbs_home/$conf/conf.txt");
	foreach my $line (split / /, $in{lines}) {
		$line =~ /line([0-9]+)/;
		my $num = $1;
		
		if ($in{$line} eq "1") {
			$$lines[$num] =~ s/^\#(DIS)? //;
		} else {
			$$lines[$num] =~ s/^([^\#])/\#DIS $1/;
		}
	}
	
	flush_file_lines();
}

#
# Enable/disable postinst scripts
#
sub bootmenu_save_postinst {
  my ($conf, $lbs_home)=@_;

  $conf =~ s/\/$//;
  if (!exists $in{saveconfpost}) { return; }
  if ($in{postinst}) {
    if ($in{postinst} eq "NULL") {
      system("rm -f $lbs_home/$conf/postinst.desc 2>/dev/null");
      system("mv -f $lbs_home/$conf/postinst  $lbs_home/$conf/postinst.dis 2>/dev/null");
      # remove from conf.txt
      if (-r "$lbs_home/$conf/conf.txt") {
	my $data;
	fileLoad("$lbs_home/$conf/conf.txt", \$data);
	$data =~ s/(\#DISPOST\s*)//mg;
	$data =~ s/kernel \(nd\).*//m;
	$data =~ s/initrd \(nd\).*//m;
	$data =~ s/setdefault .*//;
	$data =~ s/\s*$/\n/;
	fileSave("$lbs_home/$conf/conf.txt", \$data);
      }
    } else {
      if ( -r "$lbs_home/images/templates/$in{postinst}") {
	system("echo '$in{postinst}' > $lbs_home/$conf/postinst.desc");
	system("cp -f $lbs_home/images/templates/$in{postinst} $lbs_home/$conf/postinst");
	# add to conf.txt
	if (-r "$lbs_home/$conf/conf.txt") {
	  # insert postinstall instructions
	  my $data;
	  fileLoad("$lbs_home/$conf/conf.txt", \$data);
	  # add the image info
	  if (!($data =~ /\#DISPOST/)) {
	    $data =~ s/^(\s*chainloader.*)/\#DISPOST $1/m;
	    $data =~ s/^(\s*root \(hd.*)/\#DISPOST $1/m;
	    $data .= "\nkernel (nd)/tftpboot/revoboot/bin/bzImage.initrd revosavedir=$conf revopost quiet\n";
	    $data .= "initrd (nd)/tftpboot/revoboot/bin/initrd.gz\n";
	    $data .= "setdefault 0\n";
	  }
	  fileSave("$lbs_home/$conf/conf.txt", \$data);
	}
      }
    }
  }
}


#
# list_postinst_templates ($lbs_ho;e)
#
# Returns a LoL containing information about available postinstall files:
# [ [ "filename1", "description1", "contents1"], 
#   [ "filename2", "description2", "contents2"] ... ]
#
sub list_postinst_templates {
  my ($lbs_home) = @_;
  my @tmpl;
  my @files;

  use vars qw ($current_lang);

  push @tmpl, [ ("NULL", "Pas de postinstall", "") ];

  opendir(DIR, $lbs_home."/images/templates/") || return @tmpl;
  @files = grep { /^[^\.][^~]+$/ && -r $lbs_home."/images/templates/".$_ } readdir(DIR);
  closedir DIR;

  foreach my $file (sort @files) {
    my $desc = "unknown";
    my $lines = read_file_lines($lbs_home."/images/templates/".$file);
    # contents of the file
    my $con = join ("\n", @$lines);
    if ($con =~ /^\# (.*)/) {
      $desc = $1;
    }
    if ($current_lang) {
      if ($con =~ /\# desc_$current_lang:(.*)/) {
	$desc = $1;
      }
    }
    chomp($desc);
    push @tmpl, [ ( $file, $desc, $con) ];
  }
  return @tmpl;
}

#
# showFullLog ( $config_file_dir )
#
sub bootmenu_show_full_logs {
  my ($conf, $lbs_home) = @_ ;

# CSS vars
my $log_normal_style	= "color : black;";
my $log_title_style	= "font-size: 16px;";
my $log_warn_style	= "color: #A0A000;";
my $log_info_style	= "color: green;";
my $log_notice_style	= "color: blue;";
my $log_debug_style	= "color: darkgrey;";
my $log_error_style	= "color: orange;";

# let's print the wanted logs
open LOG, "$lbs_home/$conf/log.txt";

while (<LOG>) {
	if (m/^(\w{3} [ :0-9]{11}) (\(none\)) ([^ ]+)\.([^ ]+) (.*)$/) { 		# the five parts of a log file:
										# <timestamp> <hostnam> <daemon>.<level> <message> 	
		#      print "<tt style=\"".html_escape($log_normal_style)."\">$1</tt>";
		#      print "<tt style=\"".html_escape($log_normal_style)."\">$2</tt>";
		print "<tt style=\"".html_escape($log_normal_style)."\">$3.$4 </tt>";
		
		my $level=$4;
		my $message=$5;	
		if ($level =~ m/warn/) {
			print "<tt style=\"".html_escape($log_warn_style)."\">$message</tt>";
		} elsif ($level =~ m/info/) {
			print "<tt style=\"".html_escape($log_info_style)."\">$message</tt>";
		} elsif ($level =~ m/notice/) {
			print "<tt style=\"".html_escape($log_notice_style)."\">$message</tt>";
		} elsif ($level =~ m/debug/) {
			print "<tt style=\"".html_escape($log_debug_style)."\">$message</tt>";
		} elsif ($level =~ m/err/) {
			print "<tt style=\"".html_escape($log_error_style)."\">$message</tt>";
		} else {
			print "<tt style=\"".html_escape($log_normal_style)."\">$message</tt>";
		}
	} elsif (m/^(\={4}.*\={4})$/) {					# entête de section 
		print "<tt style=\"".html_escape($log_title_style)."\">$1</tt> ";
	} else {								# autre ligne
		print "<tt style=\"".html_escape($log_normal_style)."\">$_</tt> ";
	}
	print "<br />";    
}
  
close LOG;
 
}

# void printBootMenuForm($mac, $default, \@items, \@titles, \@presel, \@desc, \@status)
# args:
#   $mac: adresse MAC la machine
#   $default: identitiant du menu par defaut.
#   \@items: ref de la liste des identifiants (les sections 'menu').
#   \@titles: ref de la liste des titres (titles) du menu utilisateur.
#   \@presel: ref de la liste des items a preselectionner.
#   \@desc: ref de la liste des descriptions des items.
#   \@status: ref de la liste du statut de chaque menu item.
#
sub print_bootmenu_form {
my $firstarg= $_[0];
my $default = $_[1];
my $items   = $_[2];
my $titles  = $_[3];
my $presel  = $_[4] ? $_[4] : [];
my $desc    = $_[5];
my $status  = $_[6];
my $i;
my $item;
my $menuchk    = "";
my $defaultchk = "";
my $st;

my ($mac, $group, $profile)=($firstarg->{'mac'}, $firstarg->{'group'}, $firstarg->{'profile'});

my $umac = urlize($mac);    # Fonction Webmin.
my $umenu;
my $decor;

my @toprow = (
$text{'lab_defchoice'}, $text{'lab_display'},
$text{'lab_menu'},      $text{'lab_desc'}
);
my ( @lol, @radio, @check );

# Texte des boutons
my $but_apply      = $text{'but_apply'};
my $but_return     = $text{'but_return'};

# Attributs de la table:
my %tabattr = (
	'rotate'    => 0,
	'tr_header' => $tb,
	'tr_body'   => $cb,
	'border'    => "border=1 width='100%'",
);
	# Le tableau des menus
	print "<center>\n";
	
	print "<form action=\"bootmenu.cgi\">";

	for ( $i = 0 ; $i < scalar( @{$items} ) ; $i++ ) {
		$item = $$items[$i];
		$st   = $$status[$i];
		
		if ( $st == 0 ) {# Good status:
			$defaultchk = "";
			$defaultchk = "checked" if ( $item eq $default );
			
			$menuchk = "";
			$menuchk = "checked" if ( grep { $item eq $_ } @$presel );
			
			push @radio, "<input type=radio name=default value=\"$item\" $defaultchk>";
			push @check, "<input type=checkbox name=menu value=\"$item\" $menuchk>";
			
			# Convertion de la description en hyperlien.
			# On utilise un attribut de style pour ne pas que ces liens
			# soient soulignes.
			#
			$decor = 'style="text-decoration:none"';
			$umenu = urlize($item);
			
			$$desc[$i] = "<a href=\"desc.cgi?mac=$umac&obj=desc&menu=$umenu\" $decor>" . html_escape( $$desc[$i] ) . "</a>";
			
			$$titles[$i] = "<a href=\"title.cgi?mac=$umac&obj=title&menu=$umenu\" $decor>" . html_escape( $$titles[$i] ) . "</a>";
		} else { # Bad status:
			push @radio, "&nbsp;";
			push @check, "&nbsp;";
			$$titles[$i] = lbs_common::colorStatus( $st, html_escape( $$titles[$i] ) );
			$$desc[$i]   = lbs_common::colorStatus( $st, html_escape( $$desc[$i] ) );
		}
	}

        
	push @lol, [@radio], [@check], [ @{$titles} ], [ @{$desc} ];
	lbs_common::lolRotate( \@lol );
	print lbs_common::make_html_table( "", \@toprow, \@lol, \%tabattr );
	
        if ($mac) {
	        print "<input type=hidden name=mac value=\"$mac\">\n";
        } else {
	        print "<input type=hidden name=group value=\"$group\">\n";
	        print "<input type=hidden name=profile value=\"$profile\">\n";
        }
	print "<input type=hidden name=form value=\"bootmenu\">\n";
	print "<input type=submit name=apply value=\"$but_apply\">\n";
	print "<input type=submit name=cancel value=\"$but_return\">\n";
	
	print "</form>\n";
	
	print "</center>\n";
	
	return 1;
}

sub print_dhcp_form {
my ($action, $nrlicenses, %einfo) = @_;

my $lab_name =		$text{'lab_name'} ;
my $lab_ipaddr =	$text{'lab_ipaddr'} ;
my $lab_macaddr =	$text{'lab_macaddr'} ;
my $lab_adminid =	$text{'lab_adminid'} ;
my $but_apply =		$text{'but_apply'} ;
my $but_cancel =	$text{'but_cancel'} ;

my $formdesc = $text{'msg_dhcp_formdesc'} ;

my $num_keys = scalar keys %einfo;

	if ($num_keys > $nrlicenses) {
		print "<h2>$text{'msg_dhcp_nolic'}</h2>";
		return;
	}

print <<EOF ;
<center><p><h2>$formdesc</h2></p>
	<form action="$action">
	<table><tr>
	<td class="noborder"><b>$lab_name:</b></td><td class="noborder"><input name=name size=30 value=""></td>
	</tr><tr>
	<td class="noborder"><b>$lab_macaddr:</b></td><td class="noborder"><input name=mac size=30 value=""></td>
	</tr><tr>
	<td class="noborder"><b>$lab_ipaddr:</b></td><td class="noborder"><input name=ip size=30 value="Dynamic">$text{'lab_ordynamic'}</td>
	</tr><tr>
	<td class="noborder"><b>$lab_adminid:</b></td>
	<td class="noborder"><input type=password name=passwd size=30 value=""></td>
	</tr></table>
	<input type=submit name=apply value="$but_apply">
	<input type=submit name=cancel value="$but_cancel">
	</form>
</center>
EOF

}


sub checkhostname {
	return 0 if ( not grep(m/^[0-9a-z\.-]+$/i, $_[0]) ) ;
        1;
}


sub checkip {
my $ip = shift ;
my @ls ;
my $i ;	
	return 1 if ($ip =~ /dynamic/i);
	return 0 if (not length($ip)) ;
	@ls = split(m/\./,$ip) ;
	return 0 if (scalar(@ls) != 4) ;
	foreach $i (@ls) {
		return 0 if (not grep(m/^[0-9]+$/,$i)) ;
		return 0 if ($i<0 or $i>254) ;
	}
 1;
}

sub checkmac {
my $mac = shift ;
my @ls ;
my $i ;
	return 0 if (length($mac) != 17) ; 
	@ls = split(m/:/,$mac) ;
	return 0 if (scalar(@ls) != 6) ;
	foreach $i (@ls) {
		return 0 if (length($i) != 2) ;
		return 0 if (not grep(m/^[0-9a-f]+$/i,$i)) ;
	}
 1;
}

# void printMoveHeaderForm($mac, \@items, \@titles,\@desc, \@dirs, \@flags)
# args:
#   $mac: adresse MAC la machine
#   \@items: ref de la liste des identifiants (les sections 'menu').
#   \@titles: ref de la liste des titres (titles) du menu utilisateur.
#   \@dirs: ref de la liste des reperts associes aux images.
#   \@desc: ref de la liste des descriptions des items.
#
sub print_move_header_form {
my ($firstarg, $items, $titles, $desc, $dirs, $flags, $hlinks, $menus, $decor, $dates) = @_;

my ($mac, $group, $profile)=($firstarg->{'mac'}, $firstarg->{'group'}, $firstarg->{'profile'});

my $i ;
my $item ;
my $uitem ;
my $umac = urlize($mac) ;  # Fonction Webmin.
my $smac = $mac;
my $umenu ;
my $arrow ;
my $lbs_home = $lbs_common::lbsconf{'basedir'};

$smac =~ s/://g;
# "Menu","Description","Repertoire","Vers local"
my @toprow = (
                $text{'lab_menu'},
                $text{'lab_desc'},
                $text{'lab_date'},
                $text{'lab_dir'},
                $text{'lab_tolocal'},
                $text{'lab_burn'},
                $text{'lab_details'}
              ) ;

my (@lol, @tolocal, @burn, @detail) ;

my $but_return = $text{'but_return'} ;

# Attributs de la table:
my %tabattr = (
	'rotate'	=> 0 ,
	'tr_header'	=> $tb ,
	'tr_body'	=> $cb ,
	'border'	=> "border=1 width='100%'",
) ;

	print "<hr><center>\n" ;
	print "<form action=\"move.cgi\">" ;

	for ($i=0; $i<scalar(@{$items}); $i++) {
                my $localpath;
                
                if ($mac) {
                        $localpath = "$lbs_home/images/".lbs_common::mac_remove_columns($mac)."/$$dirs[$i]/PTABS";
                } elsif ($group or $profile) {
                        $localpath = "$lbs_home/imgprofiles/$profile/$group/$$dirs[$i]/PTABS";
                }
                
                my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($localpath);

                if ($mtime) {
                        $$dates[$i]=lbs_common::timestamp2date($mtime);
                } else {
                        $$dates[$i]="&nbsp;";
                }
                
		$item = $$items[$i] ;
		$uitem = urlize($item) ;
		$umenu = urlize($item) ;

		if ($$flags[$i]) {
			$arrow = "down1.gif" ;
		} else {
			$arrow = "cross.gif" ;
		}

                my $params = "";
                if ($mac) {
                        $params="mac=$umac";
                } elsif ($group or $profile) {
                        $params="group=$group&profile=$profile";
                }
                
                my $urlizedmenu = "";
                $urlizedmenu    = urlize($$menus[$i]) if (defined($$menus[$i]));
                my $escapeddesc    = "";
                $escapeddesc    = html_escape($$desc[$i]) if (defined($$desc[$i]));
                my $escapedtitles  = "";
                $escapedtitles  = html_escape($$titles[$i]) if (defined$$titles[$i]);

                $$desc[$i] = "<a href=\"desc.cgi?$params&obj=desc&menu=$urlizedmenu\" $decor>$escapeddesc</a>" ;
                $$titles[$i] = "<a href=\"title.cgi?$params&obj=title&menu=$urlizedmenu\" $decor>$escapedtitles</a>" ;

                push @tolocal, "<center>"
                               ."<a href=\"move.cgi?$params&img=$uitem&op=h2l\">" 
                               . "<img src=\"images/$arrow\" border=no "
                               . "alt=\"".$text{'lab_tolocal'}."\"></a>"
                               . "</center>" ;

                if ($$dirs[$i] =~ /^Base/i) {
                        push @burn, "<center><a href='/lbs-cd/?dir=".urlize($lbs_home."/imgbase/$$dirs[$i]/")."'><img border=1 src='images/burn.gif'></a></center>";
                        push @detail, "<center><a href='details.cgi?conf=".urlize("/imgbase/$$dirs[$i]/")."&$params'><img border=1 src='images/detail.gif'></a></center>";
		} elsif ($$dirs[$i] =~ /^Local-[0-9]/i) {
                        push @burn, "<center><a href='/lbs-cd/?dir=".urlize($lbs_home."/images/$smac/$$dirs[$i]/")."'><img border=1 src='images/burn.gif'></a></center>";
                        push @detail, "<center><a href='details.cgi?conf=".urlize("/images/$smac/$$dirs[$i]/")."&$params'><img border=1 src='images/detail.gif'></a></center>";
		} else {
		    push @burn, "&nbsp;";
		    push @detail, "&nbsp;";

		}

		# HACK: Adding an icon if image dir is a symlink:
		if ($$hlinks{ $$dirs[$i] }) {
			$$dirs[$i] .= q(&nbsp;<img src="images/link.gif" border="no" )
			              . 'alt="'.$text{'lab_imglink'}.'">' ;

		}
	}

	push @lol, [ @{$titles} ],  [ @{$desc} ], [ @{$dates} ], [ @{$dirs} ], [ @tolocal ], [ @burn ], [ @detail ]  ;

	lbs_common::lolRotate(\@lol) ;
	
	print lbs_common::make_html_table($text{'tab_move_bootmenu'}, \@toprow, \@lol, \%tabattr) ;

print <<EOF ;
	<input type=hidden name=mac value="$mac">
	<input type=hidden name=form value="movehdr">
	<div style='text-align: right'><input type=submit name=cancel value="$but_return"></div>

	</form>
</center>
EOF

return 1 ;
}

#--------------------------------------------------------------------------

# printMoveLocalForm ($macaddr,\@images,\@titles,\@desc,\@dirs,\@images,
#                     \@flags_l2h, \@flags_l2b)
#
#
#
sub print_move_local_form {
my ($mac, $items, $titles, $desc, $dirs, $flags2h, $flags2b, $hlinks, $dates)=@_;

my $i ;
my $item ;
my $uitem ;
my $umac = urlize($mac) ;  # Fonction Webmin.
my $smac = $mac;
my $umenu ;
my $arrow2h ;
my $arrow2b ;

my $lbs_home = $lbs_common::lbsconf{'basedir'};

$smac =~ s/://g;

# "Menu","Description","Repertoire","Effacer","Vers menu","Vers base":
my @toprow = (
                $text{'lab_menu'},
                $text{'lab_desc'},
                $text{'lab_date'},
                $text{'lab_dir'},
                $text{'lab_rm'},
                $text{'lab_tomenu'},
                $text{'lab_tobase'},
                $text{'lab_burn'},
                $text{'lab_details'}
                ) ;

my (@lol, @tohdr, @tobase, @lsdel, @burn, @detail) ;

my $but_return = $text{'but_return'} ;

# Attributs de la table:
my %tabattr = (
	'rotate'	=> 0 ,
	'tr_header'	=> $tb ,
	'tr_body'	=> $cb ,
	'border'	=> "border=1 width='100%'",
) ;

	print "<hr><center>\n" ;

	print "<form action=\"move.cgi\">" ;

	for ($i=0; $i<scalar(@{$items}); $i++) {
                
                my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$lbs_home/images/".lbs_common::mac_remove_columns($mac)."/$$dirs[$i]/PTABS");
                
                if ($mtime) {
                        $$dates[$i]=lbs_common::timestamp2date($mtime);
                } else {
                        $$dates[$i]="&nbsp;";
                }

		$item = $$items[$i] ;
		$uitem = urlize($item) ;
	
		$umenu = urlize($item) ;

		$arrow2h = "cross.gif";
		$arrow2h = "up1.gif"    if ($$flags2h[$i]);

		$arrow2b = "cross.gif";
		$arrow2b = "down1.gif"  if ($$flags2b[$i]);

		push @lsdel, "<center><a href=\"move.cgi?mac=$umac&img=$uitem&op=del\">"
		             . "<img src=\"images/trash.gif\" border=no "
		             . "alt=\"".$text{'lab_rm'}."\"></a></center>" ;

		push @tohdr, "<center><a href=\"move.cgi?mac=$umac&img=$uitem&op=l2h\">" 
		               . "<img src=\"images/$arrow2h\" border=no "
		               . "alt=\"".$text{'lab_tomenu'}."\"></a></center>" ;

		push @tobase, "<center><a href=\"move.cgi?mac=$umac&img=$uitem&op=l2b\">"
		               . "<img src=\"images/$arrow2b\" border=no "
		               . "alt=\"".$text{'lab_tobase'}."\"></a></center>" ;

		if ($$dirs[$i] =~ /^Base/i) {
			push @burn, "<center><a href='/lbs-cd/?dir=".urlize($lbs_home."/imgbase/$$dirs[$i]/")."'><img border=1 src='images/burn.gif'></a></center>";
			push @detail, "&nbsp;";
		} elsif ($$dirs[$i] =~ /^Local-[0-9]/i) {
			push @burn, "<center><a href='/lbs-cd/?dir=".urlize($lbs_home."/images/$smac/$$dirs[$i]/")."'><img border=1 src='images/burn.gif'></a></center>";
			push @detail, "<center><a href='details.cgi?conf=".urlize("/images/$smac/$$dirs[$i]/")."&mac=".urlize($mac)."'><img border=1 src='images/detail.gif'></a></center>";
		} else {
			push @burn, "&nbsp;";
			push @detail, "&nbsp;";
		}

		# HACK: Adding an icon if image dir is a symlink:
		if ($$hlinks{ $$dirs[$i] }) {
			$$dirs[$i] .= q(&nbsp;<img src="images/link.gif" border="no" )
			              .'alt="'.$text{'lab_imglink'}.'">' ;
		}
	}
	
        if (scalar(@{$items})) {
                push @lol, [ @{$titles} ],  [ @{$desc} ], [ @{$dates} ], [ @{$dirs} ], [ @lsdel ],  [ @tohdr ], [ @tobase ], [ @burn ], [ @detail ] ;
                lbs_common::lolRotate(\@lol) ;
        }
	
	print lbs_common::make_html_table($text{'tab_move_local'}, \@toprow, \@lol, \%tabattr);

print <<EOF ;
	<input type=hidden name=mac value="$mac">
	<input type=hidden name=form value="movelocal">
	<div style='text-align: right'><input type=submit name=cancel value="$but_return"></div>
	</form>
</center>
EOF
}

# --------------------------------------------------------------------

# printMoveBaseForm ($macaddr,$group,$profile,\@images,\@titles,\@desc,\@dirs,
#                    \@images,\@flags_b2h)
#
#
#
sub print_move_base_form {
my ($firstarg, $items, $titles, $desc, $dirs, $flags, $dates) = @_;

my ($mac, $group, $profile)=($firstarg->{'mac'}, $firstarg->{'group'}, $firstarg->{'profile'});
        
my $i ;
my $item ;
my $uitem ;
my $umac = urlize($mac) ;  # Fonction Webmin.
my $umenu ;
my $arrow ;
my $lbs_home = $lbs_common::lbsconf{'basedir'};

# Menu, Description, Repertoire, Vers menu:
my @toprow = (
                $text{'lab_menu'},
                $text{'lab_desc'},
                $text{'lab_date'},
                $text{'lab_dir'},
                $text{'lab_tomenu'},
                $text{'lab_burn'},
                $text{'lab_details'},
                );
my (@lol, @tohdr, @burn, @detail) ;

my $but_return = $text{'but_return'} ;

# Attributs de la table:
my %tabattr = (
	'rotate'	=> 0 ,
	'tr_header'	=> $tb ,
	'tr_body'	=> $cb ,
	'border'	=> "border=1 width='100%'",
) ;

# Le tableau des menus
print "<hr><center>\n" ;

	print "<form action=\"move.cgi\">" ;

	for ($i=0; $i<scalar(@{$items}); $i++) {
                # FIXME: hard-coded path
                my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$lbs_home/imgbase/$$dirs[$i]/PTABS");
                
                if ($mtime) {
                        $$dates[$i]=lbs_common::timestamp2date($mtime);
                } else {
                        $$dates[$i]="&nbsp;";
                }

		$item = $$items[$i] ;
		$uitem = urlize($item) ;
	
		$umenu = urlize($item) ;

		$arrow = "cross.gif";
		$arrow = "doubleup1.gif" if ($$flags[$i]);
		
                if (($profile ne "") or ($group ne "")) {
                        push @tohdr, "<center><a href=\"move.cgi?profile=$profile&group=$group&img=$uitem&op=b2h\">" 
                                      . "<img src=\"images/$arrow\" border=no "
                                      . "alt=\"".$text{'lab_tomenu'}."\" </a></center>" ;
                } else {
                        push @tohdr, "<center><a href=\"move.cgi?mac=$umac&img=$uitem&op=b2h\">" 
                                      . "<img src=\"images/$arrow\" border=no "
                                      . "alt=\"".$text{'lab_tomenu'}."\" </a></center>" ;
                }                        
		if ($$dirs[$i] =~ /^Base/i) {
			push @burn, "<center><a href='/lbs-cd/?dir=".urlize($lbs_home."/imgbase/$$dirs[$i]/")."'><img border=1 src='images/burn.gif'></a></center>";
			push @detail, "<center><a href='details.cgi?conf=".urlize("/imgbase/$$dirs[$i]/")."&mac=".urlize($mac)."'><img border=1 src='images/detail.gif'></a></center>";
		} else {
			push @burn, "&nbsp;";
			push @detail, "&nbsp;";
		}

	}
	
	push @lol, [ @{$titles} ],  [ @{$desc} ], [ @{$dates} ],[ @{$dirs} ], [ @tohdr ], [@burn], [@detail];

	lbs_common::lolRotate(\@lol) ;
	
	print lbs_common::make_html_table($text{'tab_move_base'}, \@toprow, \@lol, \%tabattr) ;

print <<EOF ;
	<input type=hidden name=mac value="$mac">
	<input type=hidden name=form value="movebase">
	<div style="float: right"><input type=submit name=cancel value="$but_return"></div>
	<div style=""><input type=submit name=imgbase value="$text{but_imgbase}"></div>
	</form>

</center>
EOF
}

#
# Return the entries of a directory but exclude symbolic links
#
sub read_subdirs_nolink {
 my $dirpath = shift ;
 my @lsdir ;

 if (not opendir(REP,$dirpath)) {
 	lbsError("readSubDirsNoLink",'RAW',"$dirpath: $!") ;
 	return ;
 }

 foreach my $ent (grep !/^\.\.?$/, readdir(REP)) {
    if ( ! -l "$dirpath/$ent" ) {
	push @lsdir, $ent;
    }
 }
 closedir(REP) ;
 return grep { -d "$dirpath/$_" } @lsdir ;
}


sub print_bootoptions_form {
    my $mac     = $_[0];
    my $default = $_[1];
    my $items   = $_[2];
    my $titles  = $_[3];
    my $presel  = $_[4] ? $_[4] : [];
    my $desc    = $_[5];
    my $status  = $_[6];
    my $i;
    my $item;
    my $menuchk    = "";
    my $defaultchk = "";
    my $st;

    my $umac = urlize($mac);    # Fonction Webmin.
    my $umenu;
    my $decor;

    my @toprow = (
        $text{'lab_defchoice'}, $text{'lab_display'},
        $text{'lab_menu'},      $text{'lab_desc'}
    );
    my ( @lol, @radio, @check );

    # Texte des boutons
    my $but_apply      = $text{'but_apply'};
    my $but_return     = $text{'but_return'};

    # Attributs de la table:
    my %tabattr = (
        'rotate'    => 0,
        'tr_header' => $tb,
        'tr_body'   => $cb,
        'border'    => "border=1 width='100%'",
    );

    # Le tableau des menus
    print "<center><table width='100%'><tr><td>\n";

    print "<form action=\"bootoptions.cgi\">";

    for ( $i = 0 ; $i < scalar( @{$items} ) ; $i++ ) {
        $item = $$items[$i];
        $st   = $$status[$i];

        # Good status:
        if ( $st == 0 ) {

            $defaultchk = "";
            if ( $item eq $default ) {
                $defaultchk = "checked";
            }

            $menuchk = "";
            if ( grep { $item eq $_ } @$presel ) {
                $menuchk = "checked";
            }

            push @radio,
              "<input type=radio name=default value=\"$item\" $defaultchk>";
            push @check,
              "<input type=checkbox name=menu value=\"$item\" $menuchk>";

            # Convertion de la description en hyperlien.
            # On utilise un attribut de style pour ne pas que ces liens
            # soient soulignes.
            #
            $decor = 'style="text-decoration:none"';
            $umenu = urlize($item);

            $$desc[$i] =
              "<a href=\"desc.cgi?mac=$umac&obj=desc&menu=$umenu\" $decor>"
              . html_escape( $$desc[$i] ) . "</a>";

            $$titles[$i] =
              "<a href=\"title.cgi?mac=$umac&obj=title&menu=$umenu\" $decor>"
              . html_escape( $$titles[$i] ) . "</a>";
        }

        # Bad status:
        else {
            push @radio, "&nbsp;";
            push @check, "&nbsp;";
            $$titles[$i] = colorStatus( $st, html_escape( $$titles[$i] ) );
            $$desc[$i]   = colorStatus( $st, html_escape( $$desc[$i] ) );
        }
    }

    push @lol, [@radio], [@check], [ @{$titles} ], [ @{$desc} ];
    lolRotate( \@lol );
    print mkHtmlTable( "", \@toprow, \@lol, \%tabattr );

    print "<input type=hidden name=mac value=\"$mac\">\n";
    print "<input type=hidden name=form value=\"bootoptions\">\n";
    print "<input type=submit name=apply value=\"$but_apply\">\n";
    print "<input type=submit name=cancel value=\"$but_return\">\n";

    print "</form>\n";

    print "</td></tr></table></center>\n";

    # Boutons effacer et deplacer
    print <<EOF ;
EOF

    return 1;
}

# bool getPartParams(\%ini, $disk, \@params, \@lol)
# Fonction specifique aux parametres disque concernant les partitions.
# Args:
#       \%ini: Hache des infos retourne par iniLoad()
#       $disk: Nom de la section du disque recherche.
#       \@params: Liste des parametres demandes
#       \@lol: Tableau 2D (liste de listes) qui recevra les valeurs des
#              parametres demandes (dans l'ordre), a raison d'une liste par
#              partition.
#
# Retourne le nombre de partitions trouvees.
#
sub get_part_params {
my ($ini, $disk, $params, $lol) = @_ ;
my ($i, $p, $row);
my (@curp, @row);
                                                                                                                                             
	@{$lol} = () ;
															     
	for ($i=0; $i<10; $i++) {
		$p = $$params[0] . $i ;
		@row = iniGetValues( $ini, $disk, $p ) ;
																     
		if (length $row[0] >0) {
			@curp = map { $_.$i } @$params ;
			@row = iniGetValues($ini, $disk, @curp ) ;
			$row[1] = parttype("0x$row[1]");
																     
			push @$lol, [ @row ] ;
		} else {
			last ;
		}
	}
                                                                                                                                             
return scalar(@$lol) ;
}

# printDescForm ($action, $mesg, $mac, $menu, $title )
#
sub print_mac_desc_form {
my ($action, $mesg, $mac, $menu, $title) = @_ ;

# my $buf = "" ;
# if (defined($_[3]) and defined($_[4])) {
# 	$buf = sprintf "<input type=hidden name=\"%s\" value=\"%s\">\n",
# 	       $_[2], $_[3] ;
# }

$title = html_escape($title) ;

my $but_apply = $text{'but_apply'} ;
my $but_cancel = $text{'but_cancel'} ;

my @n = split (/:/, $mac);

print <<EOF;
<center>
<p>$mesg</p>
<form action="$action">
<div>
<b>$text{lab_newmac}: </b>
   <input name=mac1 size=2 maxlength="2" value="$n[0]">
   <input name=mac2 size=2 maxlength="2" value="$n[1]">
   <input name=mac3 size=2 maxlength="2" value="$n[2]">
   <input name=mac4 size=2 maxlength="2" value="$n[3]">
   <input name=mac5 size=2 maxlength="2" value="$n[4]">
   <input name=mac6 size=2 maxlength="2" value="$n[5]">
</div>
   <br>
   <input type=submit name=apply value="$but_apply">
   <input type=submit name=cancel value="$but_cancel">
   
   <input type=hidden name=mac value="$mac">
   <input type=hidden name=menu value="$menu">
   <input type=hidden name=form value="title">
</form>
<center>

EOF

}

# printDescForm ($action, $mesg, $mac, $menu, $title )
#
sub print_name_desc_form {
my ($action, $mesg, $mac, $menu, $title, $redir_flag) = @_ ;

$title = html_escape($title) ;

my $n = $title;         # machine name
my $g = "";             # machine group
my $p = "";             # machine profile
if ( $n =~ m|^(.*):([^:]+)/([^/:]+)$| ) {
        $p = $1;
        $g = $2;
        $n = $3;
} elsif ( $n =~ m|^(.+)/([^/]+)$| ) {
        $g = $1;
        $n = $2;
}

$g = '' if $g eq ':';

my %ether;
etherLoad($lbs_common::lbsconf{'basedir'}."/etc/ether" , \%ether);
lbs_common::normalize_machine_names(\%ether);
my %available_profiles=lbs_common::get_all_profiles(%ether);
my %available_groups=lbs_common::get_all_groups(1, %ether);

my $buff = <<EOF ;
        <center>
                <p>$mesg</p>
                <form action="$action">
                        <table style="border-width: 0px;">
                                <tr>
                                        <td style="border-width: 0px;"><b>$text{'lab_profile'}:</b></td>
                                        <td style="border-width: 0px;"><select  style='width: 200px' name='preprofile'>
                                                <option value=''></option>
EOF
foreach my $profile (sort keys %available_profiles) {
        $buff .= "<option";
        $buff .= " SELECTED" if ($p eq $profile);
        $buff .= " value='$profile'>$profile</option>";
}

$buff .= <<EOF ;
                                        </select> ou <input name='profile' size=32 value=""></td>
                                </tr>
                                <tr>
                                        <td style="border-width: 0px;"><b>$text{'lab_group'}:</b></td>
                                        <td style="border-width: 0px;"><select style='width: 200px' name='pregroup'>
                                                <option value=''></option>
EOF
foreach my $group (sort keys %available_groups) {
        $buff .= "<option";
        $buff .= " SELECTED" if ($g eq $group);
        $buff .= " value='$group'>$group</option>";
}

$buff .= <<EOF ;
                                        </select> / <input name=group size=32 value=""></td>
                                </tr>
                                <tr>
                                        <td style="border-width: 0px;"><b>$text{'lab_name'}:</b></td>
                                        <td style="border-width: 0px;"><input name=title size=32 value="$n"></td>
                                </tr>
                        </table>
                        <div>
                                <input type=submit name=apply value="$text{'but_apply'}">
                                <input type=submit name=cancel value="$text{'but_cancel'}"></td>
                        </div>
                        <input type=hidden name=mac value="$mac">
                        <input type=hidden name=menu value="$menu">
                        <input type=hidden name=form value="title">
                        <input type=hidden name=redir_flag value="$redir_flag">
                </form>
        </center>

EOF

print $buff;
}

sub create_group_dir() {
        my ($cfgpath) = shift;
        my $lbs_home  = $lbs_common::lbsconf{'basedir'};
        my $cfgfile="$cfgpath/header.lst";
        
        if (not -e $cfgfile) {          # FIXME: well, could someone please fix the following lines ?
                `mkdir -p $cfgpath`;
                `cp -a $lbs_home/imgskel/header.lst $cfgpath`;
                `cp -a $lbs_home/imgskel/COPYNUM $cfgpath`;
                `cp -a $lbs_home/imgskel/symlinks $cfgpath`;
                `cat $lbs_home/imgskel/symlinks | sed "s/\\.\\.\\/\\.\\./\\/tftpboot\\/revoboot/" > $cfgpath/symlinks`;
                `cd $cfgpath && ./symlinks`;
        }
        
        return;
}

#
# bootmenu_show_postinst ( $image_dir , Rlbs_home)
#
sub bootmenu_show_postinst {
  my ($conf, $lbs_home) = @_ ;
  my ($ch, $type, $ll);
  my (@lol, @active, @desc);
  my $lines = read_file_lines("$lbs_home/$conf/postinst.desc");
  my $error = 0;
  
  # check if the postinstall component is available
  if (!-f $lbs_home."/lib/util/lib/libpostinst.sh" ) { return; }

  print "<h3>$text{'tit_choose_postinst'}</h3>";
  
  print "<form method=\"post\"><div align='left'>";
  my @tmpl = list_postinst_templates($lbs_home);
  print "<select name=\"postinst\">\n";
    foreach my $t (@tmpl) {
      my $sel = "";
      my $file = @$t->[0];
      my $com = @$t->[1];
      my $more = "";
      if (defined($lines->[0]) && $lines->[0] eq $file) { $sel = "selected"; }
      if ($file ne "NULL") { $more .= " $file:"; }
      if (length($com) > 80) { $com = substr($com,0,80)."..."; }
      print "<option $sel value='$file'>$more $com </option>\n";
  }
  print "</select>\n";
  print "<input type='submit' name='saveconfpost' value='OK'>";
  print "&nbsp;<input type='submit' name='editconfpost' value='$text{but_edit}'>";
  print "</div></form>";
}

# add progress information to the description if found
sub addBackupProgressInfo {
  my ($conf, $descptr) = @_;

  if (-f dirname($conf)."/conf.tmp" && -f dirname($conf)."/progress.txt") 
    {
      my $l = read_file_lines(dirname($conf)."/progress.txt");
      $$descptr .= " ".$text{'lab_partition'}." ".$$l[0];
    }
}

#
# remove the last component of a path
#
sub dirname {
  my $path = shift;

  $path =~ s|/[^/]+$||;
  return $path;
}

1;
