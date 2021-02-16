BACKUPDIR=/tbbackup/mariadb_backup

BASEBACKDIR=$BACKUPDIR/base


# Find latest backup directory
LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`


echo "latest backup base :  $LATEST"

cd $BACKUPDIR
for i in $(find . -name backup.stream.gz | grep $LATEST | xargs dirname); \
do \
mkdir -p $i/backup; \
zcat $i/backup.stream.gz | mbstream -x -C $i/backup/; \

echo $i
done

echo 'Decompress Successfully'
