#!/bin/sh
# Inspired by https://thesmarthomejourney.com/2020/05/07/how-to-update-openhabian/ and https://gist.github.com/oksbwn/0f8615395e57b876d4de4e5720c9cc55

currentDate=`date +%Y-%m-%dT%H:%M`
mkdir backup
cd backup

# Backup openhab
sudo openhab-cli backup openhab.zip

# Create influxdb backup folder and dump the openhab database and general settings into it
export INFLUX_USERNAME=
export INFLUX_PASSWORD=
mkdir influxDbBackup
sudo cp -arv "/etc/influxdb/influxdb.conf" ./influxDbBackup/influxDB.conf
sudo influxd backup ./influxDbBackup/
mkdir influxDbBackup/db
sudo influxd backup -database openhab_db influxDbBackup/db/

# Create grafana backup folder and dump the database and settings
mkdir grafanaBackup
sudo cp -arv /etc/grafana/grafana.ini ./grafanaBackup/grafana.ini
sudo cp -arv /var/lib/grafana/grafana.db ./grafanaBackup/grafana.db

# Zip it
cd ..
sudo zip -r openhab-$currentDate.zip backup

# Store to fritzbox
sudo mount -t cifs -o credentials=$HOME/.smbcredentials,vers=3.0,noserverino //fritz.box/FRITZ.NAS/ /mnt/fritzbox/
sudo cp openhab-$currentDate.zip /mnt/fritzbox/EXTERN/openhab-backup/
sudo umount /mnt/fritzbox

# Clean up
rm -f openhab-$currentDate.zip
rm -rf backup
