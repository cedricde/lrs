#!/usr/bin/perl
# LBS
# Restart du service.
#

require "../web-lib.pl";

system("/etc/init.d/lbs restart");
sleep(1);
redirect("/lbs_common/") ;
exit(0) ;
