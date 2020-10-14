#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: T1_FreesurferPipeline.sh  -sd <folder>  -subj <name>  -t1 <image>  -brain <image>  [-v <version>]  "
	echo ""
	echo "  -sd              : subject's directory "
	echo "  -subj            : subject "
	echo "  -t1              : T1 file "
	echo "  -brain           : T1 brain file "
	echo ""
	echo "Usage: T1_FreesurferPipeline.sh  -sd <folder>  -subj <name>  -t1 <image>  -brain <image>  [-v <version>] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
FS_VERSION=5.3

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage: T1_FreesurferPipeline.sh  -sd <folder>  -subj <name>  -t1 <image>  -brain <image>  [-v <version>]  "
		echo ""
		echo "  -sd              : subject's directory "
		echo "  -subj            : subject "
		echo "  -t1              : T1 file "
		echo "  -brain           : T1 brain file "
		echo ""
		echo "Usage: T1_FreesurferPipeline.sh  -sd <folder>  -subj <name>  -t1 <image>  -brain <image>  [-v <version>] "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SubjectDIR=\${$index}
		echo "subject's directory : $SubjectDIR"
		;;
	-subj)
		index=$[$index+1]
		eval SubjectID=\${$index}
		echo "input file : $SubjectID"
		;;
	-t1)
		index=$[$index+1]
		eval T1wImage=\${$index}
		echo "T1 image : $T1wImage"
		;;
	-brain)
		index=$[$index+1]
		eval T1wImageBrain=\${$index}
		echo "T1 brain image : $T1wImageBrain"
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
		echo "Usage: T1_FreesurferPipeline.sh  -sd <folder>  -subj <name>  -t1 <image>  -brain <image>  [-v <version>]  "
		echo ""
		echo "  -sd              : subject's directory "
		echo "  -subj            : subject "
		echo "  -t1              : T1 file "
		echo "  -brain           : T1 brain file "
		echo ""
		echo "Usage: T1_FreesurferPipeline.sh  -sd <folder>  -subj <name>  -t1 <image>  -brain <image>  [-v <version>] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

# Choice of FS version
if [ "${FS_VERSION}" == "5.1" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.1/
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
	sudo ln -s ${FREESURFER_HOME}/subjects/fsaverage5 ${SUBJECTS_DIR}/
elif [ "${FS_VERSION}" == "5.3" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
	sudo ln -s ${FREESURFER_HOME}/subjects/fsaverage5 ${SUBJECTS_DIR}/
fi

T1wImageFile=`remove_ext $T1wImage`;
T1wImageBrainFile=`remove_ext $T1wImageBrain`;

if [ -e "$SubjectDIR"/"$SubjectID"/scripts/IsRunning.lh+rh ] ; then
    rm -f "$SubjectDIR"/"$SubjectID"/scripts/IsRunning.lh+rh
fi

# mkdir "$SubjectDIR"/"$SubjectID"/mri
# mkdir "$SubjectDIR"/"$SubjectID"/surf
# mkdir "$SubjectDIR"/"$SubjectID"/label
# mkdir "$SubjectDIR"/"$SubjectID"/bem
# mkdir "$SubjectDIR"/"$SubjectID"/scripts
# mkdir "$SubjectDIR"/"$SubjectID"/src
# mkdir "$SubjectDIR"/"$SubjectID"/stats
# mkdir "$SubjectDIR"/"$SubjectID"/tmp
# mkdir "$SubjectDIR"/"$SubjectID"/touch
# mkdir "$SubjectDIR"/"$SubjectID"/trash

# Make Spline Interpolated Downsample to 1mm

echo "Make Spline Interpolated Downsample to 1mm"

Mean=`fslstats $T1wImageBrain -M`
flirt -interp spline -in "$T1wImage" -ref "$T1wImage" -applyisoxfm 1 -out "$T1wImageFile"_1mm.nii.gz
applywarp --rel --interp=spline -i "$T1wImage" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageFile"_1mm.nii.gz
applywarp --rel --interp=nn -i "$T1wImageBrain" -r "$T1wImageFile"_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o "$T1wImageBrainFile"_1mm.nii.gz
fslmaths "$T1wImageFile"_1mm.nii.gz -div $Mean -mul 150 -abs "$T1wImageFile"_1mm.nii.gz

# Initial Recon-all Steps

echo "Initial Recon-all Steps"

recon-all -i "$T1wImageFile"_1mm.nii.gz -subjid $SubjectID -sd $SubjectDIR -motioncor -talairach -nuintensitycor -normalization
mri_convert "$T1wImageBrainFile"_1mm.nii.gz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz --conform
mri_em_register -mask "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz "$SubjectDIR"/"$SubjectID"/mri/nu.mgz $FREESURFER_HOME/average/RB_all_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta
mri_watershed -T1 -brain_atlas $FREESURFER_HOME/average/RB_all_withskull_2008-03-26.gca "$SubjectDIR"/"$SubjectID"/mri/transforms/talairach_with_skull.lta "$SubjectDIR"/"$SubjectID"/mri/T1.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz 
cp "$SubjectDIR"/"$SubjectID"/mri/brainmask.auto.mgz "$SubjectDIR"/"$SubjectID"/mri/brainmask.mgz 

echo "Others Recon-all Steps"
recon-all -subjid $SubjectID -sd $SubjectDIR -autorecon2 -autorecon3

# recon-all -subjid $SubjectID -sd $SubjectDIR -autorecon2 -nosmooth2 -noinflate2 -nocurvstats -nosegstats
# 
# # Highres white stuff and Fine Tune T2w to T1w Reg
# 
# echo "Highres white stuff and Fine Tune T2w to T1w Reg"
# 
# T1_FreesurferHighResWhite.sh -sd $SubjectDIR -subj $SubjectID -t1 $T1wImage
# 
# # Intermediate Recon-all Steps
# 
# echo "Intermediate Recon-all Steps"
# 
# recon-all -subjid $SubjectID -sd $SubjectDIR -smooth2 -inflate2 -curvstats -sphere -surfreg -jacobian_white -avgcurv -cortparc
# 
# # Final Recon-all Steps
# 
# echo "Final Recon-all Steps"
# 
# recon-all -subjid $SubjectID -sd $SubjectDIR -surfvolume -parcstats -cortparc2 -parcstats2 -cortparc3 -parcstats3 -cortribbon -segstats -aparc2aseg -wmparc -balabels -label-exvivo-ec 

echo "Completed"
