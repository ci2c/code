#!/bin/bash


echo " BACKUP A FOLDER, COMPRESS + md5sum
"

cd $1

for subfolder in $(ls -d *)
do

if
[ -d ${subfolder} ]
then
echo "Backup ${subfolder} in $1"

backup_folder.sh $1 ${subfolder}

fi


done

