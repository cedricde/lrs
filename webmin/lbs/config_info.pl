#
#
#

package main;
require './config-lib.pl';
package lbs;

sub config_form
{
  &main::generate_config($_[0], "./config.info");
}

sub config_save
{

  &main::parse_config($_[0], "./config.info");  
  
  # update the password
  &main::lock_file("/etc/lbs.conf");
  local $lref = &main::read_file_lines("/etc/lbs.conf");
  foreach $l (@$lref) {
    if ($l =~ /^adminpass\s*=/i && defined ($_[0]->{'add_password'}) ) {
	$l = "adminpass=$_[0]->{'add_password'}";
        }
    }
  &main::flush_file_lines();
  &main::unlock_file("/etc/lbs.conf");
  
  # write the warning message
  system ("echo $_[0]->{'warning_message'} > $main::config{'chemin_basedir'}/etc/warning.txt");
}

