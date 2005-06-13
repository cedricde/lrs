#!/usr/bin/perl
# create_job.cgi
# Create a new at job

require 'timelocal.pl';

require './at-lib.pl';
&ReadParse();
&error_setup($text{'create_err'});
%access = &get_module_acl();

# Validate inputs
&can_edit_user(\%access, $in{'user'}) || &error($text{'create_ecannot'});
defined(getpwnam($in{'user'})) || &error($text{'create_euser'});
$in{'hour'} =~ /^\d+$/ && $in{'min'} =~ /^\d+$/ &&
	$in{'day'} =~ /^\d+$/ && $in{'year'} =~ /^\d+$/ ||
		&error($text{'create_edate'});
eval { $date = timelocal(0, $in{'min'}, $in{'hour'},
		         $in{'day'}, $in{'month'}, $in{'year'}-1900) };
$@ && &error($text{'create_edate'});
$date > time() || &error($text{'create_efuture'});
$in{'cmd'} =~ /\S/ || &error($text{'create_ecmd'});
-d $in{'dir'} || &error($text{'create_edir'});

# Create the job
&create_atjob($in{'user'}, $date, "$config{'wake'} $in{'cmd'} >/dev/null 2>&1", $in{'dir'});
&webmin_log("create", "job", $in{'user'}, \%in);

# redirect
my $redir = "";
if ($in{'group'} ne "") {
    $redir = "group=".$in{'group'}."&profile=".$in{'profile'};
} else {
    $redir = "mac=".urlize($in{'cmd'});
}

&redirect("index.cgi?$redir");

