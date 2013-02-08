#!/usr/bin/perl

# kills longrunning threads in mysql. Useful when a machine is overloaded
# and has a number of locked/pending tasks
# shouldn't be used regularly

# set the USERNAME/PASSWORD to an account that has access to the kill command

# MINLOAD needs to be set to something if you intend to run this as a cron
# job. Leave it at zero if you want it to kill longrunning processes manually
# This will kill idle/sleeping threads.
#
# QUERY_TIME defines the minimum execution time of a query that we want to kill

$USERNAME='root';
$PASSWORD='password';
$MINLOAD=0;
$QUERY_TIME=60;

use DBI;
use DBI::DBD;

$dbh = DBI->connect("DBI:mysql:mysql", $USERNAME, $PASSWORD);

# get our load average to decide whether we should quit
  open F,("</proc/loadavg");
  ($ld,$junk) = split /\ /,<F>;
  close F;

  if ($ld < $MINLOAD) {
    exit;
  }

# grab the processlist

  $stp = $dbh->prepare("show processlist");
  $stp->execute;

# loop through looking for long running threads

  while ($sql = $stp->fetchrow_hashref) {
    if ($sql->{'Time'} > $QUERY_TIME) {
    print "killing: " . $sql->{'Id'} . "\n";
    $kill = $dbh->prepare("kill ?");
    $kill->execute($sql->{'Id'});
    }
  }
