#!/bin/bash
set -e

FMRI=$1
SUBJECTS_DIR=$2
SUBJ=$3
OUTDIR=$4


#if [ $# -lt 8 ]
#then
#	echo ""
#	echo "Usage: FMRI_VolumePreprocessing.sh  -dtipos <path>  -dtineg <path>  -o <path>  -echospacing <value>  [-denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -t1 <t1_nifti>  -t1brain <t1brain_nifti>  -brainmask <mask_nifti>  -t1restore <nifti>  -bias <nifti>  -fs <folder>  -subj <name>]"
#	echo ""
#	echo "NIFTI IMAGE WHITHOUT EXTENSION"
#	echo "  -dtipos                   : PA dti file (nifti image) + need bval and bvec with same name "
#	echo "  -dtineg                   : AP dti file (nifti image) + need bval and bvec with same name "
#	echo "  -o                        : output folder "
#	echo "  -echospacing              : echo spacing in ms "
#	echo " "
#	echo "Options :"
#	echo "  -denoise                  : do dwi denoising (Default: NONE)"
#	echo "  -pedir                    : phase encoding direction (Default: 2 for +=PA and -=AP)"
#	echo "  -b0dist                   : minimum distance in volumes between b0s considered for preprocessing (Default: 3)"
#	echo "  -b0max                    : Volumes with a bvalue smaller than this value will be considered as b0s (Default: 50)"
#	echo "  If DTI coregistered on T1, it needs at least t1, t1brain and brainmask option "
#	echo "  -t1                       : t1 file (nifti image) (default: NONE)"
#	echo "  -t1brain                  : t1 brain file (nifti image) (default: NONE)"
#	echo "  -brainmask                : t1 brain mask (nifti image) (default: NONE)"
#	echo "  -t1restore                : t1 file after bias field correction (default : NONE)"
#	echo "  -bias                     : bias field image (default : NONE)"
#	echo "  -fs                       : Freesurfer folder (Default : NONE)"
#	echo "  -subj                     : Subject's Freesurfer folder (Default : NONE)"
#	echo ""
#	echo "Usage: FMRI_VolumePreprocessing.sh  -dtipos <path>  -dtineg <path>  -o <path>  -echospacing <value>  [-denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -t1brain <t1brain_nifti>  -brainmask <mask_nifti>  -t1restore <nifti>  -bias <nifti>  -fs <folder>  -subj <name>]"
#	exit 1
#fi


#### Inputs ####
index=1
echo "------------------------"

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions

Template2mm=${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz

T1wImage=${SUBJECTS_DIR}/${SUBJ}/T1w/T1w_acpc
T1wBrainImage=${SUBJECTS_DIR}/${SUBJ}/T1w/T1w_acpc_brain
brainmask=${SUBJECTS_DIR}/${SUBJ}/T1w/brainmask_fs

mkdir -p ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}

FMRI_SkipFrames.sh -i ${FMRI} -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf.nii.gz -skip "4"
FMRI_SliceTimingCorr.sh  -i ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf.nii.gz -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st.nii.gz -order interleavedPhilips -tr 2.4
echo "fslroi $fMRIFolder/$NameOffMRI $fMRIFolder/Scout 0 1"
${FSLDIR}/bin/fslroi ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Scout" 0 1
echo "mkdir -p ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/MotionCorrection"
mkdir -p ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/MotionCorrection
FMRI_MotionCorrectionByFSL.sh \
    -d ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/MotionCorrection \
    -i ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st \
    -r ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Scout" \
    -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc \
    -or ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Movement_Regressors" \
    -ot ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"MotionMatrices" \
    -on "MAT_" \
    -t "MCFLIRT"

bet2 ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Scout" ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"mask" -f 0.3 -n -m 
immv ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask_mask ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask

fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc -mas ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_bet

perc=`fslstats ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_bet -p 2 -p 98`
thr=`echo $perc | awk '{print $2}'`
thr=`echo "$thr / 10" | bc -l`
echo "seuil = $thr"

echo "fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_bet -thr ${thr} -Tmin -bin ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask -odt char"
fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_bet -thr ${thr} -Tmin -bin ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask -odt char

perc50=`fslstats ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc -k ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask -p 50` 

fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask -dilF ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask

fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc -mas ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/mask ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh

# despiking
echo "FMRI_Despiking.sh -i ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh.nii.gz -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds.nii.gz"
FMRI_Despiking.sh -i ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh.nii.gz -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds.nii.gz

# normalization
fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds -inm 10000 ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm

# filtering
fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm -Tmean ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/tempMean
TR=2.4
hp=0.01
hp_sigma=`echo "1 / ( 2 * ( ${TR} * ${hp} ) )" | bc -l`
fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm -bptf ${hp_sigma} -1 -add ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/tempMean ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm_hp${hp}
imrm ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/tempMean

# fMRI-T1 co-registration
FMRI_T1Coregistration.sh \
	-fmri ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Scout" \
	-t1 ${T1wImage} -t1brain ${T1wBrainImage} \
	-o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"xfms"

applywarp --rel --interp=spline -i ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Scout" -r ${Template2mm} --premat=${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/xfms/fMRI2str.mat -w ${SUBJECTS_DIR}/${SUBJ}/MNINonLinear/xfms/acpc_dc2standard.nii.gz -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/"Scout2MNI"

applywarp --rel --interp=spline -i ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm_hp${hp} -r ${Template2mm} --premat=${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/xfms/fMRI2str.mat -w ${SUBJECTS_DIR}/${SUBJ}/MNINonLinear/xfms/acpc_dc2standard.nii.gz -o ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm_hp${hp}_mni2mm

# smoothing
fwhmvol=6
Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
echo "sigma: $Sigma"
fslmaths ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm_hp${hp}_mni2mm -kernel gauss ${Sigma} -fmean ${SUBJECTS_DIR}/${SUBJ}/${OUTDIR}/fmri_rf_st_mc_thresh_ds_norm_hp${hp}_mni2mm_sm${fwhmvol}


