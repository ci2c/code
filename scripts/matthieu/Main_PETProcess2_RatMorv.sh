#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: Main_PETProcess2_RatMorv.sh -id <inputdir>  -od <outputdir> -t <MriTemplate> [options]"
	echo ""
	echo "	-id	: input dicom files directory "
	echo ""
	echo "  -od	: output nifti file directory "
	echo ""
	echo "  -t	: path of the MRI template file TemplateRat.nii "
	echo ""
	echo " options are"
	echo ""
	echo "	-all : treat all patients contained in input dir"
	echo "	-f <pathfilesubj> : path of the file subjects.txt"
	echo ""
	echo "Usage:  Main_PETProcess2_RatMorv.sh -id <inputdir>  -od <outputdir> -t <MriTemplate> [options]"
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
	-t)
		index=$[$index+1]
		eval TEMP_PATH=\${$index}
		echo "path of the file TemplateRat.nii : ${TEMP_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Main_PETProcess2_RatMorv.sh -id <inputdir>  -od <outputdir> -t <MriTemplate> [options]"
		echo ""
		echo "	-id	: input dicom files directory "
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "  -t	: path of the MRI template file TemplateRat.nii "
		echo ""
		echo " options are"
		echo ""
		echo "	-all : treat all patients contained in input dir"
		echo "	-f <pathfilesubj> : path of the file subjects.txt"
		echo ""
		echo "Usage:  Main_PETProcess2_RatMorv.sh -id <inputdir>  -od <outputdir> -t <MriTemplate> [options]"
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
elif [ -z ${TEMP_PATH} ]
then
	 echo "-t argument mandatory"
	 exit 1
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
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
						qbatch -N PET2_$tp -q fs_q -oe ~/Logdir PETProcess2_RatMorv.sh -id ${INPUT_DIR}/${subject}/${tp} -od ${OUTPUT_DIR}/${subject}/${tp} -t ${TEMP_PATH}
						sleep 5
					else
						echo "Le répertoire ${INPUT_DIR}/${subject}/${tp}/TEP n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogMorvane
					fi
				done
			else
				echo "Le répertoire ${INPUT_DIR}/${subject} n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogMorvane
			fi
		done < ${FILE_PATH}/subjects.txt
	else
		echo "Le fichier subjects.txt est vide" >> ${OUTPUT_DIR}/LogMorvane
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
					qbatch -N PET2_$tp -q fs_q -oe ~/Logdir PETProcess2_RatMorv.sh -id ${INPUT_DIR}/${subject}/${tp} -od ${OUTPUT_DIR}/${subject}/${tp} -t ${TEMP_PATH}
					sleep 5
				else
					echo "Le répertoire ${INPUT_DIR}/${subject}/${tp}/TEP n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogMorvane
				fi
			done
		else
			echo "Le répertoire ${INPUT_DIR}/${subject} est vide" >> ${OUTPUT_DIR}/LogMorvane
		fi
	done
fi
	




