#!/bin/bash

if [ $# -lt 6 ]
then
	echo "Usage: GetVoxelConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
	echo "  -dti dti_DTI                 : Path to tracto splitted files (ex : FS_PATH/SUBJECT_ID/dti/whole_brain_10_2500000_part)"
	echo "  -seg seg_Dir                 : Path to parcelisation"
	echo "  -roi roi_Dir                 : Path txt file with structures to use"
	echo "  -threhold nb                 : Threshold on the length of fiber (default = 10)"
	echo "  -out outfile_name            : Full Name of the output file"
	echo "Usage: GetVoxelConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
	exit 1
fi

#### Inputs ####
index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: GetVoxelConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
		echo "  -dti dti_DTI                 : Path to tracto splitted files (ex : FS_PATH/SUBJECT_ID/dti/whole_brain_10_2500000_part)"
		echo "  -seg seg_Dir                 : Path to parcelisation"
		echo "  -roi roi_Dir                 : Path txt file with structures to use"
		echo "  -threhold nb                 : Threshold on the length of fiber (default = 10)"
		echo "  -out outfile_name            : Full Name of the output file"
		echo "Usage: GetVoxelConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
		exit 1
	;;
	-fs)
		FS_PATH=`expr $index + 1`
		eval FS_PATH=\${$fsdir}
		echo "FS_PATH='$FS_PATH'"
		index=$[$index+1]
		;;
	-subj)
		SUBJECT_ID=`expr $index + 1`
		eval SUBJECT_ID=\${$SUBJECT_ID}
		echo "SUBJECT_ID='${SUBJECT_ID}'"
		index=$[$index+1]
		;;
	-out)
		out_name=`expr $index + 1`
		eval out_name=\${$out_name}
		echo "out_name='${out_name}'"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


#Example
#GetVoxelConnectivityMatrix.sh -dti /NAS/dumbo/HBC/Freesurfer5.0/100408/dti/whole_brain_10_2500000_part000 -seg /NAS/dumbo/HBC/FS53/100408/mri/wOnMNI_aparc.a2009s+aseg.nii.gz -out /NAS/dumbo/HBC/Freesurfer5.0/100408/connectome/testRV.mat

index=1
#DEFAULT
#FS_PATH=$1
#SUBJECT_ID=$2
#OUT_PATH="${FS_PATH}/Freesurfer5.0/${SUBJECT_ID}/connectome/"
#DTI_PATH="${FS_PATH}/Freesurfer5.0/${SUBJECT_ID}/dti/whole_brain_10_2500000_part"
#SEG_PATH="${FS_PATH}/FS53/${SUBJECT_ID}/mri/wOnMNI_aparc.a2009s+aseg.nii.gz"
#CORTEX_LOI_and_ROI="/home/romain/cortex_LOI_and_ROI.txt" ; #Corticales
#LIST_OF_STRUCT="/home/romain/ListOfStruct.txt"; #Sous-corticales
LIST_OF_STRUCT="/home/romain/ROI_and_LOI.txt" #total 164
#out_name ="Connectome_Struc_Voxel"
THRESHOLD=10

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo "Usage: GetVoxelConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
		echo "  -dti dti_DTI                 : Path to tracto splitted files (ex : FS_PATH/SUBJECT_ID/dti/whole_brain_10_2500000_part)"
		echo "  -seg seg_Dir                 : Path to parcelisation"
		echo "  -roi roi_Dir                 : Path txt file with structures to use"
		echo "  -threhold nb                 : Threshold on the length of fiber (default = 10)"
		echo "  -out outfile_name            : Full Name of the output file"
		echo "Usage: GetVoxelConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
		exit 1
		;;
	-dti)
		DTI_PATH=`expr $index + 1`
		eval DTI_PATH=\${$DTI_PATH}
		echo "DTI_PATH='${DTI_PATH}'"
		index=$[$index+1]
		;;
	-seg)
		SEG_PATH=`expr $index + 1`
		eval SEG_PATH=\${$SEG_PATH}
		echo "SEG_PATH='${SEG_PATH}'"
		index=$[$index+1]
		;;
	-roi)
		LIST_OF_STRUCT=`expr $index + 1`
		eval LIST_OF_STRUCT=\${$LIST_OF_STRUCT}
		echo "LIST_OF_STRUCT='${LIST_OF_STRUCT}'"
		index=$[$index+1]
		;;
	-out)
		OUT_NAME=`expr $index + 1`
		eval OUT_NAME=\${$OUT_NAME}
		echo "OUT_NAME=${OUT_NAME}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done

matlab -nodisplay <<EOF
getVoxelConnectivityMatrix('${DTI_PATH}','${SEG_PATH}','${OUT_NAME}','${LIST_OF_STRUCT}',0)
EOF


#équivalent à getVoxelConnectivityMatrix(
#[PATHSTR,NAME,EXT] = fileparts('${OUT_NAME}');
#%cd ${PATHSTR}
#ConnectomeVoxSsCor=sparse([]);
#filelist = dir(['${DTI_PATH}' '*.tck']);
#rep=fileparts('${DTI_PATH}');
#for cpt=1:length(filelist)
#	disp([rep '/' filelist(cpt).name]);
#	tmp = getVolumeConnectMatrix_VoxelLevel('${SEG_PATH}',[rep '/' filelist(cpt).name],'${LIST_OF_STRUCT}',${THRESHOLD});
#	ConnectomeVoxSsCor=cat(1,ConnectomeVoxSsCor,tmp); 
#end

#fid = fopen('${LIST_OF_STRUCT}', 'r');
#T = textscan(fid, '%d %s');
#LOI_nb = T{1};

#V = spm_vol('${SEG_PATH}');
#[labels, XYZ] = spm_read_vols(V);
#labels = round(labels);
#ConnectomeVoxSsCor=spones(ConnectomeVoxSsCor);
#ConnectomeVoxSsCor=ConnectomeVoxSsCor(:,find(ismember(labels,LOI_nb)));
#connectomeVox=ConnectomeVoxSsCor'*ConnectomeVoxSsCor;

#Mask = logical(connectomeVox);
#Mask = triu(Mask, 1);
#Mat = Mask .* connectomeVox;
#clear Mask;

#disp('Save data...');
#save "/NAS/dumbo/HBC/Freesurfer5.0/100408/connectome/testRV_toDelete" Mat -v7.3;
#save('${OUT_NAME}', 'Mat', '-v7.3');





#%save Connectome_Struc_Voxel_SsCor ConnectomeVoxSsCor -v7.3;
#%ConnectomeVoxCor=sparse([]);
#%for cpt=1:length(filelist)
#%	tmp = getVolumeConnectMatrix_VoxelLevel('${SEG_PATH}',filelist(i),'${CORTEX_LOI_and_ROI}',10);
#%	ConnectomeVoxCor=cat(1,ConnectomeVoxCor,tmp); 
#%end

#%fid = fopen('${CORTEX_LOI_and_ROI}', 'r');
#%T = textscan(fid, '%d %s');
#%LOI_nb = T{1};
#%ConnectomeVoxCor=spones(ConnectomeVoxCor);
#%ConnectomeVoxCor=ConnectomeVoxCor(:,find(ismember(labels,LOI_nb)));
#%save Connectome_Struc_Voxel_Cor ConnectomeVoxCor -v7.3;

#%incidenceVox=[ConnectomeVoxCor ConnectomeVoxSsCor];
#%connectomeVox=incidenceVox'*incidenceVox;
#
