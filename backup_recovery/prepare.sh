BACKUPDIR=/tbbackup/mariadb_backup

BASEBACKDIR=$BACKUPDIR/base


# Find latest backup directory
LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`


echo "latest backup base :  $LATEST"

PREPARE_DIR=$BASEBACKDIR/$LATEST/backup

echo $PREPARE_DIR

mariabackup --prepare --target-dir $PREPARE_DIR --user backup --password "Mysql123!" --apply-log-only


cd $BACKUPDIR/incr
for i in $(find $BACKUPDIR/incr -name backup.stream.gz| sort | grep $LATEST | xargs dirname); 
do 
echo $i

mariabackup --prepare --target-dir $PREPARE_DIR --user backup --password "Mysql123!" --apply-log-only --incremental-dir $i/backup

done

echo 'Prepare Successfully'
