#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Baltazar_VBM8.sh -i <SUBJECTS_DIR> "
	echo ""
	echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
	echo ""
	echo "Usage: Baltazar_VBM8.sh -i <SUBJECTS_DIR> "
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
		echo ""
		echo "Usage: Baltazar_VBM8.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Baltazar_VBM8.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: Baltazar_VBM8.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Baltazar_VBM8.sh -i <SUBJECTS_DIR> "
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

## Check if ouput folder exists
if [ ! -d ${input}/vbm8 ]
then
	echo "mkdir ${input}/vbm8"
	mkdir ${input}/vbm8
fi

count=0
total=0
for subj in `ls -1 ${input} --hide=00_Admin --hide=FreeSurfer --hide=newsegment --hide=vbm8`
do
	if [ ! -d ${input}/vbm8/${subj} ]
	then
		echo "Patient : ${subj}"
		echo "mkdir ${input}/vbm8/${subj}"
		mkdir ${input}/vbm8/${subj}
		if [ -e ${input}/${subj}/*.nii.gz ]
		then
			cp ${input}/${subj}/*.nii.gz ${input}/vbm8/${subj}/
			gunzip ${input}/vbm8/${subj}/*.gz
		else
			if [ -e ${input}/${subj}/*.nii ]
			then
				cp ${input}/${subj}/*.nii ${input}/vbm8/${subj}/
			else				
				echo "dcm2nii -o ${input}/vbm8/${subj} ${input}/${subj}/*"
				dcm2nii -o ${input}/vbm8/${subj} ${input}/${subj}/*.par
				gunzip ${input}/vbm8/${subj}/*.gz
			fi
		fi
		
		echo "qbatch -q fs_q -oe /home/renaud/log/ -N ns_${subj} NewSegmentSPM8.sh -i ${input}/vbm8/${subj}"
		qbatch -q fs_q -oe /home/renaud/log/ -N v_${subj} VBM8.sh -i ${input}/vbm8/${subj}

		total=$[$total+1]
	else
		echo "patient ${subj} ok !!"
	fi
done

echo "$total newsegment ont été lancés"

