#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: T1_ProcessingFSBased.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ]  "
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
	echo "Usage: T1_ProcessingFSBased.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ] "
	echo ""
	exit 1
fi

HOME=/home/${USER}
index=1
T2="NONE"
FLAIR="NONE"
QCfolder="NONE"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: T1_ProcessingFSBased.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ]  "
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
		echo "Usage: T1_ProcessingFSBased.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ] "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SubjFolder=\${$index}
		echo "SUBJECTS_DIR folder : ${SubjFolder}"
		;;
	-subj)
		index=$[$index+1]
		eval Subject=\${$index}
		echo "Subject id : ${Subject}"
		;;
	-t1)
		index=$[$index+1]
		eval T1=\${$index}
		echo "t1 image : ${T1}"
		;;
	-t2)
		index=$[$index+1]
		eval T2=\${$index}
		echo "t2 image : ${T2}"
		;;
	-flair)
		index=$[$index+1]
		eval FLAIR=\${$index}
		echo "flair image : ${FLAIR}"
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
		echo "Usage: T1_ProcessingFSBased.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ]  "
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
		echo "Usage: T1_ProcessingFSBased.sh  -sd <subjects_dir>  -subj <subject>  -t1 <t1_image>  [-t2 <t2_image>  -flair <flair_image>  -qc <folder> ] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${T1} ]
then
	 echo "-t1 argument mandatory"
	 exit 1
fi

if [ -z ${SubjFolder} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${Subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

# compress if not
filename=$(basename "$T1")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1; T1=${T1}.gz; fi

# Create SUBJECTS_DIR folder
echo "Create SUBJECTS_DIR folder"
if [ ! -d ${SubjFolder} ]; then mkdir ${SubjFolder}; fi

# Processing
echo -e "\n"
echo -e "\n Start..."
echo -e "\n"

# figure out whether to include a random seed generator seed in all the recon-all command lines
seed_cmd_appendix=""
if [ -z "${recon_all_seed}" ] ; then
	seed_cmd_appendix=""
else
	seed_cmd_appendix="-norandomness -rng-seed ${recon_all_seed}"
fi
echo -e "\n seed_cmd_appendix: ${seed_cmd_appendix}"


if [ ! $T2 = "NONE" ] ; then

	echo -e "\n"
	echo -e "\n Use of T2 image"

	# compress if not
	filename=$(basename "$T2")
	extension="${filename##*.}"
	if [ "${extension}" == "nii" ]; then gzip -f $T2; T2=${T2}.gz; fi

	echo -e "\n T1_HCP_PreFreeSurferPipeline.sh -path ${SubjFolder} -subject ${Subject} -t1 ${T1} -t2 ${T2}"
	T1_HCP_PreFreeSurferPipeline.sh -path ${SubjFolder} -subject ${Subject} -t1 ${T1} -t2 ${T2}

	T1wImage="${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
	T1wImageBrain="${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)
	T2wImage="${SubjFolder}/${Subject}/T1w/T2w_acpc_dc_restore.nii.gz" #T2w FreeSurfer Input (Full Resolution)

	T1wImageFile=`remove_ext $T1wImage`;
	T1wImageBrainFile=`remove_ext $T1wImageBrain`;

	SubjectDIR=${SubjFolder}/${Subject}/T1w
	SubjectID=${Subject}

	#Make Spline Interpolated Downsample to 1mm
	echo -e "\n Make Spline Interpolated Downsample to 1mm"

	Mean=`fslstats $T1wImageBrain -M`
	flirt -interp spline -in "$T1wImage" -ref "$T1wImage" -applyisoxfm 1 -out "$T1wImageFile"_1mm.nii.gz
	applywarp --rel --interp=spline -i "$T1wImage" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageFile"_1mm.nii.gz
	applywarp --rel --interp=nn -i "$T1wImageBrain" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageBrainFile"_1mm.nii.gz
	fslmaths "$T1wImageFile"_1mm.nii.gz -div $Mean -mul 150 -abs "$T1wImageFile"_1mm.nii.gz

	#Initial Recon-all Steps
	echo -e "\n Initial Recon-all Steps"

	# Call recon-all with flags that are part of "-autorecon1", with the exception of -skullstrip.
	# -skullstrip of FreeSurfer not reliable for Phase II data because of poor FreeSurfer mri_em_register registrations with Skull on, 
	# so run registration with PreFreeSurfer masked data and then generate brain mask as usual.
	recon-all -i "$T1wImageFile"_1mm.nii.gz -subjid $SubjectID -sd $SubjectDIR -motioncor -talairach -nuintensitycor -normalization ${seed_cmd_appendix}

	# Generate brain mask
	mri_convert "$T1wImageBrainFile"_1mm.nii.gz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz --conform
	mri_em_register -mask "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz "$SubjectDIR"/"$SubjectID"/mri/nu.mgz $FREESURFER_HOME/average/RB_all_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta
	mri_watershed -T1 -brain_atlas $FREESURFER_HOME/average/RB_all_withskull_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta "$SubjectDIR"/"$SubjectID"/mri/T1.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz 
	cp "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz

	# Last recon-all Steps
	echo -e "\n recon-all -sd "$SubjectDIR" -subjid "${SubjectID}" -autorecon2 -autorecon3 -T2 ${T2wImage} -T2pial ${seed_cmd_appendix}"
	recon-all -sd "$SubjectDIR" -subjid "${SubjectID}" -autorecon2 -autorecon3 -T2 ${T2wImage} -T2pial ${seed_cmd_appendix}

	echo "$SubjectID" > "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1 0 0 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 1 0 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 0 1 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 0 0 1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "round" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat

	echo -e "\n T1_HCP_PostFreeSurferPipeline.sh -StudyFolder ${SubjFolder} -Subjlist ${Subject} -runlocal -ist2"
	T1_HCP_PostFreeSurferPipeline.sh -StudyFolder ${SubjFolder} -Subjlist ${Subject} -runlocal -ist2


elif [ ! $FLAIR = "NONE" ] ; then

	echo -e "\n"
	echo -e "\n Use of FLAIR image"

	# compress if not
	filename=$(basename "$FLAIR")
	extension="${filename##*.}"
	if [ "${extension}" == "nii" ]; then gzip -f $FLAIR; FLAIR=${FLAIR}.gz; fi

	echo -e "\n T1_HCP_PreFreeSurferPipeline.sh -path ${SubjFolder} -subject ${Subject} -t1 ${T1} -t2 ${FLAIR}"
	T1_HCP_PreFreeSurferPipeline.sh -path ${SubjFolder} -subject ${Subject} -t1 ${T1} -t2 ${FLAIR}

	T1wImage="${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
	T1wImageBrain="${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)
	FLAIRImage="${SubjFolder}/${Subject}/T1w/T2w_acpc_dc_restore.nii.gz" #T2w FreeSurfer Input (Full Resolution)

	T1wImageFile=`remove_ext $T1wImage`;
	T1wImageBrainFile=`remove_ext $T1wImageBrain`;

	SubjectDIR=${SubjFolder}/${Subject}/T1w
	SubjectID=${Subject}

	#Make Spline Interpolated Downsample to 1mm
	echo -e "\n Make Spline Interpolated Downsample to 1mm"

	Mean=`fslstats $T1wImageBrain -M`
	flirt -interp spline -in "$T1wImage" -ref "$T1wImage" -applyisoxfm 1 -out "$T1wImageFile"_1mm.nii.gz
	applywarp --rel --interp=spline -i "$T1wImage" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageFile"_1mm.nii.gz
	applywarp --rel --interp=nn -i "$T1wImageBrain" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageBrainFile"_1mm.nii.gz
	fslmaths "$T1wImageFile"_1mm.nii.gz -div $Mean -mul 150 -abs "$T1wImageFile"_1mm.nii.gz

	#Initial Recon-all Steps
	echo -e "\n Initial Recon-all Steps"

	# Call recon-all with flags that are part of "-autorecon1", with the exception of -skullstrip.
	# -skullstrip of FreeSurfer not reliable for Phase II data because of poor FreeSurfer mri_em_register registrations with Skull on, 
	# so run registration with PreFreeSurfer masked data and then generate brain mask as usual.
	recon-all -i "$T1wImageFile"_1mm.nii.gz -subjid $SubjectID -sd $SubjectDIR -motioncor -talairach -nuintensitycor -normalization ${seed_cmd_appendix}

	# Generate brain mask
	mri_convert "$T1wImageBrainFile"_1mm.nii.gz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz --conform
	mri_em_register -mask "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz "$SubjectDIR"/"$SubjectID"/mri/nu.mgz $FREESURFER_HOME/average/RB_all_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta
	mri_watershed -T1 -brain_atlas $FREESURFER_HOME/average/RB_all_withskull_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta "$SubjectDIR"/"$SubjectID"/mri/T1.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz 
	cp "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz

	# Last recon-all Steps
	echo -e "\n recon-all -sd "$SubjectDIR" -subjid "${SubjectID}" -autorecon2 -autorecon3 -FLAIR ${FLAIRImage} -FLAIRpial ${seed_cmd_appendix}"
	recon-all -sd "$SubjectDIR" -subjid "${SubjectID}" -autorecon2 -autorecon3 -FLAIR ${FLAIRImage} -FLAIRpial ${seed_cmd_appendix}

	echo "$SubjectID" > "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1 0 0 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 1 0 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 0 1 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 0 0 1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "round" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat

	echo -e "\n T1_HCP_PostFreeSurferPipeline.sh -StudyFolder ${SubjFolder} -Subjlist ${Subject} -runlocal -ist2"
	T1_HCP_PostFreeSurferPipeline.sh -StudyFolder ${SubjFolder} -Subjlist ${Subject} -runlocal -ist2

else

	echo -e "\n"
	echo -e "\n Do not use T2 or FLAIR images"

	echo -e "\n T1_HCP_PreFreeSurferPipeline.sh -path ${SubjFolder} -subject ${Subject} -t1 ${T1} -t2 "NONE""
	T1_HCP_PreFreeSurferPipeline.sh -path ${SubjFolder} -subject ${Subject} -t1 ${T1} -t2 "NONE"

	T1wImage="${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
	T1wImageBrain="${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)

	T1wImageFile=`remove_ext $T1wImage`;
	T1wImageBrainFile=`remove_ext $T1wImageBrain`;

	SubjectDIR=${SubjFolder}/${Subject}/T1w
	SubjectID=${Subject}

	#Make Spline Interpolated Downsample to 1mm
	echo -e "\n Make Spline Interpolated Downsample to 1mm"

	Mean=`fslstats $T1wImageBrain -M`
	flirt -interp spline -in "$T1wImage" -ref "$T1wImage" -applyisoxfm 1 -out "$T1wImageFile"_1mm.nii.gz
	applywarp --rel --interp=spline -i "$T1wImage" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageFile"_1mm.nii.gz
	applywarp --rel --interp=nn -i "$T1wImageBrain" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageBrainFile"_1mm.nii.gz
	fslmaths "$T1wImageFile"_1mm.nii.gz -div $Mean -mul 150 -abs "$T1wImageFile"_1mm.nii.gz

	#Initial Recon-all Steps
	echo -e "\n Initial Recon-all Steps"

	# Call recon-all with flags that are part of "-autorecon1", with the exception of -skullstrip.
	# -skullstrip of FreeSurfer not reliable for Phase II data because of poor FreeSurfer mri_em_register registrations with Skull on, 
	# so run registration with PreFreeSurfer masked data and then generate brain mask as usual.
	recon-all -i "$T1wImageFile"_1mm.nii.gz -subjid $SubjectID -sd $SubjectDIR -motioncor -talairach -nuintensitycor -normalization ${seed_cmd_appendix}

	# Generate brain mask
	mri_convert "$T1wImageBrainFile"_1mm.nii.gz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz --conform
	mri_em_register -mask "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz "$SubjectDIR"/"$SubjectID"/mri/nu.mgz $FREESURFER_HOME/average/RB_all_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta
	mri_watershed -T1 -brain_atlas $FREESURFER_HOME/average/RB_all_withskull_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta "$SubjectDIR"/"$SubjectID"/mri/T1.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz 
	cp "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz

	# Last recon-all Steps
	echo -e "\n recon-all -sd "$SubjectDIR" -subjid "${SubjectID}" -autorecon2 -autorecon3 ${seed_cmd_appendix}"
	recon-all -sd "$SubjectDIR" -subjid "${SubjectID}" -autorecon2 -autorecon3 ${seed_cmd_appendix}

	echo "$SubjectID" > "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "1 0 0 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 1 0 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 0 1 0" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "0 0 0 1" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat
	echo "round" >> "$SubjectDIR"/"$SubjectID"/mri/transforms/eye.dat

	echo -e "\n T1_HCP_PostFreeSurferPipeline.sh -StudyFolder ${SubjFolder} -Subjlist ${Subject} -runlocal"
	T1_HCP_PostFreeSurferPipeline.sh -StudyFolder ${SubjFolder} -Subjlist ${Subject} -runlocal


fi




#------------------------------------------------------------------------------
#                             QUALITY CONTROL
#------------------------------------------------------------------------------

if [ $QCfolder = "NONE" ]; then 
	echo "no quality control"
else

	if [ ! -d ${QCfolder} ]; then mkdir -p ${QCfolder}; fi

	# Mask
	overlay 1 1 ${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz -a ${SubjFolder}/${Subject}/T1w/brainmask_fs.nii.gz 1 10 ${SubjFolder}/${Subject}/T1w/rendered.nii.gz
	slicer ${SubjFolder}/${Subject}/T1w/rendered.nii.gz -s 1 -x 0.35 ${QCfolder}/t1/${Subject}_sla.png -x 0.45 ${QCfolder}/t1/${Subject}_slb.png -x 0.55 ${QCfolder}/t1/${Subject}_slc.png -x 0.65 ${QCfolder}/t1/${Subject}_sld.png -y 0.35 ${QCfolder}/t1/${Subject}_sle.png -y 0.45 ${QCfolder}/t1/${Subject}_slf.png -y 0.55 ${QCfolder}/t1/${Subject}_slg.png -y 0.65 ${QCfolder}/t1/${Subject}_slh.png -z 0.35 ${QCfolder}/t1/${Subject}_sli.png -z 0.45 ${QCfolder}/t1/${Subject}_slj.png -z 0.55 ${QCfolder}/t1/${Subject}_slk.png -z 0.65 ${QCfolder}/t1/${Subject}_sll.png
	pngappend ${QCfolder}/t1/${Subject}_sla.png + ${QCfolder}/t1/${Subject}_slb.png + ${QCfolder}/t1/${Subject}_slc.png + ${QCfolder}/t1/${Subject}_sld.png - ${QCfolder}/t1/${Subject}_sle.png + ${QCfolder}/t1/${Subject}_slf.png + ${QCfolder}/t1/${Subject}_slg.png + ${QCfolder}/t1/${Subject}_slh.png - ${QCfolder}/t1/${Subject}_sli.png + ${QCfolder}/t1/${Subject}_slj.png + ${QCfolder}/t1/${Subject}_slk.png + ${QCfolder}/t1/${Subject}_sll.png ${QCfolder}/t1/${Subject}_brainmask.png
	rm -f ${QCfolder}/t1/${Subject}_sl?.png ${SubjFolder}/${Subject}/T1w/rendered.nii.gz

	# Parcellation
	if [ ! -d ${QCfolder}/t1 ]; then mkdir -p ${QCfolder}/t1; fi
	slicer ${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain ${SubjFolder}/${Subject}/T1w/aparc.a2009s+aseg -s 2 -x 0.35 ${QCfolder}/t1/${Subject}_sla.png -x 0.45 ${QCfolder}/t1/${Subject}_slb.png -x 0.55 ${QCfolder}/t1/${Subject}_slc.png -x 0.65 ${QCfolder}/t1/${Subject}_sld.png -y 0.35 ${QCfolder}/t1/${Subject}_sle.png -y 0.45 ${QCfolder}/t1/${Subject}_slf.png -y 0.55 ${QCfolder}/t1/${Subject}_slg.png -y 0.65 ${QCfolder}/t1/${Subject}_slh.png -z 0.35 ${QCfolder}/t1/${Subject}_sli.png -z 0.45 ${QCfolder}/t1/${Subject}_slj.png -z 0.55 ${QCfolder}/t1/${Subject}_slk.png -z 0.65 ${QCfolder}/t1/${Subject}_sll.png
	pngappend ${QCfolder}/t1/${Subject}_sla.png + ${QCfolder}/t1/${Subject}_slb.png + ${QCfolder}/t1/${Subject}_slc.png + ${QCfolder}/t1/${Subject}_sld.png + ${QCfolder}/t1/${Subject}_sle.png + ${QCfolder}/t1/${Subject}_slf.png + ${QCfolder}/t1/${Subject}_slg.png + ${QCfolder}/t1/${Subject}_slh.png + ${QCfolder}/t1/${Subject}_sli.png + ${QCfolder}/t1/${Subject}_slj.png + ${QCfolder}/t1/${Subject}_slk.png + ${QCfolder}/t1/${Subject}_sll.png ${QCfolder}/t1/${Subject}_aparc1.png
	slicer ${SubjFolder}/${Subject}/T1w/aparc.a2009s+aseg ${SubjFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain -s 2 -x 0.35 ${QCfolder}/t1/${Subject}_sla.png -x 0.45 ${QCfolder}/t1/${Subject}_slb.png -x 0.55 ${QCfolder}/t1/${Subject}_slc.png -x 0.65 ${QCfolder}/t1/${Subject}_sld.png -y 0.35 ${QCfolder}/t1/${Subject}_sle.png -y 0.45 ${QCfolder}/t1/${Subject}_slf.png -y 0.55 ${QCfolder}/t1/${Subject}_slg.png -y 0.65 ${QCfolder}/t1/${Subject}_slh.png -z 0.35 ${QCfolder}/t1/${Subject}_sli.png -z 0.45 ${QCfolder}/t1/${Subject}_slj.png -z 0.55 ${QCfolder}/t1/${Subject}_slk.png -z 0.65 ${QCfolder}/t1/${Subject}_sll.png
	pngappend ${QCfolder}/t1/${Subject}_sla.png + ${QCfolder}/t1/${Subject}_slb.png + ${QCfolder}/t1/${Subject}_slc.png + ${QCfolder}/t1/${Subject}_sld.png + ${QCfolder}/t1/${Subject}_sle.png + ${QCfolder}/t1/${Subject}_slf.png + ${QCfolder}/t1/${Subject}_slg.png + ${QCfolder}/t1/${Subject}_slh.png + ${QCfolder}/t1/${Subject}_sli.png + ${QCfolder}/t1/${Subject}_slj.png + ${QCfolder}/t1/${Subject}_slk.png + ${QCfolder}/t1/${Subject}_sll.png ${QCfolder}/t1/${Subject}_aparc2.png
	pngappend ${QCfolder}/t1/${Subject}_aparc1.png - ${QCfolder}/t1/${Subject}_aparc2.png ${QCfolder}/t1/${Subject}_aparc.png
	rm -f ${QCfolder}/t1/${Subject}_sl?.png ${QCfolder}/t1/${Subject}_aparc1.png ${QCfolder}/t1/${Subject}_aparc2.png

fi
