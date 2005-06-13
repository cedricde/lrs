#!/usr/bin/perl
# exec_cron.cgi
# Execute an existing cron job, and display the output

require './cron-lib.pl';
&ReadParse();

@jobs = &list_cron_jobs();
$job = $jobs[$in{'idx'}];
&can_edit_user(\%access, $job->{'user'}) || &error($text{'exec_ecannot'});
&foreign_require("proc", "proc-lib.pl");

# split command into command and input
$job->{'command'} =~ s/\\%/\0/g;
@lines = split(/%/ , $job->{'command'});
foreach (@lines) { s/\0/%/g; }
for($i=1; $i<@lines; $i++) {
	$input .= $lines[$i]."\n";
	}

$| = 1;
$theme_no_table++;
&header($text{'exec_title'}, "");
print "<hr>\n";
&additional_log('exec', undef, $lines[0]);
&webmin_log("exec", "cron", $job->{'user'}, $job);

# Remove variables that wouldn't be in the 'real' cron
foreach $e ('SERVER_PORT', 'GATEWAY_INTERFACE', 'WEBMIN_VAR', 'SERVER_ROOT',
	    'REMOTE_USER', 'SERVER_ADMIN', 'REQUEST_METHOD', 'REMOTE_HOST',
	    'REMOTE_ADDR', 'SERVER_SOFTWARE', 'PATH_TRANSLATED', 'QUERY_STRING',
	    'MINISERV_CONFIG', 'SERVER_NAME', 'SERVER_PROTOCOL', 'REQUEST_URI',
	    'DOCUMENT_ROOT', 'WEBMIN_CONFIG', 'SESSION_ID', 'PATH_INFO',
	    'BASE_REMOTE_USER') {
	delete($ENV{$e});
	}
foreach $e (keys %ENV) {
	delete($ENV{$e}) if ($e =~ /^HTTP_/);
	}

# Set cron environment variables
foreach $e (&read_envs($job->{'user'})) {
	$ENV{$1} = $2 if ($e =~ /^(\S+)\s+(.*)$/);
	}

# Get command and switch uid/gid
@uinfo = getpwnam($job->{'user'});
$ENV{"HOME"} = $uinfo[7];
$ENV{"SHELL"} = "/bin/sh";
$ENV{"LOGNAME"} = $ENV{"USER"} = $job->{'user'};
$( = $uinfo[3];
$) = "$uinfo[3] $uinfo[3]";
($>, $<) = ($uinfo[2], $uinfo[2]);

# Execute cron command and display output..
print &text('exec_cmd', "<tt>$lines[0]</tt>"),"<p>\n";
print "<pre>";
$got = &foreign_call("proc", "safe_process_exec",
		     $lines[0], 0, 0, STDOUT, $input, 1);
print "<i>$text{'exec_none'}</i>\n" if (!$got);
print "</pre>\n";

print "<hr>\n";
&footer("edit_cron.cgi?idx=$in{'idx'}", $text{'edit_return'},
	"", $text{'index_return'});

