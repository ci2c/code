#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Main_MS_FirstStep.sh -id <inputdir> -od <outputdir> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
	echo ""
	echo "	-id	: input dicom files directory "
	echo ""
	echo "  -od	: output nifti file directory "
	echo ""
	echo "	-lasm	: path of the oriented LAS mask file BrainMouseMask_LAS.nii "
	echo ""
	echo "	-rpsm	: path of the oriented RPS mask file BrainMouseMask_RPS.nii "
	echo ""
	echo "Usage: Main_MS_FirstStep.sh -id <inputdir> -od <outputdir> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
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
		echo "Usage: Main_MS_FirstStep.sh -id <inputdir> -od <outputdir> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		echo "	-id	: input dicom files directory "
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "	-lasm	: path of the oriented LAS mask file BrainMouseMask_LAS.nii "
		echo ""
		echo "	-rpsm	: path of the oriented RPS mask file BrainMouseMask_RPS.nii "
		echo ""
		echo "Usage: Main_MS_FirstStep.sh -id <inputdir> -od <outputdir> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		exit 1
		;;
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
		echo "Usage: Main_MS_FirstStep.sh -id <inputdir> -od <outputdir> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
		echo ""
		echo "	-id	: input dicom files directory "
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "	-lasm	: path of the oriented LAS mask file BrainMouseMask_LAS.nii "
		echo ""
		echo "	-rpsm	: path of the oriented RPS mask file BrainMouseMask_RPS.nii "
		echo ""
		echo "Usage: Main_MS_FirstStep.sh -id <inputdir> -od <outputdir> -lasm <LASmaskpath> -rpsm <RPSmaskpath>"
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
elif [ -z ${LASM_PATH} ]
then
	 echo "-lasm argument mandatory"
	 exit 1
elif [ -z ${RPSM_PATH} ]
then
	 echo "-rpsm argument mandatory"
	 exit 1
fi

## Copy of the input data to a tmp directory
# cp -R -f ${INPUT_DIR} /tmp/matthieu/MouseStudy

## Conversion of dicom files to Nifti, mean of Nifti PET files and copy of the right brain mouse template
for tp in $(ls ${INPUT_DIR})
do
	for subj in $(ls ${INPUT_DIR}/${tp})
	do
		for modal in $(ls ${INPUT_DIR}/${tp}/${subj})
		do
			if [ -d ${INPUT_DIR}/${tp}/${subj}/${modal} -a -s ${INPUT_DIR}/${tp}/${subj}/${modal} ]
			then
				qbatch -N ${subj}_${tp}_${modal}_1 -q fs_q -oe ~/Logdir MouseStudy_FirstStep.sh -id ${INPUT_DIR}/${tp}/${subj} -od ${OUTPUT_DIR}/${tp}/${subj} -m ${modal} -lasm ${LASM_PATH} -rpsm ${RPSM_PATH}
				sleep 2
			else
				echo "Le répertoire ${INPUT_DIR}/${tp}/${subj}/${modal} n'existe pas ou est vide" >> ~/Logdir/LogMouses1
			fi
		done
	done
done
