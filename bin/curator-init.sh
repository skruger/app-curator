#!/bin/bash

. ~/bin/env_import

HTTPPIDFILE=~/httpd/run/httpd.pid
EXITCODE=0
case $1 in
	start)
		apachectl -f ~/httpd/curator.conf -k $1
		;;
	stop)
		HTTPPID=`cat $HTTPPIDFILE `
		apachectl -f ~/httpd/curator.conf -k $1
		while true; do
			echo -n "."
			test -d /proc/$HTTPPID && break
		done
		;;
	status)
		STATUS="stopped"
		EXITCODE=1
		if test -f $HTTPPIDFILE; then
			HTTPPID=`cat $HTTPPIDFILE`
			if test -d /proc/$HTTPPID ; then
				STATUS="running"
				EXITCODE=0
			fi
		fi
		echo $STATUS
		;;
	*)
		echo "$0 (start|stop)"
		;;
esac

exit $EXITCODE
	
