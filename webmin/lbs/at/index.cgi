#!/usr/bin/perl
# index.cgi
# List all at jobs and display a form for creating a new one
#

use POSIX;

require './at-lib.pl';

%access = &get_module_acl();

ReadParse() ;

chdir("$root_directory/lbs_common"); 
foreign_require("lbs_common", "lbs_common.pl"); 

lbs_common::print_header( $text{'index_title'}, "imgbase", "");
lbs_common::print_html_tabs(['list_of_machines', "wol_tasks", "at"]);

@jobs = &list_atjobs();
@jobs = grep { &can_edit_user(\%access, $_->{'user'}) } @jobs;
if (@jobs) {
	@jobs = sort { $a->{'id'} <=> $b->{'id'} } @jobs;
	print "<h2>$text{'index_title'}:</h2>\n";
	print "<table border width=100%>\n";
	print "<tr $tb> <td><b>$text{'index_id'}</b></td>\n";
	print "<td><b>$text{'index_user'}</b></td>\n";
	print "<td><b>$text{'index_exec'}</b></td>\n";
	print "<td><b>$text{'index_created'}</b></td>\n";
	print "<td><b>$text{'index_cmd'}</b></td> </tr>\n";
	foreach $j (@jobs) {
		print "<tr $cb>\n";
		print "<td><a href='edit_job.cgi?id=$j->{'id'}'>",
		      "$j->{'id'}</td>\n";
		print "<td>",&html_escape($j->{'user'}),"</b></td>\n";
		$date = localtime($j->{'date'});
		print "<td><tt>$date</tt></td>\n";
		$created = localtime($j->{'created'});
		print "<td><tt>$created</tt></td>\n";
		print "<td>",join("<br>", split(/\n/, &html_escape($j->{'realcmd'}))),"</td>\n";
		print "</tr>\n";
		}
	print "</table><br><hr>\n";
} else {
	print "<h2>$text{'index_title'}: <i>$text{'index_none'}</i></h2>\n";
    
}

print "<form action=create_job.cgi>\n";
print "<table border>\n";
print "<tr $tb> <td><b>$text{'index_header'}</b></td> </tr>\n";
print "<tr $cb> <td><table>\n";

print "<input type=hidden name=user value='root'>\n";
print "<input type=hidden name=group value='".$in{'group'}."'>\n";
print "<input type=hidden name=profile value='".$in{'profile'}."'>\n";

@now = localtime(time());
print "<tr> <td><b>$text{'index_date'}</b></td>\n";
printf "<td><input name=day size=2 value='%d'>/", $now[3];
print "<select name=month>\n";
for($i=0; $i<12; $i++) {
	printf "<option value=%s %s>%s\n",
		$i, $now[4] == $i ? 'selected' : '', $text{"smonth_".($i+1)};
	}
print "</select>/";
printf "<input name=year size=4 value='%d'>\n", $now[5] + 1900;
print &date_chooser_button("day", "month", "year"),"</td>\n";

print "<td><b>$text{'index_time'}</b></td>\n";
print "<td><input name=hour size=2>:<input name=min size=2 value='00'></td> </tr>\n";

($date, $time) = split(/\s+/, &make_date(time()));

print "<tr> <td class='noborder'><b>$text{'index_cdate'}</b></td>\n";
print "<td class='noborder'>$date</td>\n";

print "<td class='noborder'><b>$text{'index_ctime'}</b></td>\n";
print "<td class='noborder'>$time</td> </tr>\n";

print "<input type=hidden name=dir value='/'>\n";

print "<tr> <td class='noborder'valign=middle><b>$text{'index_mac'}</b></td>\n";
print "<td class='noborder' colspan=3><textarea rows=5 cols=40 name=cmd>$in{ext_cmd}</textarea></td></tr>\n";

print "<tr> <td  class='noborder' colspan=4 align=right>",
      "<input type=submit value='$text{'create'}'></td> </tr>\n";

print "</table></td></tr></table></form>\n";
print "<hr>\n";

# end of tabs
lbs_common::print_end_menu();		
lbs_common::print_end_menu();		

footer("/", $text{'index'});
