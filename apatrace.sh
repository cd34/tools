#!/bin/bash

/usr/bin/killall -9 apache2
/usr/sbin/apache2ctl start

sleep 5
PSLIST=`ps ax|grep apache|cut -c -5|sed 's/ //g'`

for h in $PSLIST; do
  nohup strace -p $h 2> /var/tmp/trace/trace.$h &
done
