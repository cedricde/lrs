#!/usr/bin/perl
# save_env.cgi
# Save cron environment for some user

require './cron-lib.pl';
&ReadParse();
&can_edit_user(\%access, $in{'user'}) ||
	&error($text{'env_ecannot'});

for($i=0; $i<$in{count}; $i++) {
	$n = $in{"name$i"}; $v = $in{"value$i"};
	if ($n =~ /\S/) {
		if ($n !~ /^\S+$/) {
			&error(&text('env_ename', $n));
			}
		push(@args, $n);
		push(@args, $v);
		}
	}
&save_envs($in{'user'}, @args);
&redirect("edit_env.cgi?$in{'user'}");

