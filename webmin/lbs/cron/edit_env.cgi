#!/usr/bin/perl
# edit_env.cgi
# Some cron versions support the definition of environment variables in the
# crontab. This form is for editing those variables

require './cron-lib.pl';
$u = $ARGV[0];
&can_edit_user(\%access, $u) ||
	&error($text{'env_ecannot'});
&header($text{'env_title'}, "");
print "<hr>\n";

print "<h3>",&text('env_desc', $u),"</h3>\n";
@envs = &read_envs($u);
print "<form action=save_env.cgi>\n";
print "<input type=hidden name=user value=\"$u\">\n";
printf "<input type=hidden name=count value=%d>\n", scalar(@envs)+1;
print "<table border>\n";
print "<tr $tb> <td><b>$text{'env_name'}</b></td> ",
      "<td><b>$text{'env_value'}</b></td> </tr>\n";
for($i=0; $i<=@envs; $i++) {
	$envs[$i] =~ /^(\S+) (.*)$/;
	printf "<tr $cb> <td><input name=name$i size=20 value=\"%s\"></td>\n",
		$i<@envs ? $1 : "";
	printf "<td><input name=value$i size=40 value=\"%s\"></td> </tr>\n",
		$i<@envs ? $2 : "";
	}
print "</table>\n";
print "<input type=submit value=\"$text{'save'}\"></form>\n";

print "<hr>\n";
&footer("", $text{'index_return'});
