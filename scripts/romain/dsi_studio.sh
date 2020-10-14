#!/bin/bash

#transformation des dcm en nii
#dcm2nii 

#Generate SRC files from DICOM/NIFTI/2dseq images
#PATH_DTI=/NAS/dumbo/romain/PreClinque/Data-dti-souris/Test3DTI/Test3DTI/pdata/1
PATH_DTI=/NAS/dumbo/romain/PreClinque/DTI_wholeBrain_exvivo/DTI_WB_exvivo_30dir/pdata/1
dsi_studio --action=src --source=${PATH_DTI}/2dseq --output=${PATH_DTI}/dti.src.gz > ${PATH_DTI}/dsi_studio_src.txt

#Image Reconstruction
# Reconstruction Parameters
method=7          # 7 for QSDR
param0="1.25"
voxel_res="1"     # 1mm voxels
thread="16"
dsi_studio --action=rec --thread=${thread} --source=${PATH_DTI}/dti.src.gz --method=${method} --param0=${param0} --param1=${voxel_res} --output_jac=1 --output_map=1 --record_odf=1 --reg_method=2 

#Tractography
#interpo_angle
smoothing=0.5
fa_threshold=0.6
step_size=0.085
turning_angle=30
min_length=0.2
max_length=4

dsi_studio --action=trk --source=${PATH_DTI}/dti.src.gz.odf8.f5rec.bal.fz.reg2i2.qsdr.1.25.1mm.jac.map.R56.fib.gz --seed_count=1000000 --turning_angle=${turning_angle} --step_size=${step_size} --smoothing=${smoothing} --min_length=${min_length} --max_length=${max_length} --thread_count=8 --export=stat,tdi,tdi2,qa,gfa --output=${PATH_DTI}/track.trk > ${PATH_DTI}/dsi_studio_trk.txt

#dsi_studio --action=trk --source=my.fib.gz --roi=aal:Precentral_L --roi2=aal:Precentral_R --fiber_count=1000 --thread_count=10

#ATLAS
#  dsi_studio --action=atl-

#Analyse
#  dsi_studio --action=ana --source=my.fib.gz --tract=Tracts2.trk --end=multiple_roi.nii --export=connectivity

#Export
# dsi_studio --action=exp 
