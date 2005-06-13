# log_parser.pl
# Functions for parsing this module's logs

do './cron-lib.pl';

# parse_webmin_log(user, script, action, type, object, &params, [long])
# Converts logged information from this module into human-readable form
sub parse_webmin_log
{
local ($user, $script, $action, $type, $object, $p, $long) = @_;
if ($action eq 'modify') {
	return &text($long ? 'log_modify_l' : 'log_modify',
		     "<tt>$object</tt>",
		     "<tt>".&html_escape($p->{'cmd'})."</tt>");
	}
elsif ($action eq 'create') {
	return &text($long ? 'log_create_l' : 'log_create',
		     "<tt>$object</tt>",
		     "<tt>".&html_escape($p->{'cmd'})."</tt>");
	}
elsif ($action eq 'delete') {
	return &text($long ? 'log_delete_l' : 'log_delete',
		     "<tt>$object</tt>",
		     "<tt>".&html_escape($p->{'command'})."</tt>");
	}
elsif ($action eq 'exec') {
	return &text($long ? 'log_exec_l' : 'log_exec',
		     "<tt>$object</tt>",
		     "<tt>".&html_escape($p->{'command'})."</tt>");
	}
elsif ($action eq 'allow') {
	return $text{'log_allow'};
	}
else {
	return undef;
	}
}

