#!/bin/bash
# 
echo "
*---------------------* 
* Starting Sql Backup *
*---------------------*

"

THEDATE=`date +%Y-%m-%d_%H-%M`

cd /NAS/dumbo/BACKUP3T/sql_db/

mysqldump -v --user=root --password=xpzf1248 philips_par > /NAS/dumbo/BACKUP3T/sql_db/sql_backup_$THEDATE.bak
echo "
Compressing ... "
tar -cvf sql_backup_$THEDATE.bak.tar sql_backup_$THEDATE.bak
pbzip2 -f sql_backup_$THEDATE.bak.tar
rm sql_backup_$THEDATE.bak


echo "Removing older sql backup : keeping 15 days ...
"

find /NAS/dumbo/BACKUP3T/sql_db/sql_backup_* -mtime +15 -exec rm {} \;

echo "
*----------------------* 
* Starting Site Backup *
*----------------------*

Compressing ...
"
tar -cvf /NAS/dumbo/BACKUP3T/sql_db/site_backup_$THEDATE.tar   /var/www/imvdb/
pbzip2 -f site_backup_$THEDATE.tar
echo "
Removing older site backup : keeping 15 days ...
"
find /NAS/dumbo/BACKUP3T/sql_db/site_backup_* -mtime +15 -exec rm {} \;

echo "Backup finished"

