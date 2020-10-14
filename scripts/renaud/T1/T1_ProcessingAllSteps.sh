#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: T1_ProcessingAllSteps.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ]  "
	echo ""
	echo "  -sd                         : SUBJECTS_DIR folder "
	echo "  -subj                       : Subject id "
	echo "  -t1                         : t1 image (path/.nii.gz) "
	echo ""
	echo "Options "
	echo "  -t2                         : t2 image (path/.nii.gz) "
	echo "  -flair                      : flair image (path/.nii.gz) "
	echo "  -qc                         : quality control folder (Default: NONE)"
	echo ""
	echo "Usage: T1_ProcessingAllSteps.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ] "
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
T2wInputImage="NONE"
FlairInputImage="NONE"
QCfolder="NONE"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: T1_ProcessingAllSteps.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ]  "
		echo ""
		echo "  -sd                         : SUBJECTS_DIR folder "
		echo "  -subj                       : Subject id "
		echo "  -t1                         : t1 image (path/.nii.gz) "
		echo ""
		echo "Options "
		echo "  -t2                         : t2 image (path/.nii.gz) "
		echo "  -flair                      : flair image (path/.nii.gz) "
		echo "  -qc                         : quality control folder (Default: NONE)"
		echo ""
		echo "Usage: T1_ProcessingAllSteps.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ] "
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
	-t1)
		index=$[$index+1]
		eval T1wInputImage=\${$index}
		echo "T1w image : ${T1wInputImage}"
		;;
	-t2)
		index=$[$index+1]
		eval T2wInputImage=\${$index}
		echo "T2w image : ${T2wInputImage}"
		;;
	-flair)
		index=$[$index+1]
		eval FlairInputImage=\${$index}
		echo "Flair image : ${FlairInputImage}"
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
		echo "Usage: T1_ProcessingAllSteps.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ]  "
		echo ""
		echo "  -sd                         : SUBJECTS_DIR folder "
		echo "  -subj                       : Subject id "
		echo "  -t1                         : t1 image (path/.nii.gz) "
		echo ""
		echo "Options "
		echo "  -t2                         : t2 image (path/.nii.gz) "
		echo "  -flair                      : flair image (path/.nii.gz) "
		echo "  -qc                         : quality control folder (Default: NONE)"
		echo ""
		echo "Usage: T1_ProcessingAllSteps.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${T1wInputImage} ]
then
	 echo "-t1 argument mandatory"
	 exit 1
fi

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



echo ""
echo "START: T1_ProcessingAllSteps.sh"
echo ""


# ------------------------------------------------------------------------------
#  Show Environment Variables
# ------------------------------------------------------------------------------

echo ""
echo "FSLDIR: ${FSLDIR}"
echo "HCPPIPEDIR: ${HCPPIPEDIR}"
echo "HCPPIPEDIR_Global: ${HCPPIPEDIR_Global}"
echo "HCPPIPEDIR_PreFS: ${HCPPIPEDIR_PreFS}"
echo ""


# ------------------------------------------------------------------------------
#  Preprocessing
# ------------------------------------------------------------------------------

echo ""
echo "Preprocessing"
echo ""
echo "T1_Preprocessing.sh -sd ${StudyFolder} -subj ${Subject} -t1 ${T1wInputImage} -t2 ${T2wInputImage} -flair ${FlairInputImage} -qc ${QCFOLDER}"
T1_Preprocessing.sh -sd ${StudyFolder} -subj ${Subject} -t1 ${T1wInputImage} -t2 ${T2wInputImage} -flair ${FlairInputImage} -qc ${QCFOLDER}


# ------------------------------------------------------------------------------
#  FreeSurfer
# ------------------------------------------------------------------------------

echo ""
echo ""
echo "FreeSurfer"
echo ""

if [ $T2wInputImage != "NONE" ] ; then

	T1=${StudyFolder}/${Subject}/T1w/T1w_acpc_restore.nii.gz
	t1brain=${StudyFolder}/${Subject}/T1w/T1w_acpc_restore_brain.nii.gz
	T2=${StudyFolder}/${Subject}/T1w/T2w_acpc_restore.nii.gz
	echo "T1_FSProcessing.sh -sd ${StudyFolder}/${Subject}/T1w -subj ${Subject} -t1 ${T1} -t1brain ${t1brain} -t2 ${T2}"
	T1_FSProcessing.sh -sd ${StudyFolder}/${Subject}/T1w -subj ${Subject} -t1 ${T1} -t1brain ${t1brain} -t2 ${T2}

elif [ $FlairInputImage != "NONE" ] ; then

	T1=${StudyFolder}/${Subject}/T1w/T1w_acpc.nii.gz
	t1brain=${StudyFolder}/${Subject}/T1w/T1w_acpc_brain.nii.gz
	FLAIR=${StudyFolder}/${Subject}/T1w/Flair_acpc.nii.gz
	echo "T1_FSProcessing.sh -sd ${StudyFolder}/${Subject}/T1w -subj ${Subject} -t1 ${T1} -t1brain ${t1brain} -flair ${FLAIR}"
	T1_FSProcessing.sh -sd ${StudyFolder}/${Subject}/T1w -subj ${Subject} -t1 ${T1} -t1brain ${t1brain} -flair ${FLAIR}

else

	T1=${StudyFolder}/${Subject}/T1w/T1w_acpc.nii.gz
	t1brain=${StudyFolder}/${Subject}/T1w/T1w_acpc_brain.nii.gz
	echo "T1_FSProcessing.sh -sd ${StudyFolder}/${Subject}/T1w -subj ${Subject} -t1 ${T1} -t1brain ${t1brain}"
	T1_FSProcessing.sh -sd ${StudyFolder}/${Subject}/T1w -subj ${Subject} -t1 ${T1} -t1brain ${t1brain}

fi



# ------------------------------------------------------------------------------
#  Postprocessing
# ------------------------------------------------------------------------------


echo ""
echo ""
echo "Post-processing"
echo ""

if [ $T2wInputImage != "NONE" ] ; then

	echo "T1_Postrocessing.sh -sd ${StudyFolder} -subj ${Subject} -t2"
	T1_Postprocessing.sh -sd ${StudyFolder} -subj ${Subject} -t2

elif [ $FlairInputImage != "NONE" ] ; then

	echo "T1_Postrocessing.sh -sd ${StudyFolder} -subj ${Subject} -flair"
	T1_Postprocessing.sh -sd ${StudyFolder} -subj ${Subject} -flair

else

	echo "T1_Postrocessing.sh -sd ${StudyFolder} -subj ${Subject}"
	T1_Postprocessing.sh -sd ${StudyFolder} -subj ${Subject}

fi


