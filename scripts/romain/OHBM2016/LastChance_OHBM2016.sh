#!/bin/bash

FS_PATH=$1
SUBJECT_ID=$2
DATA_PATH=$3

DTI_PATH="${FS_PATH}/${SUBJECT_ID}/dti/"
OUT_PATH="${FS_PATH}/${SUBJECT_ID}/connectome/"
DATA_PATH="${DATA_PATH}/${SUBJECT_ID}/T1w/"
CORTEX_LOI_and_ROI="/home/romain/cortex_LOI_and_ROI.txt"
LIST_OF_STRUCT="/home/romain/ListOfStruct.txt"

matlab -nodisplay <<EOF

cd ${OUT_PATH}
%ConnectomeVoxSsCor=sparse([]);
%for cpt=1:250
%	disp(['${DTI_PATH}/whole_brain_10_2500000_part' num2str(cpt, '%.6d') '.tck']);
%	tmp = getVolumeConnectMatrix_VoxelLevel('${DATA_PATH}/aparc.a2009s+aseg.nii.gz',['${DTI_PATH}/whole_brain_10_2500000_part' num2str(cpt, '%.6d') '.tck'],'${LIST_OF_STRUCT}',10);
%	ConnectomeVoxSsCor=cat(1,ConnectomeVoxSsCor,tmp); 
%    Voxel=sparse([]);
%    for cpt=1:size(tmp.region,2)
%        Voxel=[Voxel tmp.region(cpt).selected];
%    end
%    ConnectomeVoxSsCor=cat(1,ConnectomeVoxSsCor,Voxel);
%end
load('Connectome_Struc_Voxel_SsCor')
fid = fopen('${LIST_OF_STRUCT}', 'r');
T = textscan(fid, '%d %s');
LOI_nb = T{1};

V = spm_vol('${DATA_PATH}/aparc.a2009s+aseg.nii.gz');
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);
ConnectomeVoxSsCor=spones(ConnectomeVoxSsCor);
ConnectomeVoxSsCor=ConnectomeVoxSsCor(:,find(ismember(labels,LOI_nb)));
save Connectome_Struc_Voxel_SsCor2 ConnectomeVoxSsCor -v7.3;

%ConnectomeVoxCor=sparse([]);
%for cpt=1:250
%    tmp = getVolumeConnectMatrix_VoxelLevel('${DATA_PATH}/aparc.a2009s+aseg.nii.gz',['${DTI_PATH}/whole_brain_10_2500000_part' num2str(cpt, '%.6d') '.tck'],'${CORTEX_LOI_and_ROI}',10);
%    ConnectomeVoxCor=cat(1,ConnectomeVoxCor,tmp); 
%end

load('Connectome_Struc_Voxel_Cor')

fid = fopen('${CORTEX_LOI_and_ROI}', 'r');
T = textscan(fid, '%d %s');
LOI_nb = T{1};
ConnectomeVoxCor=spones(ConnectomeVoxCor);
ConnectomeVoxCor=ConnectomeVoxCor(:,find(ismember(labels,LOI_nb)));
save Connectome_Struc_Voxel_Cor ConnectomeVoxCor -v7.3;

incidenceVox=[ConnectomeVoxCor ConnectomeVoxSsCor];
connectomeVox=incidenceVox'*incidenceVox;
Mask = logical(connectomeVox);
Mask = triu(Mask, 1);
Mat = Mask .* connectomeVox;
clear Mask;

save Connectome_Struc_Voxel connectomeVox -v7.3;
EOF
