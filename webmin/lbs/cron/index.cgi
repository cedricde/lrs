#!/usr/bin/perl
# index.cgi
# Display a list of all cron jobs, with the username and command for each one

require './cron-lib.pl';

chdir("$root_directory/lbs_common"); 
foreign_require("lbs_common", "lbs_common.pl"); 

lbs_common::print_header( $text{'index_title'}, "intro", "");
lbs_common::print_html_tabs(['list_of_machines', "wol_tasks", "cron"]);


#&header($text{'index_title'}, "", undef, 1, 1, 0,
#	&help_search_link("cron", "man", "doc"));
print "<hr>\n";
map { $ucan{$_}++ } split(/\s+/, $access{'users'});
@jobs = &list_cron_jobs();
@ulist = &unique(map { $_->{'user'} } @jobs);
@ulist = ( "root" ) ;
if ($access{'mode'} == 1) {
	@ulist = grep { $ucan{$_} } @ulist;
	}
elsif ($access{'mode'} == 2) {
	@ulist = grep { !$ucan{$_} } @ulist;
	}
elsif ($access{'mode'} == 3) {
	@ulist = ( $remote_user );
	}
foreach $u (@ulist) {
	if ((@uinfo = getpwnam($u)) && $uinfo[5] =~ /\S/) {
		$uname = "$u ($uinfo[5])";
		}
	else { $uname = $u; }

	@jlist = grep { $_->{'user'} eq $u } @jobs;
	@plist = ();
	for($i=0; $i<@jlist; $i++) {
		local $rpd = &is_run_parts($jlist[$i]->{'command'});
		local @exp = $rpd ? &expand_run_parts($rpd) : ();
		if (!$rpd || @exp) {
			push(@plist, [ $jlist[$i], \@exp ]);
			}
		}
	for($i=0; $i<@plist; $i++) {
		local $job = $plist[$i]->[0];
		local @exp = @{$plist[$i]->[1]};
		local $idx = $job->{'index'};
		if (!$donehead) {
			print "<table border width=100%> <tr $tb>\n";
			if (@ulist != 1) {
				print "<td><b>$text{'index_user'}</b></td>\n";
				}
			print "<td><b>$text{'index_active'}</b></td>\n";
			print "<td><b>$text{'index_command'}</b></td> </tr>\n";
			$donehead = 1;
			}
		if (!($job->{'command'} =~ /\/wake/)) { next; }
		print "<tr $cb>\n";
		if ($i == 0 && @ulist != 1) {
			printf "<td valign=top rowspan=%d>", scalar(@plist);
			#if ($config{'vixie_cron'}) {
			#	print "<a href=\"edit_env.cgi?$uname\">",
			#	      "$uname</a>";
			#	}
			#else { print $uname; }
			print &html_escape($uname);
			print "</td>\n";
			}
		printf "<td valign=top>%s</td>\n",
			$job->{'active'} ? $text{'yes'}
				: "<font color=#ff0000>$text{'no'}</font>";
		if (@exp) {
			@exp = map { &html_escape($_) } @exp;
			print "<td><a href=\"edit_cron.cgi?idx=$idx\">",
			      join("<br>",@exp),"</a></td>\n";
			}
		else {
			local $cmd = $job->{'command'};
			$cmd =~ s/$config{'wake'}/Wake On Lan, /;
			$cmd =~ s/>.dev.null//;
			$cmd =~ s/\\%/\0/g; $cmd =~ s/%.*$//;
			$cmd =~ s/\0/%/g;
			$cmd = &html_escape($cmd);
			printf "<td><a href=\"edit_cron.cgi?idx=$idx\">".
			       "%s</a>%s</td>\n",
				length($cmd) > 60 ? substr($cmd, 0, 60) :
				$cmd !~ /\S/ ? "BLANK" : $cmd,
				length($cmd) > 60 ? " ..." : "";
			}
		print "</tr>\n";
		}
	}
if ($donehead) {
	print "</table>\n";
	}
else {
	print "<b>$text{'index_none'}</b> <p>\n";
	}
print "<br><br><a href=\"edit_cron.cgi?new=1\">$text{'index_create'}</a> <p>\n";

if ($config{cron_allow_file} && $config{cron_deny_file} && $access{'allow'}) {
	print "<h3><a href=edit_allow.cgi>$text{'index_allow'}</a></h3>\n";
	}

lbs_common::print_end_menu();		
lbs_common::print_end_menu();		

footer("", $text{'index'});
