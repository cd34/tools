#!/usr/bin/python

DEFAULT_PATH = '/var/www/uc'

import os

ips = os.popen('/sbin/ifconfig -a|grep "inet addr"|cut -f 2 -d ":"|cut -f 1 -d " "|grep -v 127.0.0.1')
for ip in ips:
    print """
<VirtualHost %s:80>
ServerName %s
DocumentRoot %s
</VirtualHost>""" % (ip.strip(), ip.strip(), DEFAULT_PATH)
