#
# Load lbs-lib.pl and push the lbs path in @INC
#

use vars qw/@INC %config/;

# always lbs.conf...
my $conffile=$config{'lbs_conf'};

if (-r "/etc/lbs.conf") {

        my %cnf;
        read_env_file ("/etc/lbs.conf", \%cnf);
        push @INC, $cnf{'basedir'}."/bin/";
        $LRS_HERE=1;
}

1;
