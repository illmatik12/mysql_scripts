#!/bin/sh

# Create a backup user
# GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'backup'@'localhost' identified by 'YourPassword';
# FLUSH PRIVILEGES;
#
# Usage:
# MYSQL_PASSWORD=YourPassword bash run-mariabackup.sh

MYSQL_USER=backup
MYSQL_PASSWORD=Mysql123!
MYSQL_HOST=127.0.0.1
MYSQL_PORT=13306
BACKCMD=mariabackup # Galera Cluster uses mariabackup instead of xtrabackup.
#BACKDIR=/data/mysql_backup
BACKDIR=/tbbackup/mariadb_backup
FULLBACKUPCYCLE=604800 # Create a new full backup every X seconds
#FULLBACKUPCYCLE= # Create a new full backup every X seconds
KEEP=30 # Number of additional backups cycles a backup should kept for.
LOCKDIR=/tmp/mariabackup.lock

ReleaseLockAndExitWithCode () {
  if rmdir $LOCKDIR
  then
    echo "Lock directory removed"
  else
    echo "Could not remove lock dir" >&2
  fi
  exit $1
}

GetLockOrDie () {
  if mkdir $LOCKDIR
  then
    echo "Lock directory created"
  else
    echo "Could not create lock directory" $LOCKDIR
    echo "Is another backup running?"
    exit 1
  fi
}

USEROPTIONS="--user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} --port=${MYSQL_PORT}"
ARGS="--parallel=8"
BASEBACKDIR=$BACKDIR/base
INCRBACKDIR=$BACKDIR/incr
START=`date +%s`

echo "----------------------------"
echo
echo "run-mariabackup.sh: MySQL backup script"
echo "started: `date`"
echo

if test ! -d $BASEBACKDIR
then
  mkdir -p $BASEBACKDIR
fi

# Check base dir exists and is writable
if test ! -d $BASEBACKDIR -o ! -w $BASEBACKDIR
then
  error
  echo $BASEBACKDIR 'does not exist or is not writable'; echo
  exit 1
fi

if test ! -d $INCRBACKDIR
then
  mkdir -p $INCRBACKDIR
fi

# check incr dir exists and is writable
if test ! -d $INCRBACKDIR -o ! -w $INCRBACKDIR
then
  error
  echo $INCRBACKDIR 'does not exist or is not writable'; echo
  exit 1
fi

if [ -z "`mysqladmin $USEROPTIONS status | grep 'Uptime'`" ]
then
  echo "HALTED: MySQL does not appear to be running."; echo
  exit 1
fi

if ! `echo 'exit' | /usr/bin/mysql -s $USEROPTIONS`
then
  echo "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)"; echo
  exit 1
fi

GetLockOrDie

echo "Check completed OK"

# Find latest backup directory
LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`



AGE=`stat -c %Y $BASEBACKDIR/$LATEST`

echo '########################################'
echo $LATEST
echo $AGE

echo '########################################'
if [ "$LATEST" -a `expr $AGE + $FULLBACKUPCYCLE + 5` -ge $START ]
then
  echo 'New incremental backup'
  # Create an incremental backup

  # Check incr sub dir exists
  # try to create if not
  if test ! -d $INCRBACKDIR/$LATEST
  then
    mkdir -p $INCRBACKDIR/$LATEST
  fi

  # Check incr sub dir exists and is writable
  if test ! -d $INCRBACKDIR/$LATEST -o ! -w $INCRBACKDIR/$LATEST
  then
    echo $INCRBACKDIR/$LATEST 'does not exist or is not writable'
    ReleaseLockAndExitWithCode 1
  fi

  LATESTINCR=`find $INCRBACKDIR/$LATEST -mindepth 1  -maxdepth 1 -type d | sort -nr | head -1`
  if [ ! $LATESTINCR ]
  then
    # This is the first incremental backup
    INCRBASEDIR=$BASEBACKDIR/$LATEST
  else
    # This is a 2+ incremental backup
    INCRBASEDIR=$LATESTINCR
  fi

  TARGETDIR=$INCRBACKDIR/$LATEST/`date +%F_%H-%M-%S`
  mkdir -p $TARGETDIR

  # Create incremental Backup
  $BACKCMD --backup $USEROPTIONS $ARGS --extra-lsndir=$TARGETDIR --incremental-basedir=$INCRBASEDIR --stream=xbstream | gzip > $TARGETDIR/backup.stream.gz
else
  echo 'New full backup'

  TARGETDIR=$BASEBACKDIR/`date +%F_%H-%M-%S`
  mkdir -p $TARGETDIR

  # Create a new full backup
  $BACKCMD --backup $USEROPTIONS $ARGS --extra-lsndir=$TARGETDIR --stream=xbstream | gzip > $TARGETDIR/backup.stream.gz
fi

MINS=$(($FULLBACKUPCYCLE * ($KEEP + 1 ) / 60))
echo "Cleaning up old backups (older than $MINS minutes) and temporary files"

# Delete old backups
for DEL in `find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -mmin +$MINS -printf "%P\n"`
do
  echo "deleting $DEL"
  rm -rf $BASEBACKDIR/$DEL
  rm -rf $INCRBACKDIR/$DEL
done

SPENT=$((`date +%s` - $START))
echo
echo "took $SPENT seconds"
echo "completed: `date`"
ReleaseLockAndExitWithCode 0
