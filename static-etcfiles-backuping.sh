#!/bin/bash
BACKUP_BUCKET='project-stage-backups'
ROTATION_COUNT_S3='14'
ROTATION_COUNT_LOCAL='3'
S3_ENDPOINT='https://s3.selcdn.ru'
BASE_DIR='/var/backups/staticfiles'
YMD=$(date "+%Y-%m-%d")
HM=$(date "+%H%M")
DIR="$BASE_DIR/$YMD"
SOURCE_DIRS='/var/www/project/current/storage/app/ /etc/'

mkdir -p "$DIR"
cd "$DIR"

XZ_OPT=-9 tar cJf $DIR/project-static-$YMD-$HM.tar.xz $SOURCE_DIRS

echo "Backups were created at $YMD:$(date "+%H:%M:%S")" >> "$DIR/backup.log"

# send backups to dump-server
aws s3 sync --endpoint-url $S3_ENDPOINT $DIR s3://$BACKUP_BUCKET/staticfiles/$YMD

#Rotation backup s3
OLDBACKUPS=$(aws --endpoint-url=$S3_ENDPOINT s3 ls s3://$BACKUP_BUCKET/staticfiles/ | head -n -$ROTATION_COUNT_S3 | awk '{print $2}') #$2 for folders, $4 for files
for BACKUP in $OLDBACKUPS; do
        aws --endpoint-url=$S3_ENDPOINT s3 rm --recursive s3://$BACKUP_BUCKET/staticfiles/$BACKUP;
done

#Rotation backup local
cd "$BASE_DIR"
ls -1 $BASE_DIR/ | sort | head -n -$ROTATION_COUNT_LOCAL | xargs rm -rfv
