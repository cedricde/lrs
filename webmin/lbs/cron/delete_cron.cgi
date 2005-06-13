#!/usr/bin/perl
# delete_cron.cgi
# Delete a cron job for some user

require './cron-lib.pl';
&ReadParse();
@jobs = &list_cron_jobs();
$job = $jobs[$in{'idx'}];
&lock_file($job->{'file'});
&can_edit_user(\%access, $job->{'user'}) ||
	&error("You are not allowed to delete cron jobs for this user");
&delete_cron_job($job);
&unlock_file($job->{'file'});
&webmin_log("delete", "cron", $job->{'user'}, $job);
&redirect("");

