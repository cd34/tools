#!/bin/bash

# cd34, 20120303
# 
# find /var/www -type f -wholename \*wp-includes/version.php|awk '{ print "grep -H \"wp_version =\" " $1 }' | sh > /var/tmp/wpversions
# 
# if you want to really save time:
# awk < /var/tmp/wpversion '{ print "/path/to/wpu.sh " $1 }' | sh -x

# set this to match your temporary directory location for Wordpress
WORDPRESS_TMPDIR=/var/tmp/wordpress
# wget -O /var/tmp http://wordpress.org/latest.tar.gz
# cd /var/tmp
# tar xzf latest.tar.gz

# PATH_PART_LOCATION is the index of the part of the path that contains
# the domain name. If your domain structure is /var/www/domain.com, then
# PATH_PART_LOCATION should be 3   [0]/var[1]/www[2]/domain.com[3].
PATH_PART_LOCATION=3

if [ "X" == "$1X" ];
then
  echo "Needs a pathname for the version.php file"
  echo
  echo "$0 /var/www/domain.com/wp-includes/version.php"
  echo
  echo "You can include data after version.php, i.e. :$version from find command"
else
  WP_INCLUDE_PATH=$1
  WP_PATH=${WP_INCLUDE_PATH%%/wp-includes/version.php*}
  IFS='/' read -ra PATHPARTS <<< "$WP_PATH"
  D=${PATHPARTS[@]:$PATH_PART_LOCATION}
  DOMAIN="${D// //}"

  TMP=`stat $WP_PATH|grep Uid:`
  TMP_GID=${TMP##*Gid: ( }
  TMP_GID=${TMP_GID/ /}
  DGID=${TMP_GID%%/*}
  TMP_UID=${TMP##*Uid: ( }
  DUID=${TMP_UID%%/*}

  `cp -Rp $WORDPRESS_TMPDIR/* $WP_PATH`
  `chown -R --from=root $DUID.$DGID $WP_PATH`
  `/usr/bin/wget -q -O /dev/null "http://$DOMAIN/wp-admin/upgrade.php?step=1"`
  echo "Upgraded: http://$DOMAIN"
fi
