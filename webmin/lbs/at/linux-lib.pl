# linux-lib.pl


foreach my $d ( ("/var/spool/at","/var/spool/cron/atjobs","/var/spool/atjobs") ) {
    if (-d $d) {
	$config{'at_dir'} = $d;
	last;
    }
}

sub list_atjobs
{
local @rv;
opendir(DIR, $config{'at_dir'});
while($f = readdir(DIR)) {
	local $p = "$config{'at_dir'}/$f";
	if ($f =~ /^a(\S{5})(\S+)$/) {
		local @st = stat($p);
		local $job = { 'id' => hex($1),
			       'date' => hex($2) * 60,
			       'user' => scalar(getpwuid($st[4])),
			       'created' => $st[9] };
		open(FILE, $p);
		while(<FILE>) {
			$job->{'cmd'} .= $_;
			}
		close(FILE);
		$job->{'realcmd'} = $job->{'cmd'};
		$job->{'realcmd'} =~ s/^[\000-\177]+cd\s+(\S+)\s+\|\|\s+{\n.*\n.*\n.*\n//;
		$job->{'realcmd'} =~ s/^[a-z\/ ]+//;
		$job->{'realcmd'} =~ s/>\/.*$//;		
		if ($job->{'cmd'} =~ /revoboot/) {
		    push(@rv, $job);
		}
	   }
	}
closedir(DIR);
return @rv;
}

# create_atjob(user, time, commands, directory)
sub create_atjob
{
local @tm = localtime($_[1]);
local $date = sprintf "%2.2d:%2.2d %d.%d.%d",
		$tm[2], $tm[1], $tm[3], $tm[4]+1, $tm[5]+1900;
open(AT, "| su \"$_[0]\" -c \"cd $_[3] ; at $date\" >/dev/null 2>&1"); 
print AT $_[2];
close(AT);
&additional_log('exec', undef, "su \"$_[0]\" -c \"cd $_[3] ; at $date\"");
}

# delete_atjob(id)
sub delete_atjob
{
&system_logged("atrm \"$_[0]\" >/dev/null 2>&1");
}

