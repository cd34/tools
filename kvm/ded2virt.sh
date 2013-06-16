#!/bin/bash -x

HOSTNAME=$1
VG=$2

umount /mnt
mount -o loop,offset=1048576 -t ext4 /dev/vg0/$VG /mnt
rsync --delete -aplx root@$HOSTNAME:/ /mnt/
rsync --delete -aplx root@$HOSTNAME:/dev/ /mnt/dev/
rsync --delete -aplx root@$HOSTNAME:/home/ /mnt/home/
rsync --delete -aplx root@$HOSTNAME:/usr/ /mnt/usr/
rsync --delete -aplx root@$HOSTNAME:/var/ /mnt/var/
umount /mnt
