# $Id$
# some debug code

use Data::Dumper;
BEGIN {
our $logrep="/var/lib/lbs";

	close STDERR;
	
	`mkdir -p $logrep` unless (-d $logrep);

	open STDERR, ">> /var/lib/lbs/webmin.log";     	# FIXME: faire du logrotate
							# FIXME: faire un script de postinst créant ce ù*$ de rep.
							
	print STDERR "#" x 80;
	print STDERR "\n";
	
}
