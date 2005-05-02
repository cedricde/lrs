#! /bin/sh
#
# start/stop the LRS server
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/tftpboot/revoboot/bin/lbs_starter
NAME=lbs
DESC="Linbox Rescue Server"

test -x $DAEMON || exit 0

set -e

case "$1" in
  start)
	echo -n "Starting $DESC: "
	#start-stop-daemon --start --quiet --background --make-pidfile --pidfile /var/run/$NAME.pid --exec $DAEMON
	exec $DAEMON
	;;
  stop)
	echo -n "Stopping $DESC: "
	if [ -x /sbin/start-stop-daemon ]
	then
	    start-stop-daemon --stop --quiet --oknodo --pidfile /var/run/$NAME.pid
	else 
	    killall -q getClientResponse
	fi
	echo "$NAME."
	;;
  restart|force-reload)
	$0 stop
	$0 start
	;;
  *)
	N=/etc/init.d/$NAME
	# echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0
