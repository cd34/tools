#!/usr/bin/python
"""

max_load = load throttle, reads one minute average

glob_match = '*.(php|txt)'

"""

import os
import re
import time

path = '.'
max_load = 50
file_match = re.compile('\.(php|txt)$', re.IGNORECASE);
iteration_count = 500

def check_load():
    load_avg = int(os.getloadavg()[0])
    while load_avg > max_load:
        time.sleep(30)
        load_avg = int(os.getloadavg()[0])

def getdir(path):
    files = os.listdir(path)
    numfiles = len(files)
    for loop,file in enumerate(files):
        if loop % iteration_count == 0:
            print '%d of %d (%d%%)' % (loop, numfiles, loop*100/numfiles)
            check_load()
        if file_match.search(file):
            os.unlink(file)

try:
    getdir(path)
except KeyboardInterrupt:
    pass
