#!/bin/bash
set -e

if [ $# -lt 12 ]
then
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
	-t1)
		index=$[$index+1]
		eval T1wImage=\${$index}
		echo "T1 : $T1wImage"
		;;
	-t1brain)
		index=$[$index+1]
		eval T1wBrainImage=\${$index}
		echo "T1 : $T1wBrainImage"
		;;
	-str2std)
		index=$[$index+1]
		eval StructuralToStandard=\${$index}
		echo "Structural to standard transf : $StructuralToStandard"
		;;
	-mask)
		index=$[$index+1]
		eval brainmask=\${$index}
		echo "brain mask in MNI : $brainmask"
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
	-order)
		index=$[$index+1]
		eval sliceorder=\${$index}
		echo "slice order : ${sliceorder}"
		;;
	-echospacing)
		index=$[$index+1]
		eval echospacing=\${$index}
		echo "echospacing : ${echospacing}"
		;;
	-sepos)
		index=$[$index+1]
		eval CORRPA=\${$index}
		echo "spin-echo phase 1 : ${CORRPA}"
		;;
	-seneg)
		index=$[$index+1]
		eval CORRAP=\${$index}
		echo "spin-echo phase 2 : ${CORRAP}"
		;;
	-unwarpdir)
		index=$[$index+1]
		eval UnwarpDir=\${$index}
		echo "UnwarpDir : $UnwarpDir"
		;;
	-biasfield)
		index=$[$index+1]
		eval BiasField=\${$index}
		echo "Bias field (MNI space) : ${BiasField}"
		;;
	-biasfieldt1)
		index=$[$index+1]
		eval BiasFieldT1=\${$index}
		echo "Bias field (T1 space) : ${BiasFieldT1}"
		;;
	-fmriresout)
		index=$[$index+1]
		eval FinalfMRIResolution=\${$index}
		echo "Final fMRI resolution : $FinalfMRIResolution"
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
if [ -d ${OUTDIR} ]; then rm -rf ${OUTDIR}; fi
echo "mkdir -p ${OUTDIR}"
mkdir -p ${OUTDIR}

fMRIName="fmri"

InputfMRI=`$FSLDIR/bin/remove_ext $InputfMRI`
T1wImage=`$FSLDIR/bin/remove_ext $T1wImage`
T1wBrainImage=`$FSLDIR/bin/remove_ext $T1wBrainImage`
T1wFolder=`dirname $T1wImage`
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


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                  DESPIKING                                    "
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_Despiking.sh -i ${CURRENTFMRI}.nii.gz -o ${CURRENTFMRI}_d.nii.gz"
FMRI_Despiking.sh -i ${CURRENTFMRI}.nii.gz -o ${CURRENTFMRI}_d.nii.gz

CURRENTFMRI=${CURRENTFMRI}_d


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                           SLICE TIMING CORRECTION                               "
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_SliceTimingCorr.sh \
	-i ${CURRENTFMRI} \
	-o ${CURRENTFMRI}_st \
	-order ${sliceorder} \
	-tr ${TR}"
FMRI_SliceTimingCorr.sh \
	-i ${CURRENTFMRI} \
	-o ${CURRENTFMRI}_st \
	-order ${sliceorder} \
	-tr ${TR}

CURRENTFMRI=${CURRENTFMRI}_st


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



echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                              fMRI-T1 COREGISTRATION                             "
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_T1Coregistration.sh \
	-fmri ${OUTDIR}/Scout \
	-t1 ${T1wImage} \
	-t1brain ${T1wBrainImage} \
	-o ${OUTDIR}/xfms"
FMRI_T1Coregistration.sh \
	-fmri ${OUTDIR}/"Scout" \
	-t1 ${T1wImage} \
	-t1brain ${T1wBrainImage} \
	-o ${OUTDIR}/"xfms"




# --------------------------------------------------------------------------------
#                                     TOPUP                                       
# --------------------------------------------------------------------------------

if [ ${CORRPA} != "NONE" ]; then

	echo ""
	echo "# --------------------------------------------------------------------------------"
	echo "#                                     TOPUP                                       "
	echo "# --------------------------------------------------------------------------------"
	echo ""

	# sanity check the seneg option
	if [[ "$CORRPA" != "NONE" && "$CORRAP" = "NONE" ]]
	then
		echo "Error: if sepos option exists, then it needs seneg option."
		exit 1
	fi

	if [[ `fslhd $CORRPA | grep '^dim[123]'` != `fslhd ${OUTDIR}/"Scout" | grep '^dim[123]'` ]]
	then

		echo "FMRI_Topup.sh \
			-d ${OUTDIR}/FieldMap \
			-phaseone ${CORRPA} \
			-phasetwo ${CORRAP} \
			-scout ${OUTDIR}/"Scout" \
			-echospacing ${echospacing} \
			-unwarpdir ${UnwarpDir} \
			-topupconfig "${HCPPIPEDIR_Config}"/b02b0.cnf \
			-sedti"
		FMRI_Topup.sh \
			-d ${OUTDIR}/FieldMap \
			-phaseone ${CORRPA} \
			-phasetwo ${CORRAP} \
			-scout ${OUTDIR}/"Scout" \
			-echospacing ${echospacing} \
			-unwarpdir ${UnwarpDir} \
			-topupconfig "${HCPPIPEDIR_Config}"/b02b0.cnf \
			-sedti

	else

		echo "FMRI_Topup.sh \
			-d ${OUTDIR}/FieldMap \
			-phaseone ${CORRPA} \
			-phasetwo ${CORRAP} \
			-scout ${OUTDIR}/"Scout" \
			-echospacing ${echospacing} \
			-unwarpdir ${UnwarpDir} \
			-topupconfig "${HCPPIPEDIR_Config}"/b02b0.cnf"
		FMRI_Topup.sh \
			-d ${OUTDIR}/FieldMap \
			-phaseone ${CORRPA} \
			-phasetwo ${CORRAP} \
			-scout ${OUTDIR}/"Scout" \
			-echospacing ${echospacing} \
			-unwarpdir ${UnwarpDir} \
			-topupconfig "${HCPPIPEDIR_Config}"/b02b0.cnf

	fi

fi




echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                              ONE-STEP RESAMPLING                                "
echo "# --------------------------------------------------------------------------------"
echo ""


if [[ "$BiasField" = "NONE" && "$CORRPA" = "NONE" ]]; then

	echo "FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/Scout  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-o ${OUTDIR}/onestepresampling"
	FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/"Scout"  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-o ${OUTDIR}/onestepresampling

elif [[ "$BiasField" != "NONE" && "$CORRPA" = "NONE" ]]; then

	echo "FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/Scout  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-biasfield ${BiasField} \
		-o ${OUTDIR}/onestepresampling"
	FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/"Scout"  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-biasfield ${BiasField} \
		-o ${OUTDIR}/onestepresampling

elif [[ "$BiasField" = "NONE" && "$CORRPA" != "NONE" ]]; then

	echo "FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/Scout  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-gdfield ${OUTDIR}/FieldMap/WarpField \
		-o ${OUTDIR}/onestepresampling"
	FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/"Scout"  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-gdfield ${OUTDIR}/FieldMap/WarpField \
		-o ${OUTDIR}/onestepresampling

else

	echo "FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/Scout  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-gdfield ${OUTDIR}/FieldMap/WarpField \
		-biasfield ${BiasField} \
		-o ${OUTDIR}/onestepresampling"
	FMRI_OneStepResamplingT1AndMNI.sh  \
		-fmri ${CURRENTFMRI}  \
		-scoutin ${OUTDIR}/"Scout"  \
		-t1 ${T1wImage}  \
		-fmri2structin ${OUTDIR}/xfms/fMRI2str  \
		-struct2std ${StructuralToStandard}  \
		-motionmat ${OUTDIR}/MotionMatrices/MAT_  \
		-fsbrainmask ${brainmask}  \
		-fmriresout ${FinalfMRIResolution} \
		-gdfield ${OUTDIR}/FieldMap/WarpField \
		-biasfield ${BiasField} \
		-o ${OUTDIR}/onestepresampling

fi



echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                              INTENSITY NORMALIZATION                            "
echo "# --------------------------------------------------------------------------------"
echo ""

T1wImageFile=`basename "$T1wImage"`

if [ $BiasFieldT1 != "NONE" ]; then
	BiasFieldT1File=`basename "$BiasFieldT1"`
	BiasFieldT1File=${BiasFieldT1File}_T1
	echo "${FSLDIR}/bin/applywarp --rel --interp=spline -i ${BiasFieldT1} -r ${OUTDIR}/onestepresampling/${T1wImageFile}.${FinalfMRIResolution} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution}"
	${FSLDIR}/bin/applywarp --rel --interp=spline -i ${BiasFieldT1} -r ${OUTDIR}/onestepresampling/${T1wImageFile}.${FinalfMRIResolution} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution}
	${FSLDIR}/bin/fslmaths ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution} -thr 0.1 ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution}
fi

if [ $CORRPA != "NONE" ]; then

	echo ""
	echo "applywarp --rel --interp=spline -i ${OUTDIR}/FieldMap/Jacobian -r ${OUTDIR}/onestepresampling/${T1wImageFile}.${FinalfMRIResolution} -w ${OUTDIR}/xfms/fMRI2str -o ${OUTDIR}/FieldMap/Jacobian_T1.${FinalfMRIResolution}"
	applywarp --rel --interp=spline -i ${OUTDIR}/FieldMap/Jacobian -r ${OUTDIR}/onestepresampling/${T1wImageFile}.${FinalfMRIResolution} -w ${OUTDIR}/xfms/fMRI2str -o ${OUTDIR}/FieldMap/Jacobian_T1.${FinalfMRIResolution}

	echo ""
	echo ""
	${FSLDIR}/bin/applywarp --rel --interp=spline -i ${OUTDIR}/FieldMap/Jacobian -r ${OUTDIR}/onestepresampling/${T1wImageFile}.${FinalfMRIResolution} -w ${OUTDIR}/xfms/fMRI2Std -o ${OUTDIR}/FieldMap/Jacobian_MNI.${FinalfMRIResolution}

fi

fMRIBaseName=`basename "$CURRENTFMRI"`

if [[ "$BiasField" = "NONE" && "$CORRPA" = "NONE" ]]; then

	echo " MNI "
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask

	echo " T1 "
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}__T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask

elif [[ "$BiasField" != "NONE" && "$CORRPA" = "NONE" ]]; then

	echo " MNI "
	BiasFieldFile=`basename "$BiasField"`
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldFile}.${FinalfMRIResolution}"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldFile}.${FinalfMRIResolution}

	echo " T1 "
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution}"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution}

elif [[ "$BiasField" = "NONE" && "$CORRPA" != "NONE" ]]; then

	echo " MNI "
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_MNI.${FinalfMRIResolution}"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_MNI.${FinalfMRIResolution}

	echo " T1 "
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_T1.${FinalfMRIResolution}"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_T1.${FinalfMRIResolution}

else

	echo " MNI "

	echo " MNI "
	BiasFieldFile=`basename "$BiasField"`

	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldFile}.${FinalfMRIResolution} \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_MNI.${FinalfMRIResolution}"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_MNI_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_MNI  \
		-oscout ${OUTDIR}/Scout_MNI_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_MNI_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldFile}.${FinalfMRIResolution} \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_MNI.${FinalfMRIResolution}

	echo " T1 "
	echo "FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution} \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_T1.${FinalfMRIResolution}"
	FMRI_IntensityNormalization.sh  \
		-fmri ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1  \
		-ofmri ${OUTDIR}/${fMRIBaseName}_T1_norm  \
		-scout ${OUTDIR}/onestepresampling/Scout_T1  \
		-oscout ${OUTDIR}/Scout_T1_norm  \
		-mask ${OUTDIR}/onestepresampling/${fMRIBaseName}_T1_mask \
		-biasfield ${OUTDIR}/onestepresampling/${BiasFieldT1File}.${FinalfMRIResolution} \
		-jacobian ${OUTDIR}/FieldMap/Jacobian_T1.${FinalfMRIResolution}
		
	
fi


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                  CREATE MASKS                                   "
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_CreateMask.sh \
	-aparc ${T1wFolder}/aparc.a2009s+aseg \
	-brainmask ${T1wFolder}/brainmask_fs \
	-scout ${OUTDIR}/Scout_T1_norm \
	-o ${OUTDIR}/masks \
	-erode"
FMRI_CreateMask.sh \
	-aparc ${T1wFolder}/aparc.a2009s+aseg \
	-brainmask ${T1wFolder}/brainmask_fs \
	-scout ${OUTDIR}/Scout_T1_norm \
	-o ${OUTDIR}/masks \
	-erode


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                         GENERATE CONFOUNDS TIME-SERIES                          "
echo "# --------------------------------------------------------------------------------"
echo ""

if [ ! -d ${OUTDIR}/regressors ]; then mkdir -p ${OUTDIR}/regressors; fi

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	fmrifile   = fullfile('${OUTDIR}','${fMRIBaseName}_T1_norm.nii.gz');
	motionfile = fullfile('${OUTDIR}','Movement_Regressors.txt');
	WMfile     = fullfile('${OUTDIR}/masks','WM_erode1.nii.gz');
	CSFfile    = fullfile('${OUTDIR}/masks','CSF_erode1.nii.gz');
	WMCSFfile  = fullfile('${OUTDIR}/masks','WM_CSF_erode1.nii.gz');
	Brainfile  = fullfile('${OUTDIR}/masks','BrainMask.nii.gz');
	outfile    = fullfile('${OUTDIR}','regressors','confounds');
	hp         = 0.01;
	TR         = ${TR};
	nPCs       = 5;
	flag_gsc   = 1;
	[x,x2,reg] = FMRI_GenerateConfoundsTimeSeries(fmrifile,motionfile,WMfile,CSFfile,WMCSFfile,Brainfile,outfile,hp,TR,nPCs,flag_gsc);

EOF


echo " "
echo "END: FMRI_CommonPreprocessing.sh"
echo " END: `date`"
echo ""

