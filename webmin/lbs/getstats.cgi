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

print "Content-type: application/x-gzip;\n";
print "Content-Disposition: attachment; filename=LRS.info.tgz\n\n";

my @commands = (
                "==== initrd version ====\n" .      lbs_common::get_client_initrd_version(),
                "==== revoboot version ====\n" .    lbs_common::get_client_revoboot_version(),
                "==== kernel version ====\n" .      lbs_common::get_server_kernel_version(),
                "==== free space ====\n" .          lbs_common::get_server_free_space(),
                "==== net config ====\n" .          lbs_common::get_server_net_conf(),
                "==== free memory ====\n" .         lbs_common::get_server_free_memory(),
                "==== revoboot content ====\n",     lbs_common::get_server_tftpboot_content(),
                );

my $buffer;
my $statsfile="/tmp/stats.$$.txt";

foreach my $command (@commands) { # generate a stat file
        $buffer .= $command;
        $buffer .= "\n";
}
open STATS, "> $statsfile";
print STATS $buffer;
close STATS;

print `/bin/tar zc /var/log/syslog* /tftpboot/revoboot/log /root/.bash_history /var/lib/backuppc/log/LOG* /var/lib/backuppc/pc/*/LOG* $statsfile`;

unlink $statsfile;