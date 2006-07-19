#!/usr/bin/perl -w
# index.cgi
# $Id$

# stay strict
use strict;
use File::stat;
use POSIX qw(locale_h strftime);

# get some common functions ...
require 'lbs_common.pl';

# ... and vars
use vars qw (%in %text $VERSION %config $current_lang %lbsconf);
init_lbs_conf() or exit(0) ;
my $lbs_home = $lbsconf{'basedir'};

# entete
print_header( $text{'tit_index'}, "index", $VERSION);

# tabs
print_html_tabs(['list_of_machines', 'configuration', 'configuration_backup']);

#
if (exists($in{'saveconf'})) {
    my $files = "/etc/lbs.conf /etc/backuppc/* /etc/hosts /etc/hostname /etc/dhcp3/* ".    
	"/etc/samba/* /etc/fstab /etc/aliases /etc/resolv.conf /etc/exports ".
	"/etc/mysql/my.cnf /etc/exim/* /etc/network/interfaces /etc/network/options ".
	"/etc/webmin/* /var/spool/cron/* /var/lib/mysql/inventory /var/lib/mysql/lsc ".
	"/etc/apt/apt.conf.d/99proxy /root/.ssh/*";
    
    mkdir($lbs_home."/backup");
    system("/etc/init.d/mysql stop >/dev/null");
    system("tar cf $lbs_home/backup/lrs.tar $files");
    system("/etc/init.d/mysql start >/dev/null");    
} elsif (exists($in{'loadconf'})) {
    print "<h2>".$text{lab_datarestored}.":</h2>";
    print "<pre>";
    system("/etc/init.d/mysql stop >/dev/null");
    system("tar xvf $lbs_home/backup/lrs.tar -C /");
    system("/etc/init.d/mysql start >/dev/null");
    print "</pre>";
}

#
my $template = new Qtpl("./tmpl/$current_lang/saveconfig.tpl");

$template->assign('LAST','---');
my $st = stat("$lbs_home/backup/lrs.tar");
if ($st) {
    my $locale = "en";
    if ($current_lang eq "fr") { $locale = "fr_FR" };
    if ($current_lang eq "de") { $locale = "de_DE" };
    setlocale(LC_TIME, $locale);
    $template->assign('LAST',  strftime("%c", localtime($st->mtime)));
}

$template->parse('all');
$template->out('all');

# end of tabs
print_end_menu();
print_end_menu();

# pied de page
footer("/", text('index'));
