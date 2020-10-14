#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: PrepareSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift  -no-corr]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo " "
	echo "Options :"
	echo "  -lmax lmax                   : Maximum harmonic order (default : 6)"
	echo "  -N Nfiber                    : Number of fibers (default : 1500000)"
	echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
	echo "                                    (default : Does apply voxel shift)"
	echo "  -no-corr                     : Does not apply distortion correction "
	echo "                                    (default : Does apply distortion correction)"
	echo "  -mask			 		     : mask for the seed"
	echo " "
	echo "Important : To make the script working, please create the directory dti within SubjDir/SubjName"
	echo "            And copy the Diffusion weighted images and gradient files."
	echo "            There sould be 4 files in the dti directory prior to running the script :"
	echo "            1. dti_back.nii.gz [Reverse acquisition]"
	echo "            2. dti.nii.gz      [Forward acquisition]"
	echo "            3. dti.bval        [B-values of the forward acquisition]"
	echo "            4. dti.bec         [Directions of the gradients of the forward DWI]"
	echo " "
	echo "If these 4 files can not be found, the script will fail. Except if no-corr option is selected, in this case dti_back is not required"
	echo ""
	echo "Usage: PrepareSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift  -no-corr]"
	exit 1
fi

#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
vox_shift=1
dist_corr=1
lmax=6
Nfiber=1500000
#mrtrix_ver="/home/global/mrtrix3/release/bin/"
mrtrix_ver="/home/global/mrtrix3_RC2/mrtrix3/bin/"
rep="dti"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PrepareSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift  -no-corr]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo " "
		echo "Options :"
		echo "  -lmax lmax                   : Maximum harmonic order (default : 6)"
		echo "  -N Nfiber                    : Number of fibers (default : 1500000)"
		echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
		echo "                                    (default : Does apply voxel shift)"
		echo "  -no-corr                     : Does not apply distortion correction "
		echo "                                    (default : Does apply distortion correction)"
		echo "  -mask			     		 : mask for the seed"
		echo "  -include				     : mask for the include"
	
		echo " "
		echo "Important : To make the script working, please create the directory dti within SubjDir/SubjName"
		echo "            And copy the Diffusion weighted images and gradient files."
		echo "            There sould be 4 files in the dti directory prior to running the script :"
		echo "            1. dti_back.nii.gz [Reverse acquisition]"
		echo "            2. dti.nii.gz      [Forward acquisition]"
		echo "            3. dti.bval        [B-values of the forward acquisition]"
		echo "            4. dti.bec         [Directions of the gradients of the forward DWI]"
		echo " "
		echo "If these 4 files can not be found, the script will fail. Except if no-corr option is selected, in this case dti_back is not required"
		echo ""
		echo "Usage: PrepareSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift  -no-corr]"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-lmax)
		lmax=`expr $index + 1`
		eval lmax=\${$lmax}
		echo "  |-------> Optional lmax : ${lmax}"
		index=$[$index+1]
		;;
	-N)
		Nfiber=`expr $index + 1`
		eval Nfiber=\${$Nfiber}
		echo "  |-------> Optional N : ${Nfiber}"
		index=$[$index+1]
		;;
	-no-shift)
		vox_shift=0
		echo "  |-------> Disabled voxel shift"
		;;
	-no-corr)
		dist_corr=0
		echo "  |-------> Disabled distortion correction"
		;;
	-mask)
		seedMask=`expr $index + 1`
		eval seedMask=\${$seedMask}
		echo "  |-------> Seed mask : ${seedMask}"
		index=$[$index+1]
		;;
    -rep)
        index=$[$index+1]
        eval REP=\${$index}
        echo "dti folder : ${REP}"
        ;;
	-include)
		includeMask=`expr $index + 1`
		eval includeMask=\${$includeMask}
		echo "  |-------> Include mask : ${includeMask}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


# Check inputs
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

DTI=${DIR}/${REP}
if [ ! -e ${DTI} ]
then
	echo "Can not find ${DTI} directory"
fi

if [ ${dist_corr} -eq "1" ]; then
	rev_dti=${DTI}/dti_back.nii.gz
	if [ ! -e ${rev_dti} ]
	then
		echo "Can not find file ${rev_dti}"
		exit 1
	fi
else
	rev_dti=""
fi

for_dti=${DTI}/dti.nii.gz
if [ ! -e ${for_dti} ]
then
	echo "Can not find file ${for_dti}"
	exit 1
fi

bval=${DTI}/dti.bval
if [ ! -e ${bval} ]
then
	echo "Can not find file ${bval}"
	exit 1
fi

bvec=${DTI}/dti.bvec
if [ ! -e ${bvec} ]
then
	echo "Can not find file ${bvec}"
	exit 1
fi

if [ ${dist_corr} -eq "1" ]; then

	echo "does apply distortion correction"

	DCDIR=${DTI}/distorsion_correction

	# Step 1. Correct distortions
	if [ ! -e ${DTI}/distorsion_correction/b0_norm_unwarp.nii.gz ]
	then
		mkdir ${DTI}/distorsion_correction
		echo "fslroi ${for_dti} ${DCDIR}/b0 0 1"
		fslroi ${for_dti} ${DCDIR}/b0 0 1
		echo "fslroi ${rev_dti} ${DCDIR}/b0_back 0 1"
		fslroi ${rev_dti} ${DCDIR}/b0_back 0 1
	
		gunzip -f ${DCDIR}/*gz
	
		# Shift the reverse DWI by 1 voxel
		# Only for Philips images, for *unknown* reason
		# Then AP-flip the image for CMTK
		matlab -nodisplay <<EOF
		cd ${DCDIR}
		EPIshift_and_flip('b0_back.nii', 'rb0_back.nii', 'sb0_back.nii', ${vox_shift});
EOF

		# Normalize the signal
		S=`fslstats ${DCDIR}/b0.nii -m`
		fslmaths ${DCDIR}/b0.nii -div $S -mul 1000 ${DCDIR}/b0_norm -odt double
	
		S=`fslstats ${DCDIR}/rb0_back.nii -m`
		fslmaths ${DCDIR}/rb0_back.nii -div $S -mul 1000 ${DCDIR}/rb0_back_norm -odt double
	
		# Launch CMTK
		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
	
		gzip -f ${DCDIR}/*.nii
	fi

else

	echo "does not apply distortion correction"

fi

# Step 2. Eddy current correction
if [ ! -e ${DTI}/dti_eddycor.ecclog ]
then
	echo "Step 2.  eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0"
	eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0
fi

# Step 3. Rotate bvec
if [ ! -e ${DTI}/dti.bvec_old ]
then
	echo "Step 3.  rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}"
	rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}
fi

# Step 4. Apply distortion corrections to the whole DWI
final_dti=${DTI}/dti_finalcor.nii.gz
if [ ${dist_corr} -eq "1" ]; then
	echo " if Step 4."
	if [ ! -e ${DTI}/dti_finalcor.nii.gz ]
	then
		echo "fslsplit ${DTI}/dti_eddycor.nii.gz ${DCDIR}/voltmp -t"
		fslsplit ${DTI}/dti_eddycor.nii.gz ${DCDIR}/voltmp -t
	
		for I in `ls ${DCDIR} | grep voltmp`
		do
			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd
		
			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
		
			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
		done
	
		echo "fslmerge -t ${DTI}/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
		fslmerge -t ${DTI}/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
	
		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
		gzip -f ${DCDIR}/*.nii	
	fi

else
	echo " else Step 4."
	cmd="cp -f ${DTI}/dti_eddycor.nii.gz ${final_dti};"
	echo $cmd ;     eval $cmd

fi

# Step 5. Compute DTI fit on fully corrected DTI
if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
then
	echo "Step 5.  bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m"
	bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m
	
	echo "Step 5.  dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval"
	dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval
fi

# Step 6. Get freesurfer WM mask
if [ ! -e ${DIR}/mri/aparc+aseg.mgz ]
then
	echo "Step 6. Freesurfer was not fully processed"
	echo "Script terminated"
	exit 1
fi

if [ ! -e ${DTI}/wm_mask.nii.gz ]
then
	echo "Step 6.2"
	echo "mris_fill -r 0.5 -c ${DIR}/surf/lh.white ${DTI}/lh.white.mgz"
	mris_fill -r 0.5 -c ${DIR}/surf/lh.white ${DTI}/lh.white.mgz
	
	echo "mris_fill -r 0.5 -c ${DIR}/surf/rh.white ${DTI}/rh.white.mgz"
	mris_fill -r 0.5 -c ${DIR}/surf/rh.white ${DTI}/rh.white.mgz
	
	echo "mri_or ${DTI}/lh.white.mgz ${DTI}/rh.white.mgz ${DTI}/white.mgz"
	mri_or ${DTI}/lh.white.mgz ${DTI}/rh.white.mgz ${DTI}/white.mgz
	
	# Extract subcortical structures
	echo "mri_extract_label ${DIR}/mri/aparc+aseg.mgz 10 11 12 13 17 18 26 49 50 51 52 53 54 58 ${DTI}/sc_labels_tmp.mgz"
	#RV ajout de 7 15 16 46 pour le cervelet et le tronc 
	if [ -e ${DIR}/mri/aparc.a2009s+aseg.mgz ]
	then
		mri_extract_label ${DIR}/mri/aparc.a2009s+aseg.mgz 7 10 11 12 13 15 16 17 18 26 46 49 50 51 52 53 54 58 ${DTI}/sc_labels_tmp.mgz
	else
		mri_extract_label ${DIR}/mri/aparc+aseg.mgz 7 10 11 12 13 15 16 17 18 26 46 49 50 51 52 53 54 58 ${DTI}/sc_labels_tmp.mgz
	fi
	echo "mri_or ${DTI}/white.mgz ${DTI}/sc_labels_tmp.mgz ${DTI}/white.mgz"
	mri_or ${DTI}/white.mgz ${DTI}/sc_labels_tmp.mgz ${DTI}/white.mgz
	
	echo "mri_morphology ${DTI}/white.mgz dilate 1 ${DTI}/white_dil.mgz"
	mri_morphology ${DTI}/white.mgz dilate 1 ${DTI}/white_dil.mgz
	
	echo "mri_convert ${DTI}/white_dil.mgz ${DTI}/wm_mask.nii --out_orientation RAS"
	mri_convert ${DTI}/white_dil.mgz ${DTI}/wm_mask.nii --out_orientation RAS
	
	rm -f ${DTI}/lh.white.mgz ${DTI}/rh.white.mgz ${DTI}/white.mgz ${DTI}/white_dil.mgz ${DTI}/sc_labels_tmp.mgz
	
	gzip -f ${DTI}/*.nii
else
	echo "----"
	echo "****----GOT THE wm_mask.nii.gz----****"
	echo "----"
fi

# Step 7. Register T1 to DTI
if [ ! -e ${DTI}/rt1_dti_ras.nii.gz ]
then
	areaSeed=$(basename ${seedMask%.*})
	areaSeed=$(basename ${areaSeed%.*})
	
	areaInclude=$(basename ${includeMask%.*})
	areaInclude=$(basename ${areaInclude%.*})
	
	echo "Step 7 $area $include"
	echo "mri_convert ${DIR}/mri/nu.mgz ${DTI}/t1_native_ras.nii --out_orientation RAS"
	mri_convert ${DIR}/mri/nu.mgz ${DTI}/t1_native_ras.nii --out_orientation RAS
	cmd="mri_convert ${DTI}/wm_mask.nii.gz ${DTI}/wm_mask_ras.nii.gz --out_orientation RAS"
	echo $cmd; eval $cmd
	cmd="mri_convert ${seedMask} ${DIR}/mri/${areaSeed}_ras.nii.gz --out_orientation RAS"
	echo $cmd; eval $cmd
	cmd="mri_convert ${includeMask} ${DIR}/mri/${areaInclude}_ras.nii.gz --out_orientation RAS"
	echo $cmd; eval $cmd

	cmd="cp -f ${DTI}/t1_native_ras.nii ${DTI}/t1_dti_ras.nii"
	echo $cmd; eval $cmd
	cmd="cp -f ${DTI}/wm_mask_ras.nii.gz ${DTI}/wm_mask_dti.nii.gz"
	echo $cmd; eval $cmd
	cmd="cp -f ${DIR}/mri/${areaSeed}_ras.nii.gz ${DIR}/mri/${areaSeed}_dti.nii.gz"
	echo $cmd; eval $cmd
	cmd="cp -f ${DIR}/mri/${areaInclude}_ras.nii.gz ${DIR}/mri/${areaInclude}_dti.nii.gz"
	echo $cmd; eval $cmd

	m=${DIR}/mri/${areaInclude}_dti.nii.gz
	s=${DIR}/mri/${areaSeed}_dti.nii.gz
	
	fslroi ${final_dti} ${DTI}/b0 0 1
	cmd="gunzip -f ${DTI}/b0.nii.gz ${DTI}/wm_mask_dti.nii.gz ${m} ${s} ${m2}"
	echo $cmd ; eval $cmd
	
	s="${s%.*}"
	m="${m%.*}"
	
	echo $s
	echo $m
	
	# SPM coregister estimation
	# Then reslice T1 and brain mask to DTI space
	matlab -nodisplay <<EOF
	spm_jobman('initcfg');
	
	matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.source = {'${DTI}/t1_dti_ras.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.other = {'${s},1';'${m},1';'${DTI}/wm_mask_dti.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

	matlabbatch{2}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{2}.spm.spatial.coreg.write.source = {'${DTI}/t1_dti_ras.nii,1'};
	matlabbatch{2}.spm.spatial.coreg.write.roptions.interp = 1;
	matlabbatch{2}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{2}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{2}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
	matlabbatch{3}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{3}.spm.spatial.coreg.write.source = {'${DTI}/wm_mask_dti.nii,1'};
	matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 1;
	matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
	matlabbatch{4}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{4}.spm.spatial.coreg.write.source = {'$m,1'};
	matlabbatch{4}.spm.spatial.coreg.write.roptions.interp = 1;
	matlabbatch{4}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{4}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{4}.spm.spatial.coreg.write.roptions.prefix = 'r';

	matlabbatch{5}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{5}.spm.spatial.coreg.write.source = {'$s,1'};
	matlabbatch{5}.spm.spatial.coreg.write.roptions.interp = 1;
	matlabbatch{5}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{5}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{5}.spm.spatial.coreg.write.roptions.prefix = 'r';

	inputs = cell(0, 1);
	spm('defaults', 'PET');
	spm_jobman('serial', matlabbatch, '', inputs{:});
EOF
	
	#rm -f ${DTI}/b0.nii
	gzip -f ${DTI}/*.nii
	
	# Remove NaNs
	echo "fslmaths ${DTI}/rt1_dti_ras.nii.gz -nan ${DTI}/rt1_dti_ras.nii.gz"
	fslmaths ${DTI}/rt1_dti_ras.nii.gz -nan ${DTI}/rt1_dti_ras.nii.gz
	
	echo "fslmaths ${DTI}/rwm_mask_dti.nii.gz -nan ${DTI}/rwm_mask_dti.nii.gz"
	fslmaths ${DTI}/rwm_mask_dti.nii.gz -nan ${DTI}/rwm_mask_dti.nii.gz
fi

# Step 8. Performs tractography
	# Step 8.1 Convert images and bvec
if [ ! -e ${DTI}/dti_finalcor.mif ]
then
	echo "Step 8."
	# dti
	gunzip -f ${final_dti}
	cmd="${mrtrix_ver}mrconvert -force ${DTI}/dti_finalcor.nii ${DTI}/dti_finalcor.mif"
	echo ${cmd}
	eval ${cmd}
	gzip -f ${DTI}/dti_finalcor.nii
	
	# wm mask
	gunzip -f ${DTI}/rwm_mask_dti.nii.gz
	cmd="${mrtrix_ver}mrconvert -force ${DTI}/rwm_mask_dti.nii ${DTI}/rwm_mask_dti.mif"
	echo ${cmd}
	eval ${cmd}
	gzip -f ${DTI}/rwm_mask_dti.nii
	
    cmd="${mrtrix_ver}mrthreshold -force -abs 0.1 ${DTI}/rwm_mask_dti.mif  ${DTI}/temp.mif"
	echo ${cmd}
	eval ${cmd}
	mv -f ${DTI}/temp.mif ${DTI}/rwm_mask_dti.mif
	
	# bvec
	cp ${DTI}/dti.bvec ${DTI}/temp.txt
	cat ${DTI}/dti.bval >> ${DTI}/temp.txt
	matlab -nodisplay <<EOF
	bvecs_to_mrtrix('${DTI}/temp.txt', '${DTI}/bvecs_mrtrix');
EOF
	
	rm -f ${DTI}/temp.txt
		
fi

	# Step 8.2 All steps until the response estimate
if [ ! -e ${DTI}/response.txt ]
then
        echo "Step 8.2"
	# Calculate tensors
	cmd="${mrtrix_ver}dwi2tensor -force ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif"
	echo -e "Step 8.2.1 : ${cmd}"
	eval ${cmd}
	
	# Calculate FA
	cmd="${mrtrix_ver}tensor2metric -force  -fa - ${DTI}/dt.mif | ${mrtrix_ver}mrcalc -force - ${DTI}/rwm_mask_dti.mif -mult ${DTI}/fa.mif"	
	echo -e "Step 8.2.2 : ${cmd}"
	eval ${cmd}
		
	# Calculate highly anisotropic voxels
	cmd="${mrtrix_ver}maskfilter -force ${DTI}/rwm_mask_dti.mif erode - |"
	cmd+=" ${mrtrix_ver}maskfilter -force - erode - |"
	cmd+=" ${mrtrix_ver}mrcalc -force  ${DTI}/fa.mif - -mult - |"
	cmd+=" ${mrtrix_ver}mrthreshold -force -abs 0.7 - ${DTI}/sf.mif"
	echo -e "Step 8.2.3 : ${cmd}"
	eval ${cmd}
	
	
	# Estimate response function
	#cmd="/home/global/mrtrix3/scripts/dwi2response manual -lmax ${lmax} -force -grad ${DTI}/bvecs_mrtrix ${DTI}/dti_finalcor.mif ${DTI}/sf.mif ${DTI}/response.txt"
	#cmd="/home/global/mrtrix3/scripts/dwi2response manual -force -grad ${DTI}/bvecs_mrtrix ${DTI}/dti_finalcor.mif ${DTI}/sf.mif ${DTI}/response.txt"
	cmd="${mrtrix_ver}dwi2response tournier -force -grad ${DTI}/bvecs_mrtrix ${DTI}/dti_finalcor.mif ${DTI}/response.txt"
	echo -e "Step 8.2.4 : ${cmd}"
	eval ${cmd}
fi

	# Step 8.3 Spherical deconvolution
if [ ! -e ${DTI}/CSD${lmax}.mif ]
then
	echo "Step 8.3"
	# Local computations to reduce bandwidth usage
	rm -f /tmp/${subj}_CSD${lmax}.mif
	cmd="${mrtrix_ver}dwi2fod -grad ${DTI}/bvecs_mrtrix -lmax ${lmax} -mask ${DTI}/rwm_mask_dti.mif -force csd ${DTI}/dti_finalcor.mif  ${DTI}/response.txt /tmp/${subj}_CSD${lmax}.mif"
	echo -e "Step 8.3 : ${cmd}"
	eval ${cmd}
	cp -f /tmp/${subj}_CSD${lmax}.mif ${DTI}/CSD${lmax}.mif
	rm -f /tmp/${subj}_CSD${lmax}.mif
fi

	# Step 8.4 Fiber tracking
if [ ! -e ${DTI}/whole_brain_${lmax}_${Nfiber}.tck ]
then
	echo "Step 8.4"
	# Stream locally to avoid RAM filling
	# Loop fiber tracking to generate lighter files
	Nfile=`echo "scale=0; ${Nfiber} / 10000" | bc -l`
	Ifile=1
	while [ ${Ifile} -le ${Nfile} ]
	do
		fID=`printf '%.6d' ${Ifile}`
		rm -f /tmp/${subj}_whole_brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part${fID}.tck
		echo "Streaming whole_brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part${fID}.tck"
		#http://doi.org/10.1016/j.neuroimage.2012.06.005

		extension=${seedMask##*.}
		filename=$(basename "${seedMask}")
		filename="${filename%.*}"
		filename="${filename%.*}"
		pathf=$(dirname "${seedMask}")
		s=${pathf}/r${filename}_dti.nii

		extension=${includeMask##*.}
		filename=$(basename "${includeMask}")
		filename="${filename%.*}"
		filename="${filename%.*}"
		pathf=$(dirname "${includeMask}")
		m=${pathf}/r${filename}_dti.nii
		

		cmd="${mrtrix_ver}tckgen -force -algorithm iFOD2 -mask ${DTI}/rwm_mask_dti.mif -seed_image $s -include $m -seeds 0 -select 10000 ${DTI}/CSD${lmax}.mif /tmp/${subj}_brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part${fID}.tck ;"
		echo $cmd ; eval $cmd
		
		cmd="cp -f /tmp/${subj}_brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part${fID}.tck ${DTI}/brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part${fID}.tck;"
		echo $cmd ; eval $cmd
		rm -f /tmp/${subj}_brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part${fID}.tck
		Ifile=$[${Ifile}+1]
	done
	tckedit ${DTI}/brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}_part*.tck ${DTI}/brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}.tck
	#RV touch ${DTI}/whole_brain_${lmax}_${Nfiber}.tck
fi

#RV il faudrait lancer le merge non 
#cf. PrepareSurfConnectome_4_IRMfmemoire.sh
#du coup c'est redondant avec tckedit
	echo "cat_fibers(${Nfiber},${NfiberPerFile},'${DTI}','brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}.');"
	matlab -nodisplay <<EOF
cat_fibers(${Nfiber},${NfiberPerFile},'${DTI}','brain_$(basename ${seedMask%.*})_${lmax}_${Nfiber}');
EOF

	# Step 8.5 Cut the fiber file into small matlab files
# if [ ! -e ${DTI}/whole_brain_${lmax}_${Nfiber}_part000001.tck ]
# then
#	
# matlab -nodisplay <<EOF
# split_fibers('${DTI}/whole_brain_${lmax}_${Nfiber}.tck', '${DTI}', 'whole_brain_${lmax}_${Nfiber}');
# EOF
#	
#fi

# Step 9. Save cortical surfaces in volume space
if [ ! -e ${DIR}/surf/lh.white.ras ]
then
echo "Step 9"
mri_convert ${DIR}/mri/T1.mgz ${DIR}/mri/t1_ras.nii --out_orientation RAS

matlab -nodisplay <<EOF
surf = surf_to_ras_nii('${DIR}/surf/lh.white', '${DIR}/mri/t1_ras.nii');
SurfStatWriteSurf('${DIR}/surf/lh.white.ras', surf, 'b');

surf = surf_to_ras_nii('${DIR}/surf/rh.white', '${DIR}/mri/t1_ras.nii');
SurfStatWriteSurf('${DIR}/surf/rh.white.ras', surf, 'b');
EOF

rm -f ${DIR}/mri/t1_ras.nii

fi

