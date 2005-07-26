# cron-lib.pl
# Common cront table functions

do '../../web-lib.pl';
$gconfig{'overlang'} = "cron_lang";
&init_config();

# Override the default configuration
$config{'cron_input'}=0;
$config{'cron_deny_file'}="/var/spool/cron/deny";
$config{'cron_dir'}="/var/spool/cron/crontabs";
$config{'cron_deny_all'}=2;
$config{'cron_delete_command'}="crontab -u USER -r";
$config{'cron_edit_command'}="crontab -u USER -e";
$config{'cron_allow_file'}="/var/spool/cron/allow";
$config{'cron_get_command'}="crontab -u USER -l";
$config{'vixie_cron'}=1;
$config{'system_crontab'}="/dev/null";
$config{'cronfiles_dir'}="/dev/null";
$config{'run_parts'}="run-parts";


%access = &get_module_acl();
$cron_temp_file = &tempname();

# list_cron_jobs()
# Returns a lists of structures of all cron jobs
sub list_cron_jobs
{
local (@rv, $lnum, $f);

# read the master crontab file
if ($config{'vixie_cron'}) {
	$lnum = 0;
	open(TAB, $config{'system_crontab'});
	while(<TAB>) {
		if (/^(#+)?\s*(-)?\s*([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+(\S+)\s+(.*)/) {
			push(@rv, { 'file' => $config{'system_crontab'},
				    'line' => $lnum,
				    'type' => 1,
				    'nolog' => $2,
				    'active' => !$1,
				    'mins' => $3, 'hours' => $4,
				    'days' => $5, 'months' => $6,
				    'weekdays' => $7, 'user' => $8,
				    'command' => $9,
				    'index' => scalar(@rv) });
			if ($rv[$#rv]->{'user'} =~ /^\//) {
				# missing the user, as in redhaty 7 !
				$rv[$#rv]->{'command'} = $rv[$#rv]->{'user'}.
					' '.$rv[$#rv]->{'command'};
				$rv[$#rv]->{'user'} = 'root';
				}
			}
		$lnum++;
		}
	close(TAB);
	}

# read package-specific cron files
opendir(DIR, $config{'cronfiles_dir'});
while($f = readdir(DIR)) {
	next if ($f =~ /^\./);
	$lnum = 0;
	open(TAB, "$config{'cronfiles_dir'}/$f");
	while(<TAB>) {
		if (/^(#+)?\s*(-)?\s*([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+(\S+)\s+(.*)/) {
			push(@rv, { 'file' => "$config{'cronfiles_dir'}/$f",
				    'line' => $lnum,
				    'type' => 2,
				    'active' => !$1,
				    'nolog' => $2,
				    'mins' => $3, 'hours' => $4,
				    'days' => $5, 'months' => $6,
				    'weekdays' => $7, 'user' => $8,
				    'command' => $9,
				    'index' => scalar(@rv) });
			}
		$lnum++;
		}
	close(TAB);
	}
closedir(DIR);

# read per-user cron files
opendir(DIR, $config{'cron_dir'});
while($f = readdir(DIR)) {
	next if ($f =~ /^\./ || !(@uinfo = getpwnam($f)));
	$lnum = 0;
	open(TAB, "$config{'cron_dir'}/$f");
	while(<TAB>) {
		if (/^(#+)?\s*(-)?\s*([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+([0-9\-\*\/,]+)\s+(.*)/) {
			push(@rv, { 'file' => "$config{'cron_dir'}/$f",
				    'line' => $lnum,
				    'type' => 0,
				    'active' => !$1, 'nolog' => $2,
				    'mins' => $3, 'hours' => $4,
				    'days' => $5, 'months' => $6,
				    'weekdays' => $7, 'user' => $f,
				    'command' => $8,
				    'index' => scalar(@rv) });
			}
		$lnum++;
		}
	close(TAB);
	}
closedir(DIR);
return @rv;
}

sub cron_job_line
{
local @c;
push(@c, "#") if (!$_[0]->{'active'});
push(@c, ($_[0]->{'nolog'} ? '-' : '').$_[0]->{'mins'},
         $_[0]->{'hours'}, $_[0]->{'days'},
	 $_[0]->{'months'}, $_[0]->{'weekdays'});
push(@c, $_[0]->{'user'}) if ($_[0]->{'type'});
push(@c, $_[0]->{'command'});
return join(" ", @c);
}

# create_cron_job(&job)
sub create_cron_job
{
unlink($cron_temp_file);
system("cp $config{'cron_dir'}/$_[0]->{'user'} $cron_temp_file 2>/dev/null");
open(TAB, ">>$cron_temp_file");
print TAB &cron_job_line($_[0]),"\n";
close(TAB);
system("chown $_[0]->{'user'} $cron_temp_file");
&copy_crontab($_[0]->{'user'});
}

# change_cron_job(&job)
sub change_cron_job
{
if ($_[0]->{'type'} == 0) {
	unlink($cron_temp_file);
	system("cp $config{'cron_dir'}/$_[0]->{'user'} $cron_temp_file");
	&replace_file_line($cron_temp_file, $_[0]->{'line'},
			   &cron_job_line($_[0])."\n");
	&copy_crontab($_[0]->{'user'});
	}
else {
	&replace_file_line($_[0]->{'file'}, $_[0]->{'line'},
			   &cron_job_line($_[0])."\n");
	}
}

# delete_cron_job(&job)
sub delete_cron_job
{
if ($_[0]->{'type'} == 0) {
	unlink($cron_temp_file);
	system("cp $config{'cron_dir'}/$_[0]->{'user'} $cron_temp_file");
	&replace_file_line($cron_temp_file, $_[0]->{'line'});
	&copy_crontab($_[0]->{'user'});
	}
else {
	&replace_file_line($_[0]->{'file'}, $_[0]->{'line'});
	}
}

# read_crontab(user)
# Return an array containing the lines of the cron table for some user
sub read_crontab
{
local(@tab);
open(TAB, "$config{cron_dir}/$_[0]");
@tab = <TAB>;
close(TAB);
if ($config{vixie_cron} && $tab[0] =~ /DO NOT EDIT/ &&
    $tab[1] =~ /^\s*#/ && $tab[2] =~ /^\s*#/) {
	@tab = @tab[3..$#tab];
	}
return @tab;
}


# copy_crontab(user)
sub copy_crontab
{
local($pwd);
if (`cat $cron_temp_file` =~ /\S/) {
	if ($config{'cron_edit_command'}) {
		# fake being an editor
		chop($pwd = `pwd`);
		$ENV{"VISUAL"} = $ENV{"EDITOR"} = "$pwd/cron_editor.pl";
		$ENV{"CRON_EDITOR_COPY"} = $cron_temp_file;
		system("chown $_[0] $cron_temp_file");
		system(&user_sub($config{'cron_edit_command'},$_[0]).
		       " >/dev/null 2>/dev/null");
		}
	else {
		# use the cron copy command
		system(&user_sub($config{'cron_copy_command'},$_[0]).
		       " <$cron_temp_file >/dev/null 2>/dev/null");
		}
	}
else {
	system(&user_sub($config{cron_delete_command},$_[0]).
	       " >/dev/null 2>/dev/null");
	}
unlink($cron_temp_file);
}


# parse_job(job)
# Parse a crontab line into an array containing:
#  active, mins, hrs, days, mons, weekdays, command
sub parse_job
{
local($job, $active) = ($_[0], 1);
if ($job =~ /^#+\s*(.*)$/) {
	$active = 0;
	$job = $1;
	}
$job =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)$/;
return ($active, $1, $2, $3, $4, $5, $6);
}

# user_sub(command, user)
# Replace the string 'USER' in the command with the user name
sub user_sub
{
local($tmp);
$tmp = $_[0];
$tmp =~ s/USER/$_[1]/g;
return $tmp;
}


# list_allowed()
# Returns a list of all users in the cron allow file
sub list_allowed
{
local(@rv, $_);
open(ALLOW, $config{cron_allow_file});
while(<ALLOW>) {
	chop; push(@rv, $_);
	}
close(ALLOW);
return @rv;
}


# list_denied()
# Return a list of users from the cron deny file
sub list_denied
{
local(@rv, $_);
open(DENY, $config{cron_deny_file});
while(<DENY>) {
	chop; push(@rv, $_);
	}
close(DENY);
return @rv;
}


# save_allowed(user, user, ...)
# Save the list of allowed users
sub save_allowed
{
local($_);
open(ALLOW, ">$config{cron_allow_file}");
foreach (@_) { print ALLOW $_,"\n"; }
close(ALLOW);
chmod(0444, $config{cron_allow_file});
}


# save_denied(user, user, ...)
# Save the list of denied users
sub save_denied
{
local($_);
open(DENY, "> $config{cron_deny_file}");
foreach (@_) { print DENY $_,"\n"; }
close(DENY);
chmod(0444, $config{cron_deny_file});
}

# read_envs(user)
# Returns an array of name,value pairs containing the environment settings
# from the crontab for some user
sub read_envs
{
local(@tab, @rv, $_);
@tab = &read_crontab($_[0]);
foreach (@tab) {
	chop; s/#.*$//g;
	if (/^\s*(\S+)\s*=\s*(.*)$/) { push(@rv, "$1 $2"); }
	}
return @rv;
}

# save_envs(user, [name, value]*)
# Updates the cron file for some user with the given list of environment
# variables. All others in the file are removed
sub save_envs
{
local($i, @tab, $line);
@tab = &read_crontab($_[0]);
open(TAB, "> $cron_temp_file");
for($i=1; $i<@_; $i+=2) {
	print TAB "$_[$i]=$_[$i+1]\n";
	}
foreach (@tab) {
	chop($line = $_); $line =~ s/#.*$//g;
	if ($line !~ /^\s*(\S+)\s*=\s*(.*)$/) { print TAB $_; }
	}
close(TAB);
&copy_crontab($_[0]);
}

# expand_run_parts(directory)
sub expand_run_parts
{
local $dir = $_[0];
$dir = "$config{'run_parts_dir'}/$dir"
	if ($config{'run_parts_dir'} && $dir !~ /^\//);
opendir(DIR, $dir);
local @rv = readdir(DIR);
closedir(DIR);
@rv = grep { !/^\./ } @rv;
@rv = map { $dir."/".$_ } @rv;
return @rv;
}

# is_run_parts(command)
sub is_run_parts
{
local $rp = $config{'run_parts'};
return $rp && $_[0] =~ /$rp(.*)\s+(\S+)$/ ? $2 : undef;
}

# can_edit_user(&access, user)
sub can_edit_user
{
local %umap;
map { $umap{$_}++; } split(/\s+/, $_[0]->{'users'});
if ($_[0]->{'mode'} == 1 && !$umap{$_[1]} ||
    $_[0]->{'mode'} == 2 && $umap{$_[1]}) { return 0; }
elsif ($_[0]->{'mode'} == 3) {
	return $remote_user eq $_[1];
	}
else {
	return 1;
	}
}

# show_times_input(&job)
sub show_times_input
{
local $job = $_[0];
print "<td><b>$text{'edit_hours'}</b></td> <td><b>$text{'edit_mins'}</b></td> ",
      "<td><b>$text{'edit_days'}</b></td> <td><b>$text{'edit_months'}</b></td>",
      "<td><b>$text{'edit_weekdays'}</b></td> </tr> <tr $cb>\n";

local @mins = (0..59);
local @hours = (0..23);
local @days = (1..31);
local @months = map { $text{"month_$_"}."=".$_ } (1 .. 12);
local @weekdays = map { $text{"day_$_"}."=".$_ } (0 .. 6);

foreach $arr ("hours", "mins", "days", "months", "weekdays") {
	# Find out which ones are being used
	local %inuse;
	local $min = ($arr =~ /days|months/ ? 1 : 0);
	local $max = $min+scalar(@$arr)-1;
	foreach $w (split(/,/ , $job->{$arr})) {
		if ($w eq "*") {
			# all values
			for($j=$min; $j<=$max; $j++) { $inuse{$j}++; }
			}
		elsif ($w =~ /^\*\/(\d+)$/) {
			# only every Nth
			for($j=$min; $j<=$max; $j+=$1) { $inuse{$j}++; }
			}
		elsif ($w =~ /^(\d+)-(\d+)\/(\d+)$/) {
			# only every Nth of some range
			for($j=$1; $j<=$2; $j+=$3) { $inuse{int($j)}++; }
			}
		elsif ($w =~ /^(\d+)-(\d+)$/) {
			# all of some range
			for($j=$1; $j<=$2; $j++) { $inuse{int($j)}++; }
			}
		else {
			# One value
			$inuse{int($w)}++;
			}
		}
	if ($job->{$arr} eq "*") { undef(%inuse); }

	# Output selection list
	print "<td valign=top>\n";
	if ($arr eq "hours" || $arr eq "mins") {
	    print "<center><input type='text' size=2 name=$arr value='".$job->{$arr}."'></center>";
	    print "  <input type='hidden' name=all_$arr value=0>\n";
	} else {
	    printf "<input type=radio name=all_$arr value=1 %s> $text{'edit_all'}<br>\n",
		$job->{$arr} eq "*" ? "checked" : "";
	    printf "<input type=radio name=all_$arr value=0 %s> $text{'edit_selected'}<br>\n",
		$job->{$arr} ne "*" ? "checked" : "";
	    print "<table> <tr>\n";
	    for($j=0; $j<@$arr; $j+=12) {
		$jj = $j+11;
		if ($jj >= @$arr) { $jj = @$arr - 1; }
		@sec = @$arr[$j .. $jj];
		printf "<td valign=top><select multiple size=12 name=$arr>\n",
			@sec > 12 ? 12 : scalar(@sec);
		foreach $v (@sec) {
			if ($v =~ /^(.*)=(.*)$/) { $disp = $1; $code = $2; }
			else { $disp = $code = $v; }
			printf "<option value=\"$code\" %s>$disp\n",
				$inuse{$code} ? "selected" : "";
			}
		print "</select></td>\n";
	    }
	    print "</tr></table>\n";
	}
	print "</td>";
    }
print "</tr>\n";
}

# parse_times_input(&job, &in)
sub parse_times_input
{
local $job = $_[0];
local %in = %{$_[1]};
foreach $arr ("mins", "hours", "days", "months", "weekdays") {
	if ($in{"all_$arr"} || (defined($in{$arr}) && ($in{$arr} eq ""))) {
		# All mins/hrs/etc.. chosen
		$job->{$arr} = "*";
		}
	elsif (defined($in{$arr})) {
		# Need to work out and simplify ranges selected
		local (@range, @newrange, $i);
		@range = split(/\0/, $in{$arr});
		@range = sort { $a <=> $b } @range;
		local $start = -1;
		for($i=0; $i<@range; $i++) {
			if ($i && $range[$i]-1 == $range[$i-1]) {
				# ok.. looks like a range
				if ($start < 0) { $start = $i-1; }
				}
			elsif ($start < 0) {
				# Not in a range at all
				push(@newrange, $range[$i]);
				}
			else {
				# End of the range.. add it
				$newrange[@newrange - 1] =
					"$range[$start]-".$range[$i-1];
				push(@newrange, $range[$i]);
				$start = -1;
				}
			}
		if ($start >= 0) {
			# Reached the end while in a range
			$newrange[@newrange - 1] =
				"$range[$start]-".$range[$i-1];
			}
		$job->{$arr} = join(',' , @newrange);
		}
	else {
		&error(&text('save_enone', $text{"edit_$arr"}));
		}
	}
}

1;

