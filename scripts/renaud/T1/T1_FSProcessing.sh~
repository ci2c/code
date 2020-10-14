#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: T1_FSProcessing.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  -t1brain <t1_brain>  [-t2 <t2_image>  -flair <flair_image>  -seed <value> ]  "
	echo ""
	echo "  -sd                         : SUBJECTS_DIR folder "
	echo "  -subj                       : Subject id "
	echo "  -t1                         : t1 image (path/.nii.gz) "
	echo "  -t1brain                    : t1 brain image (path/.nii.gz) "
	echo ""
	echo "Options "
	echo "  -t2                         : t2 image (path/.nii.gz) "
	echo "  -flair                      : flair image (path/.nii.gz) "
	echo "  -seed                       : fix the random seed generator"
	echo ""
	echo "Usage: T1_FSProcessing.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  -t1brain <t1_brain>  [-t2 <t2_image>  -flair <flair_image>  -seed <value> ] "
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

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: T1_FSProcessing.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  -t1brain <t1_brain>  [-t2 <t2_image>  -flair <flair_image>  -seed <value> ]  "
		echo ""
		echo "  -sd                         : SUBJECTS_DIR folder "
		echo "  -subj                       : Subject id "
		echo "  -t1                         : t1 image (path/.nii.gz) "
		echo "  -t1brain                    : t1 brain image (path/.nii.gz) "
		echo ""
		echo "Options "
		echo "  -t2                         : t2 image (path/.nii.gz) "
		echo "  -flair                      : flair image (path/.nii.gz) "
		echo "  -seed                       : fix the random seed generator"
		echo ""
		echo "Usage: T1_FSProcessing.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  -t1brain <t1_brain>  [-t2 <t2_image>  -flair <flair_image>  -seed <value> ] "
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
	-t1brain)
		index=$[$index+1]
		eval T1wImageBrain=\${$index}
		echo "T1w brain image : ${T1wImageBrain}"
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
	-seed)
		index=$[$index+1]
		eval recon_all_seed=\${$index}
		echo "random seed : ${recon_all_seed}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: T1_FSProcessing.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  -t1brain <t1_brain>  [-t2 <t2_image>  -flair <flair_image>  -seed <value> ]  "
		echo ""
		echo "  -sd                         : SUBJECTS_DIR folder "
		echo "  -subj                       : Subject id "
		echo "  -t1                         : t1 image (path/.nii.gz) "
		echo "  -t1brain                    : t1 brain image (path/.nii.gz) "
		echo ""
		echo "Options "
		echo "  -t2                         : t2 image (path/.nii.gz) "
		echo "  -flair                      : flair image (path/.nii.gz) "
		echo "  -seed                       : fix the random seed generator"
		echo ""
		echo "Usage: T1_FSProcessing.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  -t1brain <t1_brain>  [-t2 <t2_image>  -flair <flair_image>  -seed <value> ] "
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
echo -e "\n START: T1_FSProcessing.sh"
echo ""

# ------------------------------------------------------------------------------
#  Show Environment Variables
# ------------------------------------------------------------------------------

echo ""
echo -e "\n FSLDIR: ${FSLDIR}"
echo -e "\n FreeSurfer: $FREESURFER_HOME"
echo -e "\n HCPPIPEDIR: ${HCPPIPEDIR}"
echo -e "\n HCPPIPEDIR_Global: ${HCPPIPEDIR_Global}"


# ------------------------------------------------------------------------------
#  CONFIG
# ------------------------------------------------------------------------------

# Compress if not
filename=$(basename "$T1wInputImage")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wInputImage; T1wInputImage=${T1wInputImage}.gz; fi
filename=$(basename "$T1wImageBrain")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wImageBrain; T1wImageBrain=${T1wImageBrain}.gz; fi

if [ $T2wInputImage != "NONE" ] ; then 
	filename=$(basename "$T2wInputImage")
	extension="${filename##*.}"
	if [ "${extension}" == "nii" ]; then gzip -f $T2wInputImage; T2wInputImage=${T2wInputImage}.gz; fi
fi
if [ $FlairInputImage != "NONE" ] ; then 
	filename=$(basename "$FlairInputImage")
	extension="${filename##*.}"
	if [ "${extension}" == "nii" ]; then gzip -f $FlairInputImage; FlairInputImage=${FlairInputImage}.gz; fi
fi


# Create SUBJECTS_DIR folder
echo -e "\n Create SUBJECTS_DIR folder"
if [ ! -d ${StudyFolder} ]; then mkdir ${StudyFolder}; fi

# Figure out whether to include a random seed generator seed in all the recon-all command lines
seed_cmd_appendix=""
if [ -z "${recon_all_seed}" ] ; then
	seed_cmd_appendix=""
else
	seed_cmd_appendix="-norandomness -rng-seed ${recon_all_seed}"
fi
echo -e "\n seed_cmd_appendix: ${seed_cmd_appendix}"


# ------------------------------------------------------------------------------
#  PROCESSING
# ------------------------------------------------------------------------------

echo -e "\n"
echo -e "\n FreeSurfer Processing"
echo -e "\n"

T1wImageFile=`remove_ext $T1wInputImage`;
T1wImageBrainFile=`remove_ext $T1wImageBrain`;

echo -e "\n T1wImageFile: ${T1wImageFile}"
echo -e "\n T1wImageBrainFile: ${T1wImageBrainFile}"
echo -e "\n"

#Make Spline Interpolated Downsample to 1mm
echo -e "\n Make Spline Interpolated Downsample to 1mm"

Mean=`fslstats $T1wImageBrain -M`
echo -e "\n flirt -interp spline -in ${T1wInputImage} -ref ${T1wInputImage} -applyisoxfm 1 -out ${T1wImageFile}_1mm.nii.gz"
flirt -interp spline -in ${T1wInputImage} -ref ${T1wInputImage} -applyisoxfm 1 -out ${T1wImageFile}_1mm.nii.gz
echo -e "\n applywarp --rel --interp=spline -i ${T1wInputImage} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageFile}_1mm.nii.gz"
applywarp --rel --interp=spline -i ${T1wInputImage} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageFile}_1mm.nii.gz
echo -e "\n applywarp --rel --interp=nn -i ${T1wImageBrain} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageBrainFile}_1mm.nii.gz"
applywarp --rel --interp=nn -i ${T1wImageBrain} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageBrainFile}_1mm.nii.gz
echo -e "\n fslmaths ${T1wImageFile}_1mm.nii.gz -div $Mean -mul 150 -abs ${T1wImageFile}_1mm.nii.gz"
fslmaths ${T1wImageFile}_1mm.nii.gz -div $Mean -mul 150 -abs ${T1wImageFile}_1mm.nii.gz

#Initial Recon-all Steps
echo -e "\n"
echo -e "\n Initial Recon-all Steps"

# Call recon-all with flags that are part of "-autorecon1", with the exception of -skullstrip.
# -skullstrip of FreeSurfer not reliable for Phase II data because of poor FreeSurfer mri_em_register registrations with Skull on, 
# so run registration with PreFreeSurfer masked data and then generate brain mask as usual.
echo -e "\n recon-all -i ${T1wImageFile}_1mm.nii.gz -subjid $Subject -sd $StudyFolder -motioncor -talairach -nuintensitycor -normalization ${seed_cmd_appendix}"
recon-all -i ${T1wImageFile}_1mm.nii.gz -subjid $Subject -sd $StudyFolder -motioncor -talairach -nuintensitycor -normalization ${seed_cmd_appendix}

# Generate brain mask
mri_convert ${T1wImageBrainFile}_1mm.nii.gz ${StudyFolder}/${Subject}/mri/brainmask.mgz --conform
mri_em_register -mask ${StudyFolder}/${Subject}/mri/brainmask.mgz ${StudyFolder}/${Subject}/mri/nu.mgz $FREESURFER_HOME/average/RB_all_2008-03-26.gca ${StudyFolder}/${Subject}/mri/transforms/talairach_with_skull.lta
mri_watershed -T1 -brain_atlas $FREESURFER_HOME/average/RB_all_withskull_2008-03-26.gca ${StudyFolder}/${Subject}/mri/transforms/talairach_with_skull.lta ${StudyFolder}/${Subject}/mri/T1.mgz ${StudyFolder}/${Subject}/mri/brainmask.auto.mgz 
cp ${StudyFolder}/${Subject}/mri/brainmask.auto.mgz ${StudyFolder}/${Subject}/mri/brainmask.mgz


# Last recon-all Steps
if [ $T2wInputImage != "NONE" ] ; then 

	echo -e "\n"
	echo -e "\n Use of T2w"
	echo -e "\n"	

	echo -e "\n recon-all -sd ${StudyFolder} -subjid ${Subject} -autorecon2 -autorecon3 -T2 ${T2wInputImage} -T2pial ${seed_cmd_appendix}"
	recon-all -sd ${StudyFolder} -subjid ${Subject} -autorecon2 -autorecon3 -T2 ${T2wInputImage} -T2pial ${seed_cmd_appendix}

	
elif [ $FlairInputImage != "NONE" ] ; then

	echo -e "\n"
	echo -e "\n Use of Flair"
	echo -e "\n"

	# Last recon-all Steps
	echo -e "\n recon-all -sd ${StudyFolder} -subjid ${Subject} -autorecon2 -autorecon3 -FLAIR ${FlairInputImage} -FLAIRpial ${seed_cmd_appendix}"
	recon-all -sd ${StudyFolder} -subjid ${Subject} -autorecon2 -autorecon3 -FLAIR ${FlairInputImage} -FLAIRpial ${seed_cmd_appendix}

else

	echo -e "\n"
	echo -e "\n Don't use T2w or Flair"
	echo -e "\n"

	# Last recon-all Steps
	echo -e "\n recon-all -sd ${StudyFolder} -subjid ${Subject} -autorecon2 -autorecon3 ${seed_cmd_appendix}"
	recon-all -sd ${StudyFolder} -subjid ${Subject} -autorecon2 -autorecon3 ${seed_cmd_appendix}

fi

if [ ! -f ${StudyFolder}/${Subject}/mri/transforms/eye.dat ]; then

	if [ ! -d ${StudyFolder}/${Subject}/mri/transforms ]; then mkdir ${StudyFolder}/${Subject}/mri/transforms; fi
	echo ${Subject} > ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "1" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "1" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "1" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "1 0 0 0" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "0 1 0 0" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "0 0 1 0" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "0 0 0 1" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat
	echo "round" >> ${StudyFolder}/${Subject}/mri/transforms/eye.dat

fi

