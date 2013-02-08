#!/bin/bash -x

# mkfs.xfs options

AGCOUNT=(2 4 6 8 16 32)
LOG=(32 64 128)
LAZY=(0 1)
INODE=(256 512 1024 2048)
BLOCK=(4096 8192 16384 32768 65536)

# mount options
FIXED_OPTIONS='noatime,logbufs=8,logbsize=256k'
LARGEIO=('nolargeio' 'largeio')
DELAYLOG=('nodelaylog' 'delaylog')

# IO scheduler options
IO=('cfq' 'deadline' 'noop')

# command paths
MKFS=/sbin/mkfs.xfs
RSYNC=/usr/bin/rsync
CHOWN=/bin/chown
BONNIE=/usr/sbin/bonnie++
MOUNT=/bin/mount
UMOUNT=/bin/umount

# UID:GID for bonnie++
UIDGID='1000:1000'

# device/work paths
LOG_FILE=/mnt/mount_test
SOURCE_DEVICE=/dev/sda5
SOURCE_PATH=/mnt
TEST_DEVICE=/dev/sda6
TEST_PATH=/dt
TEST_DEV=sda

function mkfs_loop()
{

  for a in ${AGCOUNT[@]}
  do
    for l in ${LOG[@]}
    do
      for lazy in ${LAZY[@]}
      do
        for inode in ${INODE[@]}
        do
          for block in ${BLOCK[@]}
          do
# at this point, we have our filesystem creation options
# now, we need to run the tests using different mount options
# and different IO schedulers
            MKFS_CMD="$MKFS -d agcount=$a -l size=${l}m -l lazy-count=$lazy -i size=$inode -b size=$block -f $TEST_DEVICE"
            mount_loop
          done
        done
      done
    done
  done
}

function mount_loop()
{
# we have $MKFS_CMD
  for largeio in ${LARGEIO[@]}
  do
    for delaylog in ${DELAYLOG[@]}
    do
      MOUNT_CMD="$MOUNT -o $FIXED_OPTIONS,$largeio,$delaylog $TEST_DEVICE $TEST_PATH"
      scheduler_loop
    done
  done
}

function scheduler_loop()
{
  for iosched in ${IO[@]}
  do
# at this point, we have $iosched, $MKFS_CMD and $MOUNT_CMD
# time to do the benchmark
    benchmark_test
  done
}

function benchmark_test()
{
  cd $SOURCE_PATH
  echo $iosched > /sys/block/$TEST_DEV/queue/scheduler
  ($UMOUNT $TEST_DEVICE) 2>/dev/null
  $MKFS_CMD
  $MOUNT_CMD
  TIME_RSYNC=`(time $RSYNC -aplx $SOURCE_PATH/ $TEST_PATH/) 2>&1|tr '\n' ' '`
  TIME_CHOWN=`(time $CHOWN -R $UIDGID $TEST_PATH) 2>&1|tr '\n' ' '`
# at this point, our TEST_PATH is set up, properly chowned and 
# ready for benchmarking
  cd $TEST_PATH
# untar
  TIME_UNTAR=`(time (ls -1d *.bz2 | awk '{ print "tar xjf " $1 }' | sh) 2>&1)|tr '\n' ' '`
# retar
  TIME_TAR=`(time tar cjf bigtar.tar linux*) 2>&1|tr '\n' ' '`
# remove 100k
  TIME_RM=`(time rm -rf $TEST_PATH/100kdir) 2>&1|tr '\n' ' '`
# bonnie
  TIME_BONNIE=`(time ($BONNIE -q -g $UIDGID -s 8g -n 512 2>/dev/null) 2>&1)|tr '\n' ' '`
  echo "START----------" >> $LOG_FILE
  echo `date` >> $LOG_FILE
  echo "Scheduler: $iosched" >> $LOG_FILE
  echo "mkfs: $MKFS_CMD" >> $LOG_FILE
  echo "mount: $MOUNT_CMD" >> $LOG_FILE
  echo "Times:" >> $LOG_FILE
  echo "rsync: $TIME_RSYNC" >> $LOG_FILE
  echo "chown: $TIME_CHOWN" >> $LOG_FILE
  echo "untar: $TIME_UNTAR" >> $LOG_FILE
  echo "tar: $TIME_TAR" >> $LOG_FILE
  echo "rm: $TIME_RM" >> $LOG_FILE
  echo "bonnie: $TIME_BONNIE" >> $LOG_FILE
  echo "END------------" >> $LOG_FILE
  cd $SOURCE_PATH

}

# mount source_path which contains 5 bzipped kernels, two directories with
# 10000 and 100000 files
cd $SOURCE_PATH
mkfs_loop
