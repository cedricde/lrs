#!/usr/bin/perl
# config_save.cgi
# Save inputs from config.cgi

require '../web-lib.pl';
require './config-lib.pl';
&init_config();
&ReadParse();
$m = $in{'module'};
&read_acl(\%acl);
&error_setup($text{'config_err'});
$acl{$base_remote_user,$m} || &error($text{'config_eaccess'});
%access = &get_module_acl(undef, $m);
$access{'noconfig'} && &error($text{'config_ecannot'});

&lock_file("/etc/aliases");

&parse_config(\%conf, "emails.info");

local $lref = &read_file_lines("/etc/aliases");
foreach $l (@$lref) {
    foreach $name ("admin","lrs","ocsinventory","backuppc","lsc") { 
        if ($l =~ /^$name: /i && defined ($conf{$name}) ) {
	    if ($conf{$name} ne "") {
        	$l = "$name: $conf{$name}";
	    } else {
		$l = undef;
	    }
	    $conf{$name} = undef;
	}
    }
}
# add new aliases at the end of file
foreach $name ("admin","lrs","ocsinventory","backuppc","lsc") { 
    if (defined ($conf{$name}) && $conf{$name} ne "") {
	push @$lref, "$name: $conf{$name}";
    } 
}
&flush_file_lines();
&unlock_file("/etc/aliases");

&redirect("index.cgi");
