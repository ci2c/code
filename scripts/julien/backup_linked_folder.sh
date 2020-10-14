#!/bin/bash


echo " BACKUP A LINKED FOLDER, COMPRESS + md5sum
"



cd $1

link_path=$(readlink $2)
link_folder=$(echo "${link_path}" | awk -F/ '{print $NF}')
nb_cara_folder=${#link_folder}
nb_cara_path=${#link_path}
echo "linked path : ${link_path} (${nb_cara_path})"
echo "folder to compress : ${link_folder} (${nb_cara_folder})"
nb=$(( ${nb_cara_path} - ${nb_cara_folder} ))
small_path=${link_path:0:${nb}}
echo "Compress in (${nb}) : ${small_path}"

cd ${small_path}
tar -cvf $2.tar  ${link_folder}/
pbzip2 -f $2.tar
md5sum $2.tar.bz2 > $2.checksum
echo "check bzip2 integrity"
bzip2 -vt $2.tar.bz2
echo "check md5sum"
md5sum -c $2.checksum
echo "Moving archive"
mv $2.tar.bz2 $1
mv $2.checksum $1
echo "Backup finished"