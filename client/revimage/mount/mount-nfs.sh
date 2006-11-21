#!/bin/sh
#
# Mount helper script for NFS
#
# $Id$
#

SIP=$1
PREFIX=$2
DIR=$3

SUBDIR=`dirname $3`

# get the mac address
getmac() {
    MAC=$(ifconfig `cat /etc/eth`|grep HWaddr|sed 's/.*HWaddr //'|sed 's/[: ]//g')
}


# Get DHCP options
. /etc/netinfo.sh

[ -n "$Option_177" ] && SIP=`echo $Option_177|cut -d : -f 1`

RPCINFO=`rpcinfo -p $SIP`

logger "rpcinfo:"
logger "$RPCINFO"

# check nfs
echo
echo
sleep 1
if echo "$RPCINFO"|grep -q nfs
then
    echo "*** NFS seems to be ok on $SIP"
else
    echo "*** Warning : the NFS service does not seem to work on the LRS !"
    echo "*** IP configuration :"
    cat /etc/netinfo.log
    sleep 10
fi

# Get NFS options
if grep -q slownfs /etc/cmdline
then
    NFSOPT=rsize=1024,wsize=1024,udp
else 
    if echo "$RPCINFO"|grep nfs|grep -q tcp
    then 
	NFSOPT=rsize=8192,wsize=8192,tcp
    else
	echo "*** No TCP on NFS server switching to UDP"
	NFSOPT=rsize=8192,wsize=8192,udp
	sleep 2
    fi
fi

# shared backup ?
if echo $SUBDIR|grep -q /imgbase
then
    getmac
    # adjust the remote /revoinfo directory
    SUBDIR=/images/$MAC
fi

if [ -z "$Option_177" ] 
then
    echo "Using $SIP:$PREFIX as backup dir"
    mount -t nfs $SIP:$PREFIX$SUBDIR /revoinfo -o hard,intr,nolock,sync,$NFSOPT
    mount -t nfs $SIP:$PREFIX$DIR /revosave -o hard,intr,nolock,sync,$NFSOPT
else
    echo "Using Option 177: $Option_177 as backup dir"
    mount -t nfs $Option_177$SUBDIR /revoinfo -o hard,intr,nolock,sync,$NFSOPT
    mount -t nfs $Option_177$DIR /revosave -o hard,intr,nolock,sync,$NFSOPT
fi
# IMPORTANT !!! NO OTHER INSTRUCTIONS AFTER MOUNTS !!! 
