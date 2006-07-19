#!/usr/bin/perl -w
# index.cgi
# $Id$

# stay strict
use strict;

# get some common functions ...
require 'lbs_common.pl';

# ... and vars
ReadParse();
use vars qw (%in %text $VERSION %config $current_lang);

# entete
print_header( $text{'tit_index'}, "index", $VERSION);

# tabs
print_html_tabs(['list_of_machines', 'configuration']);

#
my $template = new Qtpl("./tmpl/$current_lang/config.tpl");
$template->parse('all');  
$template->out('all');  


# end of tabs
print_end_menu();
print_end_menu();

# pied de page
footer("/", text('index'));
