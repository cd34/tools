#!/bin/bash

/usr/sbin/apache2ctl graceful-stop
/usr/sbin/apache2ctl start

sleep 5
PSLIST=$(ps ax | grep apache | grep -v grep | awk '{print $1}')

for h in $PSLIST; do
  nohup strace -p "$h" 2> "/var/tmp/trace/trace.$h" &
done
