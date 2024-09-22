#!/bin/bash

#Get the relative path of the backup script
        backup_script=$(dirname "$realpath $0")
#Define backup directory
        backup_folder_name="/opt/mastodon-backup/backup-data/$(date +"%Y_%m_%d_%I_%M_%p")"
        old_backup_folder_name="/opt/mastodon-backup/backup-data/$(date -d "7 days ago" +"%Y_%m_%d_%I_%M_%p")"
#Define log directory
        logdirectory="/opt/mastodon-backup/logs"

#Script GO Home
cd $backup_script


# Validate if exist the backup dirs
        DIRECTORY="./backup-data"
if [ ! -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does not exist."
  mkdir $DIRECTORY
  echo "$DIRECTORY created"
else
  echo "$DIRECTORY does exist."
fi

        DIRECTORY="$backup_folder_name"
if [ ! -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does not exist."
  mkdir $DIRECTORY
  echo "$DIRECTORY created"
else
  echo "$DIRECTORY does exist."
fi

        DIRECTORY="$logdirectory"
if [ ! -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does not exist."
  mkdir $DIRECTORY
  echo "$DIRECTORY created"
else
  echo "$DIRECTORY does exist."
fi

#Stopping mastodon processes
    systemctl stop mastodon-*

#Generating a database dump backup
    su - mastodon -c "cd /home/mastodon/live && pg_dump -Fc mastodon_production > backup.dump"

#Moving the database backup
    #$AWS s3 mv /home/mastodon/live/backup.dump s3://$s3_bucket_name/$backup_folder_name/home/mastodon/live/backup.dump
    mkdir -p $backup_folder_name/home/mastodon/live
    mv -v /home/mastodon/live/backup.dump $backup_folder_name/home/mastodon/live/backup.dump

#Copying important files
    #$AWS s3 cp /home/mastodon/live/.env.production s3://$s3_bucket_name/$backup_folder_name/home/mastodon/live/.env.production
    #$AWS s3 cp /var/lib/redis/dump.rdb s3://$s3_bucket_name/$backup_folder_name/var/lib/redis/dump.rdb
    #$AWS s3 cp /etc/nginx/sites-available/ s3://$s3_bucket_name/$backup_folder_name/etc/nginx/sites-available/ --recursive
    #$AWS s3 cp /etc/elasticsearch/jvm.options s3://$s3_bucket_name/$backup_folder_name/etc/elasticsearch/jvm.options

    cp -v /home/mastodon/live/.env.production $backup_folder_name/home/mastodon/live/.env.production
    mkdir -p $backup_folder_name/var/lib/redis
    cp -v /var/lib/redis/dump.rdb $backup_folder_name/var/lib/redis/dump.rdb
    mkdir -p $backup_folder_name/etc/nginx/sites-available
    cp -v /etc/nginx/sites-available/ $backup_folder_name/etc/nginx/sites-available/ --recursive
    #mkdir -p $backup_folder_name/etc/elasticsearch
    #cp /etc/elasticsearch/jvm.options $backup_folder_name/etc/elasticsearch/jvm.options
#Starting the mastodon processes
    systemctl start mastodon-web mastodon-sidekiq mastodon-streaming



        DIRECTORY="$old_backup_folder_name"
if [ -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does exist."
  rm -r $DIRECTORY
  echo "$DIRECTORY created"
else
  echo "$DIRECTORY not does exist."
fi
