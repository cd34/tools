#!/usr/bin/python

import operator
import re
import sys

slow_re = re.compile('^(SELECT|DELETE)')
mysql_re = re.compile('Query')
query_search = re.compile('(Quit|Connect|Query|Init DB)')
slow_query_clean_1_re = re.compile('\d+')
slow_query_clean_2_re = re.compile('([\'"]).+?([\'"])')
query_clean_1_re = re.compile('^\t+\d+\ Query\t')

def add_query(line, counts):
    query = line.replace('  ',' ')
    query = re.sub(slow_query_clean_1_re, 'XXX', query)
    query = re.sub(slow_query_clean_2_re, '\'XXX\'', query)
    #counts.setdefault(query, 0)
    if query in counts:
        counts[query] += 1
    else:
        counts[query] = 1
    return counts
    
def process_slow_query_log(counts, f, in_query = False):
    for line in f:
        if slow_re.search(line) and not in_query:
            in_query = True
            query = line.strip()
        elif in_query and line.startswith('#'):
            in_query = False
            counts = add_query(query, counts)
        elif in_query:
            query += ' ' + line.strip()
    return counts

def process_query_log(counts, f, in_query = False):
    for line in f:
        if mysql_re.search(line) and not in_query:
            in_query = True
            query = re.sub(query_clean_1_re, '', line).strip()
        elif in_query and re.search(query_search, line):
            in_query = False
            counts = add_query(query, counts)
        elif in_query:
            query += ' ' + line.strip()
    return counts

def process_log(filename):
    in_slow = False
    in_mysql = False
    counts = {}
    f = open(filename, 'r')
    for line in f:
        if slow_re.search(line) and not in_slow:
            in_slow = True
            query = line.strip()
        elif in_slow and line.startswith('#'):
            in_slow = False
            counts = add_query(query, counts)
            process_slow_query_log(counts, f)
        elif in_slow:
            query += ' ' + line.strip()
        if mysql_re.search(line) and not in_mysql:
            in_mysql = True
            query = line.strip()
        elif in_mysql and re.search('^(\d+)?.*\d+.(Quit|Connect|Query|Init DB)', line):
            in_mysql = False
            counts = add_query(query, counts)
            process_query_log(counts, f)
        elif in_mysql:
            query += ' ' + line.strip()
    return counts

counts = process_log(sys.argv[1])
vk_query = sorted(counts.items(), key=operator.itemgetter(1), reverse=True)
for q in vk_query:
    print q[1],q[0]
