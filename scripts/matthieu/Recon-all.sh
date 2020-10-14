#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Recon-all.sh -sd <SubjDir> -subjid <SubjectId> -i <InputDir> -v <FSVersion>"
	echo ""
	echo "  -sd 	: Path to FS output directory"
	echo " 	-subjid	: Subject ID"
	echo "  -i	: Path to input directory containing 3DT1.nii"
	echo "  -v	: Version of FS used"
	echo ""
	echo "Usage: Recon-all.sh -sd <SubjDir> -subjid <SubjectId> -i <InputDir> -v <FSVersion>"
	echo ""
	exit 1
fi

index=1
ADD_INPUT_DIR=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Recon-all.sh -sd <SubjDir> -subjid <SubjectId> -i <InputDir> -v <FSVersion>"
		echo ""
		echo "  -sd 	: Path to FS output directory"
		echo " 	-subjid	: Subject ID"
		echo "  -i	: Path to input directory containing 3DT1.nii"
		echo "  -v	: Version of FS used"
		echo ""
		echo "Usage: Recon-all.sh -sd <SubjDir> -subjid <SubjectId> -i <InputDir> -v <FSVersion>"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "FS output directory : ${SUBJECTS_DIR}"
		;;
	-subjid)
		index=$[$index+1]
		eval SUBJECT_ID=\${$index}
		echo "Subject ID : ${SUBJECT_ID}"
		;;
	-i)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Path to input directory containing 3DT1.nii : ${INPUT_DIR}"
		;;
	-v)
		index=$[$index+1]
		eval FS_VERSION=\${$index}
		echo "Version of FS used : ${FS_VERSION}"
		;;

	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Recon-all.sh -sd <SubjDir> -subjid <SubjectId> -i <InputDir> -v <FSVersion>"
		echo ""
		echo "  -sd 	: Path to FS output directory"
		echo " 	-subjid	: Subject ID"
		echo "  -i	: Path to input directory containing 3DT1.nii"
		echo "  -v	: Version of FS used"
		echo ""
		echo "Usage: Recon-all.sh -sd <SubjDir> -subjid <SubjectId> -i <InputDir> -v <FSVersion>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
elif [ -z ${INPUT_DIR} ]
then
	 echo "-i argument mandatory"
	 exit 1
elif [ -z ${SUBJECT_ID} ]
then
	 echo "-subjid argument mandatory"
	 exit 1
elif [ -z ${FS_VERSION} ]
then
	 echo "-v argument mandatory"
	 exit 1
fi

# Choice of FS version
if [ "${FS_VERSION}" == "5.1" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.1/
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "5.3_3T" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "5.3_1.5T" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "5.3_edit" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "6b" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer6_b/
	export FSFAST_HOME=${Soft_dir}/freesurfer6_b/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer6_b/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "6_3T" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer6_0/
	export FSFAST_HOME=${Soft_dir}/freesurfer6_0/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer6_0/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
fi

# Launch recon-all FS command
# Skip the automatic failure detection of Talairach alignment : -notal-check
# Recon-all without gca-atlas or atlas: -no-wsgcaatlas or -no-wsatlas
# Brainstem Substructures : -brainstem-structures
# Segmentation of hippocampal subfields : -hippocampal-subfields-T1
# Relancer le recon-all après réduction des débordements de la GM sur le brainsmask : recon-all -s <subject> -autorecon-pial
# Relancer le recon-all après tuning des paramètres watershed (skull-stripping) : recon-all -skullstrip -wsthresh 35 -clean-bm -no-wsgcaatlas -subjid skullstrip1_before
# Relancer le recon-all après l'ajout de point de contrôle pour corriger les problèmes d'intensités normalisées : recon-all -s <subject> -autorecon2-cp -autorecon3
# Relancer le recon-all après édition de la WM (fill/erase): recon-all -autorecon2-wm -autorecon3 -s <subject>
# Relancer le recon-all si interrompu en cours de route mais -i input déjà traitée : supprimer l'option -i

if [ "${FS_VERSION}" == "5.3_3T" ]
then
	# recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -i ${INPUT_DIR}/2*MPRAGE1x1x1mmiPAT*.nii.gz
	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -i ${INPUT_DIR}/2*3DT1ISO1mm*.nii.gz
	# recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T
# # 	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -i ${INPUT_DIR}/2*WIPs3DT1YEUXFERMES*.nii.gz
# 	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -i ${INPUT_DIR}/2*[0-9]s3DT1*.nii.gz
# 	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -i ${INPUT_DIR}/t1.nii.gz
# 	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -make all
	recon-all -qcache -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -no-isrunning
elif [ "${FS_VERSION}" == "5.3_1.5T" ]
then
	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/MNI152_T1_2mm.nii.gz
	recon-all -qcache -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -no-isrunning
elif [ "${FS_VERSION}" == "6b" ]
then
# 	recon-all -all -notal-check -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -brainstem-structures -hippocampal-subfields-T1 -nuintensitycor-3T -i ${INPUT_DIR}/3DT1.nii.gz
	recon-all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -brainstem-structures
# 	recon-all -qcache -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -no-isrunning
elif [ "${FS_VERSION}" == "6_3T" ]
then
# 	-T2 /path/to/T2_volume -T2pial -FLAIR ${INPUT_DIR}/sub-*_FLAIR.nii.gz -FLAIRpial
	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -bigventricles -i ${INPUT_DIR}/3DT1.nii.gz -openmp 7
# 	recon-all -all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -nuintensitycor-3T -bigventricles -i ${INPUT_DIR}/sub-*_T1w.nii.gz -openmp 7
# 	recon-all -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -hippocampal-subfields-T1
# 	recon-all -qcache -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -no-isrunning
# 	# Use of gcut to remove any extra dura that could influence the surfaces
# 	recon-all -skullstrip -clean-bm -gcut -subjid ${SUBJECT_ID}
# 	# Regenerate Freesurfer output based on the new brainmask.mgz
# 	recon-all -s ${SUBJECT_ID} -autorecon-pial
elif [ "${FS_VERSION}" == "5.3_edit" ]
then
	# 1. Relaunch cortical reconstruction based on editing made
	# # Relancer le recon-all après réduction des débordements de la GM sur le brainsmask
	# recon-all -s ${SUBJECT_ID} -autorecon-pial -no-isrunning
	# # Relancer le recon-all après tuning des paramètres watershed (skull-stripping)
	# recon-all -skullstrip -wsthresh 35 -clean-bm -no-wsgcaatlas -subjid ${SUBJECT_ID}
	# # Relancer le recon-all après l'ajout de point de contrôle pour corriger les problèmes d'intensités normalisées (wm < 110)
	# recon-all -s ${SUBJECT_ID} -autorecon2-cp -autorecon3 -no-isrunning
	# # Relancer le recon-all après édition de la WM (fill/erase)
	# recon-all -autorecon2-wm -autorecon3 -s ${SUBJECT_ID} -no-isrunning
	# # Cannot remember which command to run, use the -make flag
	# recon-all -s ${SUBJECT_ID} -make all -no-isrunning
 	# corrected several types of errors
	recon-all -all -s ${SUBJECT_ID} -no-isrunning

	# # 2. Relaunch qcache processing
	# recon-all -qcache -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -no-isrunning
fi
