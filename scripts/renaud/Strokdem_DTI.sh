#!/bin/bash

# Renaud Lopes @ CHRU Lille, 2012
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Strokdem_DTI.sh  -fs <FS_dir>  -subj <subj> -bsthre <threshold> "
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo " "
	echo "Option :"
	echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
	echo ""
	echo "Usage: Strokdem_DTI.sh  -fs <FS_dir>  -subj <subj>  -bsthre <threshold>  -lin"
	echo ""
	exit 1
fi

index=1
bsthre=9

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Strokdem_DTI.sh  -fs <FS_dir>  -subj <subj> -bsthre <threshold>  -lin "
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo " "
		echo "Option :"
		echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
		echo ""
		echo "Usage: Strokdem_DTI.sh  -fs <FS_dir>  -subj <subj> -bsthre <threshold>  -lin "
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "FS_dir : $fs"
		;;
	-bsthre)
		bsthre=`expr $index + 1`
		eval bsthre=\${$bsthre}
		echo "BS threshold : set to $bsthre"
		;;
	-subj)
		index=`expr $index + 1`
		eval subj=\${$index}
		echo "subj : ${subj}"
		;;
	esac
	index=$[$index+1]
done

DIR=${fs}/${subj}
cd ${DIR}/dti

##################################################
# Step #0 : Make directory for reprocessing touch
##################################################
if [ ! -d ${DIR}/dti/steps ]
then
	mkdir ${DIR}/dti/steps
fi

########################################################
# Step #1 : Remove / Replace abnormal diffusion volumes
########################################################
if [ ! -f ${DIR}/dti/steps/remove-black-slice.touch ]
then
	# Remove volume from previous run
	rm -f ${DIR}/dti/orig/dti_nobs*
	#
	
	i=1
	for DTI in `ls ${DIR}/dti/orig/dti?.nii.gz`
	do
		echo ${DTI}
		echo "bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m"
		bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m
		mv ${DTI%.nii.gz}_brain_mask.nii.gz ${DIR}/dti/orig/mask${i}.nii.gz
		i=$[$i+1]
	done
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${current_dir}
	
	repairBlackSlices('${DIR}/dti/orig/', ${bsthre})
EOF
	touch ${DIR}/dti/steps/remove-black-slice.touch
fi


#############################
# Step #2 : Run eddy correct
#############################
if [ ! -f ${DIR}/dti/steps/eddy-correct.touch ]
then
	cp ${DIR}/dti/orig/dti_nobs.nii.gz ${DIR}/dti/temp.nii.gz
	cp ${DIR}/dti/orig/dti_nobs.bvec ${DIR}/dti/data.bvec
	cp ${DIR}/dti/orig/dti_nobs.bval ${DIR}/dti/data.bval
	echo "eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data_corr 0"
	eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data_corr 0
	rm -f ${DIR}/dti/temp.nii.gz
	touch ${DIR}/dti/steps/eddy-correct.touch
fi


##########################
# Step #3 : Correct bvecs
##########################
echo "rotate_bvecs ${DIR}/dti/data_corr.ecclog ${DIR}/dti/data.bvec"
do_cmd 2 ${DIR}/dti/steps/rotate_bvecs.touch rotate_bvecs data_corr.ecclog data.bvec


#######################
# Step #4 : Run dtifit
#######################
echo "dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval"
do_cmd 2 ${DIR}/dti/steps/dtifit.touch dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval


########################
# Step #5 : Unwarp data
########################

if [ -d ${DIR}/dti/warp ]
then
	rm -rf ${DIR}/dti/warp
fi

echo "mkdir ${DIR}/dti/warp"
mkdir ${DIR}/dti/warp
mri_convert ${DIR}/mri/T1.mgz ${DIR}/dti/orig/t1_ras.nii --out_orientation RAS
echo "cp ${DIR}/dti/data_corr_* ${DIR}/dti/warp/"
cp ${DIR}/dti/data_corr_* ${DIR}/dti/warp/
echo "fslsplit ${DIR}/dti/warp/data_corr_brain.nii.gz ${DIR}/dti/warp/epi_ -t"
fslsplit ${DIR}/dti/warp/data_corr_brain.nii.gz ${DIR}/dti/warp/epi_ -t
echo "rm -f ${DIR}/dti/warp/data_corr_brain.nii.gz ${DIR}/dti/warp/data_corr_brain_mask.nii.gz"
rm -f ${DIR}/dti/warp/data_corr_brain.nii.gz ${DIR}/dti/warp/data_corr_brain_mask.nii.gz
echo "gunzip ${DIR}/dti/warp/*.gz"
gunzip ${DIR}/dti/warp/*.gz
echo "cd ${DIR}/dti/warp/"
cd ${DIR}/dti/warp/

matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${current_dir}

Strokdem_WarpB0OnT1_SPM(fullfile('${DIR}','dti'));

EOF



