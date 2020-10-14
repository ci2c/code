#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: SPM_Mouse_Main.sh -id <inputdir> -od <outputdir>"
	echo ""
	echo "	-id	: input dicom files directory "
	echo ""
	echo "  -od	: output nifti file directory "
	echo ""
	echo "Usage: SPM_Mouse_Main.sh -id <inputdir> -od <outputdir>"
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
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "output subjects directory : ${OUTPUT_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: SPM_Mouse_Main.sh -id <inputdir> -od <outputdir>"
		echo ""
		echo "	-id	: input dicom files directory "
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "Usage: SPM_Mouse_Main.sh -id <inputdir> -od <outputdir>"
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
fi

index=1	
ls -F ${INPUT_DIR} | sed 's,/$,,g' > /tmp/timepoint
nbtp=$(cat /tmp/timepoint | wc -l)
echo $nbtp
while read tp
do
	echo "$tp"
# 	mkdir ${OUTPUT_DIR}/${tp}

	## Conversion of Dicom files from PET/CT to nifti file(s)
	ls ${INPUT_DIR}/${tp} > /tmp/Subject
	nbsubj=$(cat /tmp/Subject | wc -l)
	echo $nbsubj
	while read subj
	do
		echo "$subj"
# 		mkdir ${OUTPUT_DIR}/${tp}/${subj}
		for modal in CT TEP
		do
			if [ -d ${INPUT_DIR}/${tp}/${subj}/${modal} -a -s ${INPUT_DIR}/${tp}/${subj}/${modal} ]
			then
# 				mkdir ${OUTPUT_DIR}/${tp}/${subj}/${modal}
# 				ls ${INPUT_DIR}/${tp}/${subj}/${modal} > /tmp/DicomFiles
# 				nbdfiles=$(cat /tmp/DicomFiles | wc -l)
# 				echo $nbdfiles
# 				while read dfiles
# 				do
# 					echo "${INPUT_DIR}/${tp}/${subj}/${modal}/${dfiles}" >> /tmp/PathsDFiles
# 				done < /tmp/DicomFiles
# 				rm -f /tmp/DicomFiles
# 				./SPM_DICOM_Convert.sh -f /tmp/PathsDFiles -od ${OUTPUT_DIR}/${tp}/${subj}/${modal}
# 				rm -f /tmp/PathsDFiles

				# Mean of the PET files (nifti)
				if [ ${modal} = TEP ]
				then
					ls ${OUTPUT_DIR}/${tp}/${subj}/${modal} > /tmp/TmpTep
					nbniifiles=$(cat /tmp/TmpTep | wc -l)
					echo $nbniifiles
					while read niifile
					do
						echo "${OUTPUT_DIR}/${tp}/${subj}/${modal}/${niifile}" >> /tmp/PathsNiiFilesPET
					done < /tmp/TmpTep
					rm -f /tmp/TmpTep
					./SPM_Mean_PET_Files.sh -f /tmp/PathsNiiFilesPET
					rm -f /tmp/PathsNiiFilesPET
				fi
			else
				echo "Le répertoire ${INPUT_DIR}/${tp}/${subj}/${modal} n'existe pas ou est vide" >> ~/LogMouses
			fi
		done
	done < /tmp/Subject
	rm -f /tmp/Subject
done < /tmp/timepoint
rm -f /tmp/timepoint

