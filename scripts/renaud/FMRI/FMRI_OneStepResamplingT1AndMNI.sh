#! /bin/bash
set -e

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage: FMRI_OneStepResamplingT1AndMNI.sh  -fmri <file>  -scoutin <file>  -t1 <file>  -fmri2structin <file>  -struct2std <file>  -motionmat <dir/name>  -fsbrainmask <file>  -o <dir>  [-fmriresout <value>  -biasfield <file>  -gdfield <field>] "
	echo ""
	echo "  -fmri                        : input fMRI 4D image "
	echo "  -scoutin                     : input scout image (before distortion correction) "
	echo "  -t1                          : input T1w restored image "
	echo "  -fmri2structin               : input fMRI to T1w warp "
	echo "  -struct2std                  : input T1w to MNI warp "
	echo "  -motionmat                   : input motion correcton matrix filename prefix + directory "
	echo "  -fsbrainmask                 : input FreeSurfer brain mask, nifti format in MNI space"
	echo "  -o                           : working dir"
	echo " OPTIONS "
	echo "  -fmriresout                  : output resolution for images, typically the fmri resolution "
	echo "  -biasfield                   : input biasfield image, in MNI space"
	echo "  -gdfield                     : input warpfield for gradient non-linearity correction "
	echo ""
	echo "Usage: FMRI_OneStepResamplingT1AndMNI.sh  -fmri <file>  -scoutin <file>  -t1 <file>  -fmri2structin <file>  -struct2std <file>  -motionmat <dir/name>  -fsbrainmask <file>  -o <dir>  [-fmriresout <value>  -biasfield <file>  -gdfield <field>] "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

FinalfMRIResolution="2"
GradientDistortionField="NONE"
BiasField="NONE"
JAC="YES"


# --------------------------------------------------------------------------------
#                              DEFAULT
# --------------------------------------------------------------------------------

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_OneStepResamplingT1AndMNI.sh  -fmri <file>  -scoutin <file>  -t1 <file>  -fmri2structin <file>  -struct2std <file>  -motionmat <dir/name>  -fsbrainmask <file>  -o <dir>  [-fmriresout <value>  -biasfield <file>  -gdfield <field>] "
		echo ""
		echo "  -fmri                        : input fMRI 4D image "
		echo "  -scoutin                     : input scout image (before distortion correction) "
		echo "  -t1                          : input T1w restored image "
		echo "  -fmri2structin               : input fMRI to T1w warp "
		echo "  -struct2std                  : input T1w to MNI warp "
		echo "  -motionmat                   : input motion correcton matrix filename prefix + directory "
		echo "  -fsbrainmask                 : input FreeSurfer brain mask, nifti format in MNI space"
		echo "  -o                           : working dir"
		echo " OPTIONS "
		echo "  -fmriresout                  : output resolution for images, typically the fmri resolution "
		echo "  -biasfield                   : input biasfield image, in MNI space"
		echo "  -gdfield                     : input warpfield for gradient non-linearity correction "
		echo ""
		echo "Usage: FMRI_OneStepResamplingT1AndMNI.sh  -fmri <file>  -scoutin <file>  -t1 <file>  -fmri2structin <file>  -struct2std <file>  -motionmat <dir/name>  -fsbrainmask <file>  -o <dir>  [-fmriresout <value>  -biasfield <file>  -gdfield <field>] "
		echo ""
		exit 1
		;;
	-fmri)
		index=$[$index+1]
		eval InputfMRI=\${$index}
		echo "fMRI : $InputfMRI"
		;;
	-scoutin)
		index=$[$index+1]
		eval ScoutInput=\${$index}
		echo "Scout fMRI : $ScoutInput"
		;;
	-t1)
		index=$[$index+1]
		eval T1wImage=\${$index}
		echo "T1 : $T1wImage"
		;;
	-fmri2structin)
		index=$[$index+1]
		eval fMRIToStructuralInput=\${$index}
		echo "input fMRI to T1w warp : $fMRIToStructuralInput"
		;;
	-struct2std)
		index=$[$index+1]
		eval StructuralToStandard=\${$index}
		echo "T1 space to MNI space : $StructuralToStandard"
		;;
	-motionmat)
		index=$[$index+1]
		eval MotionMatrix=\${$index}
		echo "input motion correcton matrix filename prefix + folder : ${MotionMatrix}"
		;;
	-fsbrainmask)
		index=$[$index+1]
		eval FreeSurferBrainMask=\${$index}
		echo "input FreeSurfer brain mask : ${FreeSurferBrainMask}"
		;;
	-o)
		index=$[$index+1]
		eval WD=\${$index}
		echo "output folder : ${WD}"
		;;
	-fmriresout)
		index=$[$index+1]
		eval FinalfMRIResolution=\${$index}
		echo "Final fMRI resolution : $FinalfMRIResolution"
		;;
	-biasfield)
		index=$[$index+1]
		eval BiasField=\${$index}
		echo "Bias field : ${BiasField}"
		;;
	-gdfield)
		index=$[$index+1]
		eval GradientDistortionField=\${$index}
		echo "fMRI Fieldmap : ${GradientDistortionField}"
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


# --------------------------------------------------------------------------------
#                      Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


# --------------------------------------------------------------------------------
#                                     CONFIG
# --------------------------------------------------------------------------------

#T1wImage=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/T1w/T1w_acpc_restore
#WD=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/onestepresampling
#fMRIToStructuralInput=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/xfms/fMRI2str
#StructuralToStandard=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/MNINonLinear/xfms/acpc_dc2standard
#ScoutInput=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/Scout 
#InputfMRI=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/fmri_rf_st
#FreeSurferBrainMask=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/MNINonLinear/brainmask_fs
##MotionMatrixFolder=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/MotionMatrices
##GradientDistortionField=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/FieldMap/WarpField
#BiasField=/NAS/tupac/protocoles/healthy_volunteers/process/T01S01/MNINonLinear/BiasField

fMRIFolder=`dirname ${InputfMRI}`
MotionMatrixFolder=`dirname ${MotionMatrix}`
MotionMatrixPrefix=`basename ${MotionMatrix}`
InputfMRIName=`basename ${InputfMRI}`
ScoutName=`basename ${ScoutInput}`
RegFolder=`dirname ${fMRIToStructuralInput}`

OutputfMRI=${WD}/${InputfMRIName}_MNI
OutputfMRI2T1=${WD}/${InputfMRIName}_T1
OutputScout=${WD}/${ScoutName}_MNI
OutputScout2T1=${WD}/${ScoutName}_T1

OutputTransform=${RegFolder}/fMRI2Std
OutputInvTransform=${RegFolder}/Std2fMRI

T1wImageFile=`basename $T1wImage`
T1wFolder=`dirname $T1wImage`
FreeSurferBrainMaskFile=`basename "$FreeSurferBrainMask"`
echo "T1wImageFile=${T1wImageFile}"

if [ ! -d ${WD} ]; then mkdir ${WD}; fi

if [ -e ${fMRIFolder}/Movement_RelativeRMS.txt ] ; then
	/bin/rm -v ${fMRIFolder}/Movement_RelativeRMS.txt
fi
if [ -e ${fMRIFolder}/Movement_AbsoluteRMS.txt ] ; then
	/bin/rm -v ${fMRIFolder}/Movement_AbsoluteRMS.txt
fi
if [ -e ${fMRIFolder}/Movement_RelativeRMS_mean.txt ] ; then
	/bin/rm -v ${fMRIFolder}/Movement_RelativeRMS_mean.txt
fi
if [ -e ${fMRIFolder}/Movement_AbsoluteRMS_mean.txt ] ; then
	/bin/rm -v ${fMRIFolder}/Movement_AbsoluteRMS_mean.txt
fi

if [ ! -f ${GradientDistortionField}.nii.gz ]; then
	${FSLDIR}/bin/fslroi ${InputfMRI} ${GradientDistortionField} 0 3
	${FSLDIR}/bin/fslmaths ${GradientDistortionField} -mul 0 ${GradientDistortionField}
	JAC="NONE"
fi


echo " "
echo "START: FMRI_OneStepResamplingT1AndMNI.sh"
echo " START: `date`"
echo ""

# --------------------------------------------------------------------------------
#                                    PROCESS
# --------------------------------------------------------------------------------

# Save TR for later
TR_vol=`${FSLDIR}/bin/fslval ${InputfMRI} pixdim4 | cut -d " " -f 1`
echo "TR = ${TR_vol}"
# Number of dynamics
NumFrames=`${FSLDIR}/bin/fslval ${InputfMRI} dim4`
echo "N = ${NumFrames}"

# Create fMRI resolution standard space files for T1w image, wmparc, and brain mask
#   NB: don't use FLIRT to do spline interpolation with -applyisoxfm for the 
#       2mm and 1mm cases because it doesn't know the peculiarities of the 
#       MNI template FOVs
if [ ${FinalfMRIResolution} = "2" ] ; then
	ResampRefIm=$FSLDIR/data/standard/MNI152_T1_2mm
elif [ ${FinalfMRIResolution} = "1" ] ; then
	ResampRefIm=$FSLDIR/data/standard/MNI152_T1_1mm
else
	${FSLDIR}/bin/flirt -interp spline -in ${T1wImage} -ref ${T1wImage} -applyisoxfm $FinalfMRIResolution -out ${WD}/${T1wImageFile}.${FinalfMRIResolution}
	ResampRefIm=${WD}/${T1wImageFile}.${FinalfMRIResolution} 
fi
echo "${FSLDIR}/bin/applywarp --rel --interp=spline -i ${T1wImage} -r ${ResampRefIm} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/${T1wImageFile}.${FinalfMRIResolution}"
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${T1wImage} -r ${ResampRefIm} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/${T1wImageFile}.${FinalfMRIResolution}


# Downsample warpfield (fMRI to standard) to increase speed 
#   NB: warpfield resolution is 10mm, so 1mm to fMRIres downsample loses no precision
echo "${FSLDIR}/bin/convertwarp --relout --rel --warp1=${fMRIToStructuralInput} --warp2=${StructuralToStandard} --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --out=${OutputTransform}"
${FSLDIR}/bin/convertwarp --relout --rel --warp1=${fMRIToStructuralInput} --warp2=${StructuralToStandard} --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --out=${OutputTransform}

# Inverse warpfield (standard to fMRI)
echo "invwarp -w ${OutputTransform} -o ${OutputInvTransform} -r ${ScoutInput}"
invwarp -w ${OutputTransform} -o ${OutputInvTransform} -r ${ScoutInput}

# Create brain masks in this space from the FreeSurfer output (changing resolution)
echo "applywarp --rel --interp=nn -i ${FreeSurferBrainMask}.nii.gz -r ${ScoutInput} -w ${OutputInvTransform} -o ${ScoutInput}_mask.nii.gz"
applywarp --rel --interp=nn -i ${FreeSurferBrainMask}.nii.gz -r ${ScoutInput} -w ${OutputInvTransform} -o ${ScoutInput}_mask.nii.gz

# Create brain masks in this space from the FreeSurfer output (changing resolution)
echo "${FSLDIR}/bin/applywarp --rel --interp=nn -i ${FreeSurferBrainMask}.nii.gz -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/${FreeSurferBrainMaskFile}.${FinalfMRIResolution}.nii.gz"
${FSLDIR}/bin/applywarp --rel --interp=nn -i ${FreeSurferBrainMask}.nii.gz -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/${FreeSurferBrainMaskFile}.${FinalfMRIResolution}.nii.gz

# Create versions of the biasfield (changing resolution)
if [ -f ${BiasField}.nii.gz ]; then
	echo "Create versions of the biasfield (changing resolution)"
	BiasFieldFile=`basename "$BiasField"`
	echo "${FSLDIR}/bin/applywarp --rel --interp=spline -i ${BiasField} -r ${WD}/${FreeSurferBrainMaskFile}.${FinalfMRIResolution}.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/${BiasFieldFile}.${FinalfMRIResolution}"
	${FSLDIR}/bin/applywarp --rel --interp=spline -i ${BiasField} -r ${WD}/${FreeSurferBrainMaskFile}.${FinalfMRIResolution}.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/${BiasFieldFile}.${FinalfMRIResolution}
	${FSLDIR}/bin/fslmaths ${WD}/${BiasFieldFile}.${FinalfMRIResolution} -thr 0.1 ${WD}/${BiasFieldFile}.${FinalfMRIResolution}
fi

echo ""
echo "#=============================================="
echo "#                 SCOUT image"
echo "#=============================================="
echo ""

# Combine transformations: gradient non-linearity distortion + fMRI_dc to standard
echo "${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --warp1=${GradientDistortionField} --warp2=${OutputTransform} --out=${WD}/Scout_gdc_MNI_warp.nii.gz"
${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --warp1=${GradientDistortionField} --warp2=${OutputTransform} --out=${WD}/Scout_gdc_MNI_warp.nii.gz
echo "${FSLDIR}/bin/applywarp --rel --interp=spline --in=${ScoutInput} -w ${WD}/Scout_gdc_MNI_warp.nii.gz -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -o ${OutputScout}"
${FSLDIR}/bin/applywarp --rel --interp=spline --in=${ScoutInput} -w ${WD}/Scout_gdc_MNI_warp.nii.gz -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -o ${OutputScout}

# Combine transformations: gradient non-linearity distortion + fMRI_dc to T1
echo "${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --warp1=${GradientDistortionField} --warp2=${fMRIToStructuralInput} --out=${WD}/Scout_gdc_T1_warp.nii.gz"
${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --warp1=${GradientDistortionField} --warp2=${fMRIToStructuralInput} --out=${WD}/Scout_gdc_T1_warp.nii.gz
echo "${FSLDIR}/bin/applywarp --rel --interp=spline --in=${ScoutInput} -w ${WD}/Scout_gdc_T1_warp.nii.gz -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -o ${OutputScout2T1}"
${FSLDIR}/bin/applywarp --rel --interp=spline --in=${ScoutInput} -w ${WD}/Scout_gdc_T1_warp.nii.gz -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -o ${OutputScout2T1}


echo ""
echo "#=============================================="
echo "#                 fMRI image"
echo "#=============================================="
echo ""

mkdir -p ${WD}/prevols
mkdir -p ${WD}/postvols
mkdir -p ${WD}/postvols2T1

# Apply combined transformations to fMRI (combines gradient non-linearity distortion, motion correction, and registration to T1w space, but keeping fMRI resolution)
echo "Apply combined transformations to fMRI (combines gradient non-linearity distortion, motion correction, and registration to T1w space, but keeping fMRI resolution)"
${FSLDIR}/bin/fslsplit ${InputfMRI} ${WD}/prevols/vol -t
FrameMergeSTRING=""
FrameMergeSTRINGII=""
FrameMergeSTRING2T1=""
FrameMergeSTRINGII2T1=""
k=0
while [ $k -lt $NumFrames ] ; do

	vnum=`${FSLDIR}/bin/zeropad $k 4`
	echo "n° frame = ${vnum}"

	###Add stuff for RMS###
	rmsdiff ${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum} ${MotionMatrixFolder}/${MotionMatrixPrefix}0000 ${ScoutInput} ${ScoutInput}_mask.nii.gz | tail -n 1 >> ${fMRIFolder}/Movement_AbsoluteRMS.txt
	if [ $k -eq 0 ] ; then
		echo "0" >> ${fMRIFolder}/Movement_RelativeRMS.txt
	else
		rmsdiff ${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum} $prevmatrix ${ScoutInput} ${ScoutInput}_mask.nii.gz | tail -n 1 >> ${fMRIFolder}/Movement_RelativeRMS.txt
	fi

	prevmatrix="${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}"
	###Add stuff for RMS###

	${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/prevols/vol${vnum}.nii.gz --warp1=${GradientDistortionField} --postmat=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum} --out=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_warp.nii.gz
	${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --warp1=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_warp.nii.gz --warp2=${OutputTransform} --out=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_all_warp.nii.gz
	${FSLDIR}/bin/fslmaths ${WD}/prevols/vol${vnum}.nii.gz -mul 0 -add 1 ${WD}/prevols/vol${vnum}_mask.nii.gz
	${FSLDIR}/bin/applywarp --rel --interp=spline --in=${WD}/prevols/vol${vnum}.nii.gz --warp=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_all_warp.nii.gz --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --out=${WD}/postvols/vol${k}.nii.gz
	${FSLDIR}/bin/applywarp --rel --interp=nn --in=${WD}/prevols/vol${vnum}_mask.nii.gz --warp=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_all_warp.nii.gz --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --out=${WD}/postvols/vol${k}_mask.nii.gz
	FrameMergeSTRING="${FrameMergeSTRING}${WD}/postvols/vol${k}.nii.gz " 
	FrameMergeSTRINGII="${FrameMergeSTRINGII}${WD}/postvols/vol${k}_mask.nii.gz "

	# To T1
	${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --warp1=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_warp.nii.gz --warp2=${fMRIToStructuralInput} --out=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_all_warp2T1.nii.gz
	${FSLDIR}/bin/applywarp --rel --interp=spline --in=${WD}/prevols/vol${vnum}.nii.gz --warp=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_all_warp2T1.nii.gz --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --out=${WD}/postvols2T1/vol${k}.nii.gz
	${FSLDIR}/bin/applywarp --rel --interp=nn --in=${WD}/prevols/vol${vnum}_mask.nii.gz --warp=${MotionMatrixFolder}/${MotionMatrixPrefix}${vnum}_all_warp2T1.nii.gz --ref=${WD}/${T1wImageFile}.${FinalfMRIResolution} --out=${WD}/postvols2T1/vol${k}_mask.nii.gz
	FrameMergeSTRING2T1="${FrameMergeSTRING2T1}${WD}/postvols2T1/vol${k}.nii.gz " 
	FrameMergeSTRINGII2T1="${FrameMergeSTRINGII2T1}${WD}/postvols2T1/vol${k}_mask.nii.gz " 

	k=`echo "$k + 1" | bc`

done


# Merge together results and restore the TR (saved beforehand)
echo "${FSLDIR}/bin/fslmerge -tr ${OutputfMRI} $FrameMergeSTRING $TR_vol"
${FSLDIR}/bin/fslmerge -tr ${OutputfMRI} $FrameMergeSTRING $TR_vol
echo "${FSLDIR}/bin/fslmerge -tr ${OutputfMRI}_mask $FrameMergeSTRINGII $TR_vol"
${FSLDIR}/bin/fslmerge -tr ${OutputfMRI}_mask $FrameMergeSTRINGII $TR_vol
echo "fslmaths ${OutputfMRI}_mask -Tmin ${OutputfMRI}_mask"
fslmaths ${OutputfMRI}_mask -Tmin ${OutputfMRI}_mask


# T1
# Merge together results and restore the TR (saved beforehand)
echo "${FSLDIR}/bin/fslmerge -tr ${OutputfMRI2T1} $FrameMergeSTRING2T1 $TR_vol"
${FSLDIR}/bin/fslmerge -tr ${OutputfMRI2T1} $FrameMergeSTRING2T1 $TR_vol
echo "${FSLDIR}/bin/fslmerge -tr ${OutputfMRI2T1}_mask $FrameMergeSTRINGII2T1 $TR_vol"
${FSLDIR}/bin/fslmerge -tr ${OutputfMRI2T1}_mask $FrameMergeSTRINGII2T1 $TR_vol
echo "fslmaths ${OutputfMRI2T1}_mask -Tmin ${OutputfMRI2T1}_mask"
fslmaths ${OutputfMRI2T1}_mask -Tmin ${OutputfMRI2T1}_mask


## Create spline interpolated version of Jacobian  (T1w space, fMRI resolution)
##${FSLDIR}/bin/applywarp --rel --interp=spline -i ${JacobianIn} -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -w ${StructuralToStandard} -o ${JacobianOut}
##fMRIToStructuralInput is from gdc space to T1w space, ie, only fieldmap-based distortions (like topup)
##output jacobian is both gdc and topup/fieldmap jacobian, but not the to MNI jacobian
##JacobianIn was removed from inputs, now we just compute it from the combined warpfield of gdc and dc (NOT MNI)
##compute combined warpfield, but don't use jacobian output because it has 8 frames for no apparent reason
##NOTE: convertwarp always requires -o anyway
#if [ $JAC = "YES" ] ; then
#	
#	echo "Do Jacobian"
#	echo "${FSLDIR}/bin/convertwarp --relout --rel --ref=${fMRIToStructuralInput} --warp1=${GradientDistortionField} --warp2=${fMRIToStructuralInput} -o ${WD}/gdc_warp --jacobian=${WD}/gdc_dc_jacobian"
#	${FSLDIR}/bin/convertwarp --relout --rel --ref=${fMRIToStructuralInput} --warp1=${GradientDistortionField} --warp2=${fMRIToStructuralInput} -o ${WD}/gdc_warp --jacobian=${WD}/gdc_jacobian
#	#but, convertwarp's jacobian is 8 frames - each combination of one-sided differences, so average them
#	echo "${FSLDIR}/bin/fslmaths ${WD}/gdc_jacobian -Tmean ${WD}/gdc_jacobian"
#	${FSLDIR}/bin/fslmaths ${WD}/gdc_jacobian -Tmean ${WD}/gdc_jacobian

#	#and resample it to MNI space
#	echo "${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/gdc_jacobian -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -w ${StructuralToStandard} -o ${WD}/Jacobian_MNI.${FinalfMRIResolution}"
#	${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/gdc_jacobian -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} -w ${StructuralToStandard} -o ${WD}/Jacobian_MNI.${FinalfMRIResolution}

#	#and resample it to T1 space
#	echo "${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/gdc_jacobian -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/Jacobian_T1.${FinalfMRIResolution}"
#	${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/gdc_jacobian -r ${WD}/${T1wImageFile}.${FinalfMRIResolution} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/Jacobian_T1.${FinalfMRIResolution}

#fi


###Add stuff for RMS###
echo "cat ${fMRIFolder}/Movement_RelativeRMS.txt | awk '{ sum += $1} END { print sum / NR }' >> ${fMRIFolder}/Movement_RelativeRMS_mean.txt"
cat ${fMRIFolder}/Movement_RelativeRMS.txt | awk '{ sum += $1} END { print sum / NR }' >> ${fMRIFolder}/Movement_RelativeRMS_mean.txt
echo "cat ${fMRIFolder}/Movement_AbsoluteRMS.txt | awk '{ sum += $1} END { print sum / NR }' >> ${fMRIFolder}/Movement_AbsoluteRMS_mean.txt"
cat ${fMRIFolder}/Movement_AbsoluteRMS.txt | awk '{ sum += $1} END { print sum / NR }' >> ${fMRIFolder}/Movement_AbsoluteRMS_mean.txt
###Add stuff for RMS###

echo " "
echo "END: FMRI_OneStepResamplingT1AndMNI.sh"
echo " END: `date`"

