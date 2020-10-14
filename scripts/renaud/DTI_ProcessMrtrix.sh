#!/bin/bash

# Pierre Besson @ CHRU Lille, 2010 - 2011
# Modified: Choice between linear or nonlinear registration (Renaud Lopes)


if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: DTI_ProcessMrtrix.sh  -fs <FS_dir>  -subj <subj1> -o <folder> -bsthre <threshold>  -lin  -initLin "
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo "  -o <folder>                        : output folder"
	echo " "
	echo "Option :"
	echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
	echo "  -lin                               : Apply linear registration instead of nonlinear registration"
	echo "  -initLin                           : Apply linear registration before nonlinear registration"
	echo ""
	echo "Usage: DTI_ProcessMrtrix.sh  -fs <FS_dir>  -subj <subj1> -o <folder> -bsthre <threshold>  -lin  -initLin "
	echo ""
	exit 1
fi


index=1
bsthre=9
nlin=1
initLin=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_ProcessMrtrix.sh  -fs <FS_dir>  -subj <subj1>  -o <folder>  -bsthre <threshold>  -lin  -initLin "
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo "  -o <folder>                        : output folder"
		echo " "
		echo "Option :"
		echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
		echo "  -lin                               : Apply linear registration instead of nonlinear registration"
		echo "  -initLin                           : Apply linear registration before nonlinear registration"
		echo ""
		echo "Usage: DTI_ProcessMrtrix.sh  -fs <FS_dir>  -subj <subj1>  -o <folder>  -bsthre <threshold>  -lin  -initLin "
		echo ""
		exit 1
		;;
	-fs)
		index=$[$index+1]
		eval fs=\${$index}
		echo "FS_dir : $fs"
		;;
	-bsthre)
		index=$[$index+1]
		eval bsthre=\${$index}
		echo "BS threshold : set to $bsthre"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : $output"
		;;
	-lin)
		nlin=0
		echo "nlin = ${nlin}"
		echo "Apply linear registration"
		;;
	-initLin)
		initLin=1
		echo "Linear registration (initialization) = ${initLin}"
		echo "Apply linear registration"
		;;
	-subj)
		index=$[$index+1]
		eval Subject=\${$index}
		echo "subj : $Subject"
		;;
	esac
	index=$[$index+1]
done


DIR=${fs}/${Subject}
cd ${DIR}/${output}

#####################
# Step #0 : Make directory for reprocessing touch
#####################
if [ ! -d ${DIR}/${output}/steps ]
then
	mkdir ${DIR}/${output}/steps
fi

#####################
# Step #1 : Remove / Replace abnormal diffusion volumes
#####################
#if [ ! -f ${DIR}/${output}/steps/remove-black-slice.touch ]
#then
#	# Remove volume from previous run
#	rm -f ${DIR}/${output}/orig/dti_nobs*
#	#
#	
#	i=1
#	for DTI in `ls ${DIR}/${output}/orig/dti?.nii.gz`
#	do
#		echo ${DTI}
#		echo "bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m"
#		bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m
#		mv ${DTI%.nii.gz}_brain_mask.nii.gz ${DIR}/${output}/orig/mask${i}.nii.gz
#		i=$[$i+1]
#	done
#/usr/local/matlab11/bin/matlab -nodisplay <<EOF
#	% Load Matlab Path
#	p = pathdef;
#	addpath(p);
#	cd ${current_dir}
#	
#	repairBlackSlices('${DIR}/${output}/orig/', ${bsthre})
#EOF
#	touch ${DIR}/${output}/steps/remove-black-slice.touch
#fi

#####################
# Step #2 : Run eddy correct
#####################
if [ ! -f ${DIR}/${output}/steps/eddy-correct.touch ]
then
	cp ${DIR}/${output}/orig/dti1.nii.gz ${DIR}/${output}/temp.nii.gz
	cp ${DIR}/${output}/orig/dti1.bvec ${DIR}/${output}/data.bvec
	cp ${DIR}/${output}/orig/dti1.bval ${DIR}/${output}/data.bval
	echo "eddy_correct ${DIR}/${output}/temp.nii.gz ${DIR}/${output}/data_corr 0"
	eddy_correct ${DIR}/${output}/temp.nii.gz ${DIR}/${output}/data_corr 0
	rm -f ${DIR}/${output}/temp.nii.gz
	touch ${DIR}/${output}/steps/eddy-correct.touch
fi

#####################
# Step #3 : Correct bvecs
#####################
echo "rotate_bvecs ${DIR}/${output}/data_corr.ecclog ${DIR}/${output}/data.bvec"
do_cmd 2 ${DIR}/${output}/steps/rotate_bvecs.touch rotate_bvecs ${DIR}/${output}/data_corr.ecclog ${DIR}/${output}/data.bvec

#####################
# Step #4 : Create brain mask
#####################
echo "bet ${DIR}/${output}/data_corr ${DIR}/${output}/data_corr_brain -F -f 0.25 -g 0 -m"
do_cmd 2 ${DIR}/${output}/steps/BET.touch bet ${DIR}/${output}/data_corr ${DIR}/${output}/data_corr_brain -F -f 0.25 -g 0 -m

#####################
# Step #5 : Run dtifit
#####################
echo "dtifit --data=${DIR}/${output}/data_corr.nii.gz --out=${DIR}/${output}/data_corr --mask=${DIR}/${output}/data_corr_brain_mask.nii.gz --bvecs=${DIR}/${output}/data.bvec --bvals=${DIR}/${output}/data.bval"
do_cmd 2 ${DIR}/${output}/steps/dtifit.touch dtifit --data=${DIR}/${output}/data_corr.nii.gz --out=${DIR}/${output}/data_corr --mask=${DIR}/${output}/data_corr_brain_mask.nii.gz --bvecs=${DIR}/${output}/data.bvec --bvals=${DIR}/${output}/data.bval

#####################
# Step #6 : Non-linear fitting of T1 on DTI B0
#####################
if [ -f ${DIR}/mri/T1.mgz ]
then
	mri_convert ${DIR}/mri/T1.mgz ${DIR}/${output}/orig/t1_ras.nii --out_orientation RAS
	
	if [ ${initLin} -eq 1 ]
	then
		mkdir ${DIR}/${output}/tmpsplit
		fslsplit ${DIR}/${output}/data_corr.nii.gz ${DIR}/${output}/tmpsplit/epi_ -t
		gunzip ${DIR}/${output}/tmpsplit/epi_0000.nii.gz
		
/usr/local/matlab/bin/matlab -nodisplay <<EOF
		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		
		spm('Defaults','fMRI');
		spm_jobman('initcfg'); % SPM8 only

		matlabbatch{1}.spm.spatial.coreg.estimate.ref    = {'${DIR}/${output}/tmpsplit/epi_0000.nii,1'};
		matlabbatch{1}.spm.spatial.coreg.estimate.source = {'${DIR}/${output}/orig/t1_ras.nii,1'};
		matlabbatch{1}.spm.spatial.coreg.estimate.other  = {''};
		matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
		matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
		matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
		matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
		
		spm_jobman('run',matlabbatch);
EOF
		rm -rf ${DIR}/${output}/tmpsplit
	fi
	if [ ${nlin} -eq 1 ]
	then
		do_cmd 20 ${DIR}/${output}/steps/nlfit_t1_to_b0.touch NlFit_t1_to_b0.sh -source ${DIR}/${output}/orig/t1_ras.nii -target ${DIR}/${output}/data_corr.nii.gz -o ${DIR}/${output}/nl_fit/ -newsegment -keeptmp
	else
		do_cmd 20 ${DIR}/${output}/steps/linfit_t1_to_b0.touch LinFit_t1_to_b0.sh -source ${DIR}/${output}/orig/t1_ras.nii -target ${DIR}/${output}/data_corr.nii.gz -o ${DIR}/${output}/lin_fit/ -newsegment -keeptmp
	fi
fi

#####################
# Step #7 : Tractography (Mrtrix)
#####################
LOI=/home/renaud/SVN/scripts/pierre/aparc2009LOI.txt
#echo "CMatrixVolume_mrtrix.sh -fs ${fs} -subj ${Subject} -parcname aparc.a2009s+aseg.mgz -labels ${LOI} -dti ${DIR}/${output}/data_corr_brain.nii.gz -bvecs ${DIR}/${output}/data.bvec -bvals ${DIR}/${output}/data.bval -outdir ${DIR}/${output}/mrtrix"
#do_cmd 20 ${DIR}/${output}/steps/mrtrix.touch CMatrixVolume_mrtrix.sh -fs ${fs} -subj ${Subject} -parcname aparc.a2009s+aseg.mgz -labels ${LOI} -dti ${DIR}/${output}/data_corr_brain.nii.gz -bvecs ${DIR}/${output}/data.bvec -bvals ${DIR}/${output}/data.bval -outdir ${DIR}/${output}/mrtrix -N 500000

