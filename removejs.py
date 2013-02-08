#!/usr/bin/python
"""

Quick search and replace to replace an exploit on a client's site while
trying to keep the load disruption on the machine to a minimum.

Default's to . for path

max_load = load throttle, reads one minute average

exploit_regexp = regexp snippet to match

file_exclude = regexp to exclude filenames from matches

exclude_dirs = regexp to exclude certain directory paths

"""

import os
import re
import time

path = '.'
max_load = 20

exploit_regexp = re.compile('<script>var i,y,x=.*</script>')

file_exclude = re.compile('\.(gif|jpe?g|swf|css|js|flv|wmv|mp3|mp4|pdf|ico|png|zip)$', \
                          re.IGNORECASE)

exclude_dirs = re.compile('(cgi-bin/tr/cache)')

def check_load():
    load_avg = int(os.getloadavg()[0])
    while load_avg > max_load:
        time.sleep(30)
        load_avg = int(os.getloadavg()[0])

def getdir(path):
    if not exclude_dirs.search(path):
        check_load()
        files = [i for i in os.listdir(path) if not file_exclude.search(i)]
        for file in files:
            file_path = os.path.join(path,file)
            if os.path.isdir(file_path):
                getdir(file_path)
            else:
                process_file(file_path)

def process_file(file_path):
    file = open(file_path, 'r+')
    contents = file.read()
    if exploit_regexp.search(contents):
        print 'fixing:', file_path
        contents = re.sub(exploit_regexp, '', contents)
        file.truncate(0)
        file.seek(0, os.SEEK_SET )
        file.write(contents)
    file.close()

try:
    getdir(path)
except KeyboardInterrupt:
    pass
