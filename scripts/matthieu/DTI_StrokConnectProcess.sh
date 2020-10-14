#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_StrokConnectProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo " "
	echo "Options :"
	echo "  -lmax lmax                   : Maximum harmonic order (default : 6)"
	echo "  -N Nfiber                    : Number of fibers (default : 250000)"
	echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
	echo "                                    (default : Does apply voxel shift)"
	echo " "
	echo "Important : To make the script working, please create the directory dti within SubjDir/SubjName"
	echo "            And copy the Diffusion weighted images and gradient files."
	echo "            There sould be 4 files in the dti directory prior to running the script :"
	echo "            1. dti_back.nii.gz [Reverse acquisition]"
	echo "            2. dti.nii.gz      [Forward acquisition]"
	echo "            3. dti.bval        [B-values of the forward acquisition]"
	echo "            4. dti.bec         [Directions of the gradients of the forward DWI]"
	echo " "
	echo "If these 4 files can not be found, the script will fail."
	echo ""
	echo "Usage: DTI_StrokConnectProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
vox_shift=1
lmax=6
Nfiber=500000
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_StrokConnectProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo " "
		echo "Options :"
		echo "  -lmax lmax                   : Maximum harmonic order (default : 6)"
		echo "  -N Nfiber                    : Number of fibers (default : 250000)"
		echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
		echo "                                    (default : Does apply voxel shift)"
		echo " "
		echo "Important : To make the script working, please create the directory dti within SubjDir/SubjName"
		echo "            And copy the Diffusion weighted images and gradient files."
		echo "            There sould be 4 files in the dti directory prior to running the script :"
		echo "            1. dti_back.nii.gz [Reverse acquisition]"
		echo "            2. dti.nii.gz      [Forward acquisition]"
		echo "            3. dti.bval        [B-values of the forward acquisition]"
		echo "            4. dti.bec         [Directions of the gradients of the forward DWI]"
		echo " "
		echo "If these 4 files can not be found, the script will fail."
		echo ""
		echo "Usage: DTI_StrokConnectProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift]"
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
		echo "|-------> Disabled voxel shift"
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

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

## Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh


# Check inputs
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

DTI=${DIR}/dti
if [ ! -e ${DTI} ]
then
	echo "Can not find ${DTI} directory"
fi

rev_dti=${DTI}/dti_back.nii.gz
if [ ! -e ${rev_dti} ]
then
	echo "Can not find file ${rev_dti}"
	exit 1
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

DCDIR=${DTI}/distorsion_correction

# # Step 1. Correct distortions
# if [ ! -e ${DTI}/distorsion_correction/b0_norm_unwarp.nii.gz ]
# then
# 	mkdir ${DTI}/distorsion_correction
# 	echo "fslroi ${for_dti} ${DCDIR}/b0 0 1"
# 	fslroi ${for_dti} ${DCDIR}/b0 0 1
# 	echo "fslroi ${rev_dti} ${DCDIR}/b0_back 0 1"
# 	fslroi ${rev_dti} ${DCDIR}/b0_back 0 1
# 	
# 	gunzip -f ${DCDIR}/*gz
# 	
# 	# Shift the reverse DWI by 1 voxel
# 	# Only for Philips images, for *unknown* reason
# 	# Then AP-flip the image for CMTK
# 	matlab -nodisplay <<EOF
# 	cd ${DCDIR}
# 	V = spm_vol('b0_back.nii');
# 	Y = spm_read_vols(V);
# 	
# 	Y = circshift(Y, [-1 0 0]);
# 	V.fname = 'sb0_back.nii';
# 	spm_write_vol(V,Y);
# 	
# 	Y = flipdim(Y, 2);
# 	V.fname = 'rb0_back.nii';
# 	spm_write_vol(V,Y);
# EOF
# 
# 	# Normalize the signal
# 	S=`fslstats ${DCDIR}/b0.nii -m`
# 	fslmaths ${DCDIR}/b0.nii -div $S -mul 1000 ${DCDIR}/b0_norm -odt double
# 	
# 	S=`fslstats ${DCDIR}/rb0_back.nii -m`
# 	fslmaths ${DCDIR}/rb0_back.nii -div $S -mul 1000 ${DCDIR}/rb0_back_norm -odt double
# 	
# 	# Launch CMTK
# 	echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
# 	cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
# 	
# 	gzip -f ${DCDIR}/*.nii
# fi
# 
# # Step 2. Eddy current correction
# if [ ! -e ${DTI}/dti_eddycor.ecclog ]
# then
# 	echo "eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0"
# 	eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0
# fi
# 
# # Step 3. Rotate bvec
# if [ ! -e ${DTI}/dti.bvec_old ]
# then
# 	echo "rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}"
# 	rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}
# fi
# 
# # Step 4. Apply distortion corrections to the whole DWI
final_dti=${DTI}/dti_finalcor.nii.gz
# if [ ! -e ${DTI}/dti_finalcor.nii.gz ]
# then
# 	echo "fslsplit ${DTI}/dti_eddycor.nii.gz ${DCDIR}/voltmp -t"
# 	fslsplit ${DTI}/dti_eddycor.nii.gz ${DCDIR}/voltmp -t
# 	
# 	for I in `ls ${DCDIR} | grep voltmp`
# 	do
# 		echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
# 		cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd
# 		
# 		echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
# 		cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
# 		
# 		rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
# 	done
# 	
# 	echo "fslmerge -t ${DTI}/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
# 	fslmerge -t ${DTI}/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
# 	
# 	rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
# 	gzip -f ${DCDIR}/*.nii	
# fi
# 
# # Step 5. Compute DTI fit on fully corrected DTI
# if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
# then
# 	echo "bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m"
# 	bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m
# 	
# 	echo "dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval"
# 	dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval
# fi
# 
# # Step 6. Get freesurfer WM mask
# if [ ! -e ${DIR}/mri/aparc.a2009s+aseg.mgz ]
# then
# 	echo "Freesurfer was not fully processed"
# 	echo "Script terminated"
# 	exit 1
# fi
# 
# if [ ! -e ${DTI}/wm_mask.nii.gz ]
# then
# 	echo "mris_fill -r 0.5 -c ${DIR}/surf/lh.white ${DTI}/lh.white.mgz"
# 	mris_fill -r 0.5 -c ${DIR}/surf/lh.white ${DTI}/lh.white.mgz
# 	
# 	echo "mris_fill -r 0.5 -c ${DIR}/surf/rh.white ${DTI}/rh.white.mgz"
# 	mris_fill -r 0.5 -c ${DIR}/surf/rh.white ${DTI}/rh.white.mgz
# 	
# 	echo "mri_or ${DTI}/lh.white.mgz ${DTI}/rh.white.mgz ${DTI}/white.mgz"
# 	mri_or ${DTI}/lh.white.mgz ${DTI}/rh.white.mgz ${DTI}/white.mgz
# 	
# 	# Extract subcortical structures
# 	echo "mri_extract_label ${DIR}/mri/aparc.a2009s+aseg.mgz 10 11 12 13 17 18 26 49 50 51 52 53 54 58 ${DTI}/sc_labels_tmp.mgz"
# 	mri_extract_label ${DIR}/mri/aparc.a2009s+aseg.mgz 10 11 12 13 17 18 26 49 50 51 52 53 54 58 ${DTI}/sc_labels_tmp.mgz
# 	
# 	echo "mri_or ${DTI}/white.mgz ${DTI}/sc_labels_tmp.mgz ${DTI}/white.mgz"
# 	mri_or ${DTI}/white.mgz ${DTI}/sc_labels_tmp.mgz ${DTI}/white.mgz
# 	
# 	echo "mri_morphology ${DTI}/white.mgz dilate 1 ${DTI}/white_dil.mgz"
# 	mri_morphology ${DTI}/white.mgz dilate 1 ${DTI}/white_dil.mgz
# 	
# 	echo "mri_convert ${DTI}/white_dil.mgz ${DTI}/wm_mask.nii --out_orientation RAS"
# 	mri_convert ${DTI}/white_dil.mgz ${DTI}/wm_mask.nii --out_orientation RAS
# 	
# 	rm -f ${DTI}/lh.white.mgz ${DTI}/rh.white.mgz ${DTI}/white.mgz ${DTI}/white_dil.mgz ${DTI}/sc_labels_tmp.mgz
# 	
# 	gzip -f ${DTI}/*.nii
# fi

# Step 7. Register T1 to DTI
if [ ! -e ${DTI}/rt1_dti_ras.nii.gz ]
then
	echo "mri_convert ${DIR}/mri/nu.mgz ${DTI}/t1_native_ras.nii --out_orientation RAS"
	mri_convert ${DIR}/mri/nu.mgz ${DTI}/t1_native_ras.nii --out_orientation RAS

 	echo "mri_convert ${DTI}/aIPS.nii.gz ${DTI}/aIPS_ras.nii.gz --out_orientation RAS"
 	mri_convert ${DTI}/aIPS.nii.gz ${DTI}/aIPS_ras.nii.gz --out_orientation RAS

 	echo "mri_convert ${DTI}/pIPS.nii.gz ${DTI}/pIPS_ras.nii.gz --out_orientation RAS"
 	mri_convert ${DTI}/pIPS.nii.gz ${DTI}/pIPS_ras.nii.gz --out_orientation RAS
 	
 	echo "mri_convert ${DTI}/SPOC.nii.gz ${DTI}/SPOC_ras.nii.gz --out_orientation RAS"
 	mri_convert ${DTI}/SPOC.nii.gz ${DTI}/SPOC_ras.nii.gz --out_orientation RAS
	
	cp -f ${DTI}/t1_native_ras.nii ${DTI}/t1_dti_ras.nii
	cp -f ${DTI}/wm_mask.nii.gz ${DTI}/wm_mask_dti.nii.gz

	cp -f ${DTI}/aIPS_ras.nii.gz ${DTI}/aIPS_dti_ras.nii.gz
	cp -f ${DTI}/pIPS_ras.nii.gz ${DTI}/pIPS_dti_ras.nii.gz
	cp -f ${DTI}/SPOC_ras.nii.gz ${DTI}/SPOC_dti_ras.nii.gz
	
	fslroi ${final_dti} ${DTI}/b0 0 1
	gunzip -f ${DTI}/b0.nii.gz ${DTI}/wm_mask_dti.nii.gz ${DTI}/aIPS_dti_ras.nii.gz ${DTI}/pIPS_dti_ras.nii.gz ${DTI}/SPOC_dti_ras.nii.gz
	
	# SPM coregister estimation
	# Then reslice T1 and brain mask to DTI space
	matlab -nodisplay <<EOF
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
	
	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estimate.source = {'${DTI}/t1_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estimate.other = {
							      '${DTI}/wm_mask_dti.nii,1'
							      '${DTI}/aIPS_dti_ras.nii,1'
							      '${DTI}/pIPS_dti_ras.nii,1'
							      '${DTI}/SPOC_dti_ras.nii,1'							      
							      };
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/t1_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 1;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/wm_mask_dti.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/aIPS_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/pIPS_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/SPOC_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
	spm_jobman('run',matlabbatch);
EOF
	
	rm -f ${DTI}/b0.nii
	
	gzip -f ${DTI}/*.nii
	
	# Remove NaNs
	echo "fslmaths ${DTI}/rt1_dti_ras.nii.gz -nan ${DTI}/rt1_dti_ras.nii.gz"
	fslmaths ${DTI}/rt1_dti_ras.nii.gz -nan ${DTI}/rt1_dti_ras.nii.gz
	
	echo "fslmaths ${DTI}/rwm_mask_dti.nii.gz -nan ${DTI}/rwm_mask_dti.nii.gz"
	fslmaths ${DTI}/rwm_mask_dti.nii.gz -nan ${DTI}/rwm_mask_dti.nii.gz
	
	echo "fslmaths ${DTI}/raIPS_dti_ras.nii.gz -nan ${DTI}/raIPS_dti_ras.nii.gz"
	fslmaths ${DTI}/raIPS_dti_ras.nii.gz -nan ${DTI}/raIPS_dti_ras.nii.gz
	
	echo "fslmaths ${DTI}/rpIPS_dti_ras.nii.gz -nan ${DTI}/rpIPS_dti_ras.nii.gz"
	fslmaths ${DTI}/rpIPS_dti_ras.nii.gz -nan ${DTI}/rpIPS_dti_ras.nii.gz
	
	echo "fslmaths ${DTI}/rSPOC_dti_ras.nii.gz -nan ${DTI}/rSPOC_dti_ras.nii.gz"
	fslmaths ${DTI}/rSPOC_dti_ras.nii.gz -nan ${DTI}/rSPOC_dti_ras.nii.gz
fi

# Step 8. Performs tractography
	# Step 8.1 Convert images and bvec
if [ ! -e ${DTI}/dti_finalcor.mif ]
then
	# dti
	gunzip -f ${final_dti}
	echo "mrconvert ${DTI}/dti_finalcor.nii ${DTI}/dti_finalcor.mif"
	mrconvert ${DTI}/dti_finalcor.nii ${DTI}/dti_finalcor.mif
	gzip -f ${DTI}/dti_finalcor.nii
	
	# wm mask
	gunzip -f ${DTI}/rwm_mask_dti.nii.gz
	echo "mrconvert ${DTI}/rwm_mask_dti.nii ${DTI}/rwm_mask_dti.mif"
	mrconvert ${DTI}/rwm_mask_dti.nii ${DTI}/rwm_mask_dti.mif
	gzip -f ${DTI}/rwm_mask_dti.nii
# 	echo "threshold ${DTI}/rwm_mask_dti.mif -abs 0.1 ${DTI}/temp.mif"
# 	threshold ${DTI}/rwm_mask_dti.mif -abs 0.1 ${DTI}/temp.mif
# 	mv -f ${DTI}/temp.mif ${DTI}/rwm_mask_dti.mif

	# aIPS mask
	gunzip -f ${DTI}/raIPS_dti_ras.nii.gz
	echo "mrconvert ${DTI}/raIPS_dti_ras.nii ${DTI}/raIPS_dti.mif"
	mrconvert ${DTI}/raIPS_dti_ras.nii ${DTI}/raIPS_dti_ras.mif
	gzip -f ${DTI}/raIPS_dti_ras.nii
# 	echo "threshold ${DTI}/raIPS_dti.mif -abs 0.1 ${DTI}/temp.mif"
# 	threshold ${DTI}/raIPS_dti.mif -abs 0.1 ${DTI}/temp.mif
# 	mv -f ${DTI}/temp.mif ${DTI}/raIPS_dti.mif
	
	# pIPS mask
	gunzip -f ${DTI}/rpIPS_dti_ras.nii.gz
	echo "mrconvert ${DTI}/rpIPS_dti_ras.nii ${DTI}/rpIPS_dti_ras.mif"
	mrconvert ${DTI}/rpIPS_dti_ras.nii ${DTI}/rpIPS_dti_ras.mif
	gzip -f ${DTI}/rpIPS_dti_ras.nii
# 	echo "threshold ${DTI}/rpIPS_dti.mif -abs 0.1 ${DTI}/temp.mif"
# 	threshold ${DTI}/rpIPS_dti.mif -abs 0.1 ${DTI}/temp.mif
# 	mv -f ${DTI}/temp.mif ${DTI}/rpIPS_dti.mif
	
	# SPOC mask
	gunzip -f ${DTI}/rSPOC_dti_ras.nii.gz
	echo "mrconvert ${DTI}/rSPOC_dti_ras.nii ${DTI}/rSPOC_dti_ras.mif"
	mrconvert ${DTI}/rSPOC_dti_ras.nii ${DTI}/rSPOC_dti_ras.mif
	gzip -f ${DTI}/rSPOC_dti_ras.nii
# 	echo "threshold ${DTI}/rSPOC_dti.mif -abs 0.1 ${DTI}/temp.mif"
# 	threshold ${DTI}/rSPOC_dti.mif -abs 0.1 ${DTI}/temp.mif
# 	mv -f ${DTI}/temp.mif ${DTI}/rSPOC_dti.mif
	
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
	# Calculate tensors
	rm -f ${DTI}/dt.mif
	echo "dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif"
	dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif
	
	# Calculate FA
	rm -f ${DTI}/fa.mif
	echo "tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/rwm_mask_dti.mif ${DTI}/fa.mif"
	tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/rwm_mask_dti.mif ${DTI}/fa.mif
	
	# Calculate highly anisotropic voxels
	rm -f ${DTI}/sf.mif
	echo "erode ${DTI}/rwm_mask_dti.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif"
	erode ${DTI}/rwm_mask_dti.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif
	
	# Estimate response function
	echo "estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/response.txt"
	estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/response.txt
fi

	# Step 8.3 Spherical deconvolution
if [ ! -e ${DTI}/CSD${lmax}.mif ]
then
	# Local computations to reduce bandwidth usage
	# csdeconv ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/response.txt -lmax ${lmax} -mask ${DTI}/rwm_mask_dti.mif ${DTI}/CSD${lmax}.mif
	rm -f /tmp/${subj}_CSD${lmax}.mif
	csdeconv ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/response.txt -lmax ${lmax} -mask ${DTI}/rwm_mask_dti.mif /tmp/${subj}_CSD${lmax}.mif
	cp -f /tmp/${subj}_CSD${lmax}.mif ${DTI}/CSD${lmax}.mif
	rm -f /tmp/${subj}_CSD${lmax}.mif
fi

	# Step 8.4 Fiber tracking
# if [ ! -e ${DTI}/aIPS_${lmax}_${Nfiber}.tck ]
# then
# 	# Stream locally to avoid RAM filling
# 	rm -f /tmp/${subj}_aIPS_${lmax}_${Nfiber}.tck
# 	streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/raIPS_dti.mif -mask ${DTI}/rwm_mask_dti.mif /tmp/${subj}_aIPS_${lmax}_${Nfiber}.tck -num ${Nfiber}
# 	
# 	cp -f /tmp/${subj}_aIPS_${lmax}_${Nfiber}.tck ${DTI}/aIPS_${lmax}_${Nfiber}.tck
# 	rm -f /tmp/${subj}_aIPS_${lmax}_${Nfiber}.tck	
# fi

qbatch -N DTI_Trac_${subj}_aIPS -q M32_q -oe ~/Logdir DTI_Tracto_ROI.sh aIPS ${subj} ${DTI} ${lmax} ${Nfiber}

qbatch -N DTI_Trac_${subj}_pIPS -q M32_q -oe ~/Logdir DTI_Tracto_ROI.sh pIPS ${subj} ${DTI} ${lmax} ${Nfiber}

qbatch -N DTI_Trac_${subj}_SPOC -q M32_q -oe ~/Logdir DTI_Tracto_ROI.sh SPOC ${subj} ${DTI} ${lmax} ${Nfiber}