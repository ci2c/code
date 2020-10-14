#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: T1_Postprocessing.sh  -sd <subjects_dir>  -subj <subject>  [-t2  -flair  -qc <folder> ]  "
	echo ""
	echo "  -sd                         : SUBJECTS_DIR folder "
	echo "  -subj                       : Subject id "
	echo ""
	echo "Options "
	echo "  -t2                         : use t2 "
	echo "  -flair                      : use flair "
	echo "  -qc                         : quality control folder (Default: NONE)"
	echo ""
	echo "Usage: T1_Postprocessing.sh  -sd <subjects_dir>  -subj <subject>  [-t2  -flair  -qc <folder> ] "
	echo ""
	exit 1
fi

USER=`whoami`

# ------------------------------------------------------------------------------
#  Load Function Libraries
# ------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions

HOME=/home/${USER}
index=1
useT2="NONE"
useFLAIR="NONE"
RegName="FS"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: T1_Postprocessing.sh  -sd <subjects_dir>  -subj <subject>  [-t2  -flair  -qc <folder> ]  "
		echo ""
		echo "  -sd                         : SUBJECTS_DIR folder "
		echo "  -subj                       : Subject id "
		echo ""
		echo "Options "
		echo "  -t2                         : use t2 "
		echo "  -flair                      : use flair "
		echo "  -qc                         : quality control folder (Default: NONE)"
		echo ""
		echo "Usage: T1_Postprocessing.sh  -sd <subjects_dir>  -subj <subject>  [-t2  -flair  -qc <folder> ] "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval StudyFolder=\${$index}
		echo "SUBJECTS_DIR folder : ${StudyFolder}"
		;;
	-subj)
		index=$[$index+1]
		eval Subject=\${$index}
		echo "Subject id : ${Subject}"
		;;
	-t2)
		useT2="TRUE"
		echo "use of T2"
		;;
	-flair)
		useFLAIR="TRUE"
		echo "use of FLAIR"
		;;
	-qc)
		index=$[$index+1]
		eval QCfolder=\${$index}
		echo "QC folder : ${QCfolder}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: T1_Postprocessing.sh  -sd <subjects_dir>  -subj <subject>  [-t2  -flair  -qc <folder> ]  "
		echo ""
		echo "  -sd                         : SUBJECTS_DIR folder "
		echo "  -subj                       : Subject id "
		echo ""
		echo "Options "
		echo "  -t2                         : use t2 "
		echo "  -flair                      : use flair "
		echo "  -qc                         : quality control folder (Default: NONE)"
		echo ""
		echo "Usage: T1_Postprocessing.sh  -sd <subjects_dir>  -subj <subject>  [-t2  -flair  -qc <folder> ] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments

if [ -z ${StudyFolder} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${Subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi


# ------------------------------------------------------------------------------
#  Conversion of FreeSurfer Volumes and Surfaces to NIFTI and GIFTI and 
#  Create Caret Files and Registration
# ------------------------------------------------------------------------------

echo -e "\n"
echo -e "\n Conversion of FreeSurfer Volumes and Surfaces to NIFTI and GIFTI and Create Caret Files and Registration"
echo -e "\n"

if [ $useT2 != "NONE" ] ; then

	echo -e "\n"
	echo -e "\n Use of T2"

	T1wInputImage="T1w_acpc_restore"
	T2wInputImage="T2w_acpc_restore"
	AtlasSpaceT1wImage="T1w_acpc_restore"
	AtlasSpaceT2wImage="T2w_acpc_restore"

	T1_FS2CaretWithT2.sh  \
		-sd ${StudyFolder} \
		-subj ${Subject} \
		-t1 ${T1wInputImage} \
		-t2 ${T2wInputImage} \
		-atlast1 ${AtlasSpaceT1wImage} \
		-atlast2 ${AtlasSpaceT2wImage}


elif [ $useFLAIR != "NONE" ] ; then

	echo -e "\n"
	echo -e "\n Use of FLAIR"

	T1wInputImage="T1w_acpc"
	FlairInputImage="Flair_acpc"
	AtlasSpaceT1wImage="T1w_acpc"
	AtlasSpaceFlairImage="Flair_acpc"

	T1_FS2CaretWithT2.sh  \
		-sd ${StudyFolder} \
		-subj ${Subject} \
		-t1 ${T1wInputImage} \
		-t2 ${FlairInputImage} \
		-atlast1 ${AtlasSpaceT1wImage} \
		-atlast2 ${AtlasSpaceFlairImage}


else

	echo -e "\n"
	echo -e "\n Only use T1"

	T1wInputImage="T1w_acpc"
	AtlasSpaceT1wImage="T1w_acpc"

	T1_FS2CaretWithoutT2.sh  \
		-sd ${StudyFolder} \
		-subj ${Subject} \
		-t1 ${T1wInputImage} \
		-atlast1 ${AtlasSpaceT1wImage}
	

fi


# ------------------------------------------------------------------------------
#  Create Ribbon
# ------------------------------------------------------------------------------

echo -e "\n"
echo -e "\n START: Create Ribbon"
echo -e "\n"

T1wFolder=${StudyFolder}/${Subject}/T1w
echo "T1wFolder: ${T1wFolder}"

AtlasSpaceFolder=${StudyFolder}/${Subject}/MNINonLinear
echo "AtlasSpaceFolder: ${AtlasSpaceFolder}"

NativeFolder="Native"
echo "NativeFolder: ${NativeFolder}"

FreeSurferLabels="${HCPPIPEDIR_Config}/FreeSurferAllLut.txt"
echo "FreeSurferLabels: ${FreeSurferLabels}"

echo "${HCPPIPEDIR_PostFS}/CreateRibbon.sh ${StudyFolder} ${Subject} ${T1wFolder} ${AtlasSpaceFolder} ${NativeFolder} ${AtlasSpaceT1wImage} ${T1wInputImage} ${FreeSurferLabels}"
${HCPPIPEDIR_PostFS}/CreateRibbon.sh \
	${StudyFolder} \
	${Subject} \
	${T1wFolder} \
	${AtlasSpaceFolder} \
	${NativeFolder} \
	${AtlasSpaceT1wImage} \
	${T1wInputImage} \
	${FreeSurferLabels}

echo -e "\n"
echo -e "\n END: Create Ribbon"
echo -e "\n"


# ------------------------------------------------------------------------------
#  Myelin mapping
# ------------------------------------------------------------------------------

if [ $useT2 != "NONE" ] ; then

	echo -e "\n"
	echo -e "\n START: Create Ribbon"
	echo -e "\n"

	HighResMesh="164" #Usually 164k vertices
  	LowResMeshes="32" #Usually 32k vertices, if multiple delimit with @, must already exist in templates dir
	OrginalT1wImage="T1w"
	OrginalT2wImage="T2w"
	T2wFolder=${StudyFolder}/${Subject}/T2w
	T1wImageBrainMask="brainmask_fs"
	InitialT1wTransform="acpc.mat"
	dcT1wTransform="T1w.nii.gz"
	InitialT2wTransform="acpc.mat"
	dcT2wTransform="T2w_reg.nii.gz"
	FinalT2wTransform="${StudyFolder}/${Subject}/T2w/T2wToT1wReg/T2w2T1w.mat"
	AtlasTransform="$AtlasSpaceFolder"/xfms/"acpc_dc2standard"
	BiasField="BiasField_acpc"
	OutputT1wImage="T1w_acpc"
	OutputT1wImageRestore="T1w_acpc_restore"
	OutputT1wImageRestoreBrain="T1w_acpc_restore_brain"
	OutputMNIT1wImage="T1w"
	OutputMNIT1wImageRestore="T1w_restore"
	OutputMNIT1wImageRestoreBrain="T1w_restore_brain"
	OutputT2wImage="T2w_acpc"
	OutputT2wImageRestore="T2w_acpc_restore"
	OutputT2wImageRestoreBrain="T2w_acpc_restore_brain"
	OutputMNIT2wImage="T2w"
	OutputMNIT2wImageRestore="T2w_restore"
	OutputMNIT2wImageRestoreBrain="T2w_restore_brain"
	OutputOrigT1wToT1w="OrigT1w2T1w.nii.gz"
	OutputOrigT1wToStandard="OrigT1w2standard.nii.gz" #File was OrigT2w2standard.nii.gz, regnerate and apply matrix
	OutputOrigT2wToT1w="OrigT2w2T1w.nii.gz" #mv OrigT1w2T2w.nii.gz OrigT2w2T1w.nii.gz
	OutputOrigT2wToStandard="OrigT2w2standard.nii.gz"
	BiasFieldOutput="BiasField"
	Jacobian="NonlinearRegJacobians.nii.gz"
	RegName="FS"
	ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii"
	CorrectionSigma=`opts_DefaultOpt $CorrectionSigma $(echo "sqrt ( 200 )" | bc -l)`

	${HCPPIPEDIR_PostFS}/CreateMyelinMaps.sh \
		${StudyFolder} \
		${Subject} \
		${AtlasSpaceFolder} \
		${NativeFolder} \
		${T1wFolder} \
		${HighResMesh} ${LowResMeshes} \
		${T1wFolder}/${OrginalT1wImage} ${T2wFolder}/${OrginalT2wImage} \
		${T1wFolder}/${T1wImageBrainMask} \
		"$T1wFolder"/xfms/"$InitialT1wTransform" "$T1wFolder"/xfms/"$dcT1wTransform" \
		"$T2wFolder"/xfms/"$InitialT2wTransform" "$T1wFolder"/xfms/"$dcT2wTransform" "$FinalT2wTransform" \
		"$AtlasTransform" "$T1wFolder"/"$BiasField" \
		"$T1wFolder"/"$OutputT1wImage" "$T1wFolder"/"$OutputT1wImageRestore" "$T1wFolder"/"$OutputT1wImageRestoreBrain" \
		"$AtlasSpaceFolder"/"$OutputMNIT1wImage" "$AtlasSpaceFolder"/"$OutputMNIT1wImageRestore" "$AtlasSpaceFolder"/"$OutputMNIT1wImageRestoreBrain" \
		"$T1wFolder"/"$OutputT2wImage" "$T1wFolder"/"$OutputT2wImageRestore" "$T1wFolder"/"$OutputT2wImageRestoreBrain" \
		"$AtlasSpaceFolder"/"$OutputMNIT2wImage" "$AtlasSpaceFolder"/"$OutputMNIT2wImageRestore" "$AtlasSpaceFolder"/"$OutputMNIT2wImageRestoreBrain" \
		"$T1wFolder"/xfms/"$OutputOrigT1wToT1w" "$T1wFolder"/xfms/"$OutputOrigT1wToStandard" \
		"$T1wFolder"/xfms/"$OutputOrigT2wToT1w" "$T1wFolder"/xfms/"$OutputOrigT2wToStandard" \
		"$AtlasSpaceFolder"/"$BiasFieldOutput" "$AtlasSpaceFolder"/"$T1wImageBrainMask" \
		"$AtlasSpaceFolder"/xfms/"$Jacobian" "$ReferenceMyelinMaps" "$CorrectionSigma" "$RegName"	

	echo -e "\n"
	echo -e "\n END: Create Ribbon"
	echo -e "\n"
fi

