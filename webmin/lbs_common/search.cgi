#!/usr/bin/perl -w 
# index.cgi
# $Id$

# stay strict
use strict;

# get some common functions ...
require 'lbs_common.pl';

# ... and vars
ReadParse();
use vars qw (%in %text $tb $TFTPBOOT $VERSION $TEMPLATES_PATH @LRS_MODULES $root_directory);

# entete
print_header( $text{'tit_index'}, "index", $VERSION);

# tabs
print_html_tabs(['list_of_machines', 'search']);

if (not defined $in{'searchkind'}) {
        print_search_form();
} else {
        
        my %ether;

        if (lc($in{'searchkind'}) eq "quick") {
                etherLoad("$TFTPBOOT/etc/ether" , \%ether);
                normalize_machine_names(\%ether);
                keep_machines_by_name($in{'keyword'}, \%ether, "i");
        } elsif (lc($in{'searchkind'}) eq "normal") {
                etherLoad("$TFTPBOOT/etc/ether" , \%ether);
                normalize_machine_names(\%ether);
                keep_machines_by_id($in{'name'}, \%ether, "i");
                keep_machines_by_group($in{'group'}, \%ether, "i");
                keep_machines_by_profile($in{'profile'}, \%ether, "i");
                keep_machines_by_mac($in{'mac'}, \%ether, "i");
        }
        
        print_search_results(\%ether);
}
# end of tabs
print_end_menu();
print_end_menu();

# pied de page
footer("/", text('index'));


sub print_search_form {
        my $template = new Qtpl("$TEMPLATES_PATH/search.tpl");

        $template->assign('SEARCHQUERY', $text{'lab_searchform'});

        $template->assign('PROFILE', $text{'lab_profile'});
        $template->assign('GROUP', $text{'lab_group'});
        $template->assign('NAME', $text{'lab_name'});
        $template->assign('MAC', $text{'lab_macaddr'});

        $template->assign('SEARCH', $text{'lab_search'});

        $template->parse('searchform');
        $template->out('searchform');
}

sub print_search_results {
        my ($etherref) = @_;
        my %ether = %$etherref;
        my $template = new Qtpl("$TEMPLATES_PATH/search.tpl");

        my (@labelfunctions, @bodyfunctions);
        foreach my $module (@LRS_MODULES) {
                if (-r "$root_directory/$module/lrs-export.pl") {
                        foreign_require($module, "lrs-export.pl");
                        push @labelfunctions, foreign_call($module, "mainlist_label_callback");
                        push @bodyfunctions, foreign_call($module, "mainlist_content_callback");
                }
        }
        
        # main title
        $template->assign('SEARCHRESULTS', $text{'lab_searchresults'});
        $template->parse('resultslist.title');

        $template->parse('resultslist.starttable');

        $template->assign('TB', $tb);
        foreach my $word( $text{'lab_profile'}, $text{'lab_group'}, $text{'lab_name'}) {
                $template->assign('TITLE', $word);
                $template->parse('resultslist.toprow.topcell');
        }
        foreach my $headcallback (@labelfunctions) {
                foreach my $label (&$headcallback({'section' => "search"})) {
                        if (defined($label) and $label) {
                                $template->assign('TITLE', $label->{'content'});
                                $template->parse('resultslist.toprow.topcell');
                        }
                }
        }
        $template->parse('resultslist.toprow');

        $template->assign('TB', $tb);

        foreach my $key (keys %$etherref) {
                ${%$etherref}{$key}[1] =~ m|([^:]*):(.*)/([^/]*)|;
                $template->assign('CONTENT', "<a href='index.cgi?profile=$1'>$1</a>");
                $template->parse('resultslist.normalrow.normalcell');
                $template->assign('CONTENT', "<a href='index.cgi?group=$2'>$2</a>");
                $template->parse('resultslist.normalrow.normalcell');
                $template->assign('CONTENT', "<a href='index.cgi?mac=$key'>$3</a>");
                $template->parse('resultslist.normalrow.normalcell');

                foreach my $bodycallback (@bodyfunctions) {
                        foreach my $content (&$bodycallback({'section' => "search", 'mac' => $key})) {
                                if (defined($content) and $content) {
                                        $template->assign('CONTENT', $content->{'content'});
                                        $template->parse('resultslist.normalrow.normalcell');
                                }
                        }
                }

                $template->parse('resultslist.normalrow');
        }
        
        $template->assign('OTHERSEARCH', $text{'lab_searchother'});
        $template->parse('resultslist.endtable');
        $template->parse('resultslist');

        $template->out('resultslist');

	return 1;
}
