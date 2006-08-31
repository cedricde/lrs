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
				  -value => html_escape($in{group}),
				  -expires => '+1M'
				 );
      print "Set-Cookie: $c\n";
    }

    if ($in{profile} || $in{profile} eq "") {
      my $c = new CGI::Cookie(-name => 'profile',
				  -value => html_escape($in{profile}),
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

  if (!$in{'group'}) {
    if ( defined($cookies{'group'}) ) {
      $in{'group'} = html_escape($cookies{'group'}->value);
    }
  }
  if (! defined($in{'profile'}) ) {
    if ( defined($cookies{'profile'}) ) {
      $in{'profile'} = html_escape($cookies{'profile'}->value);
    }
  }
}

1;
