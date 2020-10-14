#!/bin/bash

FS_dir=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/
Lesion_dir=/NAS/tupac/protocoles/Strokdem/Lesions/M6/

for f in $Lesion_dir/*
do
f2=`basename $f`

	echo "--------------------------------------------------------------------"
	echo "------------------------------RUN $f2-----------------------"
	echo "--------------------------------------------------------------------"


if [ ! -e ${f}/WM/cer_mask_bin_mni.nii ]; then

	echo "$f2" >>/NAS/tupac/protocoles/Strokdem/Lesions/M6/pb.txt
fi

if [ ! -e ${f}/WM/cer_mask_bin_mni.nii ]; then

	mkdir ${f}/WM

	if [ -e ${f}/T1_mni152.nii ]; then
		gunzip ${f}/T1_mni152.nii*
		cp ${f}/T1_mni152.nii ${f}/WM/
	fi


###Extraction masque cervelet-TC + recalage sur MNI
	if [ ! -e ${f}/WM/cer_mask_bin.nii.gz ]; then

		mni_brain=/NAS/tupac/protocoles/Strokdem/MNI152_1mm_brain.nii
		affine=${f}/WM/norm_mni152_rigid
		bspline=${f}/WM/norm_mni152
		aparc_mask=${f}/WM/aparc+aseg.nii.gz


		mri_convert $FS_dir/${f2}/mri/aparc+aseg.mgz ${f}/WM/aparc+aseg.nii.gz

		mri_extract_label $aparc_mask 16 7 8 46 47 ${f}/WM/cer_mask.nii.gz
		mri_binarize --i ${f}/WM/cer_mask.nii.gz --o ${f}/WM/cer_mask_bin.nii.gz --min 1
	
###Recalage linéaire masque aparc +aseg sur MNI

		ANTS 3 -m MI[$mni_brain,$aparc_mask,1,32] -o $affine -i 0 --rigid-affine
		WarpImageMultiTransform 3 $aparc_mask ${f}/WM/aparc+aseg_rigid.nii.gz $affine'Affine.txt' -R $mni_brain

###Recalage non linéaire masque aparc +aseg sur MNI
	
		ANTS 3 -m CC[$mni_brain,${f}/WM/aparc+aseg_rigid.nii.gz,1,4] -i 100x100x100x20 -o $bspline -t SyN[0.25] -r Gauss[3,0]
		WarpImageMultiTransform 3 $aparc_mask ${f}/WM/aparc+aseg_mni.nii.gz $bspline'Warp.nii.gz' $bspline'Affine.txt' $affine'Affine.txt' -R $mni_brain --use-BSpline

###Application de la déformation au cervelet 

		WarpImageMultiTransform 3  ${f}/WM/cer_mask_bin.nii.gz ${f}/WM/cer_mask_bin_mni.nii.gz $bspline'Warp.nii.gz' $bspline'Affine.txt' $affine'Affine.txt' -R $mni_brain --use-NN
		gunzip ${f}/WM/cer_mask_bin_mni.nii.gz
	fi
fi
	T1_MNI=${f}/T1_mni152.nii

	if [ ! -e $T1_MNI ]; then

	T1=$(ls -a $f/*3DT1*)
	Template=/home/global/fsl/data/standard/MNI152_T1_1mm.nii.gz
	affineT1=$f/norm_mni152_rigid
	bsplineT1=${f}/norm_mni152

###Recelage 3DT1 sur MNI

	ANTS 3 -m MI[$Template,$T1,1,32] -o $affineT1 -i 0 --rigid-affine
	WarpImageMultiTransform 3 $T1 $f/T1_mni152_rigid.nii.gz $affineT1'Affine.txt' -R $Template

	ANTS 3 -m CC[$Template,$f/T1_mni152_rigid.nii.gz,1,4] -i 100x100x100x20 -o $bsplineT1 -t SyN[0.25] -r Gauss[3,0]
	WarpImageMultiTransform 3 $T1 $T1_MNI $bsplineT1'Warp.nii.gz' $bsplineT1'Affine.txt' $affineT1'Affine.txt' -R $Template --use-BSpline

	cp $T1_MNI ${f}/WM/
	gunzip ${f}/WM/T1_mni152.nii*
	fi
	if [ ! -e ${f}/WM/WM-cer.nii ]; then

		T1_mni=${f}/WM/T1_mni152.nii
###Performing Segment à partir du T1_MNI
	/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	
	% Load Matlab Path
	change_path_spm8

	t1_mni='${T1_mni},1';

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	matlabbatch{1}.spm.spatial.preproc.data = {t1_mni};
	matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
	matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
	matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
	matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
	matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
	matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
                                               	'/home/global/matlab_toolbox/spm8/tpm/grey.nii'
                                               	'/home/global/matlab_toolbox/spm8/tpm/white.nii'
                                               	'/home/global/matlab_toolbox/spm8/tpm/csf.nii'
                                               	};
	matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2
                                                 	2
                                                 	2
                                                 	4];
	matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
	matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
	matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
	matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
	matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
	matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
	matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};

	spm_jobman('run',matlabbatch);
EOF

###calcul enlève masque cervelet
mris_calc -o ${f}/WM/WM-cer.nii ${f}/WM/c2T1_mni152.nii sub ${f}/WM/cer_mask_bin_mni.nii
	fi
done

