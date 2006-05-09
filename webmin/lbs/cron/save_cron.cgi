#!/usr/bin/perl
# save_cron.cgi
# Save an existing cron job, or create a new one

require './cron-lib.pl';
&error_setup($text{'save_err'});
&ReadParse();

@jobs = &list_cron_jobs();
if ($in{'new'}) {
	$job = { 'type' => 0 };
	}
else {
	$oldjob = $jobs[$in{'idx'}];
	$job->{'type'} = $oldjob->{'type'};
	$job->{'file'} = $oldjob->{'file'};
	$job->{'line'} = $oldjob->{'line'};
	$job->{'nolog'} = $oldjob->{'nolog'};
	}

@files = &unique((map { $_->{'file'} } @jobs),
	         "$config{'cron_dir'}/$in{'user'}");
foreach $f (@files) { &lock_file($f); }

# Check and parse inputs
if ($in{"cmd"} !~ /\S/) {
	&error($text{'save_ecmd'});
	}
if (!$in{'user'}) {
	&error($text{'save_euser'});
	}
if (!defined(getpwnam($in{'user'}))) {
	&error(&text('save_euser2', $in{'user'}));
	}
&parse_times_input($job, \%in);
$in{input} =~ s/\r//g; 
$in{input} =~ s/%/\\%/g;
$in{cmd} =~ s/%/\\%/g;
$in{cmd} =~ s/[\n\r ]+/ /g;
$in{cmd} = $config{'wake'}." ".$in{'cmd'}." >/dev/null";
$job->{'active'} = $in{'active'};
$job->{'command'} = $in{'cmd'};
if ($in{input} =~ /\S/) {
	@inlines = split(/\n/ , $in{input});
	$job->{'command'} .= '%'.join('%' , @inlines);
	}

# Check if this user is allowed to execute cron jobs
if (-r $config{cron_allow_file}) {
	if (&indexof($in{user}, &list_allowed()) < 0) { $err = 1; }
	}
elsif (-r $config{cron_deny_file}) {
	if (&indexof($in{user}, &list_denied()) >= 0) { $err = 1; }
	}
elsif ($config{cron_deny_all} == 0) { $err = 1; }
elsif ($config{cron_deny_all} == 1) {
	if ($in{user} ne "root") { $err = 1; }
	}
#if ($err) { &error(&text('save_eallow', $in{'user'})); }
$job->{'user'} = $in{'user'};

# Check module access control
#&can_edit_user(\%access, $in{'user'}) ||
#	&error(&text('save_ecannot', $in{'user'}));

if (!$in{'new'}) {
	# Editing an existing job
	&can_edit_user(\%access, $oldjob->{'user'}) ||
		&error(&text('save_ecannot', $oldjob->{'user'}));
	if ($job->{'user'} eq $oldjob->{'user'}) {
		&change_cron_job($job);
		}
	else {
		&delete_cron_job($oldjob);
		&create_cron_job($job);
		}
	}
else {
	# Creating a new job
	&create_cron_job($job);
	}

foreach $f (@files) { &unlock_file($f); }
if ($in{'new'}) {
	&webmin_log("create", "cron", $in{'user'}, \%in);
	}
else {
	&webmin_log("modify", "cron", $in{'user'}, \%in);
	}

# redirect
my $redir = "";
if ($in{'group'} ne "") {
    $redir = "group=".$in{'group'}."&profile=".$in{'profile'};
} else {
    $redir = "mac=".urlize($in{'cmd'});
}

&redirect("index.cgi?$redir");
