#!/usr/bin/perl
# config.cgi
# Display a form for editing some entries of /etc/aliases

require "lbs_common.pl";
require './config-lib.pl';

init_lbs_conf() or exit(0) ;

$m = "lbs_common";
%access = &get_module_acl(undef, $m);
$access{'noconfig'} &&
	&error($text{'config_ecannot'});
%module_info = &get_module_info($m);


print_header( $text{'config_title'}, "index", $VERSION);
print_html_tabs(['list_of_machines', '']);

print "<center><font size=+2>$text{'config_title'} ",&text('config_dir', $module_info{'desc'}),
      "</font></center>\n";
print "<hr>\n";

print "<form action=\"emails_save.cgi\" method=post>\n";
print "<input type=hidden name=module value=\"$m\">\n";
print "<table border>\n";
print "<tr $tb> <td><b>",&text('config_header', $module_info{'desc'}),
      "</b></td> </tr>\n";
print "<tr $cb> <td><table width=100%>\n";

#&read_file("/etc/lbs.conf", \%conf);

local $lref = &read_file_lines("/etc/aliases");
foreach $l (@$lref) {
    if ($l =~ /^admin: (.*)/) {
	$conf{'admin'} = $1;
    }
    if ($l =~ /^backuppc: (.*)/) {
	$conf{'backuppc'} = $1;
    }
    if ($l =~ /^lrs: (.*)/) {
	$conf{'lrs'} = $1;
    }
    if ($l =~ /^ocsinventory: (.*)/) {
	$conf{'ocsinventory'} = $1;
    }
}

&generate_config(\%conf, "emails.info");

print "</table></td></tr></table>\n";
print "<input type=submit value=\"$text{'save'}\"></form>\n";
print "<hr>\n";

# end of tabs                                                                   
print_end_menu();                                                   
print_end_menu(); 

&footer("/lbs_common/", $text{'index'});
