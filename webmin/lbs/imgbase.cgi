#!/usr/bin/perl -w
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

use strict;

# get some common functions ...
require "./lbs.pl";

# ... and vars
use vars qw (%access %config %in %lbsconf %text $VERSION);
lbs_common::init_lbs_conf() or exit(0) ;

ReadParse();

my $decor = 'style="text-decoration:none"' ;
my $lbs_home = $lbs_common::lbsconf{'basedir'};
my $imgdir = "$lbs_home/imgbase" ;
my ($image, $warning, $mesg, $buf) ;
my ($desc,$title) ;
my (%busage,%bdesc,%btitle,%bstat) ;
my @names ;

error(text("err_dnf",$lbs_home)) if (not -d $lbs_home);

# L'utilisateur a t-il le droit d'effectuer des modifs?
error( $text{'acl_error'} ) if ($access{'modify'});

if (exists $in{'cancel'}) {     					# CANCEL button pressed

	redirect("imgbase.cgi") ;
	exit(0) ;

} elsif (exists($in{'imgbase'}) and exists($in{'apply'})) {     	# APPLY button pressed

	$image = $in{'imgbase'} ;
	imgDeleteBase($lbs_home,$image) or error( lbsGetError() ) ;
	redirect("imgbase.cgi") ;
	exit(0) ;

} elsif (exists($in{'imgbase'})) {

	$image = $in{'imgbase'} ;
	imgBaseUsage($lbs_home, \%busage) or error(lbsGetError()) ;
	
	if ( (exists($busage{$image})) and (scalar(@{$busage{$image}})) ) {     # when some images are still in use
		@names = @{$busage{$image}} ;
		$mesg = text("err_imgbase_usedby",$image, "<ul><li>".join("</li><li>",@names)."</li></ul>") ;
		error($mesg) ;
	}

	# a simple message
	$mesg = text("msg_imgbase_delconfirm",$image) ;
	$mesg = "<h2>$mesg</h2>" ;
	
	# a warning message
	$warning = $text{'msg_imgbase_delwarn'} ;
	$warning = "<h2><font color=#FF0000>$warning</font></h2>" ;

	# the header
	lbs_common::print_header( $text{'tit_imgbase'}, "imgbase", $VERSION);
	lbs_common::print_html_tabs(['list_of_machines', 'shared_images']);
    
	# then the main part
	print_confirmation_form("imgbase.cgi", $mesg . $warning, "imgbase", $image ) ;
	
	# then the footer
	footer("", $text{'index'}) ;

} else {								# show images array
	imgBaseUsage($lbs_home, \%busage) or error(lbsGetError()) ;
	
	delete($busage{"Backup-L"});
	delete($busage{"Backup-B"});
	delete($busage{"Util-Mbr"});
	delete($busage{"Util-MemTest"});
	delete($busage{"Local-Disk"});
	delete($busage{"Local-Floppy"});
	
	foreach $image (keys %busage) {
		my $buf = '' ;
		my $ff = "imgbase/$image";
		if (not fileLoad("$imgdir/$image/conf.txt", \$buf)) {
			$btitle{$image} = $image ;
			$bdesc{$image}  = lbsGetError() ;
			$bstat{$image} = 2 ;
		}
		else {
			$bdesc{$image} =  itemGetVal($buf, 'desc')  || $text{'lab_nodesc'} ;
			$bdesc{$image} = "<a href='desc2.cgi?conf=$ff' $decor>$bdesc{$image}</a>";
			addBackupProgressInfo("$imgdir/$image/conf.txt", \$bdesc{$image});
			$btitle{$image} = itemGetVal($buf, 'title') || $text{'lab_notitle'};
			$btitle{$image} = "<a href='title2.cgi?conf=$ff' $decor>$btitle{$image}</a>";
			$bstat{$image} = 0 ;
		}
	}
	
	# headers	
	lbs_common::print_header( $text{'tit_imgbase'}, "imgbase", $VERSION);
	
	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'shared_images']);

	# lists available images
	images_base_usage(\%busage, \%btitle, \%bdesc, \%bstat, $imgdir) ;

	# end of tabs
	lbs_common::print_end_menu();		
	
	# and get out of here
	footer("", $text{'index'}) ;
}
