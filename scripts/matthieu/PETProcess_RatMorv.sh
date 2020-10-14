#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: PETProcess_RatMorv.sh -id <inputsubjdir> -od <outputsubjdir> -sm <smallmaskpath> -lm <largemaskpath>"
	echo ""
	echo "	-id	: input directory of the timepoint subject "
	echo ""
	echo "	-od	: output directory of the timepoint subject "
	echo ""
	echo "	-sm	: path of the small mask file SBrainRatMask.nii "
	echo ""
	echo "	-lm	: path of the large mask file LBrainRatMask.nii "
	echo ""
	echo "Usage: PETProcess_RatMorv.sh -id <inputsubjdir> -od <outputsubjdir> -sm <smallmaskpath> -lm <largemaskpath>"
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
		echo "Usage: PETProcess_RatMorv.sh -id <inputsubjdir> -od <outputsubjdir> -sm <smallmaskpath> -lm <largemaskpath>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-sm	: path of the small mask file SBrainRatMask.nii "
		echo ""
		echo "	-lm	: path of the large mask file LBrainRatMask.nii "
		echo ""
		echo "Usage: PETProcess_RatMorv.sh -id <inputsubjdir> -od <outputsubjdir> -sm <smallmaskpath> -lm <largemaskpath>"
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
		echo "Usage: PETProcess_RatMorv.sh -id <inputsubjdir> -od <outputsubjdir> -sm <smallmaskpath> -lm <largemaskpath>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-sm	: path of the small mask file SBrainRatMask.nii "
		echo ""
		echo "	-lm	: path of the large mask file LBrainRatMask.nii "
		echo ""
		echo "Usage: PETProcess_RatMorv.sh -id <inputsubjdir> -od <outputsubjdir> -sm <smallmaskpath> -lm <largemaskpath>"
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
elif [ -z ${SM_PATH} ]
then
	 echo "-sm argument mandatory"
	 exit 1
elif [ -z ${LM_PATH} ]
then
	 echo "-lm argument mandatory"
	 exit 1
fi				

# Creation of the output directories						
mkdir -p ${OUTSUBJ_DIR}/TEP
						
## Conversion of PET Dicom files to nifti file(s)
ls ${INSUBJ_DIR}/TEP > ${INSUBJ_DIR}/TEP/TmpTep
nbdfilesp=$(cat ${INSUBJ_DIR}/TEP/TmpTep | wc -l)
echo $nbdfilesp
while read dfilesp
do
	echo "${INSUBJ_DIR}/TEP/${dfilesp}" >> ${OUTSUBJ_DIR}/TEP/PathsDFilesPET
done < ${INSUBJ_DIR}/TEP/TmpTep
rm -f ${INSUBJ_DIR}/TEP/TmpTep
SPM_DICOM_Convert.sh -f ${OUTSUBJ_DIR}/TEP/PathsDFilesPET -od ${OUTSUBJ_DIR}/TEP
rm -f ${OUTSUBJ_DIR}/TEP/PathsDFilesPET

# Mean of the PET files (nifti)
ls ${OUTSUBJ_DIR}/TEP > ${OUTSUBJ_DIR}/TEP/TmpTep
nbniifiles=$(cat ${OUTSUBJ_DIR}/TEP/TmpTep | wc -l)
echo $nbniifiles
while read niifile
do
	echo "${OUTSUBJ_DIR}/TEP/${niifile}" >> ${OUTSUBJ_DIR}/TEP/PathsNiiFilesPET
done < ${OUTSUBJ_DIR}/TEP/TmpTep
rm -f ${OUTSUBJ_DIR}/TEP/TmpTep
SPM_Mean_Images.sh -f ${OUTSUBJ_DIR}/TEP/PathsNiiFilesPET
rm -f ${OUTSUBJ_DIR}/TEP/PathsNiiFilesPET
							
Copy of the PET Brain rats mask 
if [[ ${OUTSUBJ_DIR} == *T1 ]] || [[ ${OUTSUBJ_DIR} == *T2 ]]
then 
	if [ -e ${SM_PATH}/SBrainRatMask.nii -a -s ${SM_PATH}/SBrainRatMask.nii ]
	then
		cp ${SM_PATH}/SBrainRatMask.nii ${OUTSUBJ_DIR}/TEP
	else
		echo "Le fichier SBrainRatMask.nii n'existe pas ou est vide" >> ${OUTPUT_DIR}/../../LogMorvane
	fi
else
      OrientLAS=$(mri_info ${OUTSUBJ_DIR}/TEP/mean*.nii | grep 'LAS' | wc -l)
      OrientRPS=$(mri_info ${OUTSUBJ_DIR}/TEP/mean*.nii | grep 'RPS' | wc -l)
      if [ ${OrientLAS} = 1 ]
      then
		if [ -e ${LM_PATH}/LBrainRatMask_LAS.nii -a -s ${LM_PATH}/LBrainRatMask_LAS.nii ]
		then	
			cp ${LM_PATH}/LBrainRatMask_LAS.nii ${OUTSUBJ_DIR}/TEP
		else
			echo "Le fichier LBrainRatMask_LAS.nii n'existe pas ou est vide" >> ${OUTPUT_DIR}/../../LogMorvane
		fi
      elif [ ${OrientRPS} = 1 ]
      then
		if [ -e ${LM_PATH}/LBrainRatMask_RPS.nii -a -s ${LM_PATH}/LBrainRatMask_RPS.nii ]
		then	
			cp ${LM_PATH}/LBrainRatMask_RPS.nii ${OUTSUBJ_DIR}/TEP
		else
			echo "Le fichier LBrainRatMask_RPS.nii n'existe pas ou est vide" >> ${OUTPUT_DIR}/../../LogMorvane
		fi
      fi
fi