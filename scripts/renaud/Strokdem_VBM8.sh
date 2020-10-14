#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Strokdem_VBM8.sh -i <SUBJECTS_DIR> "
	echo ""
	echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
	echo ""
	echo "Usage: Strokdem_VBM8.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: Strokdem_VBM8.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Strokdem_VBM8.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: Strokdem_VBM8.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Strokdem_VBM8.sh -i <SUBJECTS_DIR> "
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

ARRAY=(72H M6 M12)
count=0
total=0
while [ ${count} -le 2 ]
do
	for subj in `ls -1 ${input} --hide=00_Admin --hide=asl --hide=spharm --hide=freesurfer --hide=jobs --hide=dti --hide=FS5.1 --hide=GPU --hide=vbm8`
	do
		if [ ! -d ${input}/vbm8/${subj}_${ARRAY[$count]} ]
		then
			if [ "$(ls -A ${input}/${subj}/${ARRAY[$count]})" ]
			then
				echo "Patient : ${subj}_${ARRAY[$count]}"
				echo "mkdir ${input}/vbm8/${subj}_${ARRAY[$count]}"
				mkdir ${input}/vbm8/${subj}_${ARRAY[$count]}
				if [ -e ${input}/${subj}/${ARRAY[$count]}/*.nii ]
				then
					cp ${input}/${subj}/${ARRAY[$count]}/*.nii ${input}/vbm8/${subj}_${ARRAY[$count]}/
				else
					if [ -e ${input}/${subj}/${ARRAY[$count]}/*.nii.gz ]
					then
						cp ${input}/${subj}/${ARRAY[$count]}/*.nii.gz ${input}/vbm8/${subj}_${ARRAY[$count]}/
						gunzip ${input}/vbm8/${subj}_${ARRAY[$count]}/*.gz
					else				
						echo "dcm2nii -o ${input}/vbm8/${subj}_${ARRAY[$count]} ${input}/${subj}/${ARRAY[$count]}/*"
						dcm2nii -o ${input}/vbm8/${subj}_${ARRAY[$count]} ${input}/${subj}/${ARRAY[$count]}/*
						gunzip ${input}/vbm8/${subj}_${ARRAY[$count]}/*.gz
					fi
				fi
		
				echo "qbatch -q fs_q -oe /home/renaud/log/ -N ns_${subj}_${ARRAY[$count]} NewSegmentSPM8.sh -i ${input}/vbm8/${subj}"
				qbatch -q fs_q -oe /home/renaud/log/ -N v_${subj}_${ARRAY[$count]} VBM8.sh -i ${input}/vbm8/${subj}_${ARRAY[$count]}

				total=$[$total+1]
			fi
		else
			echo "patient ${subj}_${ARRAY[$count]} ok !!"
		fi
	
	done
	count=$[$count+1]
done

echo "$total vbm8 ont été lancés"
