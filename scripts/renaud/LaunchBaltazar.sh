#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: LaunchBaltazar.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: LaunchBaltazar.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i              : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: LaunchBaltazar.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: LaunchBaltazar.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i              : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: LaunchBaltazar.sh -i <SUBJECTS_DIR> "
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

count=0
total=0
for subj in `ls -1 ${input} --hide=00_Admin --hide=FreeSurfer --hide=newsegment`
do
	if [ ! -d ${input}/FreeSurfer/${subj}/mri ]
	then
		echo "Patient : ${subj}"
		if [ ! -d ${input}/FreeSurfer/${subj} ]
		then
			echo "mkdir ${input}/FreeSurfer/${subj}"
			mkdir ${input}/FreeSurfer/${subj}
		fi
		rm -f ${input}/${subj}/*.nii
		rm -f ${input}/${subj}/*.gz
		echo "dcm2nii -o ${input}/${subj} ${input}/${subj}/*"
		dcm2nii -o ${input}/${subj} ${input}/${subj}/*
		echo "qbatch -q fs_q -oe /home/renaud/log/ -N fs_${subj} recon-all -all -sd ${input}/FreeSurfer/ -subjid ${subj} -nuintensitycor-3T -force -i `ls -1 ${input}/${subj}/*gz`"
		qbatch -q fs_q -oe /home/renaud/log/ -N fs_${subj} recon-all -all -sd ${input}/FreeSurfer/ -subjid ${subj} -nuintensitycor-3T -force -i `ls -1 ${input}/${subj}/*gz`
		total=$[$total+1]
	else
		echo "patient ${subj} ok !!"
	fi
done

echo "$total freesurfers ont été lancés"

