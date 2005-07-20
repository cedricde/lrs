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

#theme_prebody - called just before the main body of every page, so it can print any HTML it likes.
#theme_postbody - called just after the main body of every page.
#theme_header - called instead of the normal header function, with the same parameters. You could use this to re-write the header function in your own style with help and index links whereever you want them.
#theme_footer - called instead of the footer function with the same parameters.
#theme_error - called instead of the error function, with the same parameters.

my $DEFAULTINDEX = "index.cgi";

sub theme_header {

local @available = ("webmin", "system", "servers", "cluster", "hardware", "", "net", "kororaweb");

local $ll;
local %access = &get_module_acl();
local %gaccess = &get_module_acl(undef, "");

# some useful vars
local   $os_type        = $gconfig{'real_os_type'}    ? $gconfig{'real_os_type'}    : $gconfig{'os_type'};
local   $os_version     = $gconfig{'real_os_version'} ? $gconfig{'real_os_version'} : $gconfig{'os_version'};
my      $charset        = "iso-8859-1"; # if !$charset;
my      $themeroot      = $gconfig{'theme'};
my      $webprefix      = $gconfig{'webprefix'} || "";


# HTML header

# No DOCTYPE: workaround for the css mozilla bug and webmin sending css as text/plain
#	print "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>\n";

	print "<html>";
	print "<head>";
	print "\t<meta name='description' content='Linbox Free&amp;ALter Soft est une SSII sp&eacute;cialis&eacute; dans les logiciels libres (SSLL), depuis sa cr&eacute;ation en 1996.' />\n";
        print "\t<link rel=\"shortcut icon\" type=\"image/x-icon\" href=\"/$themeroot/images/favicon.ico\" />\n";
	print "\t<link rel='StyleSheet' href='/$themeroot/css/base.css' type='text/css' media='screen' />\n";
	print "\t<link rel='StyleSheet' href='/$themeroot/css/links.css' type='text/css' media='screen' />\n";
	print "\t<link rel='StyleSheet' href='/$themeroot/css/lbstheme.css' type='text/css' media='screen' />\n";
	
# based on wanted URL, we inject a supplementary CSS
	if (!(
		((lc($module_name) eq 'net') && (lc($scriptname) eq 'index.cgi'))    	# webmin's network main page
		||
		((lc($module_name) eq 'webmin') && (lc($scriptname) eq 'index.cgi'))    # webmin's network main page
		||
		((lc($module_name) eq 'backuppc') && (lc($scriptname) eq 'index.cgi'))  # backuppc's main page
		||
		((lc($module_name) eq 'exim') && (lc($scriptname) eq 'index.cgi'))    	# exim's main page
		||
		((lc($module_name) eq 'mrtg') && (lc($scriptname) eq 'index.cgi'))    	# mrtg's main page
		||
		((lc($module_name) eq 'custom') && (lc($scriptname) eq 'index.cgi'))    # custom page
		||
		((lc($module_name) eq 'samba') && (lc($scriptname) eq 'index.cgi'))    	# samba's main page
		||
		((lc($module_name) eq 'bind') && (lc($scriptname) eq 'index.cgi'))    	# bind's main page
		||
		((lc($module_name) eq 'squid') && (lc($scriptname) eq 'index.cgi'))    	# squid's main page
		||
		((lc($module_name) eq 'burner') && (lc($scriptname) eq 'index.cgi'))   	# burner's main page
		||
		((lc($module_name) eq 'change-user') && (lc($scriptname) eq 'index.cgi'))# user's pref page
	)) {
			print "\t<link rel='StyleSheet' href='/$themeroot/css/customwebmin.css' type='text/css' media='screen' />\n";
	}

	if (@_ > 0) {
		if (exists $gconfig{'sysinfo'}) {
		    if ($gconfig{'sysinfo'} == 1) {
			printf "\t<title>LRS Server / %s : %s on %s (%s %s)</title>\n",
				$_[0], $remote_user, &get_system_hostname(),
				$os_type, $os_version;
		    } elsif ($gconfig{'sysinfo'} == 4) {
			printf "\t<title>LRS Server / %s on %s (%s %s)</title>\n",
				$remote_user, &get_system_hostname(),
				$os_type, $os_version;
		    } else {
			print "\t<title>LRS Server / $_[0]</title>\n";
		    }
		} else {
		    print "\t<title>LRS Server / $_[0]</title>\n";		
		}
		
		print $_[7] if ($_[7]);
		
		if (exists $gconfig{'sysinfo'} && $gconfig{'sysinfo'} == 0 && $remote_user) {
			print "\t<SCRIPT LANGUAGE=\"JavaScript\">\n";
			printf "\t\tdefaultStatus=\"%s%s logged into %s %s on %s (%s %s)\";\n",
				$ENV{'ANONYMOUS_USER'} ? "Anonymous user" : $remote_user,
				$ENV{'SSL_USER'} ? " (SSL certified)" :
				$ENV{'LOCAL_USER'} ? " (Local user)" : "",
				$text{'programname'},
				&get_webmin_version(), &get_system_hostname,(),
				$os_type, $os_version;
			print "\t</SCRIPT>\n";
		}
	}
	print "</head>\n";

	# let's go with the body
	print "<body $_[8]>\n";

	@msc_modules = get_available_module_infos(1) if (!defined(@msc_modules));

	
	if ($remote_user && @_ > 1) { # Show basic header with webmin.com link and logout button
	
		print qq~
		<div id="container">
			<div id="header">
				<a href="http://www.linbox.com">
					<img src="/images/linbox_haut_01.gif" width="75" height="73" alt="Linbox" />
				</a>
			</div>
			~
	}

	# admin links
	print "<div id=\"adminlinks\">\n";
	if ($ENV{'HTTP_WEBMIN_SERVERS'}) {
		print "\t\t\t\t<a href='$ENV{'HTTP_WEBMIN_SERVERS'}'>", "$text{'header_servers'}</a><br />\n";
	}
	if (!$notabs && !$_[5]) { 
		print "\t\t\t\t<a href='$gconfig{'webprefix'}/?cat=$module_info{'category'}'>$text{'header_webmin'}</a><br />\n";
	}
	if (!$_[4]) {
		local $idx = $module_info{'index_link'};
		local $mi = $module_index_link ||
		$module_name ? "/$module_name/$idx" : "/";
		
		print "\t\t\t\t<a href=\"$gconfig{'webprefix'}$mi\">", "$text{'header_module'}</a><br />\n";
	}
	if (ref($_[2]) eq "ARRAY" && !$ENV{'ANONYMOUS_USER'}) {
		print &hlink($text{'header_help'}, $_[2]->[0], $_[2]->[1])."<br />\n";
	} elsif (defined($_[2]) && !$ENV{'ANONYMOUS_USER'}) {
		print &hlink($text{'header_help'}, $_[2])."<br />\n";
	}
	if ($_[3]) {
		if (!$access{'noconfig'}) {
			print "\t\t\t\t<a href=\"/config.cgi?$module_name\">", $text{'header_config'},"</a><br />\n";
		}
	}
	
	if ($remote_user && @_ > 1) {# Show basic header with webmin.com link and logout button
	
	local $logout = $main::session_id ? "/session_login.cgi?logout=1" : "/switch_user.cgi";
	local $loicon = $main::session_id ? "logout.jpg" : "switch.jpg";
	local $lowidth = $main::session_id ? 84 : 27;
	local $lotext = $main::session_id ? $text{'main_logout'} : $text{'main_switch'};
	
	if (!$ENV{'ANONYMOUS_USER'}) {
		if (0){#($gconfig{'nofeedbackcc'} != 2 && $gaccess{'feedback'} &&
		    #(!$module_name || $module_info{'longdesc'} || $module_info{'feedback'})) {
			print "\t\t\t\t<a href=\"$gconfig{'webprefix'}/feedback_form.cgi?module=$module_name\">$text{'main_feedback'}</a><br />\n";
		}
		
		if (!$ENV{'SSL_USER'} && !$ENV{'LOCAL_USER'} &&
		    !$ENV{'HTTP_WEBMIN_SERVERS'}) {
			if (exists $gconfig{'nofeedbackcc'} && 
			    $gconfig{'nofeedbackcc'} != 2 &&
			    $gaccess{'feedback'}) {
				print "\t\t\t\t<a href=\"$logout\">$text{'main_logout'}</a><br />\n";
				}
			}
		}
	}
	print "\t\t\t</div>\n";
	local $one = @msc_modules == 1 && $gconfig{'gotoone'};
	local $notabs = (defined($gconfig{"notabs_${base_remote_user}"})) and 
                (
                        $gconfig{"notabs_${base_remote_user}"} == 2
                ||
		        $gconfig{"notabs_${base_remote_user}"} == 0
                &&
                        $gconfig{'notabs'}
                );
	if (@_ > 1 && !$one && $remote_user && !$notabs) { # Display module categories


		local %catnames;
		&read_file("$config_directory/webmin.catnames", \%catnames);
		
		foreach $m (@msc_modules) {
			local $c = "";
			
			$c = $m->{'category'} if (defined($m->{'category'}));
			next if ($c and $cats{$c});
			
			if (%catnames) {
                                if (defined($catnames{$c})) {
                                        $cats{$c} = $catnames{$c};
                                }
                        }
                        elsif ($text{"category_$c"}) {
                                $cats{$c} = $text{"category_$c"};
                        } else { # try to get category name from module ..
                        
                                local %mtext = &load_language($m->{'dir'});
                                
                                if ($mtext{"category_$c"}) {
                                        $cats{$c} = $mtext{"category_$c"};
                                } else {
                                        $c = $m->{'category'} = "";
                                        $cats{$c} = $text{"category_$c"};
                                }
                        }
		}
		
		@cats = sort { $b cmp $a } keys %cats;
		$cats = @cats;
		$per = $cats ? 100.0 / $cats : 100;
	
		if ($theme_index_page) {
			if (!defined($in{'cat'})) { # Use default category
				if (defined($gconfig{'deftab'}) &&
					&indexof($gconfig{'deftab'}, @cats) >= 0) {
					$in{'cat'} = $gconfig{'deftab'};
				} else {
					$in{'cat'} = $cats[0];
				}
			} elsif (!$cats{$in{'cat'}}) {
				$in{'cat'} = "";
			}
		}
	
		if (!$_[5]) { # Show page title in tab
			local $title = $_[0];
			$title =~ s/&auml;/ä/g;
			$title =~ s/&ouml;/ö/g;
			$title =~ s/&uuml;/ü/g;
			$title =~ s/&nbsp;/ /g;
		
			print "\t\t\t\t<div id='maintitle'>$title</div>\n";
			
			if ($_[9]) {
				print "\t\t\t\t<div id='subtitle'>$_[9]</div>\n";
			}
			
			&theme_prebody;
		} else {
			print "\t\t\t\t<div id='maintitle'>Linbox Rescue Server</div>\n";
			printf "\t\t\t\t<div id='subtitle'>powered by Webmin v. %s and %s v. %s</div>\n\n", &get_webmin_version(), $os_type, $os_version;
		}
	
		print "\t\t\t<div id='top_menu'>\n";
		print "\t\t\t<table style='width:100%;border:0;border-collapse:collapse;'><tr>";
		foreach $c (@cats) { #####Navigation Bar START#####
			local $t = $cats{$c};
			local $currentcat=$module_info{'category'};
			$currentcat = $in{'cat'} if (!$currentcat);
			$currentcat = '' if (defined($currentcat) and $currentcat eq 'other');
			
			if (defined($currentcat) and $currentcat eq $c) {
				print "\t\t\t\t<td class=\"top_menu_sel\"><a href=\"$webprefix/?cat=$c\">$t</a></td>\n";
			} else {
				print "\t\t\t\t<td class=\"top_menu\"><a href=\"$webprefix/?cat=$c\">$t</a></td>\n";
			}
		}
		print "\t\t\t</tr></table>";
		print "\t\t\t</div>\n";

	}

	print "\t\t\t<div id='body'>\n";
	

	if (@_ > 1 && (!$_[5] || $ENV{'HTTP_WEBMIN_SERVERS'})) { # Show tabs under module categories
   
		if ($gconfig{'sysinfo'} == 2 && $remote_user) {
		printf "%s%s logged into %s %s on %s (%s%s)</td>\n",
			$ENV{'ANONYMOUS_USER'} ? "Anonymous user" : "<tt>$remote_user</tt>",
			$ENV{'SSL_USER'} ? " (SSL certified)" :
			$ENV{'LOCAL_USER'} ? " (Local user)" : "",
			$text{'programname'},
			$version, "<tt>".&get_system_hostname()."</tt>",
			$os_type, $os_version eq "*" ? "" : " $os_version";
		}
		
	
	} elsif (@_ > 1) {
	}

@header_arguments = @_;
}

sub theme_prebody
{
}

sub theme_footer {
	local $i;
	
	if (@header_arguments > 1 && !$header_arguments[5]) {
		print "\t\t\t</div>\n";
	}
	
	print "\t\t\t<div id='backlink'>\n";
	
        $module_info{'category'} = "" unless $module_info{'category'};

	for ($i=0; $i+1<@_; $i+=2) {
		local $url = $_[$i];

		if ($url eq '/') {
			$url = "/?cat=$module_info{'category'}";
		} elsif ($url eq '' && $module_name) {
			local $idx = $module_info{'index_link'};
                        $idx = $DEFAULTINDEX unless $idx;
			$url = "/$module_name/$idx";
		} elsif ($url =~ /^\?/ && $module_name) {
			$url = "/$module_name/$url";
		}
		
		if ($i == 0) {
			print "&nbsp;<a href=\"$url\"><img alt=\"<-\" align=middle border=0 src='/images/arrow.gif'></a>\n";
		} else {
			print "&nbsp;|\n";
		}
		
		print "&nbsp;<a href=\"$url\">",&text('main_return', $_[$i+1]),"</a>\n";
	}

	print "\t\t\t</div>\n";
	
	
	if (!$_[$i]) {

		if (defined(&theme_postbody)) {
			&theme_postbody(@_);
		}
		
		print "  <div id=\"footer\" class=\"small\">";
		print "         <div class=\"left\"><!--Linbox FAS: Metz Technop&ocirc;le | 152, r. de Grigy | 57070 Metz, FRANCE-->";
        	print "         	<span style=\"font-weight:bold;\">Web</span>: <a href=\"http://www.linbox.com\">www.linbox.com</a> - ";
        	print "         	<span style=\"font-weight:bold;\">Support</span>: +33 (0)3 87 50 87 90 - ";
		print "         	<span style=\"font-weight:bold;\">Contact</span>: <a href=\"mailto:info&#64;linbox.com?subject=LRS Support\">info&#64;linbox.com</a>";
		print " 	</div>";
		print "         <div class=\"right\">&copy;&nbsp; 1996-2005 Linbox FAS&nbsp;</div>";
        	print "  </div>";
		print "</body></html>\n";
	}

}

1;