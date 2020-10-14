#!/bin/bash


echo " BACKUP A FOLDER, COMPRESS + md5sum
"



cd $1
tar -cvf $2.tar  $2/
#pbzip2 -f $2.tar
lbzip2 -f --best -v -n 8 $2.tar
md5sum $2.tar.bz2 > $2.checksum
echo "check bzip2 integrity"
bzip2 -vt $2.tar.bz2
echo "check md5sum"
md5sum -c $2.checksum
echo "Backup finished"