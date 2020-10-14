#!/bin/bash

SUBJ="comblez"
FS_PATH="/NAS/tupac/romain/testHRSFC/"
RS_PATH="${FS_PATH}/${SUBJ}/rs_fmri/"
DTI_PATH="${FS_PATH}/${SUBJ}/dti/"
MRI_PATH="${FS_PATH}/${SUBJ}/mri/"
OUT_PATH="${FS_PATH}/${SUBJ}/connectome/"
RS_FILE="${RS_PATH}/resting_state.nii"
LOI_SURFACES="/home/romain/ListOfStruct4Surfaces.txt"
LOI_VOXELS="/home/romain/ListOfStruct4Voxels.txt"
Nfiber=1500000
lmax=6
VolumeT1="${MRI_PATH}/T1.mgz"
Segmentation="${FS_PATH}/aparc.a2009s+aseg.mgz"
BrainMask="${FS_PATH}/brainmask.mgz"
Whitematter="${FS_PATH}/wm.mgz"
Surfacelh="${FS_PATH}/${SUBJ}/surf/lh.pial"
Surfacerh="${FS_PATH}/${SUBJ}/surf/rh.pial"

##################################
echo "T1"
##################################
recon-all -all -sd ${FS_PATH} -subjid ${SUBJ} -nuintensitycor-3T -i ${FS_PATH}/${SUBJ}/T1.nii.gz
#freeview $VolumeT1 $Whitematter $Segview -f $Segmentation -f $Surfacelh -f $Surfacerh&

#Labe2Surfaces + spharm
ModelSubCorticalStruct.sh -fs ${FS_PATH} -subj ${SUBJ} -sfile ${LOI_VOXELS} -res 0.5
find ${FS_PATH}/${SUBJ} -iname "lh.white" | xargs freeview -f
find ${FS_PATH}/${SUBJ} -iname "rh.white" | xargs freeview -f
find ${FS_PATH}/${SUBJ} -iname "lh.sphere" | xargs ls -lh	#15 + 1 (rh)

##################################
echo "DTI"
##################################
#dti/dti_back.nii.gz dti/dti.nii.gz dti/dti.bval dti/dti.bvec
PrepareSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJ} -las
ls -lh ${DTI_PATH}/whole_brain_6_1500000.tck

getSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJ} -out "Connectome_Struc_Surf.mat"
find ${DTI_PATH} -iname "Connectome_Struc_Surf_part*" | wc -l
find ${DTI_PATH} -iname "Connectome_Struc_Surf_part*" | ls -lh 
ls -lh ${DTI_PATH}/Connectome_Struc_Surf.mat

#mri_convert ${MRI_PATH}/aparc.a2009s+aseg.mgz ${MRI_PATH}/aparc.a2009s+aseg.nii
#mri_extract_label ${MRI_PATH}/aparc.a2009s+aseg.mgz 10 11 12 13 17 18 26 49 50 51 52 53 54 58 ${MRI_PATH}/strcuturesSousCorticales.nii

matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${OUT_PATH}
Connectome = getVolumeConnectMatrix('${MRI_PATH}/aparc.a2009s+aseg.nii', '${DTI_PATH}/whole_brain_${lmax}_${Nfiber}.tck','${LOI_VOXELS}',0);
Connectome.fibers = [];
save Connectome_Struc_Voxel Connectome
EOF

find ${OUT_PATH} -iname "*_Struc_Voxel_*" |wc -l

matlab -nodisplay <<EOF
conn1=load('Connectome.mat');
ConnectomeStruct = sparse(conn1.Connectome.i+1,conn1.Connectome.j+1,ones(size(conn1.Connectome.i)),conn1.Connectome.nx,conn1.Connectome.ny);
delete conn1;
conn2=load('Connectome_Struc_Voxel.mat');
ConnectomeStruct = [ConnectomeStruct conn2.Connectome.region(:).selected];
delete conn2;
save ${OUT_PATH}/ConnectomeStruct ConnectomeStruct
EOF

##################################
echo "RestingState"
##################################
FMRI_PreprocessingVolumeAndSurface.sh -sd ${FS_PATH} -subj ${SUBJ} -epi ${RS_FILE} -o ${RS_PATH} -fwhmsurf 6 -fwhmvol 6 -acquis interleaved -rmframe 3 -tr 2.4 -doCompCor -doFilt 0.008 0.1 -doSPMNorm -doGMS -v 5.3 -doSBA
find ${RS_PATH}/run01 -iname "fcarepi_s*" |wc -l #CQ (=16 run01/fcarepi_sc_al.nii...)
find ${RS_PATH}/run01 -iname "fcarepi.sm6*" | wc -l #CQ (= 6  fcarepi.sm${fwhmsurf}.lh.nii fcarepi.sm${fwhmsurf}.lh.nii...)

matlab -nodisplay <<EOF
hdr=load_nifti('${RS_PATH}/run01/fcarepi.sm6.rh.nii.gz');
data=squeeze(hdr.vol);
Surf=SurfStatReadSurf('${FS_PATH}/${SUBJ}/surf/rh.white.ras');
for i=1:size(Surf.tri,1)
   mat(i,:)=mean(data((Surf.tri(i,:)),:));
end

hdr=load_nifti('${RS_PATH}/run01/run01/fcarepi.sm6.lh.nii.gz');
data=squeeze(hdr.vol);
Surf=SurfStatReadSurf('${FS_PATH}/${SUBJ}/surf/lh.white.ras');
for j=1:size(Surf.tri,1)
   mat(i+j,:)=mean(data((Surf.tri(j,:)),:));
end
save ${OUT_PATH}/ConnectomeFonc mat
EOF

FMRI_ConnectomeBasedOnFreesurferParcellation.sh -sd ${FS_PATH} -subj ${SUBJ} -epi ${RS_PATH}/run01/fcarepi_al.nii.gz -omat Connectome_Fonc_Vox_Surf -odir ${RS_PATH}/resting_state/ -loifs1 ${LOI_VOXELS}

##################################
echo "Subsample"
##################################
/home/romain/SVN/scripts/romain/SubsampleSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID}_enc
