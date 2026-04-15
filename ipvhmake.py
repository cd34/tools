#!/usr/bin/python3

DEFAULT_PATH = '/var/www/uc'

import os
import subprocess

result = subprocess.run(
    ['/bin/sh', '-c', '/sbin/ifconfig -a|grep "inet addr"|cut -f 2 -d ":"|cut -f 1 -d " "|grep -v 127.0.0.1'],
    capture_output=True, text=True
)
for ip in result.stdout.splitlines():
    ip = ip.strip()
    print(f"""
<VirtualHost {ip}:80>
ServerName {ip}
DocumentRoot {DEFAULT_PATH}
</VirtualHost>""")
