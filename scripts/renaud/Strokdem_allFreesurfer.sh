#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Strokdem_allFreesurfer.sh -i <SUBJECTS_DIR> "
	echo ""
	echo "  -i               : Path to data (i.e. SUBJECTS_DIR)"
	echo ""
	echo "Usage: LaunchBaltazar.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: Strokdem_allFreesurfer.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i              : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Strokdem_allFreesurfer.sh -i <SUBJECTS_DIR> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data path : $input"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Strokdem_allFreesurfer.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i              : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Strokdem_allFreesurfer.sh -i <SUBJECTS_DIR> "
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

ARRAY=(72H M6 M12)
count=0
total=0
while [ ${count} -le 2 ]
do
	for subj in `ls -1 ${datadir} --hide=00_Admin --hide=asl --hide=spharm --hide=freesurfer --hide=jobs --hide=dti --hide=FS5.1 --hide=GPU`
	do
		if [ `ls ${subj}/${ARRAY[$count]} | grep -i gz$ |wc -l` -ge 1 ] && [ -d ${input}/FS5.1/${subj}_${ARRAY[$count]} ]
		then
			echo "freesurfer patient ${subj} ok pour le timepoint ${ARRAY[$count]}"
		else
			echo "freesurfer pas fait pour le patient ${subj} time point ${ARRAY[$count]}"
			if [ `ls ${subj}/${ARRAY[$count]} | grep -i rec&` ]
			then
				echo "on convertit les donnees pour ${subj} ${ARRAY[$count]}" 
				dcm2nii -o ${input}/${subj}/${ARRAY[$count]} ${input}/${subj}/${ARRAY[$count]}/*
				qbatch -q fs_q -oe /home/renaud/log/ -N fs_${subj}_${ARRAY[$count]} Strokdem_freesurfer.sh -i ${subj} -s ${ARRAY[$count]}
				total=$[$total+1]
			fi
		fi
	done
	count=$[$count+1]
done

echo "$total freesurfers ont été lancés"
