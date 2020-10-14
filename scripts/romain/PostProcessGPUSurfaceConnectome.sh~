#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: PostProcessSurfaceConnectome.sh  -fs <FS_dir>  -subj <subj>  -mat_name <mat_name_pattern>"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subject ID"
	echo "  -mat_name <mat_name_pattern>       : Prefix of the .mat files"
	echo "                                      For example set whole_brain_6_1500000 if files"
	echo "                                      whole_brain_6_1500000_part000001.mat whole_brain_6_1500000_part000002.mat ..."
	echo "                                      were generated using the script getSurfaceConnectome.sh"
	echo "                                      The final output will be stored as MAT_NAME_PATTERN.mat in FS/SUBJ/dti"
	echo " "
	echo "Usage: PostProcessSurfaceConnectome.sh  -fs <FS_dir>  -subj <subj>  -mat_name <mat_name_pattern>"
	echo ""
	exit 1
fi


index=1
bsthre=9
nlin=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PostProcessSurfaceConnectome.sh  -fs <FS_dir>  -subj <subj>  -mat_name <mat_name_pattern>"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subject ID"
		echo "  -mat_name <mat_name_pattern>       : Prefix of the .mat files"
		echo "                                      For example set whole_brain_6_1500000 if files"
		echo "                                      whole_brain_6_1500000_part000001.mat whole_brain_6_1500000_part000002.mat ..."
		echo "                                      were generated using the script getSurfaceConnectome.sh"
		echo "                                      The final output will be stored as MAT_NAME_PATTERN.mat in FS/SUBJ/dti"
		echo " "
		echo "Usage: PostProcessSurfaceConnectome.sh  -fs <FS_dir>  -subj <subj>  -mat_name <mat_name_pattern>"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "FS_dir : $fs"
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "Subject : $subj"
		;;
	-mat_name)
		mat_name=`expr $index + 1`
		eval mat_name=\${$mat_name}
		echo "Mat prefix : $mat_name"
		;;
	esac
	index=$[$index+1]
done

matlab -nodisplay <<EOF
cd ${fs}/${subj}/dti
List = rdir('${mat_name}_part*mat');

ConnectomeF=[];

for ii = 1 : length(List)
	load(char(List(ii).name));
	ConnectomeF=[ConnectomeF;Connectome];
	clear Connectome;
end

Connectome = ConnectomeF;
clear ConnectomeF;
save('${fs}/${subj}/dti/${mat_name}.mat', 'Connectome');

EOF


