#!/bin/bash
#
# run as user mysql please...
#

TOVER=3

#
function create() {
mysqladmin create lsc

mysql lsc <<EOF
GRANT ALL PRIVILEGES ON lsc.* TO 'lrs'@'localhost'
    IDENTIFIED BY 'lrs' WITH GRANT OPTION;
EOF

mysql lsc < schema.sql
}

#
function getver() {
VER=`mysql lsc <<EOF
SELECT Number FROM version;
EOF`
VER=`echo $VER|tr -dc 0123456789`
}

#
function upgrade() {
    for i in `seq $(($VER+1)) $TOVER`
    do
	echo "Upgrading to v$i"
	mysql lsc < schema.sql.v.$i
    done
    echo "Done"
}

getver
if [ "$VER" = "" ] 
then
    echo "Create the database"
    create
    VER=1
    upgrade
else
    [ "$VER" = "$TOVER" ] && echo "No update needed" && exit 0
    echo "Upgrade from $VER"
    upgrade
fi

