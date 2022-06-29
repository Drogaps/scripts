#!/bin/bash

DUMPALL='/usr/bin/pg_dumpall'
PGDUMP='/usr/bin/pg_dump'
PSQL='/usr/bin/psql'
BACKUP_BUCKET='your_bucket_name'
ROTATION_COUNT_S3='14'
ROTATION_COUNT_LOCAL='3'
S3_ENDPOINT='https://s3.selcdn.ru'
BASE_DIR='/var/backups/postgres'
YMD=$(date "+%Y-%m-%d")
HM=$(date "+%H%M")
DIR="$BASE_DIR/$YMD/$HM"

mkdir -p "$DIR"
cd "$DIR"

# get list of databases in system , exclude the tempate dbs
DBS=( $(sudo -u postgres $PSQL --list --tuples-only |
          awk '!/template[01]/ && $1 != "|" {print $1}') )

# first dump entire postgres database, including pg_shadow etc.
sudo -u postgres $DUMPALL --column-inserts | gzip -9 > "$DIR/db.out.gz"

# next dump globals (roles and tablespaces) only
sudo -u postgres $DUMPALL --globals-only | gzip -9 > "$DIR/globals.gz"

# now loop through each individual database and backup the
# schema and data separately
for database in "${DBS[@]}" ; do

    # dump database
    sudo -u postgres $PGDUMP "$database" |
        gzip -9 > "$DIR/$database.gz"
done

echo "Backups were created at $YMD:$(date "+%H:%M:%S")" >> "$DIR/backup.log"

# send backups to dump-server
aws s3 sync --endpoint-url $S3_ENDPOINT $DIR s3://$BACKUP_BUCKET/postgres/$YMD/$HM

#Rotation backup s3
OLDBACKUPS=$(aws --endpoint-url=$S3_ENDPOINT s3 ls s3://$BACKUP_BUCKET/postgres/ | head -n -$ROTATION_COUNT_S3 | awk '{print $2}') #$2 for folders, $4 for files
for BACKUP in $OLDBACKUPS; do
        aws --endpoint-url=$S3_ENDPOINT s3 rm --recursive s3://$BACKUP_BUCKET/postgres/$BACKUP;
done

#Rotation backup local
cd "$BASE_DIR"
ls -1 $BASE_DIR/ | sort | head -n -$ROTATION_COUNT_LOCAL | xargs rm -rfv
