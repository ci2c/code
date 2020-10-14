#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: MouseStudy_FirstStep.sh -id <inputsubjdir> -od <outputsubjdir> -m <modality> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
	echo ""
	echo "	-id	: input directory of the timepoint subject "
	echo ""
	echo "	-od	: output directory of the timepoint subject "
	echo ""
	echo "	-m	: modality of the timepoint subject "
	echo ""
	echo "	-lasm	: path of the oriented LAS mask file BrainMouseMask_LAS.nii "
	echo ""
	echo "	-rpsm	: path of the oriented RPS mask file BrainMouseMask_RPS.nii "
	echo ""
	echo "Usage: MouseStudy_FirstStep.sh -id <inputsubjdir> -od <outputsubjdir> -m <modality> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
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
		echo "Usage: MouseStudy_FirstStep.sh -id <inputsubjdir> -od <outputsubjdir> -m <modality> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-m	: modality of the timepoint subject "
		echo ""
		echo "	-lasm	: path of the oriented LAS mask file BrainMouseMask_LAS.nii "
		echo ""
		echo "	-rpsm	: path of the oriented RPS mask file BrainMouseMask_RPS.nii "
		echo ""
		echo "Usage: MouseStudy_FirstStep.sh -id <inputsubjdir> -od <outputsubjdir> -m <modality> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INSUBJ_DIR=\${$index}
		echo "input directory of the timepoint subject : ${INSUBJ_DIR}"
		;;
	-od)
		index=$[$index+1]
		eval OUTSUBJ_DIR=\${$index}
		echo "output directory of the timepoint subject : ${OUTSUBJ_DIR}"
		;;
	-m)
		index=$[$index+1]
		eval MODALITY=\${$index}
		echo "modality of the timepoint subject : ${MODALITY}"
		;;
	-lasm)
		index=$[$index+1]
		eval LASM_PATH=\${$index}
		echo "path of the small mask file BrainMouseMask_LAS.nii : ${LASM_PATH}"
		;;
	-rpsm)
		index=$[$index+1]
		eval RPSM_PATH=\${$index}
		echo "path of the large mask file BrainMouseMask_RPS.nii : ${RPSM_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: MouseStudy_FirstStep.sh -id <inputsubjdir> -od <outputsubjdir> -m <modality> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-m	: modality of the timepoint subject "
		echo ""
		echo "	-lasm	: path of the oriented LAS mask file BrainMouseMask_LAS.nii "
		echo ""
		echo "	-rpsm	: path of the oriented RPS mask file BrainMouseMask_RPS.nii "
		echo ""
		echo "Usage: MouseStudy_FirstStep.sh -id <inputsubjdir> -od <outputsubjdir> -m <modality> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INSUBJ_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${OUTSUBJ_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
elif [ -z ${MODALITY} ]
then
	 echo "-m argument mandatory"
	 exit 1
elif [ -z ${LASM_PATH} ]
then
	 echo "-lasm argument mandatory"
	 exit 1
elif [ -z ${RPSM_PATH} ]
then
	 echo "-rpsm argument mandatory"
	 exit 1
fi

## Creation of the directories output
mkdir -p ${OUTSUBJ_DIR}
mkdir ${OUTSUBJ_DIR}/${MODALITY}
	
## Conversion of Dicom files from PET/CT to nifti file(s)
ls ${INSUBJ_DIR}/${MODALITY} > ${OUTSUBJ_DIR}/${MODALITY}/DicomFiles
nbdfiles=$(cat ${OUTSUBJ_DIR}/${MODALITY}/DicomFiles | wc -l)
echo $nbdfiles
while read dfiles
do
	echo " ${INSUBJ_DIR}/${MODALITY}/${dfiles}" >> ${OUTSUBJ_DIR}/${MODALITY}/PathsDFiles
done < ${OUTSUBJ_DIR}/${MODALITY}/DicomFiles
rm -f ${OUTSUBJ_DIR}/${MODALITY}/DicomFiles
SPM_DICOM_Convert.sh -f ${OUTSUBJ_DIR}/${MODALITY}/PathsDFiles -od ${OUTSUBJ_DIR}/${MODALITY}
rm -f ${OUTSUBJ_DIR}/${MODALITY}/PathsDFiles

## Mean of the PET files (nifti), check of the PET orientation, copy of the right Brain Mouse Mask
if [ ${MODALITY} = TEP ]
then
	ls ${OUTSUBJ_DIR}/${MODALITY} > ${OUTSUBJ_DIR}/${MODALITY}/TmpTep
	nbniifiles=$(cat ${OUTSUBJ_DIR}/${MODALITY}/TmpTep | wc -l)
	echo $nbniifiles
	while read niifile
	do
		echo "${OUTSUBJ_DIR}/${MODALITY}/${niifile}" >> ${OUTSUBJ_DIR}/${MODALITY}/PathsNiiFilesPET
	done < ${OUTSUBJ_DIR}/${MODALITY}/TmpTep
	rm -f ${OUTSUBJ_DIR}/${MODALITY}/TmpTep
	SPM_Mean_Images.sh -f ${OUTSUBJ_DIR}/${MODALITY}/PathsNiiFilesPET
	rm -f ${OUTSUBJ_DIR}/${MODALITY}/PathsNiiFilesPET

	mkdir ${OUTSUBJ_DIR}/Crop
	LASMask=$(mri_info ${OUTSUBJ_DIR}/${MODALITY}/mean*.nii | grep 'LAS' | wc -l)
	RPSMask=$(mri_info ${OUTSUBJ_DIR}/${MODALITY}/mean*.nii | grep 'RPS' | wc -l)
	if [ ${LASMask} -eq 1 ]
	then 
		if [ -e ${LASM_PATH}/BrainMouseMask_LAS.nii -a -s ${LASM_PATH}/BrainMouseMask_LAS.nii ]
		then
			cp ${LASM_PATH}/BrainMouseMask_LAS.nii ${OUTSUBJ_DIR}/Crop
		else
			echo "Le fichier BrainMouseMask_LAS.nii n'existe pas ou est vide" >> ~/Logdir/LogMouses1
		fi						

	elif [ ${RPSMask} -eq 1 ]
	then
		if [ -e ${RPSM_PATH}/BrainMouseMask_RPS.nii -a -s ${RPSM_PATH}/BrainMouseMask_RPS.nii ]
		then
			cp ${RPSM_PATH}/BrainMouseMask_RPS.nii ${OUTSUBJ_DIR}/Crop
		else
		      echo "Le fichier BrainMouseMask_RPS.nii n'existe pas ou est vide" >> ~/Logdir/LogMouses1
		fi	
	fi
fi
