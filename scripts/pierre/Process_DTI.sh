#!/bin/bash

# Pierre Besson @ CHRU Lille, 2010 - 2011
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
#
# Modified: Choice between linear or nonlinear registration (Renaud Lopes)


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>  -bsthre <threshold>  -lin "
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo " "
	echo "Option :"
	echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
	echo "  -lin                               : Apply linear registration instead of nonlinear registration"
	echo ""
	echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>  -bsthre <threshold>"
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
		echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>  -bsthre <threshold>  -lin "
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo " "
		echo "Option :"
		echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
		echo "  -lin                               : Apply linear registration instead of nonlinear registration"
		echo ""
		echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>  -bsthre <threshold>"
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
	-lin)
		nlin=0
		echo "nlin = ${nlin}"
		echo "Apply linear registration"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a "$infile" != "-bsthre" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "subj : $subj"
		;;
	esac
	index=$[$index+1]
done


for Subject in ${subj}
do	
	DIR=${fs}/${Subject}
	cd ${DIR}/dti
	#####################
	# Step #0 : Make directory for reprocessing touch
	#####################
	if [ ! -d ${DIR}/dti/steps ]
	then
		mkdir ${DIR}/dti/steps
	fi
	
	#####################
	# Step #1 : Remove / Replace abnormal diffusion volumes
	#####################
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
	
	#####################
	# Step #2 : Run eddy correct
	#####################
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
	
	#####################
	# Step #3 : Correct bvecs
	#####################
	echo "rotate_bvecs ${DIR}/dti/data_corr.ecclog ${DIR}/dti/data.bvec"
	do_cmd 2 ${DIR}/dti/steps/rotate_bvecs.touch rotate_bvecs data_corr.ecclog data.bvec
	
	#####################
	# Step #4 : Prepare for bedpostx
	#####################
	echo "bet ${DIR}/dti/data_corr ${DIR}/dti/data_corr_brain -F -f 0.25 -g 0 -m"
	do_cmd 2 ${DIR}/dti/steps/BET.touch bet ${DIR}/dti/data_corr ${DIR}/dti/data_corr_brain -F -f 0.25 -g 0 -m
	
	if [ ! -d ${DIR}/dti/DataBPX ]
	then
		mkdir ${DIR}/dti/DataBPX
	fi
	
	cp ${DIR}/dti/data_corr.nii.gz ${DIR}/dti/DataBPX/data.nii.gz
	cp ${DIR}/dti/data_corr_brain_mask.nii.gz ${DIR}/dti/DataBPX/nodif_brain_mask.nii.gz
	cp ${DIR}/dti/data.bval ${DIR}/dti/DataBPX/bvals
	cp ${DIR}/dti/data.bvec ${DIR}/dti/DataBPX/bvecs
	
	#####################
	# Step #5 : Run dtifit
	#####################
	echo "dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval"
	do_cmd 2 ${DIR}/dti/steps/dtifit.touch dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval
	
	#####################
	# Step #6 : Non-linear fitting of T1 on DTI B0
	#####################
	if [ -f ${DIR}/mri/T1.mgz ]
	then
		mri_convert ${DIR}/mri/T1.mgz ${DIR}/dti/orig/t1_ras.nii --out_orientation RAS
		if [ ${nlin} -eq 1 ]
		then
			do_cmd 20 ${DIR}/dti/steps/nlfit_t1_to_b0.touch NlFit_t1_to_b0.sh -source ${DIR}/dti/orig/t1_ras.nii -target ${DIR}/dti/data_corr.nii.gz -o ${DIR}/dti/nl_fit/ -newsegment
		else
			do_cmd 20 ${DIR}/dti/steps/linfit_t1_to_b0.touch LinFit_t1_to_b0.sh -source ${DIR}/dti/orig/t1_ras.nii -target ${DIR}/dti/data_corr.nii.gz -o ${DIR}/dti/lin_fit/ -newsegment
		fi
	fi
	
 	#####################
 	# Step #6 : Run bedpostx
 	#####################
 	echo "bedpostx ${DIR}/dti/DataBPX -n 2 -w 1  -b 1000"
 	do_cmd 2 ${DIR}/dti/steps/bedpostx.touch bedpostx ${DIR}/dti/DataBPX -n 2 -w 1  -b 1000
done
