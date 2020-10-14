#!/bin/bash

FS_PATH=$1
SUBJECT_ID=$2
DATA_PATH=$3

DTI_PATH="${FS_PATH}/${SUBJECT_ID}/dti/"
MRI_PATH="${FS_PATH}/${SUBJECT_ID}/mri/"
OUT_PATH="${FS_PATH}/${SUBJECT_ID}/connectome/"
DATA_PATH="${DATA_PATH}/${SUBJECT_ID}/T1w/"
CORTEX_LOI_and_ROI="/home/romain/cortex_LOI_and_ROI.txt"
LIST_OF_STRUCT="/home/romain/ListOfStruct.txt"

##FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3"
##DATA_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data"
##SUBJECT_ID='comblez'

##dcm2nii ${DATA_PATH}/${SUBJECT_ID}
#mkdir ${FS_PATH}/${SUBJECT_ID}/dti

#FILE1=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "**dti*dir*.bval" -print | head -1`
#cp ${FILE1} ${FS_PATH}/${SUBJECT_ID}/dti/dti.bval
#FILE2=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "**dti*dir*.bvec" -print | head -1`
#cp ${FILE2} ${FS_PATH}/${SUBJECT_ID}/dti/dti.bvec
#FILE3=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "**dti*dir*.nii.gz" -print | head -1`
#cp ${FILE3} ${FS_PATH}/${SUBJECT_ID}/dti/dti.nii.gz

#FILE4=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "*correctiondti*.bval" -print | head -1`
#cp ${FILE4} ${FS_PATH}/${SUBJECT_ID}/dti/dti_back.bval
#FILE5=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "*correctiondti*.bvec" -print | head -1`
#cp ${FILE5} ${FS_PATH}/${SUBJECT_ID}/dti/dti_back.bvec
#FILE6=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "*dticorr*.nii.gz" -print | head -1`
#cp ${FILE6} ${FS_PATH}/${SUBJECT_ID}/dti/dti_back.nii.gz
#FILE6=`find ${DATA_PATH}/${SUBJECT_ID}/ -iname "*correctiondti*.nii.gz" -print | head -1`
#cp ${FILE6} ${FS_PATH}/${SUBJECT_ID}/dti/dti_back.nii.gz

#PrepareSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID}

#echo "ModelSubCorticalStruct.sh -fs ${FS_PATH} -subj ${SUBJECT_ID} -sfile ${LOI_VOXELS} -res 0.5"
#ModelSubCorticalStruct.sh -fs ${FS_PATH} -subj ${SUBJECT_ID} -sfile ${LOI_VOXELS} -res 0.5

#echo "getSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID} "
#getSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID} 

#for STRUC in Accumbens-area Amygdala Hippocampus Pallidum Putamen Thalamus-Proper Caudate
#do
#	echo "RegisterSubCortSurface.sh -fs ${FS_PATH} -sname Left/Right-${STRUC} -subj ${SUBJECT_ID}"
#	getSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID} -surf_lh ${FS_PATH}/${SUBJECT_ID}/Left-${STRUC}/lh.white -surf_rh  ${FS_PATH}/${SUBJECT_ID}/Right-${STRUC}/lh.white -out Connectome_${STRUC}.mat
#	RegisterSubCortSurface.sh -fs ${FS_PATH} -sname Left-${STRUC} -subj ${SUBJECT_ID}
#	RegisterSubCortSurface.sh -fs ${FS_PATH} -sname Right-${STRUC} -subj ${SUBJECT_ID}
#done

#sleep 60;

#echo "SubsampleSurfaceConnectome.sh -fs  ${FS_PATH} -subj ${SUBJECT_ID}"
#/home/romain/SVN/scripts/romain/SubsampleSurfaceConnectome.sh -fs  ${FS_PATH} -subj ${SUBJECT_ID}

echo "ConnectomePar = getVolumeConnectMatrix('${DTI_PATH}/raparc_aseg_dti_ras.nii', '${DTI_PATH}/whole_brain_6_1500000.tck');"
echo "${DATA_PATH}/aparc.a2009s+aseg.nii.gz"
echo "${DTI_PATH}/whole_brain_6_2500000.tck"
echo "${CORTEX_LOI_and_ROI}"

if [ ! -e ${DTI}/Connectome_Struc_Par_Cor.mat ]
then
	matlab -nodisplay <<EOF
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${OUT_PATH}
	%ConnectomeParCor = getVolumeConnectMatrix('${DTI_PATH}/raparc_aseg_dti_ras.nii.gz','${DTI_PATH}/whole_brain_6_1500000.tck','${CORTEX_LOI_and_ROI}',0);

	ConnectomeParCor = getVolumeConnectMatrix('${DATA_PATH}/aparc.a2009s+aseg.nii.gz', '${DTI_PATH}/whole_brain_10_2500000.tck','${CORTEX_LOI_and_ROI}',0);
	ConnectomeParCor.fibers = [];
	save Connectome_Struc_Par_Cor ConnectomeParCor;
	clear ConnectomeParCor;
EOF
fi

if [ ! -e ${DTI}/Connectome_Struc_Par_SsCor.mat ]
then
	matlab -nodisplay <<EOF
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${OUT_PATH}
	%ConnectomeParSsCor = getVolumeConnectMatrix('${DTI_PATH}/raparc_aseg_dti_ras.nii.gz', '${DTI_PATH}/whole_brain_6_1500000.tck','${LIST_OF_STRUCT}',0);
	ConnectomeParSsCor = getVolumeConnectMatrix('${DATA_PATH}/aparc.a2009s+aseg.nii.gz', '${DTI_PATH}/whole_brain_10_2500000.tck','${LIST_OF_STRUCT}',0);
	ConnectomeParSsCor.fibers = [];
	save Connectome_Struc_Par_SsCor ConnectomeParSsCor;
	clear ConnectomeParSsCor;
EOF
fi

echo "ConnectomeVox = getVolumeConnectMatrix_VoxelLevel('${DTI_PATH}/raparc_aseg_dti_ras.nii', '${DTI_PATH}/whole_brain_6_1500000.tck','${LOI_VOXELS}',0);"

if [ ! -e ${DTI}/Connectome_Struc_Voxel_SsCor.mat ]
then
	matlab -nodisplay <<EOF
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${OUT_PATH}
	%ConnectomeVoxSsCor = getVolumeConnectMatrix_VoxelLevel('${DTI_PATH}/raparc_aseg_dti_ras.nii.gz','${DTI_PATH}/whole_brain_6_1500000.tck','${LIST_OF_STRUCT}',0);
	ConnectomeVoxSsCor = getVolumeConnectMatrix_VoxelLevel('${DATA_PATH}/aparc.a2009s+aseg.nii.gz','${DTI_PATH}/whole_brain_10_2500000.tck','${LIST_OF_STRUCT}',0);
	ConnectomeVoxSsCor.fibers = [];
	save Connectome_Struc_Voxel_SsCor ConnectomeVoxSsCor;
	clear ConnectomeVoxSsCor;
EOF
fi

if [ ! -e ${DTI}/Connectome_Struc_Voxel_Cor.mat ]
then
	matlab -nodisplay <<EOF
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${OUT_PATH}

	ConnectomeVoxCor = getVolumeConnectMatrix_VoxelLevel('${DATA_PATH}/aparc.a2009s+aseg.nii.gz','${DTI_PATH}/whole_brain_10_2500000.tck','${CORTEX_LOI_and_ROI}',0);
	ConnectomeVoxCor.fibers = [];
	save Connectome_Struc_Voxel_Cor ConnectomeVoxCor;
	clear ConnectomeVoxCor;
EOF
fi
