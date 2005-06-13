
do './cron-lib.pl';

# useradmin_create_user(&details)
sub useradmin_create_user
{
}

# useradmin_delete_user(&details)
# Delete this user's cron file
sub useradmin_delete_user
{
&lock_file("$config{'cron_dir'}/$_[0]->{'user'}");
unlink("$config{'cron_dir'}/$_[0]->{'user'}");
&unlock_file("$config{'cron_dir'}/$_[0]->{'user'}");
}

# useradmin_modify_user(&details)
sub useradmin_modify_user
{
if ($_[0]->{'user'} ne $_[0]->{'olduser'}) {
	if (-r "$config{'cron_dir'}/$_[0]->{'olduser'}") {
		&rename_logged("$config{'cron_dir'}/$_[0]->{'olduser'}",
			       "$config{'cron_dir'}/$_[0]->{'user'}");
		}
	foreach $j (&list_cron_jobs()) {
		if ($j->{'user'} eq $_[0]->{'olduser'}) {
			&lock_file($j->{'file'});
			$j->{'user'} = $_[0]->{'user'};
			&change_cron_job($j);
			&unlock_file($j->{'file'});
			}
		}
	}
}

1;

