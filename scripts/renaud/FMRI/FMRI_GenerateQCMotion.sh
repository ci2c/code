#!/bin/bash
set -e

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: FMRI_GenerateQCMotion.sh  -fmri <nifti>  -o <folder>  -skip <value> "
	echo ""
	echo "  -fmri                : fmri file "
	echo "  -o                   : output folder "
	echo "  -skip                : number of frames to skip (Default: 4) "
	echo ""
	echo "Usage: FMRI_GenerateQCMotion.sh  -fmri <nifti>  -o <folder>  -skip <value> "
	echo ""
	exit 1
fi


user=`whoami`

HOME=/home/${user}
index=1

sliceorder="interleavedPhilips"
skipframes="4"
echospacing="0.4238252"
CORRPA="NONE"
CORRAP="NONE"
UnwarpDir="y-"
FinalfMRIResolution="2"
BiasField="NONE"
BiasFieldT1="NONE"


# --------------------------------------------------------------------------------
#                              DEFAULT
# --------------------------------------------------------------------------------

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_CommonPreprocessing.sh  -fmri <nifti>  -t1 <nifti>  -t1brain <nifti>  -str2std <nifti>  -mask <nifti>  -o <folder>  [-skip <value>  -order <name>  -echospacing <value>  -sepos <nifti>  -seneg <nifti>  -unwarpdir <name>  -biasfield <nifti>  -biasfieldt1 <nifti>  -fmriresout <value> ] "
		echo ""
		echo "  -fmri                : fmri file "
		echo "  -t1                  : T1 file "
		echo "  -t1brain             : T1 brain file "
		echo "  -str2std             : Structural to MNI standard transformation "
		echo "  -mask                : brain mask in MNI space "
		echo "  -o                   : output folder "
		echo " "
		echo "OPTIONS :"
		echo "  -skip                : number of frames to skip (Default: 4) "
		echo "  -order               : slice order (Default: interleavedPhilips) "
		echo "  -echospacing         : echo spacing in ms (Default: 0.424) "
		echo "  -sepos               : spin-echo phase 1 (Default: NONE) "
		echo "  -seneg               : spin-echo phase 2 (Default: NONE) "
		echo "  -unwarpdir           : PE direction for unwarping: x/y/z/-x/-y/-z (Default: y-) "
		echo "  -biasfield           : input biasfield image, in MNI space (Default: NONE)"
		echo "  -biasfieldt1         : input biasfield image, in T1 space (Default: NONE)"
		echo "  -fmriresout          : output resolution for images, typically the fmri resolution (Default: 2) "
		echo ""
		echo "Usage: FMRI_CommonPreprocessing.sh  -fmri <nifti>  -t1 <nifti>  -t1brain <nifti>  -o <folder>  [-skip <value>  -order <name>  -echospacing <value>  -sepos <nifti>  -seneg <nifti>]"
		echo ""
		exit 1
		;;
	-fmri)
		index=$[$index+1]
		eval InputfMRI=\${$index}
		echo "fMRI : $InputfMRI"
		;;
	-o)
		index=$[$index+1]
		eval OUTDIR=\${$index}
		echo "output folder : ${OUTDIR}"
		;;
	-skip)
		index=$[$index+1]
		eval skipframes=\${$index}
		echo "nb of frames to skip : ${skipframes}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                          LOAD FUNCTIONS LIBRARIES                               "
echo "# --------------------------------------------------------------------------------"
echo ""

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


echo " "
echo "START: FMRI_CommonPreprocessing.sh"
echo " START: `date`"
echo ""


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                    CONFIG                                       "
echo "# --------------------------------------------------------------------------------"
echo ""

# Create OUTPUT folder
if [ -d ${OUTDIR} ]; then rm -rf ${OUTDIR}; fi
echo "mkdir -p ${OUTDIR}"
mkdir -p ${OUTDIR}

fMRIName="fmri"

InputfMRI=`$FSLDIR/bin/remove_ext $InputfMRI`
TR=$(fslinfo $InputfMRI | grep ^pixdim4 | awk '{print $2}')


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                  SKIP FRAMES                                    "
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_SkipFrames.sh \
	-i ${InputfMRI} \
	-o ${OUTDIR}/${fMRIName}_rf \
	-skip ${skipframes}"
FMRI_SkipFrames.sh \
	-i ${InputfMRI} \
	-o ${OUTDIR}/${fMRIName}_rf \
	-skip ${skipframes}

CURRENTFMRI=${OUTDIR}/${fMRIName}_rf



echo "Create Scout image"
echo "fslroi ${CURRENTFMRI} ${OUTDIR}/Scout 0 1"
${FSLDIR}/bin/fslroi ${CURRENTFMRI} ${OUTDIR}/Scout 0 1



echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                               MOTION CORRECTION                                 "
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_MotionCorrectionByFSL.sh \
    -d ${OUTDIR}/MotionCorrection \
    -i ${CURRENTFMRI} \
    -r ${OUTDIR}/Scout \
    -o ${CURRENTFMRI}_mc \
    -or ${OUTDIR}/Movement_Regressors \
    -ot ${OUTDIR}/MotionMatrices \
    -on MAT_ \
    -t MCFLIRT"
FMRI_MotionCorrectionByFSL.sh \
    -d ${OUTDIR}/MotionCorrection \
    -i ${CURRENTFMRI} \
    -r ${OUTDIR}/"Scout" \
    -o ${CURRENTFMRI}_mc \
    -or ${OUTDIR}/"Movement_Regressors" \
    -ot ${OUTDIR}/"MotionMatrices" \
    -on "MAT_" \
    -t "MCFLIRT"


