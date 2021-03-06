#!/bin/sh
#
# Mount helper script
#
# $Id$
#

TYPE=nfs
. /etc/netinfo.sh

# CDROM restoration: already mounted
grep -q revosavedir=/cdrom /etc/cmdline && exit 0

# Other restoration types
SRV=$Next_server
PREFIX=`echo $Boot_file|sed 's/\/bin\/revoboot.pxe//'`
DIR=`cat /etc/cmdline|cut -f 1 -d " "|cut -f 2 -d =`

echo "Mounting Storage directory... mount-$TYPE.sh $SRV $PREFIX $DIR"
while ! mount-$TYPE.sh $SRV $PREFIX $DIR
do
    sleep 1
done
