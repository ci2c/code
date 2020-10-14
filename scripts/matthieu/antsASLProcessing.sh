#!/bin/bash

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

if [[ ! -s ${ANTSPATH}/antsRegistration ]]
then
  echo "Cannot find antsRegistration.  Please \(re\)define \$ANTSPATH in your environment."
fi
if [[ ! -s ${ANTSPATH}/antsApplyTransforms ]]
then
  echo "Cannot find antsApplyTransforms.  Please \(re\)define \$ANTSPATH in your environment."
fi
if [[ ! -s ${ANTSPATH}/antsIntermodalityIntrasubject.sh ]]
then 
  echo "Cannot find antsIntermodalityIntrasubject.sh script.  Please \(re\)define \$ANTSPATH in your environemnt."
fi

time_start=`date +%s`

# Set intial parameters
ANATOMICAL_IMAGE=$1
BRAINMASK=$2
PCASL=$3
TEMPLATE=$4
TRANSFORM_PREFIX=$5
OUTNAME=$6
cbf="${OUTNAME}_kcbf.nii.gz"

# Compute motion correction
${ANTSPATH}antsMotionCorr -d 3 -a $PCASL -o ${OUTNAME}AveragePCASL.nii.gz

# Mean pcasl brain extraction 
echo "bet ${OUTNAME}AveragePCASL.nii.gz ${OUTNAME} -m -n -f 0.5"
bet ${OUTNAME}AveragePCASL.nii.gz ${OUTNAME} -m -n -f 0.5

${ANTSPATH}ImageMath 3 ${OUTNAME}pCASLBrain.nii.gz m ${OUTNAME}AveragePCASL.nii.gz ${OUTNAME}_mask.nii.gz

## Compute the PCASL to T1 registration
# INTERSUBJECT_PARAMS=" -d 3 -i ${OUTNAME}pCASLBrain.nii.gz -r $ANATOMICAL_IMAGE -x $BRAINMASK -w ${TRANSFORM_PREFIX}SubjectToTemplate -t 3 -o $OUTNAME -T $TEMPLATE "
ref="${OUTNAME}_ref.nii.gz"
${ANTSPATH}/ResampleImageBySpacing 3 $ANATOMICAL_IMAGE $ref 2.0 2.0 2.0
INTERSUBJECT_PARAMS=" -d 3 -i ${OUTNAME}pCASLBrain.nii.gz -r $ref -R $ANATOMICAL_IMAGE -x $BRAINMASK -w ${TRANSFORM_PREFIX}SubjectToTemplate -t 2 -o $OUTNAME -T $TEMPLATE "
${ANTSPATH}/antsIntermodalityIntrasubject.sh $INTERSUBJECT_PARAMS

## Compute mean CBF
${ANTSPATH}/cbf_pcasl_robust_batch.R $PCASL ${OUTNAME}brainmask.nii.gz $cbf

## Calculate mean CBF warped to template space : Apply pCASL to T1 registration, then T1 to template registration
${ANTSPATH}antsApplyTransforms -d 3 \
    -i ${OUTNAME}_kcbf.nii.gz \
    -r $TEMPLATE \
    -o ${OUTNAME}MeanCBFWarpedToTemplate.nii.gz \
    -n Linear \
    -t ${TRANSFORM_PREFIX}SubjectToTemplate1Warp.nii.gz \
    -t ${TRANSFORM_PREFIX}SubjectToTemplate0GenericAffine.mat \
    -t ${OUTNAME}1Warp.nii.gz \
    -t ${OUTNAME}0GenericAffine.mat 

## Calculate mean CBF warped to T1 space
${ANTSPATH}antsApplyTransforms -d 3 \
  -i ${OUTNAME}_kcbf.nii.gz \
  -r $ANATOMICAL_IMAGE \
  -o ${OUTNAME}MeanCBFWarpedToT1.nii.gz \
  -n Linear \
  -t ${OUTNAME}1Warp.nii.gz \
  -t ${OUTNAME}0GenericAffine.mat \

## Calculate partial volume correction of mean CBF warped to T1 space
if [ ! -f ${OUTNAME}_PVC_MeanCBFWToT1.nii.gz ]
then 
    ${ANTSPATH}antsPartialVolumeCorrection.R \
    -o ${OUTNAME} \
    --cbf ${OUTNAME}MeanCBFWarpedToT1.nii.gz \
    --gmProb ${TRANSFORM_PREFIX}BrainSegmentationPosteriors2.nii.gz \
    --wmProb ${TRANSFORM_PREFIX}BrainSegmentationPosteriors3.nii.gz
fi

## Calculate PVC_MeanCBFWToT1 warped to template
  ${ANTSPATH}antsApplyTransforms -d 3 \
  -i ${OUTNAME}_PVC_MeanCBFWToT1.nii.gz \
  -r $TEMPLATE \
  -o ${OUTNAME}_PVC_MeanCBFWToTemplate.nii.gz \
  -n Linear \
  -t ${TRANSFORM_PREFIX}SubjectToTemplate1Warp.nii.gz \
  -t ${TRANSFORM_PREFIX}SubjectToTemplate0GenericAffine.mat

time_end=`date +%s`
time_elapsed=$((time_end - time_start))

echo
echo "--------------------------------------------------------------------------------------"
echo " Done with ASL processing pipeline."
echo " Script executed in $time_elapsed seconds."
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s"
echo "--------------------------------------------------------------------------------------"

exit 0
