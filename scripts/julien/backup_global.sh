#!/bin/bash
# 
echo "
*------------------------* 
* Starting Global Backup *
*------------------------*

"

THEDATE=`date +%Y-%m-%d_%H-%M`


/home/julien/SVN/scripts/julien/archiving_tool.sh -i /home/global/ -comp lbzip2 -cpu 4 -subfolder no
mv /home/global.tar.bz2  /NAS/dumbo/BACKUP3T/global_backup/global_backup_${THEDATE}.tar.bz2
mv /home/global.checksum /NAS/dumbo/BACKUP3T/global_backup/global_backup_${THEDATE}.checksum
sudo sed -i -e "s/global.tar.bz2/global_backup_${THEDATE}.tar.bz2/g" /NAS/dumbo/BACKUP3T/global_backup/global_backup_${THEDATE}.checksum

echo "Removing older global backup : keeping 5 month ...
"

find /NAS/dumbo/BACKUP3T/global_backup/global_backup_* -mtime +150 -exec rm {} \;

echo "Backup finished"
