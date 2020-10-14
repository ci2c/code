#!/bin/bash

dcmpath=/home/notorious/2011_SEM_26/DICOM
outdir=/home/notorious/2011_SEM_26
#dcmfiles=`ls ${dcmpath}/*`

cd ${dcmpath}

#ls | grep -v '\..*$' > foldlist

# for inode in $(ls -R)
# do
# 	for dcmfile in `ls ${inode}/*`
# 	do
# 		if [ -d ${dcmfile} ]
# 		then
# 			for dcm in `ls ${dcmfile}/`
# 			do
# 				echo ${dcm}
# 				nmbrs=`dcmdump --load-short --search "0010,0010" --search-first ${dcm} | sed 's/.*\[\(.*\)\].*/\1/g' | tr '\012' ' '`
# 				if [ ! -d ${outdir}/${nmbrs} ]
# 				then
# 					sudo mkdir ${outdir}/${nmbrs}
# 				fi
# 				echo "sudo cp ${dcm} ${outdir}/${nmbrs}"
# 				sudo cp ${dcm} ${outdir}/${nmbrs}
# 			done
# 		elif [ -f ${dcmfile} ]
# 		then
# 			echo ${dcmfile} 
# 			nmbrs=`dcmdump --load-short --search "0010,0010" --search-first ${dcmfile} | sed 's/.*\[\(.*\)\].*/\1/g' | tr '\012' ' '`
# 			if [ ! -d ${outdir}/${nmbrs} ]
# 			then
# 				sudo mkdir ${outdir}/${nmbrs}
# 			fi
# 			echo "sudo cp ${dcmfile} ${outdir}/${nmbrs}"
# 			sudo cp ${dcmfile} ${outdir}/${nmbrs}
# 		fi
# 	done
# done
	
for dcmfile in `ls ${dcmpath}/*`
do
	if [ -d ${dcmfile} ]
	then
		for dcm in `ls ${dcmfile}/`
		do
			echo ${dcm}
			nmbrs=`dcmdump --load-short --search "0010,0010" --search-first ${dcm} | sed 's/.*\[\(.*\)\].*/\1/g' | tr '\012' ' '`
			if [ ! -d ${outdir}/${nmbrs} ]
			then
				sudo mkdir ${outdir}/${nmbrs}
			fi
			echo "sudo cp ${dcm} ${outdir}/${nmbrs}"
			sudo cp ${dcm} ${outdir}/${nmbrs}
		done
	elif [ -f ${dcmfile} ]
	then
		echo ${dcmfile} 
		nmbrs=`dcmdump --load-short --search "0010,0010" --search-first ${dcmfile} | sed 's/.*\[\(.*\)\].*/\1/g' | tr '\012' ' '`
		if [ ! -d ${outdir}/${nmbrs} ]
		then
			sudo mkdir ${outdir}/${nmbrs}
		fi
		echo "sudo cp ${dcmfile} ${outdir}/${nmbrs}"
		sudo cp ${dcmfile} ${outdir}/${nmbrs}
	fi
done

