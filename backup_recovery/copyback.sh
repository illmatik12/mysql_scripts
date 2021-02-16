BACKUPDIR=/tbbackup/mariadb_backup

BASEBACKDIR=$BACKUPDIR/base


# Find latest backup directory
LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`


echo "latest backup base :  $LATEST"

PREPARE_DIR=$BASEBACKDIR/$LATEST/backup

echo $PREPARE_DIR

systemctl stop mariadb

rm -rf /maria_data_bak
mv /maria_data /maria_data_bak

mkdir /maria_data

mariabackup --copy-back --target-dir $PREPARE_DIR --user backup --password "Mysql123!" --datadir /maria_data

chown -R mysql:mysql /maria_data

