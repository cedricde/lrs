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

use strict;

use vars qw($tb $cb %in %config %module_info %text);

# some common functions
sub get_files {
	my $from=shift;
	my @list=();
	
	open F,"ls $from|sort|";
	while (<F>) {
		chomp;
		if ( m/^CONF/ or m/^PTABS/ or /^(conf|size)\.txt/) {
			unshift @list,$_;
		} else {
			push @list,$_;
		}
	}
	close(F);
	
	return @list;
}

sub copy_images {
	my $from=shift;
	my $to=shift;
	my $fileref=shift;
	
	my ($size,$dir);
	
	system("mkdir -p $to/lbltmp");
	system("rm -rf $to/lbltmp/*");
	
	open F,">completion.html";
	print F "<html><head><title>$text{'Generating'}</title></head><body>$text{'Generating'}<br></body></html>\n";
	close(F);
	
	print "<SCRIPT LANGUAGE=JavaScript>\n";
	print "term = window.open('completion.html','term','width=500,height=200');\n";
	print "</SCRIPT>\n";
	
	do {
		my $file=$fileref->[0];
		($size,$dir)=split ' ',`du -k $to/lbltmp`;
		
		open F,">completion.html";
		print F "<html><head><title>$text{'Generating'}</title></head><body>$text{'Generating'}<br>\n";
		print F "$text{'Copying'} : $file<br>\n";
		print F "$text{'AmountCopied'} : $size KB<br>\n";
		print F "$text{'CDCapa'} : $config{'CDSize'} KB<br>\n";
		print F "</body></html>\n";
		close(F);

		print "<SCRIPT LANGUAGE=JavaScript>\n";
		print "term.window.location.reload();\n";
		print "</SCRIPT>\n";
		
		# hard link only since we are on the same FS
		system("cp -lv $from/$file $to/lbltmp 2>&1 >/dev/null");
		
		($size,$dir)=split ' ',`du -k $to/lbltmp`;
		
		if ( $size < $config{'CDSize'} - 4096 ) {
			shift @$fileref;
		} else {
			system("rm -f $to/lbltmp/$file");
			print "<SCRIPT LANGUAGE=JavaScript>\n";
			print "term.window.close();\n";
			print "</SCRIPT>\n";
			return;
		}
	} while ( scalar(@$fileref) && ($size < $config{'CDSize'}) );
	
	print "<SCRIPT LANGUAGE=JavaScript>\n";
	print "term.window.close();\n";
	print "</SCRIPT>\n";
}

sub do_mkisofs
{
	my $basedir = shift;
	my $from = shift;
	my $to = shift;
	my $num = shift;
	my $cdname = shift;
	
	my $opt;	
	my $linuxrestore = 0;
	
	if ( -f "$basedir/bin/initrdcd.gz" ) { $linuxrestore = 1; }

	if ($in{'oldcd'} eq "on") { $linuxrestore = 0; }
	 
	if ($num == 1) {
	    if (-f "$basedir/bin/grub.cdrom") {
		$opt = "-b grub.cdrom -no-emul-boot -boot-load-size 4 -boot-info-table"; 
		system("cp $basedir/bin/grub.cdrom $from/lbltmp/");
		system("mkdir -p $from/lbltmp/boot/grub/");
		system("cp menu.lst.tmpl $from/lbltmp/boot/grub/menu.lst;");
		if ($linuxrestore) {
			system("grep '^title\\|^desc' $from/lbltmp/conf.txt >> $from/lbltmp/boot/grub/menu.lst;
			echo 'kernel (cd)/bzImage revorestorenfs revosavedir=/cdrom quiet revonospc ' >> $from/lbltmp/boot/grub/menu.lst;
			echo 'initrd (cd)/initrd' >> $from/lbltmp/boot/grub/menu.lst;
			");
			system("cp -L $basedir/bin/bzImage.initrd $from/lbltmp/bzImage");
			system("cp -L $basedir/bin/initrd.gz $from/lbltmp/initrd");
			system("cat $basedir/bin/initrdcd.gz >> $from/lbltmp/initrd");		
		} else {
			system("cat $from/lbltmp/conf.txt >>$from/lbltmp/boot/grub/menu.lst");
		}
	    } else {
		$opt = "-b lbl.cdrom -no-emul-boot -boot-load-size 4 -boot-info-table"; 
		system("cp $basedir/bin/lbl.cdrom $from/lbltmp/");
	    }	
	} else {
		$opt = "";
	}
	
	system("echo \"Doing MKISOFS\" >/tmp/mkisofs.log");
	
	print "<SCRIPT LANGUAGE=JavaScript>\n";
	print "term2 = window.open('mkisofs.cgi','term2','width=500,height=200');\n";
	print "</SCRIPT>\n";
	
	system("mkisofs -v -R -o $to/$cdname-$num.iso $opt $from/lbltmp/ >/tmp/mkisofs.log 2>&1");
	
	print "<SCRIPT LANGUAGE=JavaScript>\n";
	print "term2.window.close();\n";
	print "</SCRIPT>\n";
	
	system("rm -f $from/lbltmp/*");
        
}

do '../web-lib.pl';

# some init
init_config();

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

if (!$in{'yesimsure'}) {
	print "<hr>\n";
	print "<SCRIPT LANGUAGE=JavaScript>\n";
	print "if (!(confirm(\"$text{'AskConfirm'}\"))) {\nhistory.back();\n}\n";
	print "</SCRIPT>\n";
}

print "<h1 id=\"lrscd_title\">$text{'PleaseWait'}</h1>\n";

my $root=html_escape($in{'dir'});
my $num=1;
my $basedir=$lbs_common::lbsconf{"basedir"};
my $cdname=html_escape($in{'cdname'});

$root =~ s/[^a-z0-9_\/-]/_/gi;
$cdname =~ s/[^a-z0-9]/_/gi ;

my @files=get_files($root);

system("sleep 4");
system("rm -f $config{'StoreDir'}/*.iso");
do {
	copy_images($root,$config{'TempDir'},\@files);
	do_mkisofs($basedir,$config{'TempDir'},$config{'StoreDir'},$num,$cdname);
	$num++;
} while ( scalar(@files) );

print "<table width=100% border><tr $tb><th>ISO file</th><th>Size</th></tr>\n";

@files=get_files($config{'StoreDir'});

system("rm -f /etc/webmin/burner/lbl_*.burn");

foreach my $i (@files) {
	my ($size,$dum)=split ' ',`du -l $config{'StoreDir'}/$i`;
	
	open F,">/etc/webmin/burner/lbl_$i.burn";
	print F "iso=$config{'StoreDir'}/$i\n";
	print F "id=lbl_$i\n";
	print F "isosize=1\ntype=1\nname=$i\n";
	close(F);
	print "<tr $cb><td><a href=\"get_iso.cgi?iso=$i\">$i</a></td><td>$size</td></tr>\n";
}

print "</table>\n";

print "<SCRIPT LANGUAGE=JavaScript>document.getElementById('lrscd_title').style.visibility='hidden'</SCRIPT>";
print "<h1>$text{'lbl_IsoDone'}</h1>\n";

print "<br><center><a href=\"$config{'cdburner'}/index.cgi\">$text{'CDBURNER_Module'}</a></center><br>";

# end of tabs
lbs_common::print_end_menu();		

# end of page
footer( "", text('index') );
