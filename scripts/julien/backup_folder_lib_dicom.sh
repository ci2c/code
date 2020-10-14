#!/bin/bash


echo " BACKUP A FOLDER, COMPRESS + md5sum
"



cd $1




for mois in $(ls -d *)
do


	cd ${1}${mois}
	
	for jour in $(ls -d *)
	do

	cd ${1}${mois}/${jour}
	
		for study in $(ls -d *)
		do
			
			echo "Compression ${study} in ${1}${mois}/${jour}"
			tar -cvf ${study}.tar  ${study}/
			pbzip2 -f ${study}.tar
			md5sum ${study}.tar.bz2 > ${study}.checksum
			echo "check bzip2 integrity"
			bzip2 -vt ${study}.tar.bz2
			echo "check md5sum"
			md5sum -c $2.checksum
			echo "Backup finished"
			rm -rf ${1}${mois}/${jour}/${study}/
		done




	done

done
