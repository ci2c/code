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
#


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_Process2Sequences.sh  -fs <FS_dir>  -subj <subj>  -bsthre <threshold>  -lin "
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo " "
	echo "Option :"
	echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
	echo "  -lin                               : Apply linear registration instead of nonlinear registration"
	echo ""
	echo "Usage: DTI_Process2Sequences.sh  -fs <FS_dir>  -subj <subj1>  -bsthre <threshold>  -lin "
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
		echo "Usage: DTI_Process2Sequences.sh  -fs <FS_dir>  -subj <subj>  -bsthre <threshold>  -lin "
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo " "
		echo "Option :"
		echo "  -bsthre <threshold>                : BlackSlice threshold. Default = 9"
		echo "  -lin                               : Apply linear registration instead of nonlinear registration"
		echo ""
		echo "Usage: DTI_Process2Sequences.sh  -fs <FS_dir>  -subj <subj1>  -bsthre <threshold>  -lin "
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
		index=`expr $index + 1`
		eval subj=\${$index}
		echo "subj : ${subj}"
		;;
	esac
	index=$[$index+1]
done

DIR=${fs}/${subj}
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
	rm -f ${DIR}/dti/orig1/dti1_nobs*
	rm -f ${DIR}/dti/orig2/dti2_nobs*
	mkdir ${DIR}/dti/orig/temp
	#
	
	# DTI 1
	cp ${DIR}/dti/orig/dti1*  ${DIR}/dti/orig/temp/
	cp ${DIR}/dti/orig/dti2*  ${DIR}/dti/orig/temp/
	i=1
	for DTI in `ls ${DIR}/dti/orig/temp/dti?.nii.gz`
	do
		echo ${DTI}
		echo "bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m"
		bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m
		mv ${DTI%.nii.gz}_brain_mask.nii.gz ${DIR}/dti/orig/temp/mask${i}.nii.gz
		i=$[$i+1]
	done
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${current_dir}
	
	repairBlackSlices('${DIR}/dti/orig/temp/', ${bsthre})
EOF
	mv ${DIR}/dti/orig/temp/mask1.nii.gz ${DIR}/dti/orig/
	mv ${DIR}/dti/orig/temp/dti_nobs.nii.gz ${DIR}/dti/orig/dti1_nobs.nii.gz
	mv ${DIR}/dti/orig/temp/dti_nobs.bval ${DIR}/dti/orig/dti1_nobs.bval
	mv ${DIR}/dti/orig/temp/dti_nobs.bvec ${DIR}/dti/orig/dti1_nobs.bvec
	mv ${DIR}/dti/orig/temp/dti1.report ${DIR}/dti/orig/

	# DTI 2
	rm -rf ${DIR}/dti/orig/temp/*
	cp ${DIR}/dti/orig/dti1.nii.gz ${DIR}/dti/orig/temp/dti2.nii.gz
	cp ${DIR}/dti/orig/dti1.bval ${DIR}/dti/orig/temp/dti2.bval
	cp ${DIR}/dti/orig/dti1.bvec ${DIR}/dti/orig/temp/dti2.bvec
	cp ${DIR}/dti/orig/dti2.nii.gz ${DIR}/dti/orig/temp/dti1.nii.gz
	cp ${DIR}/dti/orig/dti2.bval ${DIR}/dti/orig/temp/dti1.bval
	cp ${DIR}/dti/orig/dti2.bvec ${DIR}/dti/orig/temp/dti1.bvec
	i=1
	for DTI in `ls ${DIR}/dti/orig/temp/dti?.nii.gz`
	do
		echo ${DTI}
		echo "bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m"
		bet ${DTI} ${DTI%.nii.gz}_brain  -f 0.25 -g 0 -n -m
		mv ${DTI%.nii.gz}_brain_mask.nii.gz ${DIR}/dti/orig/temp/mask${i}.nii.gz
		i=$[$i+1]
	done
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${current_dir}
	
	repairBlackSlices('${DIR}/dti/orig/temp/', ${bsthre})
EOF
	mv ${DIR}/dti/orig/temp/mask1.nii.gz ${DIR}/dti/orig/mask2.nii.gz
	mv ${DIR}/dti/orig/temp/dti_nobs.nii.gz ${DIR}/dti/orig/dti2_nobs.nii.gz
	mv ${DIR}/dti/orig/temp/dti_nobs.bval ${DIR}/dti/orig/dti2_nobs.bval
	mv ${DIR}/dti/orig/temp/dti_nobs.bvec ${DIR}/dti/orig/dti2_nobs.bvec
	mv ${DIR}/dti/orig/temp/dti1.report ${DIR}/dti/orig/dti2.report
	
	rm -rf ${DIR}/dti/orig/temp

	touch ${DIR}/dti/steps/remove-black-slice.touch
fi


# #####################
# # Step #2 : Run eddy correct
# #####################
# if [ ! -f ${DIR}/dti/steps/eddy-correct.touch ]
# then
# 	cp ${DIR}/dti/orig/dti1_nobs.nii.gz ${DIR}/dti/temp.nii.gz
# 	cp ${DIR}/dti/orig/dti1_nobs.bvec ${DIR}/dti/data1.bvec
# 	cp ${DIR}/dti/orig/dti1_nobs.bval ${DIR}/dti/data1.bval
# 	echo "eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data1_corr 0"
# 	eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data1_corr 0
# 	rm -f ${DIR}/dti/temp.nii.gz
# 	
# 	cp ${DIR}/dti/orig/dti2_nobs.nii.gz ${DIR}/dti/temp.nii.gz
# 	cp ${DIR}/dti/orig/dti2_nobs.bvec ${DIR}/dti/data2.bvec
# 	cp ${DIR}/dti/orig/dti2_nobs.bval ${DIR}/dti/data2.bval
# 	echo "eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data2_corr 0"
# 	eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data2_corr 0
# 	rm -f ${DIR}/dti/temp.nii.gz
# 	
# 	touch ${DIR}/dti/steps/eddy-correct.touch
# fi

#####################
# Step #2 : Run copy data
#####################
if [ ! -f ${DIR}/dti/steps/copy-data.touch ]
then
	cp ${DIR}/dti/orig/dti1_nobs.nii.gz ${DIR}/dti/data1.nii.gz
	cp ${DIR}/dti/orig/dti1_nobs.bvec ${DIR}/dti/data1.bvec
	cp ${DIR}/dti/orig/dti1_nobs.bval ${DIR}/dti/data1.bval
	
	cp ${DIR}/dti/orig/dti2_nobs.nii.gz ${DIR}/dti/data2.nii.gz
	cp ${DIR}/dti/orig/dti2_nobs.bvec ${DIR}/dti/data2.bvec
	cp ${DIR}/dti/orig/dti2_nobs.bval ${DIR}/dti/data2.bval
	
	touch ${DIR}/dti/steps/copy-data.touch
fi


#####################
# Step #3 : Merge 2 dtis
#####################
if [ ! -f ${DIR}/dti/steps/merge-b0.touch ]
then
	echo "step #3 : Merge 2 dtis"
	echo "fslsplit ${DIR}/dti/data1.nii.gz ${DIR}/dti/tmp1_ -t"
	fslsplit ${DIR}/dti/data1.nii.gz ${DIR}/dti/tmp1_ -t
	echo "fslsplit ${DIR}/dti/data2.nii.gz ${DIR}/dti/tmp2_ -t"
	fslsplit ${DIR}/dti/data2.nii.gz ${DIR}/dti/tmp2_ -t
	echo "gunzip ${DIR}/dti/tmp*"
	gunzip ${DIR}/dti/tmp*
	
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	Coreg2B0('${DIR}/dti','tmp1','tmp2');
EOF

	cd ${HOME}
	echo "fslmerge -t ${DIR}/dti/B0_2.nii ${DIR}/dti/tmp1_0000.nii ${DIR}/dti/rtmp2_0000.nii"
	fslmerge -t ${DIR}/dti/B0_2.nii ${DIR}/dti/tmp1_0000.nii ${DIR}/dti/rtmp2_0000.nii
	echo "fslmaths ${DIR}/dti/B0_2.nii -Tmean ${DIR}/dti/B0_mean"
	fslmaths ${DIR}/dti/B0_2.nii -Tmean ${DIR}/dti/B0_mean
	rm -f ${DIR}/dti/tmp1_0000.nii ${DIR}/dti/rtmp2_0000.nii
	echo "fslmerge -t ${DIR}/dti/data ${DIR}/dti/B0_mean.nii.gz ${DIR}/dti/tmp1* ${DIR}/dti/rtmp2*"
	fslmerge -t ${DIR}/dti/data ${DIR}/dti/B0_mean.nii.gz ${DIR}/dti/tmp1* ${DIR}/dti/rtmp2* 
	echo "rm -f ${DIR}/dti/tmp1_* ${DIR}/dti/tmp2_*"
	rm -f ${DIR}/dti/tmp1_* ${DIR}/dti/tmp2_* ${DIR}/dti/rtmp2_*
	rm -f ${DIR}/dti/B0_2.nii.gz B0_mean.nii.gz

	touch ${DIR}/dti/steps/merge-b0.touch
fi


###############################################
# Step #4 : Run eddy correct and correct bvecs
###############################################
if [ ! -f ${DIR}/dti/steps/eddy-correct-fusion.touch ]
then
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	a=load('${DIR}/dti/data1.bvec');
	b=load('${DIR}/dti/data2.bvec');
	c=[a b(:,2:end)];
	
	fid=fopen('${DIR}/dti/data.bvec','w'); for i=1:size(c,1); fprintf(fid,'%i ',c(i,1)); for j=2:size(c,2); fprintf(fid,'%.7f ',c(i,j)); end; fprintf(fid,'\n'); end; fclose(fid);
	
	a=load('${DIR}/dti/data1.bval');
	b=load('${DIR}/dti/data2.bval');
	c=[a b(1,2:end)];
	
	fid=fopen('${DIR}/dti/data.bval','w'); for j=1:size(c,2); fprintf(fid,'%i ',c(1,j)); end; fclose(fid);
	
EOF
	echo "eddy_correct ${DIR}/dti/data.nii.gz ${DIR}/dti/data_corr 0"
	eddy_correct ${DIR}/dti/data.nii.gz ${DIR}/dti/data_corr 0
	touch ${DIR}/dti/steps/eddy-correct-fusion.touch
fi

echo "rotate_bvecs ${DIR}/dti/data_corr.ecclog ${DIR}/dti/data.bvec"
do_cmd 2 ${DIR}/dti/steps/rotate_bvecs.touch rotate_bvecs ${DIR}/dti/data_corr.ecclog ${DIR}/dti/data.bvec


#####################
# Step #5 : Prepare for bedpostx
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
# Step #6 : Run dtifit
#####################
echo "dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval"
do_cmd 2 ${DIR}/dti/steps/dtifit.touch dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval


#####################
# Step #7 : Non-linear fitting of T1 on DTI B0
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







	
		
