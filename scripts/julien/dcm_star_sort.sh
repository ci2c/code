#!/bin/bash


export LC_CTYPE=C
export LANG=C

echo "
********************************************************************
**            DCM STAR sort              By J.Dumont              **
********************************************************************
"



if [ $# -lt 3 ]
then
echo "Usage:  dcm_star_sort.sh  -i <input folder> -o <output folder> -c <y|n>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "  -c                         : compression"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
fi

index=1

while [ $index -le $# ]
do
eval arg=\${$index}
case "$arg" in
-h|-help)
echo ""
echo "Usage:  dcm_star_sort.sh  -i <input folder> -o <output folder> -c <y|n>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "  -c                         : compression"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
;;
-i)
index=$[$index+1]
eval input=\${$index}
echo "input folder : ${input}"
;;
-o)
index=$[$index+1]
eval output=\${$index}
echo "output folder : ${output}"
;;
-c)
index=$[$index+1]
eval compression=\${$index}
echo "compression : ${compression}"
;;
-*)
eval infile=\${$index}
echo "${infile} : unknown option"
echo ""
echo "Usage:  dcm_star_sort.sh  -i <input folder> -o <output folder> -c <y|n>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "  -c                         : compression"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
;;
esac
index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
echo "-i argument mandatory"
exit 1
fi

if [ -z ${output} ]
then
echo "-o argument mandatory"
exit 1
fi

cd ${input}


for study in $(ls -d *)
do
/home/julien/SVN/scripts/julien/dcm_sort.sh -i ${input}${study}/ -o ${output}

done



if [ "${compression}" == "y" ]
then

	cd ${output}
	if [ -f "patient.log" ]; then
	rm patient.log
	fi
	if [ -f "study.log" ]; then
	rm study.log
	fi
	rm -rf _/
	if [ -f "_.log" ]; then	
	rm _.log
	fi	

	for patient in $(ls -d *)
	do
	echo "
-------------- compression de ${patient}"
	#if
    	#	[ -d ${patient} ]
	#then

		cd ${output}${patient}/

		for study in $(ls -d *)
		do



			cd ${output}${patient}/${study}/
	
			for serie in $(ls -d *)
			do

			if
    				[ -d ${serie} ]
			then
				# compte le nombre de fichier DICOM
				# on retire les dicom commençant par phMR, qui sont des fichiers non images sur ETIAM
				cd ${output}${patient}/${study}/${serie}/
				nb=$(find -name "*.dcm" -type f | sed '/phMR*/d' | wc -l)
				echo "${nb}" >> ${output}${patient}/${study}/${serie}.log
				cd ${output}${patient}/${study}/
				#create tar
				tar -cvf ${serie}.tar  ${serie}/
				#test du .tar
				echo "Testing tar archive ..."
				if ! tar tf ${serie}.tar  &> /dev/null; then
					echo "Error when creating tar archive ${patient}/${study}->${serie}" >> error.log	
				else
					echo "tar ok"
					echo "Compressing with bzip2"
					#create bz2 
					bzip2 -f ${serie}.tar
					#testing bz archive
					echo "Testing bzip2 archive ..."
					bzip2 -vt  ${serie}.tar.bz2 2> test_${serie}.txt
					result=$(sed -n 1p test_${serie}.txt | sed 's/.*\(..\)$/\1/')
					
					if  [ "${result}" == "ok" ]
					then	
						echo "bzip2 ok"
						rm test_${serie}.txt
						rm -rf ${serie}/
						md5sum ${serie}.tar.bz2 > ${serie}.checksum
					else					
						echo "Error when creating bz2 archive ${patient}/${study}->${serie}" >> error.log
					fi


				fi
				
			fi
		done #serie
	
	done #study
#fi
done  # patient

fi # if compress





