# mastodon-backup
mastodon-backup
This is designed for a server that have 2 disks one for the / and one for /home/mastodon . The script backup the important files to a directory on `/opt/mastodon-backup/backup-data` with the current date. like `/opt/mastodon-backup/backup-data/2024_09_17_12_00_AM` and remove the las 7 day backup.

* `cd /opt/`
* `git clone https://github.com/prfiredragon/mastodon-backup.git`
* `chmod a+x /opt/mastodon-backup/backup.sh`
* `mkdir /opt/mastodon-backup/logs/`
* `crontab -e`
* add the line  `0 0 * * * /opt/mastodon-backup/backup.sh > /opt/mastodon-backup/logs/backup.log 2>&1`
* save and exit
* restart cron `sudo service cron restart`
