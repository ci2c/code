#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Main_PETProcess_RatIR.sh -id <inputdir> -od <outputdir> -sm <smallmaskpath> -lm <largemaskpath> [options]"
	echo ""
	echo "	-id	: input dicom files directory "
	echo ""
	echo "  -od	: output nifti file directory "
	echo ""
	echo "	-sm	: path of the small mask file SBrainRatMask.nii "
	echo ""
	echo "	-lm	: path of the large mask file LBrainRatMask.nii "
	echo ""
	echo " options are"
	echo ""
	echo "	-all : treat all patients contained in input dir"
	echo "	-f <pathfilesubj> : path of the file subjects.txt"
	echo ""
	echo "Usage: Main_PETProcess_RatIR.sh -id <inputdir> -od <outputdir> -sm <smallmaskpath> -lm <largemaskpath> [options]"
	echo ""
	exit 1
fi

index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "input subjects directory : ${INPUT_DIR}"
		;;
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file subjects.txt : ${FILE_PATH}"
		;;
	-all)
		echo "all patients in ${INPUT_DIR} are treated"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "output subjects directory : ${OUTPUT_DIR}"
		;;
	-sm)
		index=$[$index+1]
		eval SM_PATH=\${$index}
		echo "path of the small mask file SBrainRatMask.nii : ${SM_PATH}"
		;;
	-lm)
		index=$[$index+1]
		eval LM_PATH=\${$index}
		echo "path of the large mask file LBrainRatMask.nii : ${LM_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Main_PETProcess_RatIR.sh -id <inputdir> -od <outputdir> -sm <smallmaskpath> -lm <largemaskpath> [options]"
		echo ""
		echo "	-id	: input dicom files directory "
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "	-sm	: path of the small mask file SBrainRatMask.nii "
		echo ""
		echo "	-lm	: path of the large mask file LBrainRatMask.nii "
		echo ""
		echo " options are"
		echo ""
		echo "	-all : treat all patients contained in input dir"
		echo "	-f <pathfilesubj> : path of the file subjects.txt"
		echo ""
		echo "Usage: Main_PETProcess_RatIR.sh -id <inputdir> -od <outputdir> -sm <smallmaskpath> -lm <largemaskpath> [options]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
elif [ -z ${SM_PATH} ]
then
	 echo "-sm argument mandatory"
	 exit 1
elif [ -z ${LM_PATH} ]
then
	 echo "-lm argument mandatory"
	 exit 1
fi

# ## Initialisation of constant parameters
# AP=/home/global/ANTs-1.9.x-Linux/bin/

## Creation of the output directories, conversion from Dicom files {PET, MRI} to nifti files, mean of PET files and coregister mean PET on MRI
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		nbsubj=$(cat ${FILE_PATH}/subjects.txt | wc -l)
		echo $nbsubj
		while read subject  
		do   
			if [ -d ${INPUT_DIR}/${subject} -a $(ls -A ${INPUT_DIR}/${subject} | wc -c) -ne 0 ]
			then 
				for tp in $(ls ${INPUT_DIR}/${subject})
				do
					if [ -d ${INPUT_DIR}/${subject}/${tp}/TEP -a $(ls -A ${INPUT_DIR}/${subject}/${tp}/TEP | wc -c) -ne 0 ]				
					then
# 						
						qbatch -N PET1_${subject}_$tp -q fs_q -oe ~/Logdir PETProcess_RatIR.sh -id ${INPUT_DIR}/${subject}/${tp} -od ${OUTPUT_DIR}/${subject}/${tp} -sm ${SM_PATH} -lm ${LM_PATH}
						sleep 2
					else
						echo "Le répertoire ${INPUT_DIR}/${subject}/${tp}/TEP n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogRats
					fi
				done
			else
				echo "Le répertoire ${INPUT_DIR}/${subject} n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogRats
			fi
		done < ${FILE_PATH}/subjects.txt
	else
		echo "Le fichier subjects.txt est vide" >> ${OUTPUT_DIR}/LogRats
		exit 1	
	fi	
else
	echo "Tous les sujets contenus dans le répertoire d'entrée vont être traités"
	for subject in $(ls ${INPUT_DIR})  
	do   
		if [ -s ${INPUT_DIR}/${subject} ]
		then 
			for tp in $(ls ${INPUT_DIR}/${subject})
			do
				if [ -d ${INPUT_DIR}/${subject}/${tp}/TEP -a $(ls -A ${INPUT_DIR}/${subject}/${tp}/TEP | wc -c) -ne 0 ]				
				then
					qbatch -N PET1_${subject}_$tp -q fs_q -oe ~/Logdir PETProcess_RatIR.sh -id ${INPUT_DIR}/${subject}/${tp} -od ${OUTPUT_DIR}/${subject}/${tp} -sm ${SM_PATH} -lm ${LM_PATH}
					sleep 2
				else
					echo "Le répertoire ${INPUT_DIR}/${subject}/${tp}/TEP n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogRats
				fi
			done
		else
			echo "Le répertoire ${INPUT_DIR}/${subject} est vide" >> ${OUTPUT_DIR}/LogRats
		fi
	done
fi
