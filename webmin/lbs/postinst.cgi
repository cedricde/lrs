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

# ... and vars
use vars qw (%access %config %gconfig %in %lbsconf %text $VERSION $POSTINST_PATH);
# get some common functions ...
require "./lbs.pl";

my $POSTINST_PATH = "$config{'chemin_basedir'}/images/templates";
#### functions ####

sub postinst_createfile_form() {
	my $t=lbs_common::get_template('templates/postinst.tmpl');
	$t->assign('CREATE_FILE',text('lab_createfile'));
	$t->assign('CREATE',text('but_create'));
        $t->parse('createfile');
        $t->out('createfile');
}

sub postinst_copyfile_form($) {
	my $file=shift;
	my $t=lbs_common::get_template('templates/postinst.tmpl');
	$t->assign('COPY_FILE',text('lab_copyfile', $file));
	$t->assign('COPY',text('but_copy'));
	$t->assign('FILE',$file);
        $t->parse('copyfile');
        $t->out('copyfile');
}

sub postinst_deletefile_form($) {
	my $file=shift;
	my $t=lbs_common::get_template('templates/postinst.tmpl');
	$t->assign('DELETE_FILE',text('lab_deletefile', $file));
	$t->assign('FILE',$file);
	$t->assign('CANCEL',text('but_cancel'));
	$t->assign('CONFIRM',text('but_delete'));
        $t->parse('deletefile');
        $t->out('deletefile');
}

sub postinst_main_page($) {
	
	my $lang=$in{'lang'};
	my $lbs_home=shift;
	opendir(DIR, $POSTINST_PATH) || error(text("err_notarelativefile"));
	my @scripts = map "$POSTINST_PATH/$_", sort grep { /^[^\.][^~]+$/ && -f "$POSTINST_PATH/$_" } readdir(DIR);
	closedir DIR;

	my $t=lbs_common::get_template('templates/postinst.tmpl');
	$t->assign('CHANGE_FILE',text('lab_selectthescripttochange'));
	$t->assign('CREATE',text('but_create'));
	$t->assign('EDIT',text('but_edit'));
	$t->assign('COPY',text('but_copy'));
	$t->assign('DELETE',text('but_delete'));

	foreach my $script (@scripts) { 		# we are building the file list
		my @postinstcontent;
		postinst_read($script, \@postinstcontent);
		$script =~ s|^$lbs_home/(.*)$|$1|;
		$t->assign('FULLFILENAME', $script);
		$script =~ s|.*/(.*)$|$1|;
		$t->assign('FILENAME', "$script: " . $postinstcontent[0]->{'desc'}->{'en'})       	if $postinstcontent[0]->{'desc'}->{'en'};       # keep the english translation in last case
		$t->assign('FILENAME', "$script: " . $postinstcontent[0]->{'desc'}->{$lang})       	if $postinstcontent[0]->{'desc'}->{$lang};      # keep the local translation if we found it
		$t->assign('FILENAME', "$script: " . $postinstcontent[0]->{'desc'}->{'unified'})  	if $postinstcontent[0]->{'desc'}->{'unified'};  # keep the user's desc if it exists
		$t->parse('fileslist.file');
	}
	$t->parse('fileslist');
	$t->out('fileslist');	
}	

sub postinst_read($$) {
	my ($file, $postinstref)=@_;
	my $endheader=0;
	my $endcomment=0;
	my $firstline=0;
	@$postinstref[0]={} if !@$postinstref[0];       	# first case: general structure (desc, localized descs, comments, ...)

	$endheader=1 if (system("grep -q '#-- END HEADER --#' $file")!=0);      # case we can't find the header
	$endcomment=1 if (system("grep -q '#-- END COMMENTS --#' $file")!=0);   # case we can't find the comments
	open FILE, $file || return;
	
	while (<FILE>) {

		if (m|^
			\s*             	# (perhaps) some spaces
			\#         		# #
			\s*     		# (perhaps) some spaces
			desc_([a-zA-Z]{2})      # the desc_{iso contry code} keyword
			\s*\:\s*     		# (perhaps) some spaces, columns, some space
			(.*)    		# the description himself
			\s*     		# and (perhaps) some spaces
			$|xi) {
			@$postinstref[0]->{'desc'}->{$1}=$2;
			$firstline=1;
			next;
			}
			
		if ($firstline == 0) {  			# the first line always contains the description
			m|^\s*\#\s*(.*)$|;
			@$postinstref[0]->{'desc'}->{'unified'}=$1;
			$firstline = 1;
			next;
		}
		
		if (m/#-- END HEADER --#/) {
			$endheader=1;
			next;
		}
		next unless $endheader==1;       		# skip unless we are not in the header anymore
		
		if (m/#-- END COMMENTS --#/) {
			$endcomment=1;
			next;
		}
		
		if ( ($endheader==1) && ($endcomment==0) ) {    # record unless we are not in the comments anymore
			s|^# ||;
			@$postinstref[0]->{'comments'} .= $_;
		}
		
		next unless $endcomment==1;       # skip unless we are not in the header anymore
		
		if (m|^
			\s*             	# (perhaps) some spaces
			Mount   		# the keyword
			\s+     		# some spaces
			(/dev/[^/\b]+[0-9]+)    # the device name
			\s*     		# and (perhaps) some spaces
			$|xi) {         	# Mount /dev/blablaN
				push @$postinstref, {'keyword' => 'Mount', 'args' => $1};
		} elsif (m|^
			\s*             	# (perhaps) some spaces
			Mount   		# the keyword
			\s+     		# some spaces
			(/dev/[^/\b]+[0-9]+)    # the device name
			\s*     		# and (perhaps) some spaces
			$|xi) {         	# Mount /dev/blablaN
				push @$postinstref, {'keyword' => 'Mount', 'args' => $1};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			Mount   		# the keyword
			\s+     		# some spaces
			([0-9]+)		# the device ID
			\s*     		# and (perhaps) some spaces
			$|xi) { 		# Mount N
				push @$postinstref, {'keyword' => 'Mount', 'args' => $1};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			RegistryAddString       # the keyword
			\s+     		# some spaces
			"(\S+)"      	 	# first value: "KEY""
			\s+     		# some spaces
			(\S+)       	  	# second value: "NAME"
			\s+     		# some spaces
			(\S+)       	  	# third value: "VALUE"
			\s*     		# and (perhaps) some spaces
			$|xi) {  		# RegistryAddString <KEY> <NAME> <VALUE>
				push @$postinstref, {'keyword' => 'RegistryAddString', 'args' => "\"$1\" $2 $3"};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			RegistryAddRun          # the keyword
			\s+     		# some spaces
			(\S+)      	 	# first value: "VALUE""
			\s*     		# and (perhaps) some spaces
			$|ix) {  		# RegistryAddRun <VALUE>
				push @$postinstref, {'keyword' => 'RegistryAddRun', 'args' => $1};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			RegistryAddRunOnce      # the keyword
			\s+     		# some spaces
			(\S+)      	 	# first value: "VALUE""
			\s*     		# and (perhaps) some spaces
			$|ix) {  		# RegistryAddRunOnce <VALUE>
				push @$postinstref, {'keyword' => 'RegistryAddRunOnce', 'args' => $1};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			CopySysprepInf          # the keyword
			\s+     		# some spaces
			(\S+)      	 	# first value: "VALUE""
			\s*     		# and (perhaps) some spaces
			$|ix) {  		# CopySysprepInf <FILE>
				push @$postinstref, {'keyword' => 'CopySysprepInf', 'args' => $1};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			ChangeSID               # the keyword
			\s*     		# and (perhaps) some spaces
			$|ix) {  		# ChangeSID <FILE>
				push @$postinstref, {'keyword' => 'ChangeSID', 'args' => $1};
		} elsif (m|^
			\s*     		# (perhaps) some spaces
			ChangeSIDAndName        # the keyword
			\s*     		# and (perhaps) some spaces
			$|ix) {  		# ChangeSIDAndName <FILE>
				push @$postinstref, {'keyword' => 'ChangeSIDAndName', 'args' => $1};
		} elsif (m|\s*#(.*)|) {      	# Custom comment
				push @$postinstref, {'keyword' => 'Comment', 'args' => $1};
		} elsif (!m|^$|) {		# free command
				push @$postinstref, {'keyword' => 'Busybox', 'args' => $_};
		}

	}
	close FILE;
	

}

sub postinst_print(@) {
	my $t=lbs_common::get_template('templates/postinst.tmpl');
	my @postinstcontent=@_;

	my $j=1;
	$in{numfields}=@postinstcontent-1;

	use vars qw/$cb $tb/;
	
	my $lang=lbs_common::get_language();
	
	$t->assign('CB', $cb);
	$t->assign('TB', $tb);
	$t->assign('DESC', $postinstcontent[0]->{'desc'}->{'en'})       	if $postinstcontent[0]->{'desc'}->{'en'};       # keep the english translation in last case
	$t->assign('DESC', $postinstcontent[0]->{'desc'}->{$lang})       	if $postinstcontent[0]->{'desc'}->{$lang};      # keep the local translation if we found it
	$t->assign('DESC', $postinstcontent[0]->{'desc'}->{'unified'})  	if $postinstcontent[0]->{'desc'}->{'unified'};  # keep the user's desc if it exists

	$t->assign('COMMENTS', $postinstcontent[0]->{'comments'});
	
	do {
		$t->assign('NUM', $j);
		$t->assign('ARGS', html_escape($postinstcontent[$j]{'args'}));
		$t->assign('COMMAND', $postinstcontent[$j]{'keyword'});
		$t->assign('FREE_FIELD', $text{'lab_freefield'});
		$t->assign('SUPPRESS', $text{'but_delete'});
		
		if ($postinstcontent[$j]{'keyword'} eq 'Comment') {
			$t->parse('postinst.comment');
		} else {
			if ($postinstcontent[$j]{'keyword'} eq 'Busybox') {
				$t->assign('COMMAND_LOC', $text{'lab_freefield'});
			} else {
				$t->assign('COMMAND_LOC', $postinstcontent[$j]{'keyword'});
			}
			$t->parse('postinst.operation');
		}
			
		$j++;
	} while ($j<=$in{numfields});

	$t->assign('NUMFIELDS', $in{numfields});
	
	$t->assign('FILE', $in{'file'});
	$t->assign('LBL_EDIT', $text{'lab_editingfile'});
	$t->assign('LBL_DESC', $text{'lab_desc'});
	$t->assign('LBL_COMMENTS', $text{'lab_comments'});
	$t->assign('LBL_COMMANDS', $text{'lab_commands'});
	$t->assign('LBL_COMMAND', $text{'lab_command'});
	$t->assign('LBL_ARGUMENTS', $text{'lab_arguments'});
	$t->assign('ADDLINE', $text{'but_newline'});
	$t->assign('VALIDATE', $text{'but_apply'});
	$t->assign('CANCEL', $text{'but_cancel'});
	
        $t->parse('postinst');
        $t->out('postinst');
}

sub postinst_form2array($) {
my $postinstref=shift;
my $i=1;
my $j=1;
my $numfields=$in{numfields};
	$numfields++	if ($in{op_add});       			# minimal nbr of fields: 1

	$numfields=1	if (!$numfields);       			# minimal nbr of fields: 1
	
	@$postinstref[0]={};
	@$postinstref[0]->{'comments'}=$in{'comment'};
	@$postinstref[0]->{'desc'}->{'unified'}=$in{'desc'};

	do {
		my %tmphash;
		
		$tmphash{'args'}=$in{'op_'.$i.'_args'};
		$tmphash{'keyword'}=$in{'op_'.$i.'_keyword'};
		
		@$postinstref[$j]=\%tmphash;
		$i++;   						# next field
		($i++ && $numfields--) if ($in{'op_'.$i.'_del'});       # one more if next should be supressed
		$j++;
	} while ($j<=$numfields);
	
}

sub postinst_write($@) {
my ($file, @postinstcontents)=@_;
my $date=`date`;

	$date =~ tr/\n//d;

	open FILE, '>', $file;
	
	print FILE "# ".$postinstcontents[0]->{'desc'}->{'unified'}."\n";
	print FILE "#\n";
	print FILE "# ".text('postinst_thisisashellscr')."\n";
	print FILE "# ".text('postinst_autogenerated', $date)."\n";
	print FILE "# ".text('postinst_donotmodify')."\n";
	print FILE "# ".text('postinst_willbeerased')."\n";
	print FILE "#-- END HEADER --#\n";
	
	print FILE join "\n", map "# $_", split '\n', $postinstcontents[0]->{'comments'};
	
	print FILE "\n#-- END COMMENTS --#\n";
	print FILE "\n";
	
	undef $postinstcontents[0];
	foreach my $postinstargref (@postinstcontents) {
		next if !$postinstargref;
		my %postinstarg=%$postinstargref;
		
		if (length($postinstarg{'keyword'})>0) {
			if ($postinstarg{'keyword'} eq 'Busybox') {     	# free keyword
				print FILE "$postinstarg{'args'}\n";
			} elsif ($postinstarg{'keyword'} eq 'Comment') {	# custom comment
				print FILE "#$postinstarg{'args'}\n";
			} else {
				print FILE "$postinstarg{'keyword'} $postinstarg{'args'}\n";
			}
		}
	}
	close FILE;
	
}


#### main ####
lbs_common::init_lbs_conf() or exit(0) ;

my $lbs_home = $lbs_common::lbsconf{'basedir'};

# Resultat dans %in:
ReadParse();
lbs_common::InClean();

my $file=$in{'file'};

if ($file eq '') {      				# default call: no action chosen

	# header	
	lbs_common::print_header( $text{'tit_postinst'}, "postinst", $VERSION);
	
	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'configuration', 'postinst']);
	
	postinst_main_page($lbs_home) if -x "$lbs_home/lib/util/captive/usr/bin/captive-lufsmnt";

	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
		
} else {

	error(text("err_notarelativefile"))  if ($file =~ m|^/|);
	error(text("err_notarelativefile"))  if ($file =~ m|^\.\.|);


	if ($in{'create2'}) {
		$in{'file'}="$in{'directory'}"."$file";
		$file = "$lbs_home/$in{'file'}";
		error(text("err_filealreadyexists"))  if (-x $file);
	} else {
		$file = "$lbs_home/$file";
		error(text("err_notaregularfile"))  if (!-f $file) ;
	}
	
	# header	
	lbs_common::print_header( $text{'tit_postinst'}, "postinst", $VERSION);
	
	# tabs
	lbs_common::print_html_tabs(['list_of_machines', 'configuration', 'postinst']);

	if ($in{'save'}) { 	   	 		# file save
		my @postinstcontent;
		postinst_form2array(\@postinstcontent);
		postinst_write($file, @postinstcontent);
		@postinstcontent=();
		postinst_read($file, \@postinstcontent);
		postinst_print(@postinstcontent);
	} elsif ($in{'modify'} || $in{'op_add'}) {      # action: edition
		my @postinstcontent;
		
		if (!$in{'numfields'}) {    	    	# first call to this form
			postinst_read($file, \@postinstcontent);
		} else {
			postinst_form2array(\@postinstcontent);
		}

		postinst_print(@postinstcontent);
	} elsif ($in{'copy'}) { 	     		# action: copy
		postinst_copyfile_form($in{'file'});
	} elsif ($in{'copy2'}) { 	     		# attempt to copy an existing file
		my $newfile="$lbs_home/$in{'directory'}"."$in{'newfile'}";
		`cp $file $newfile`;
		postinst_main_page($lbs_home);
	} elsif ($in{'delete'}) { 	     		# action: deletion
		postinst_deletefile_form($in{'file'});
	} elsif ($in{'delete2'}) { 	     		# attempt to delete a file
		`rm $file`;
		postinst_main_page($lbs_home);
	} elsif ($in{'create'}) {       		# action: creation
		postinst_createfile_form();
	} elsif ($in{'create2'}) {    		  	# attempt to create a new file
		`touch $file`;
		postinst_print();
	} elsif ($in{'cancel'}) {    		  	# cancel => back to the main page
		postinst_main_page($lbs_home);
	}
	
	# end of tabs
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	lbs_common::print_end_menu();		
	
	# end of page
	footer( "", $text{'index'} );
}