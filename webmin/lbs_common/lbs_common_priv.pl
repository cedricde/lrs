# $Id$
#
# lbs_common functions which should not be useful outside lbs_common
#

use strict;

use CGI::Cookie;

#
# Send cookies to remember the current opened group
#
sub cookie_send_group($)
{
    my %params = shift;

    if ($in{group}) {
      my $c = new CGI::Cookie(-name => 'group',
				  -value => $in{group},
				  -expires => '+1M'
				 );
      print "Set-Cookie: $c\n";
    }
    if ($in{profile}) {
      my $c = new CGI::Cookie(-name => 'profile',
				  -value => $in{profile},
				  -expires => '+1M'
				 );
      print "Set-Cookie: $c\n";
    }
}

#
# Set group and profile from cookies
#
sub cookie_get_group($)
{
  my %cookies = fetch CGI::Cookie;
  my $in = %{$_[0]};

  if (!$in{group}) {
    if ( defined($cookies{'group'}) ) {
      $in{'group'} = $cookies{'group'}->value;
    }
  }
  if (!$in{profile}) {
    if ( defined($cookies{'profile'}) ) {
      $in{'profile'} = $cookies{'profile'}->value;
    }
  }
}

1;