#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  MotorCortexQuantification_Mouse.sh -subj <patientname> -od <outputdir>"
	echo ""
	echo "  -subj	: Subject name "
	echo "  -od	: Output directory "	
	echo ""
	echo "Usage:  MotorCortexQuantification_Mouse.sh -subj <patientname> -od <outputdir>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - September, 2014"
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
		echo "Usage:  MotorCortexQuantification_Mouse.sh -subj <patientname> -od <outputdir>"
		echo ""
		echo "  -subj	: Subject name "
		echo "  -od	: Output directory "	
		echo ""
		echo "Usage:  MotorCortexQuantification_Mouse.sh -subj <patientname> -od <outputdir>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - September, 2014"
		echo ""
		exit 1
		;;
	-subj)
		index=$[$index+1]
		eval subject=\${$index}
		echo "Subject name : ${subject}"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Output directory : ${OUTPUT_DIR}"
		;;	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  MotorCortexQuantification_Mouse.sh -subj <patientname> -od <outputdir>"
		echo ""
		echo "  -subj	: Subject name "
		echo "  -od	: Output directory "	
		echo ""
		echo "Usage:  MotorCortexQuantification_Mouse.sh -subj <patientname> -od <outputdir>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - September, 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi
if [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi

# OUTPUT_DIR=/NAS/dumbo/matthieu/PreClinique/Segmentation_Malaria
# subject=M3

################################
## Step 1. Prepare T2 data
################################

if [ ! -d ${OUTPUT_DIR}/${subject}/Structural ]
then
	mkdir -p ${OUTPUT_DIR}/${subject}/Structural
else
	rm -f ${OUTPUT_DIR}/${subject}/Structural/*
fi

dcm2nii -o ${OUTPUT_DIR}/${subject}/Structural ${OUTPUT_DIR}/${subject}/Malaria*/*

mv ${OUTPUT_DIR}/${subject}/Structural/*TurboRARET2*.nii.gz ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz

################################
## Step 2. Reorient source images onto T2 template
################################

if [ ! -f ${OUTPUT_DIR}/${subject}/fT2.nii.gz ]
then
	gunzip ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz
	
	matlab -nodisplay <<EOF
	
	%% Initialise SPM defaults
	%-----------------------------
	spm('defaults', 'FMRI');

	spm_jobman('initcfg');
	matlabbatch={};

	matlabbatch{end+1}.spm.util.reorient.srcfiles = {
							'${OUTPUT_DIR}/${subject}/Structural/T2.nii,1'
							 };
	matlabbatch{end}.spm.util.reorient.transform.transprm = [0 0 0 1.57 0 3.14 1 1 1 0 0 0];
	matlabbatch{end}.spm.util.reorient.prefix = 'f';

	spm_jobman('run',matlabbatch);
EOF

gzip ${OUTPUT_DIR}/${subject}/Structural/*.nii
fi

################################
## Step 3. N4BiasFieldCorrection on fT2 image
################################

${ANTSPATH}/N4BiasFieldCorrection -d 3 -i ${OUTPUT_DIR}/${subject}/Structural/fT2.nii.gz -o ${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz -b [200] -s 3 -c [50x50x30x20,1e-6]

################################
## Step 4. Resampling T2 template to a lower resolution
################################

# ${ANTSPATH}/ResampleImageBySpacing 3 ${OUTPUT_DIR}/../Atlas/Dorr_2008_average.nii.gz ${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz .1 .1 .1 0

################################
## Step 5. Perform diffeomorphic registration of T2 template lower resolution onto N4_fT2.nii.gz
################################

USEHISTOGRAMMATCHING=1
OUTPUTNAME="TemplateWToT2"
DIM=3

RIGIDCONVERGENCE="[1000x500x250x0,1e-6,10]"
RIGIDSHRINKFACTORS="8x4x2x1"
RIGIDSMOOTHINGSIGMAS="0.3x0.2x0.1x0mm"

SYNCONVERGENCE="[70x50x0,1e-6,10]"
SYNSHRINKFACTORS="2x2x1"
SYNSMOOTHINGSIGMAS="0.2x0.1x0mm"

RIGIDSTAGE="--initial-moving-transform [${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz,${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz,1] \
            --transform Rigid[0.1] \
            --metric MI[${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz,${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz,1,32,Regular,0.25] \
            --convergence $RIGIDCONVERGENCE \
            --shrink-factors $RIGIDSHRINKFACTORS \
            --smoothing-sigmas $RIGIDSMOOTHINGSIGMAS"

SYNSTAGE="--transform SyN[0.1,3,0] \
	  --metric cc[${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz,${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz,1,2]
          --convergence $SYNCONVERGENCE \
          --shrink-factors $SYNSHRINKFACTORS \
          --smoothing-sigmas $SYNSMOOTHINGSIGMAS"

STAGES="${RIGIDSTAGE} ${SYNSTAGE}"

COMMAND="${ANTSPATH}/antsRegistration --dimensionality ${DIM} \
		--output [${OUTPUT_DIR}/${subject}/${OUTPUTNAME},${OUTPUT_DIR}/${subject}/${OUTPUTNAME}Warped.nii.gz,${OUTPUT_DIR}/${subject}/${OUTPUTNAME}InverseWarped.nii.gz] \
		--interpolation Linear \
		--use-histogram-matching ${USEHISTOGRAMMATCHING} \
		--winsorize-image-intensities [0.005,0.995] \
                 ${STAGES}"

echo " antsRegistration call:"
echo "--------------------------------------------------------------------------------------"
echo ${COMMAND}
echo "--------------------------------------------------------------------------------------"
${COMMAND}

################################
## Step 6.  Apply diffeomorphic registration of T2 template onto N4_fT2.nii.gz
################################

COMMAND="${ANTSPATH}/antsApplyTransforms -d 3 \
	-r ${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz\
	-i ${OUTPUT_DIR}/../Atlas/Dorr_2008_average.nii.gz \
	-t ${OUTPUT_DIR}/${subject}/${OUTPUTNAME}1Warp.nii.gz \
	-t ${OUTPUT_DIR}/${subject}/${OUTPUTNAME}0GenericAffine.mat \
	-o ${OUTPUT_DIR}/${subject}/TemplateWToT2.nii.gz"


echo " antsApplyTransforms call:"
echo "--------------------------------------------------------------------------------------"
echo ${COMMAND}
echo "--------------------------------------------------------------------------------------"
${COMMAND}

COMMAND="${ANTSPATH}/antsApplyTransforms -d 3 \
	-r ${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz\
	-i ${OUTPUT_DIR}/../Atlas/Dorr_2008_labels.nii.gz \
	-n MultiLabel \
	-t ${OUTPUT_DIR}/${subject}/${OUTPUTNAME}1Warp.nii.gz \
	-t ${OUTPUT_DIR}/${subject}/${OUTPUTNAME}0GenericAffine.mat \
	-o ${OUTPUT_DIR}/${subject}/LabelsWToT2.nii.gz"


echo " antsApplyTransforms call:"
echo "--------------------------------------------------------------------------------------"
echo ${COMMAND}
echo "--------------------------------------------------------------------------------------"
${COMMAND}