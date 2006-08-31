#!/usr/bin/perl -w
#
# $Id$

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

# some common functions
sub lbl_ParseImageDirs {
	my $root=shift;
	my @list=();

	# do not display netapp snapshots
	open F,"find $root -name \"CONF\" -print |grep -v \.snapshot|";
	
	while (<F>) {
		chomp;
		push @list,substr($_,0,-4);
	}
	
	close(F);
	
	return sort(@list);
}

sub lbl_ParseIsoDir {
	my $basedir=shift;
        my @isolist;
        
	# list the ethernet mac address found in the OCS inventory dir
	if (opendir ISODIR, $basedir) {
		@isolist =      sort                                    # sort list
                                grep /.*\.iso$/i,                       # keep .iso files
                                grep { -f "$basedir/$_" }              # keep regular files
                                grep { -r "$basedir/$_" }               # keep readable stuff
                                readdir ISODIR;
                close ISODIR;      
        }

        return @isolist;
}

sub simplify {
	my $base=shift;
	my $fulldir=shift;
	my $result;
	
	$fulldir =~ m/$base(.*)/;
	$result="...".$1;
	
	if ( $result =~ m/images\// ) {
		my $s=substr($result,11,12);
		open F, $base."/etc/ether";
		while (<F>) {
			chomp;
			s/://g;
			next unless /$s(.*)/;
			my ($ip,$name)=split ' ',$1;
			$result="$result ($name)"; return $result;
		}
		close(F);
	}
	
	return $result;
}

sub get_desc {
	my $i=shift;
	my ($title,$desc)=("None","None");
	
	open F,$i."/conf.txt" or return ('title', $desc);
	while (<F>) {
		chomp;
		if (m/^\s*title (.*)/) {$title=$1;}
		if (m/^\s*desc (.*)/) {$desc=$1;}
	}
	return ($title,$desc);
}

sub debug {

	print "<br><br><h1>Debug info</h1><br>\n<table width=100% border>\n";
	
	#print "<tr $tb><td><b>ENV Key</b></td><td><b>Value</b></td></tr>\n";
	#foreach $i (keys %ENV) { print "<tr $cb><td>$i</td><td>$ENV{$i}</td></tr>\n"; }
	
	print "<tr $tb><th>Config KEY</th><th>Value</th></tr>\n";
	foreach $i (keys %config) { print "<tr $cb><td>$i</td><td>$config{$i}</td></tr>\n"; }
	
	print "<tr $tb><th>IN KEY</th><th>Value</th></tr>\n";
	foreach $i (keys %in) { print "<tr $cb><td>$i</td><td>$in{$i}</td></tr>\n"; }
	
	print "</table>\n";
}

do '../web-lib.pl';

# some init
init_config();

use vars qw($tb $cb %in %config %module_info);

our $VERSION='$Rev$';
$VERSION =~ s/\$Rev: (\d+) \$/$module_info{version} (r.$1)/;

# get the good module
foreign_require("lbs_common", "lbs_common.pl");

# get HTTP args
ReadParse();

# header
lbs_common::print_header(text('title'), "index", $VERSION);

# tabs
lbs_common::print_html_tabs(['lbs-cd']);

my $basedir=$lbs_common::lbsconf{"basedir"};

my @isolist=lbl_ParseIsoDir("$basedir/iso");

my @dirs=lbl_ParseImageDirs($basedir);

$in{'dir'} = html_escape($in{'dir'});
$in{'dir'} =~ s/[^a-z0-9_\/-]/_/gi;

if (!defined $in{'dir'}) {
	
	my $t=lbs_common::get_template('templates/lbs-cd.tmpl');

	foreach my $i (@isolist) {
		my ($size,$dir)=split ' ',`du -m "$basedir/iso/$i"`;
		$t->assign('CB', $cb);
		$t->assign('URL', "get_iso.cgi?iso=$i");
		$t->assign('URL2', "cdlabelgen.cgi?iso=$i")     if -x "/usr/bin/cdlabelgen";
		$t->assign('ISONAME', $i);
		$t->assign('SIZE', $size);
	        $t->assign('GEN', text('lbl_Generate'))         if -x "/usr/bin/cdlabelgen";
	        $t->assign('GEN', text('lbl_NotAvailable'))     unless -x "/usr/bin/cdlabelgen";
		$t->parse('isolist.row');
	} 

	$t->assign('BIGTITLE', text('lbl_ListofIsoImages'));
	$t->assign('TB', $tb);
	$t->assign('ISONAME', text('lbl_IsoName'));
	$t->assign('JACK', text('lbl_Jack'));
	$t->assign('SIZE', text('ImageSize'));
	$t->parse('isolist');
	$t->out('isolist');

	
	foreach $i (@dirs) {
		my ($size,$dir)=split ' ',`du -m $i`;
		my $s=simplify($basedir,$i);
		my ($title,$desc)=get_desc($i);
		$t->assign('CB', $cb);
		$t->assign('URL', "?dir=$i");
		$t->assign('LOCATION', $s);
		$t->assign('TITLE', $title);
		$t->assign('DESC', $desc);
		$t->assign('SIZE', $size);
		$t->parse('hugelist.row');
	} 
	
	$t->assign('BIGTITLE', text('lbl_ListofAvailableImages'));
	$t->assign('TB', $tb);
	$t->assign('DIRMACHINE', text('DirMachine'));
	$t->assign('TITLE', text('ImageTitle'));
	$t->assign('DESC', text('ImageDesc'));
	$t->assign('SIZE', text('ImageSize'));
	$t->parse('hugelist');
	$t->out('hugelist');
} else {
	my $dir=simplify($basedir,$in{'dir'});
	my $t=lbs_common::get_template('templates/lbs-cd.tmpl');
	
	my ($title,$desc)=get_desc($in{'dir'});
	my ($size,$dir)=split ' ',`du -k $in{'dir'}`;
	my $cd=int($size/$config{'CDSize'})+1;

	if ((system("grep -q \"0 PATH/Lvm\" ".$in{'dir'}."/conf.txt") == 0) && 
	    ( ! -f "$basedir/bin/initrdcd.gz" )) {
	    print "<h2>".text('err_lvm')."</h2>";
	    
	    lbs_common::print_end_menu();
	    footer( "", text('index') );
	    exit;
	}

	$t->assign('CB', $cb);
	$t->assign('LOCATION', $dir);
	$t->assign('TITLE', $title);
	$t->assign('CDTITLE', $title);
	$t->assign('DESC', $desc);
	$t->assign('SIZE', $size);
	$t->parse('hugelist.row');

	$t->assign('BIGTITLE', text('GenerateImageFor'));
	$t->assign('TB', $tb);
	$t->assign('DIRMACHINE', text('DirMachine'));
	$t->assign('TITLE', text('ImageTitle'));
	$t->assign('DESC', text('ImageDesc'));
	$t->assign('SIZE', text('ImageSize'));
	$t->parse('hugelist');
	$t->out('hugelist');

	$t->assign('SIZE', "$text{'DirectorySize'} : $size = $cd CD/DVD");
	$t->assign('CONFFILECONTAINS', "$text{'ConfigFileContains'} :");
	
	my $buff;
	
	open F,$in{'dir'}."CONF";
	while (<F>) {$buff .= $_;}
	close(F);

	$t->assign('OLDCD', $text{'oldcd'});
	$t->parse('form.oldcd');

	$t->assign('CONTAIN', $buff);
	$t->assign('URL', $in{'dir'});
	$t->assign('LAUNCH', $text{'LaunchMkisofs'});
	$t->parse('form');
	$t->out('form');
}


# end of tabs
lbs_common::print_end_menu();

# end of page
footer( "", text('index') );