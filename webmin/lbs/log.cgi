#!/usr/bin/perl -w
#
# Show machine logs
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
  
  push @labelfunctions, sub {return ({'content' => $text{lab_status}, 'attribs'=> 'width="100%"'}); };
  push @bodyfunctions, \&status;
  push @labelfunctions, sub {return ({'content' => $text{lab_lastrestore}});};
  push @bodyfunctions, \&lastimg;
  push @labelfunctions, sub {return ({'content' => $text{lab_details}});};
  push @bodyfunctions, \&details_butt;

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
sub status
{
    my $inf = shift;

    if (defined($inf->{'mac'})) {
	return ({'content' => &last_status($inf->{'mac'})});
    } else {
	return ({'content' =>" "});
    }
}

sub last_status
{
    my $smac = lbs_common::mac_remove_columns(shift);

    my $file = "$lbs_home/images/$smac/log";
    if (-f $file)
      {
	my $all = read_file_lines($file);
	my $num = @$all;
	my $last1 = &logfile2txt(@$all[$num-1]) if ($num >= 1);
	my $last2 = &logfile2txt(@$all[$num-2]) if ($num >= 2);
	my $last3 = &logfile2txt(@$all[$num-3]) if ($num >= 3);

	my $ret = "<div width='100%' style='padding: 0px 0px 0px 0px'><div style='float:left; width:32%'>$last3</div><div style='float:left; width:32%'>$last2</div><div style='float:left; width:32%'>$last1</div></div>";
	return "$ret";
      }
    return "&nbsp;"
}

# transform a log entry into localized text
sub logfile2txt
{
  my $log = shift;
  my %trans = (
	       "booted" => [ $text{log_booted}, "led-grey.gif"],
	       "executing menu entry" => [ $text{log_menu}, "led-grey.gif" ],
	       "restoration started" => [ $text{log_restore_start}, "led-orange.gif" ],
	       "restoration completed" => [ $text{log_restore_end}, "led-green.gif" ],
	       "backup started" => [ $text{log_backup_start}, "led-orange.gif" ],
	       "backup completed" => [ $text{log_backup_end}, "led-green.gif" ],
	       "postinstall started" => [ $text{log_post_start}, "led-orange.gif" ],
	       "postinstall completed" => [ $text{log_post_end}, "led-green.gif" ],
	       "default set to" => [ $text{log_defaultset}, "led-grey.gif" ],
	       "critical error" => [ $text{log_critical}, "led-red.gif" ],

	      );

  if ($log =~ /([0-9A-E:]+) backup started \((.*)\)/) {
    # add backup progress info
    my $name = $2;
    my $mac = $1;
    my $smac = lbs_common::mac_remove_columns($mac);
    my $dir = "$lbs_home/imgbase/$name";
    if ($name =~ /local/i) {
      $dir = "$lbs_home/images/$smac/$name";
    }
    if (-r $dir."/conf.tmp" && -r $dir."/progress.txt") {
      my $l = read_file_lines($dir."/progress.txt");
      $log .= " ".$text{'lab_partition'}." ".$$l[0];
    }
  }

  if ($log =~ /([0-9A-E:]+) restoration started \((.*)\)/) {
    # add restoration progress info
    my $name = $2;
    my $mac = $1;
    my $smac = lbs_common::mac_remove_columns($mac);
    my $dir = "$lbs_home/images/$smac/";
    if (-r $dir."/progress.txt") {
      my $l = read_file_lines($dir."/progress.txt");
      $log .= " ".$$l[0];
    }
  }
  # cut long image names
  $log =~ s/\(Base-([0-9A-F]+)-/\(Base- $1-/;

  foreach my $key (keys %trans) {
    if ($log =~ /($key) ?(.*)/) {
      return "<img align='middle' src='images/$trans{$1}[1]'>&nbsp;".$trans{$1}[0]."&nbsp;".$2;
    }
  }
  return $log;
}

sub logfile2txt_date
{
  my $log = shift;
  my $date = "";
  if ($log =~ /^(.*): /) {
    my $locale = "en";
    if ($current_lang eq "fr") { $locale = "fr_FR" };
    if ($current_lang eq "de") { $locale = "de_DE" };
    $date = `env LC_TIME=$locale date -d "$1" +%c`;
    chomp($date);
  }
  return $date.": ".logfile2txt($log);
}

# return the last restored image
sub lastimg
{
  my $inf = shift;
  
  if (defined($inf->{'mac'})) {
    my $smac = lbs_common::mac_remove_columns($inf->{'mac'});
    my $file = "$lbs_home/images/$smac/log.lastrestore";
    if (-f $file)
      {
	my $all = read_file_lines($file);	
	my $last = logfile2txt_date(@$all[0]);

	$last =~ s/[0-9]+:[0-9]+:[0-9]+//; # remove the hour	
	if ($last =~ /(.* 20[0-9]+).*\((.*)\)/) {
	  my $d = ucfirst($1);
	  my $n = $2;
	  my $n2 = $n;

	  $d =~ s/ /&nbsp;/g;
	  $n2 =~ s/ //g;
	  if (-d "$lbs_home/imgbase/$n2") {
	    return ({'content' => "<small>$d:</small> <a href='details.cgi?conf=/imgbase/$n2'>$n</a>"});
	  }
	  elsif (-d "$lbs_home/images/$smac/$n2") {
	    return ({'content' => "<small>$d:</small> <a href='details.cgi?conf=/images/$smac/$n2'>$n</a>"});
	  }
	  else {
	    return ({'content' => "<small>$d:</small> $n"});
	  }
	  

	}
      }
    return ({'content' => "&nbsp;"});

  } else {
    return ({'content' => "&nbsp;"});
  }
}

# more details button
sub details_butt
{
  my $inf = shift;

  if (defined($inf->{'mac'}))
    {
      my $smac = lbs_common::mac_remove_columns($inf->{'mac'});
      my $file = "$lbs_home/images/$smac/log";
      if (-f $file) {
	return ({'content' => "<a href='log.cgi?mac=$smac'><img src='images/detail.gif'></a>"});
      }
    }

  return ({'content' => "&nbsp;"});
}

# more log details
sub morelog
{
  my $smac = lbs_common::mac_remove_columns(shift);

  my $file = "$lbs_home/images/$smac/log";
  if (-f $file)
    {
      my $all = read_file_lines($file);
      my $num = @$all;

      print "<h2>$text{lab_status}:</h2>";
      print "<pre>";
      foreach my $l (@$all) {
	print logfile2txt_date($l)."<br>";
      }
      print "</pre>";

    }
  
}
