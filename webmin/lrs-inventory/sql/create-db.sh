#!/bin/bash
#
# run as user mysql please...
#

# lastest db version
TOVER=8

#
function create() {
mysqladmin create inventory

mysql inventory <<EOF
GRANT ALL PRIVILEGES ON inventory.* TO 'lrs'@'localhost'
    IDENTIFIED BY 'lrs' WITH GRANT OPTION;
EOF

mysql inventory < schema.sql
}

#
function getver() {
VER=`mysql inventory <<EOF
SELECT Number from Version;
EOF`
VER=`echo $VER|tr -dc 0123456789`
}

#
function upgrade() {
    for i in `seq $(($VER+1)) $TOVER`
    do
	echo "Upgrading to v$i"
	mysql inventory < schema.sql.v.$i
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
    if [ "$VER" = "$TOVER" ]; then
	echo "No update needed"
	exit 0
    fi
    echo "Upgrade from $VER"
    upgrade
fi
exit 0
