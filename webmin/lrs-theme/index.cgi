#!/usr/bin/perl
#
# $Id$
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

require './web-lib.pl';

@available = ("webmin", "system", "servers", "cluster", "hardware", "", "net");
&init_config();
$hostname = &get_system_hostname();
$ver = &get_webmin_version();
&get_miniserv_config(\%miniserv);

if ($gconfig{'real_os_type'}) {
	if ($gconfig{'os_version'} eq "*") {
		$ostr = $gconfig{'real_os_type'};
	} else {
		$ostr = "$gconfig{'real_os_type'} $gconfig{'real_os_version'}";
	}
} else {
	$ostr = "$gconfig{'os_type'} $gconfig{'os_version'}";
}

&ReadParse();

# Redirect if the user has only one module
@msc_modules = &get_available_module_infos() if (!defined(@msc_modules));

# Show standard header
$gconfig{'sysinfo'} = 0 if ($gconfig{'sysinfo'} == 1);
$theme_index_page = 1;
&header($gconfig{'nohostname'} ? $text{'main_title2'} : &text('main_title', $ver, $hostname, $ostr), "", undef, undef, 1, 1);
print $text{'main_header'};

if (!@msc_modules) {# user has no modules!
	
	print "<p><b>$text{'main_none'}</b><p>\n";
} elsif ($gconfig{"notabs_${base_remote_user}"} == 2 || $gconfig{"notabs_${base_remote_user}"} == 0 && $gconfig{'notabs'}) { # Generate main menu with all modules on one page
	
	print "<center><table cellpadding=0>\n";
	$pos = 0;
	$cols = $gconfig{'nocols'} ? $gconfig{'nocols'} : 4;
	$per = 100.0 / $cols;
	foreach $m (@msc_modules) {
		if ($pos % $cols == 0) { print "<tr>\n"; }
		print "<td valign=top align=center>\n";
		local $idx = $m->{'index_link'};
		print "<table border><tr><td><a href=$m->{'dir'}/$idx>",
		      "<img src=$m->{'dir'}/images/icon.gif border=0 ",
		      "width=48 height=48></a></td></tr></table>\n";
		print "<a href=$m->{'dir'}/$idx>$m->{'desc'}</a></td>\n";
		if ($pos % $cols == $cols - 1) { print "</tr>\n"; }
		$pos++;
		}
	print "</table></center><p><table width='100%' bgcolor='#FFFFFF'><tr><td></td></tr></table><br>\n";
} else { # Generate categorized module list
	print "<table class='webmincategories' width='100%' align='center'><tr><td class='webmincategories'><table class='webmincategories' height=20><tr>\n";
	$usercol = defined($gconfig{'cs_header'}) ||
		   defined($gconfig{'cs_table'}) ||
		   defined($gconfig{'cs_page'});

	print "</tr></table> <table class='webmincategories' ",
              "width=100% bgcolor=#FFFFFF background=images/msctile2.jpg>\n";
	print "<tr><td class='webmincategories'><table width=100% class='webmincategories' >\n";

	# Display the modules in this category
	$pos = 0;
	$cols = $gconfig{'nocols'} ? $gconfig{'nocols'} : 4;
	$per = 100.0 / $cols;
	foreach $m (@msc_modules) {
		next if ($m->{'category'} ne $in{'cat'});

		if ($pos % $cols == 0) { print "<tr>\n"; }
		print "<td class='webmincategories' valign=top align=center width=$per\%>\n";
		print "<table class='webminmodule' ><tr><td class='webmincategories'><a href=$m->{'dir'}/>",
		      "<img src=$m->{'dir'}/images/icon.gif alt=\"\" border=0></a>",
		      "</td></tr></table>\n";
		print "<a class='webminmodule' href=$m->{'dir'}/><font color=#000000>$m->{'desc'}</font></a></td>\n";
		if ($pos++ % $cols == $cols - 1) { print "</tr>\n"; }
		}
	while($pos++ % $cols) {
		print "<td class='webmincategories' width=$per\%></td>\n";
		}
	print "</table></td></tr></table></td></tr></table>";
	}

if ($miniserv{'logout'} && !$gconfig{'alt_startpage'} &&
    !$ENV{'SSL_USER'} && !$ENV{'LOCAL_USER'} &&
    $ENV{'HTTP_USER_AGENT'} !~ /webmin/i) {
	}

print $text{'main_footer'};
&footer();


sub chop_font {

        foreach $l (split(//, $t)) {
            $ll = ord($l);
            if ($ll > 127 && $lang->{'charset'}) {
                print "<img src=images/letters2/$ll.$lang->{'charset'}.gif alt=\"$l\" align=bottom border=0>";
                }
            elsif ($l eq " ") {
                print "<img src=images/letters2/$ll.gif alt=\"\&nbsp;\" align=bottom border=0>";
                }
            else {
                print "<img src=images/letters2/$ll.gif alt=\"$l\" align=bottom border=0>";
                }
            }

}