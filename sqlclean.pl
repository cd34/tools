#!/usr/bin/perl

use strict;
use warnings;

# kills longrunning threads in mysql. Useful when a machine is overloaded
# and has a number of locked/pending tasks
# shouldn't be used regularly

# set the USERNAME/PASSWORD to an account that has access to the kill command
# WARNING: avoid hardcoding credentials in production — use environment
# variables or a credentials file instead.

# MINLOAD needs to be set to something if you intend to run this as a cron
# job. Leave it at zero if you want it to kill longrunning processes manually
# This will kill idle/sleeping threads.
#
# QUERY_TIME defines the minimum execution time of a query that we want to kill

my $USERNAME = $ENV{'MYSQL_USER'} // 'root';
my $PASSWORD = $ENV{'MYSQL_PASSWORD'} // die "Set MYSQL_PASSWORD environment variable\n";
my $MINLOAD = 0;
my $QUERY_TIME = 60;

use DBI;

my $dbh = DBI->connect("DBI:mysql:mysql", $USERNAME, $PASSWORD)
    or die "Cannot connect: $DBI::errstr\n";

# get our load average to decide whether we should quit
open(my $fh, '<', '/proc/loadavg') or die "Cannot open /proc/loadavg: $!\n";
my ($ld) = split(/\ /, <$fh>);
close($fh);

if ($ld < $MINLOAD) {
    exit;
}

# grab the processlist
my $stp = $dbh->prepare("show processlist");
$stp->execute;

# loop through looking for long running threads
while (my $sql = $stp->fetchrow_hashref) {
    if ($sql->{'Time'} > $QUERY_TIME) {
        print "killing: " . $sql->{'Id'} . "\n";
        my $kill = $dbh->prepare("kill ?");
        $kill->execute($sql->{'Id'});
    }
}
