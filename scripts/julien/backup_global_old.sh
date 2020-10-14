#!/bin/bash


echo " BACKUP global
"
cd /home/global/

for dirname in $(ls -d *)
	do






tar -cvf /home/notorious/NAS/julien/gaia_backup/${dirname}.tar  ${dirname}/
pbzip2 -f /home/notorious/NAS/julien/gaia_backup/${dirname}.tar
md5sum /home/notorious/NAS/julien/gaia_backup/${dirname}.tar.bz2 > /home/notorious/NAS/julien/gaia_backup/${dirname}.checksum
echo "check bzip2 integrity"
bzip2 -vt /home/notorious/NAS/julien/gaia_backup/${dirname}.tar.bz2
echo "check md5sum"
md5sum -c /home/notorious/NAS/julien/gaia_backup/${dirname}.checksum
echo "Backup finished"

done
