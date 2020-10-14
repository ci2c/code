#!/bin/bash
#D'apres :
#http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FNIRT/UserGuide#Running_.60fnirt.60_efficiently
#fait peut-être doublon avec 
#/home/renaud/SVN/scripts/renaud/T1_AtlasRegistrationToMNI152_FLIRTandFNIRT.sh

FS_PATH=$1
SUBJ=$2

my_structural="${FS_PATH}/$SUBJ/mri/orig.nii.gz"
mri_convert ${FS_PATH}/$SUBJ/mri/orig.mgz ${my_structural} --out_orientation RAS
my_betted_structural="${FS_PATH}/$SUBJ/mri/orig_betted.nii"
#bet ${my_structural} ${my_betted_structural}
my_atlas="${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz"
my_affine_transf="${FS_PATH}/$SUBJ/mri/my_affine_transf.mat"
flirt -ref ${my_atlas} -in ${my_structural} -omat ${my_affine_transf} -out "${FS_PATH}/$SUBJ/mri/orig_betted_r.nii"

#je donne la recaler en entrée donc pas besoin de --aff
#fnirt --in=${my_structural} --aff=${my_affine_transf} --cout=${my_nonlinear_transf} --config=T1_2_MNI152_2mm
my_nonlinear_transf="${FS_PATH}/$SUBJ/mri/my_nonlinear_transf"
fnirt --in="${FS_PATH}/$SUBJ/mri/orig_betted_r.nii" --cout=${my_nonlinear_transf} --config=T1_2_MNI152_1mm --iout="${FS_PATH}/$SUBJ/mri/orig_betted_rw.nii"

applywarp --ref=${my_atlas} --in=${my_structural} --warp=${my_nonlinear_transf} --premat=${my_affine_transf} --out="${FS_PATH}/$SUBJ/mri/orig_betted_rw2.nii"

my_parcel="${FS_PATH}/$SUBJ/maROI.nii"
my_warped_parcel="${FS_PATH}/$SUBJ/maROI_onMNI2.nii.gz"
applywarp --ref=${my_atlas} --in=${my_parcel} --warp=${my_nonlinear_transf} --premat=${my_affine_transf} --out=${my_warped_parcel} --interp=nn 