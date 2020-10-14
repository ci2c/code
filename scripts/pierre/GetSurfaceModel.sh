#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: GetSurfaceModel.sh  fs_dir  subj  outdir  ROI_id"
	echo ""
	echo "  fs_dir                         : freesurfer output path (i.e. SUBJECTS_DIR)"
	echo "  subj                           : subject ID"
	echo "  outdir                         : output directory"
	echo "  ROI_id                         : ID of the ROI to use"
	echo ""
	echo "Usage: GetSurfaceModel.sh  fs_dir  subj  outdir  ROI_id"
	echo ""
	exit 1
fi


# Step. 1 : initialization
FS=$1
subj=$2
outdir=$3
ID=$4
DIR=${outdir}/${subj}
log_dir=/tmp/
SUBJECTS_DIR=${outdir}
Res="1"

# Copy original data
cp -R ${FS}/${subj} ${DIR}

# Create roi dir
if [ ! -d ${DIR}/roi ]
then
	mkdir ${DIR}/roi
else
	rm -rf ${DIR}/roi/*
fi
roidir=${DIR}/roi/

# Create surf dir
if [ ! -d ${DIR}/surf ]
then
	mkdir ${DIR}/surf
fi

# Remove useless files
cd ${DIR}
rm -rf ${DIR}/surf/* ${DIR}/epilepsy
cd mri
rm -rf aparc+aseg.mgz aseg.auto.mgz aseg.auto_noCCseg.label_intensities.txt aseg.auto_noCCseg.mgz brain.finalsurfs.mgz brainmask.auto.mgz brainmask.mgz ctrl_pts.mgz filled.mgz lh.dpial.ribbon.mgz lh.dwhite.ribbon.mgz lh.ribbon.mgz mri_nu_correct.mni.log rh.dpial.ribbon.mgz rh.dwhite.ribbon.mgz rh.ribbon.mgz rhlh.white_cereb.label.mgz ribbon.mgz segment.dat wm.asegedit.mgz wm.mgz wm.seg.mgz wmparc.mgz

# Resample files to ${Res} isotropic
if [ ! -f ${DIR}/mri/brain_orig.mgz ]
then
	mri_convert ${DIR}/mri/brain.mgz ${DIR}/mri/brain_${Res}.mgz -vs ${Res} ${Res} ${Res}
	mri_convert ${DIR}/mri/norm.mgz ${DIR}/mri/norm_${Res}.mgz -vs ${Res} ${Res} ${Res}
	mri_convert ${DIR}/mri/nu.mgz ${DIR}/mri/nu_${Res}.mgz -vs ${Res} ${Res} ${Res}
	mri_convert ${DIR}/mri/orig.mgz ${DIR}/mri/orig_${Res}.mgz -vs ${Res} ${Res} ${Res}
	mri_convert ${DIR}/mri/T1.mgz ${DIR}/mri/T1_${Res}.mgz -vs ${Res} ${Res} ${Res}
	
	mv ${DIR}/mri/brain.mgz ${DIR}/mri/brain_orig.mgz
	mv ${DIR}/mri/norm.mgz ${DIR}/mri/norm_orig.mgz
	mv ${DIR}/mri/nu.mgz ${DIR}/mri/nu_orig.mgz
	mv ${DIR}/mri/orig.mgz ${DIR}/mri/orig_orig.mgz
	mv ${DIR}/mri/T1.mgz ${DIR}/mri/T1_orig.mgz
	
	mv ${DIR}/mri/brain_${Res}.mgz ${DIR}/mri/brain.mgz
	mv ${DIR}/mri/norm_${Res}.mgz ${DIR}/mri/norm.mgz
	mv ${DIR}/mri/nu_${Res}.mgz ${DIR}/mri/nu.mgz
	mv ${DIR}/mri/orig_${Res}.mgz ${DIR}/mri/orig.mgz
	mv ${DIR}/mri/T1_${Res}.mgz ${DIR}/mri/T1.mgz
fi

if [ ! -f ${roidir}/ROI.mgz ]
then
	mri_extract_label ${DIR}/mri/aparc.a2009s+aseg.mgz ${ID} ${roidir}/ROI_128.mgz
	mri_convert ${roidir}/ROI_128.mgz ${roidir}/ROI_128_${Res}.mgz -vs ${Res} ${Res} ${Res}
	mri_morphology ${roidir}/ROI_128_${Res}.mgz close 1 ${roidir}/ROI_128_${Res}_close.mgz
	mri_binarize --i ${roidir}/ROI_128_${Res}_close.mgz --o ${roidir}/ROI.mgz --min 0.1 --max inf
	rm -f ${DIR}/mri/aparc.a2009s+aseg.mgz 
fi

cp ${roidir}/ROI.mgz ${DIR}/mri/wm.asegedit.mgz
mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz

cp wm.mgz filled.mgz

echo "mri_tessellate ../mri/wm.mgz 1 ../surf/lh.orig.nofix"
mri_tessellate ../mri/wm.mgz 1 ../surf/lh.orig.nofix

echo "mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix"
mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix

echo "mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix"
mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix

echo "mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix"
mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix

echo "mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix"
mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix

echo "cp ../surf/lh.orig.nofix ../surf/lh.orig"
cp ../surf/lh.orig.nofix ../surf/lh.orig 

echo "cp ../surf/lh.inflated.nofix ../surf/lh.inflated "
cp ../surf/lh.inflated.nofix ../surf/lh.inflated 

echo "mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 ${subj} lh"
mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 ${subj} lh

echo "mris_euler_number ../surf/lh.orig"
mris_euler_number ../surf/lh.orig

echo "mris_remove_intersection ../surf/lh.orig ../surf/lh.orig "
mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 

echo "rm ../surf/lh.inflated"
rm ../surf/lh.inflated

echo "mri_mask ../mri/T1.mgz ${roidir}/ROI.mgz ../mri/brain.finalsurfs.mgz"
mri_mask ../mri/T1.mgz ${roidir}/ROI.mgz ../mri/brain.finalsurfs.mgz

echo "mris_make_surfaces -noaparc -mgz -T1 brain.finalsurfs ${subj} lh"
mris_make_surfaces -noaparc -mgz -T1 brain.finalsurfs ${subj} lh

echo "mris_smooth ../surf/lh.white ../surf/lh.smoothwm"
mris_smooth ../surf/lh.white ../surf/lh.smoothwm

echo "mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated "
mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 

echo "mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated"
mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated

echo "mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere "
mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

