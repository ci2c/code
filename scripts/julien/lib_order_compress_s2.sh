#!/bin/bash


cd /home/notorious/NAS/julien/lib07/

for station in $(ls -d *)
do

	echo "qbatch -N d_${station} -q fs_q -oe /home/julien/log/ dcm_compress_archive.sh /home/notorious/NAS/julien/lib07/${station}/"
	qbatch -N d_${station} -q fs_q -oe /home/julien/log/ dcm_compress_archive.sh /home/notorious/NAS/julien/lib07/${station}/
	sleep 2
done


