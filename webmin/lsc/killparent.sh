#!/bin/sh
#
# Kill the last parent pid
#
PID=$1
while true; do
    NEWPID=`ps ax --format pid,ppid,command|grep -v grep|awk '{if ($2=='"$PID"') print $1}'`
    [ -z $NEWPID ] && break
    PID=$NEWPID
done
kill $PID
