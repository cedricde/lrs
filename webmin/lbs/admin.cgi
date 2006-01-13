#!/usr/bin/perl -w
#
# Show the admin panel
#
# $Id$
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

# stay strict
use strict;
use DB_File;;
use Fcntl;
# get some common functions ...
require 'lbs.pl';

# ... and vars
ReadParse();
use vars qw (%in %text $root_directory %gconfig $VERSION $LRS_HERE @LRS_MODULES %config %lbsconf $lbs_home $current_lang);

lbs_common::init_lbs_conf() or exit(0) ;
$lbs_home = $lbs_common::lbsconf{'basedir'};
# entete
lbs_common::print_header( $text{'tit_index'}, "index", $VERSION);

if (!defined $in{mac}) {

  # tabs
  lbs_common::print_html_tabs(['list_of_machines', 'logs']);

  # machine list
  my (@labelfunctions, @bodyfunctions);
  
  push @labelfunctions, sub {return ({'content' => "Renommer" }); };
  push @bodyfunctions, \&rename;
  push @labelfunctions, sub {return ({'content' => "Changer MAC" }); };
  push @bodyfunctions, \&renamemac;
  push @labelfunctions, sub {return ({'content' => "Supprimer" });};
  push @bodyfunctions, \&delete;

  lbs_common::print_machines_list(
                                        {
                                        },
                                        \@labelfunctions,
                                        \@bodyfunctions
                                );
} else {
  # log details
  lbs_common::print_html_tabs(['system_backup', 'logs']);

  &morelog($in{mac});
}


# end of tabs
lbs_common::print_end_menu();
lbs_common::print_end_menu();

# pied de page
footer("/", text('index'));

#
# Functions printing columns
#
sub rename
{
  my $inf = shift;

  if (defined($inf->{'mac'}))
    {
      my $mac = $inf->{'mac'};
      
      return ({'content' => "<a href='/lbs/rename.cgi?mac=$mac'><img src='images/detail.gif'></a>"});
      
    }

  return ({'content' => "&nbsp;"});
}

#
sub renamemac
{
  my $inf = shift;

  if (defined($inf->{'mac'}))
    {
      my $mac = $inf->{'mac'};
      return ({'content' => "<a href='/lbs/renamemac.cgi?mac=$mac'><img src='images/detail.gif'></a>"});
    }

  return ({'content' => "&nbsp;"});
}



# delete one machine
sub delete
{
  my $inf = shift;

  if (defined($inf->{'mac'}))
    {
      my $mac = $inf->{'mac'};
      return ({'content' => "<a href='/lbs/delete.cgi?mac=$mac'><img src='images/trash.gif'></a>"});
    }

  return ({'content' => "&nbsp;"});
}

