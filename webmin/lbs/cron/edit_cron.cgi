#!/usr/bin/perl
# edit_cron.cgi
# Edit an existing or new cron job

require './cron-lib.pl';
&ReadParse();

chdir("$root_directory/lbs_common"); 
foreign_require("lbs_common", "lbs_common.pl"); 

lbs_common::print_header( $text{'index_title'}, "help", "");
lbs_common::print_html_tabs(['list_of_machines', "wol_tasks", "cron"]);

if ($in{'new'}==0) {
    @jobs = &list_cron_jobs();
    $job = $jobs[$in{'idx'}];
    &can_edit_user(\%access, $job->{'user'}) ||
    	&error($text{'edit_ecannot'});
    &header($text{'edit_title'}, "");
}
elsif ($in{'new'}==1) {
    &header($text{'create_title'}, "");
    $job = { 'mins' => '0',
	     'hours' => '8',
	     'days' => '*',
	     'months' => '*',
	     'weekdays' => '*',
	     'active' => 1 };	
}
elsif ($in{'new'}==2) {
    &header($text{'create_title'}, "");
    $job = { 
	'user' => 'root',
	'command' => 'rsync%/usr/share/webmin/rsync/1394_rsync',
	'mins' => '0',
	'hours' => '22',
	'days' => '*',
	'months' => '*',
	'weekdays' => '4',
	'active' => 1 };
}

print "<hr>\n";
print "<form action=save_cron.cgi>\n";
print "<input type=hidden name=new value='$in{'new'}'>\n";
print "<input type=hidden name=idx value='$in{'idx'}'>\n";
print "<input type=hidden name=group value='".$in{'group'}."'>\n";
print "<input type=hidden name=profile value='".$in{'profile'}."'>\n";
print "<table border width=100%>\n";
print "<tr $tb> <td><b>$text{'edit_details'}</b></td> </tr>\n";
print "<tr $cb> <td><table width=100%>\n";

print "<tr>"; #<td><b>$text{'edit_user'}</b></td>\n";
#print "<td><tt>root</tt></td>\n";
print "<input type=hidden name=user value='root'>\n";

print "<td> <b>$text{'edit_active'}</b></td>\n";
printf "<td><input type=radio name=active value=1 %s> $text{'yes'}\n",
	$job->{'active'} ? "checked" : "";
printf "<input type=radio name=active value=0 %s> $text{'no'}</td> </tr>\n",
	$job->{'active'} ? "" : "checked";

$rpd = &is_run_parts($job->{'command'});
if ($rpd) {
	# run-parts command.. just show scripts that will be run
	print "<tr> <td valign=top><b>$text{'edit_commands'}</b></td>\n";
	print "<td><tt>",join("<br>",&expand_run_parts($rpd)),
	      "</tt></td> </tr>\n";
	print "<input type=hidden name=cmd value='$job->{'command'}'>\n";
	}
else {
	# Normal cron job.. can edit command
	$job->{'command'} =~ s/\\%/\0/g;
	$job->{'command'} =~ s/$config{'wake'}\s+//g;
	@lines = split(/%/ , $job->{'command'});
	if ($in{ext_cmd} ne "") {
	    $lines = [];
	    $lines[0] = $in{ext_cmd};
	}
	foreach (@lines) { s/\0/%/g; }
	print "<tr> <td><b>$text{'edit_command'}</b></td>\n";
	print "<td colspan=3><textarea name=cmd rows=5 cols=55>",
	      &html_escape($lines[0]),"</textarea></td> </tr>\n";

	#if ($config{'cron_input'}) {
	#	print "<tr> <td valign=top><b>$text{'edit_input'}</b></td>\n";
	#	print "<td colspan=3><textarea name=input rows=3 cols=50>",
	#	      join("\n" , @lines[1 .. @lines-1]),"</textarea></td> </tr>\n";
	#	}
	}

print "</table></td></tr></table><p>\n";

print "<table border width=100%>\n";
print "<tr $tb> <td colspan=5><b>$text{'edit_when'}</b></td> </tr> <tr $tb>\n";
&show_times_input($job);
print "</table>\n";

if (!$in{'new'}) {
	print "<table width=100%>\n";
	print "<tr> <td align=left class='noborder'><input type=submit value=\"$text{'save'}\"></td>\n";
	if (!$rpd) {
		print "</form><form action=\"exec_cron.cgi\">\n";
		print "<input type=hidden name=idx value=\"$in{'idx'}\">\n";
		print "<td align=center class='noborder'>",
		      "<input type=submit value=\"$text{'edit_run'}\"></td>\n";
		}
	print "</form><form action=\"delete_cron.cgi\">\n";
	print "<input type=hidden name=idx value=\"$in{'idx'}\">\n";
	print "<td align=right class='noborder'><input type=submit value=\"$text{'delete'}\"></td> </tr>\n";
	print "</form></table><p>\n";
	}
else {
	print "<input type=submit value=\"$text{'create'}\"></form><p>\n";
	}

lbs_common::print_end_menu();		
lbs_common::print_end_menu();		

footer("", $text{'index'});

#print "<hr>\n";
#&footer("", $text{'index_return'});

