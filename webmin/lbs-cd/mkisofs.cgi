#!/usr/bin/perl

print "Content-type: text/html\n\n\n";
print "<html><head>\n";
print "<META HTTP-EQUIV=\"Refresh\" CONTENT=1>\n";
print "<title>MKISOFS</title></head>\n";
print "<body><pre>\n";
open F,"tail /tmp/mkisofs.log|";
print <F>;
print "</pre></body></html>\n";

