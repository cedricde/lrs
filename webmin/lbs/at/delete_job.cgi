#!/usr/bin/perl
# delete_job.cgi

require './at-lib.pl';
&ReadParse();
&error_setup($text{'delete_err'});
@jobs = &list_atjobs();
($job) = grep { $_->{'id'} eq $in{'id'} } @jobs;
$job || &error($text{'delete_egone'});
%access = &get_module_acl();
&can_edit_user(\%access, $job->{'user'}) || &error($text{'edit_ecannot'});
&delete_atjob($in{'id'});
&webmin_log("delete", "job", $job->{'user'}, $job);
&redirect("");

