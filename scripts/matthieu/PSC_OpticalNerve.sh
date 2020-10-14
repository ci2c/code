#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: PSC_OpticalNerve.sh  -fs  <SubjDir>  -subj  <SubjName> -field <StrengthField> [-N <Nfiber>  -no-shift]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -field StrengthField         : Strength of magnetic field (1000 or 2000)"	
	echo " "
	echo "Options :"
	echo "  -N Nfiber                    : Number of fibers (default : 50000)"
	echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
	echo "                                    (default : Does apply voxel shift)"
	echo " "
	echo "Important 1 : To make the script working, please create the directory dti_b${StrengthField} within SubjDir/SubjName"
	echo "            And copy the Diffusion weighted images and gradient files."
	echo "            There sould be 4 files in the dti_b${StrengthField} directory prior to running the script :"
	echo "            1. dti_back.nii.gz [Reverse acquisition]"
	echo "            2. dti.nii.gz      [Forward acquisition]"
	echo "            3. dti.bval        [B-values of the forward acquisition]"
	echo "            4. dti.bvec        [Directions of the gradients of the forward DWI]"
	echo "If these 4 files can not be found, the script will fail."
	echo ""	
	echo "Important 2 : To make the script working, the 3 files below had to been created in the directory label within SubjDir/SubjName"
	echo "            1. LON_T1.label    : Left Optical Nerve label based on SubjDir/SubjName/mri/t1_native_ras.nii image"
	echo "            2. RON_T1.label    : Right Optical Nerve label based on SubjDir/SubjName/mri/t1_native_ras.nii image"	
	echo "            3. m3DT1_brain_mask.nii.gz : Manual brain mask of t1_native_ras.nii image adjusted to include optical nerves"
	echo " "
	echo "If these 3 files can not be found, the script will fail."
	echo ""
	echo "Usage: PSC_OpticalNerve.sh  -fs  <SubjDir>  -subj  <SubjName>  -field <StrengthField> [-N <Nfiber>  -no-shift]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
vox_shift=1
# lmax=4
# Radius=2
Nfiber=50000
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PSC_OpticalNerve.sh  -fs  <SubjDir>  -subj  <SubjName> -field <StrengthField> [-N <Nfiber>  -no-shift]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -field StrengthField         : Strength of magnetic field (1000 or 2000)"	
		echo " "
		echo "Options :"
		echo "  -N Nfiber                    : Number of fibers (default : 50000)"
		echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
		echo "                                    (default : Does apply voxel shift)"
		echo " "
		echo "Important 1 : To make the script working, please create the directory dti_b${StrengthField} within SubjDir/SubjName"
		echo "            And copy the Diffusion weighted images and gradient files."
		echo "            There sould be 4 files in the dti_b${StrengthField} directory prior to running the script :"
		echo "            1. dti_back.nii.gz [Reverse acquisition]"
		echo "            2. dti.nii.gz      [Forward acquisition]"
		echo "            3. dti.bval        [B-values of the forward acquisition]"
		echo "            4. dti.bvec        [Directions of the gradients of the forward DWI]"
		echo "If these 4 files can not be found, the script will fail."
		echo ""	
		echo "Important 2 : To make the script working, the 3 files below had to been created in the directory label within SubjDir/SubjName"
		echo "            1. LON_T1.label    : Left Optical Nerve label based on SubjDir/SubjName/mri/t1_native_ras.nii image"
		echo "            2. RON_T1.label    : Right Optical Nerve label based on SubjDir/SubjName/mri/t1_native_ras.nii image"	
		echo "            3. m3DT1_brain_mask.nii.gz : Manual brain mask of t1_native_ras.nii image adjusted to include optical nerves"
		echo " "
		echo "If these 3 files can not be found, the script will fail."
		echo ""
		echo "Usage: PSC_OpticalNerve.sh  -fs  <SubjDir>  -subj  <SubjName>  -field <StrengthField> [-N <Nfiber>  -no-shift]"
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
	-field)
		StrengthField=`expr $index + 1`
		eval StrengthField=\${$StrengthField}
		echo "  |-------> Strength of the field : ${StrengthField}"
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


# Check inputs
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

DTI=${DIR}/dti_b${StrengthField}
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

T1_ras=${DIR}/mri/t1_native_ras.nii
if [ ! -e ${T1_ras} ]
then
	echo "Can not find file ${T1_ras}"
	exit 1
fi

LON_label=${DIR}/label/LON_T1.label
if [ ! -e ${LON_label} ]
then
	echo "Can not find file ${LON_label}"
	exit 1
fi

RON_label=${DIR}/label/RON_T1.label
if [ ! -e ${RON_label} ]
then
	echo "Can not find file ${RON_label}"
	exit 1
fi

m_brain_mask=${DIR}/label/m3DT1_brain_mask.nii.gz
if [ ! -e ${m_brain_mask} ]
then
	echo "Can not find file ${m_brain_mask}"
	exit 1
fi

DCDIR=${DTI}/distorsion_correction

# Step 1. Extract labels to volumes
mri_label2vol --label ${LON_label} --regheader ${DIR}/mri/t1_native_ras.nii --o ${DIR}/label/LON_3DT1.nii --temp ${DIR}/mri/t1_native_ras.nii
mri_label2vol --label ${RON_label} --regheader ${DIR}/mri/t1_native_ras.nii --o ${DIR}/label/RON_3DT1.nii --temp ${DIR}/mri/t1_native_ras.nii

# Step 2. Correct distortions
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

# Step 3. Eddy current correction
if [ ! -e ${DTI}/dti_eddycor.ecclog ]
then
	echo "eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0"
	eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0
fi

# Step 4. Rotate bvec
if [ ! -e ${DTI}/dti.bvec_old ]
then
	echo "rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}"
	rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}
fi

# Step 5. Apply distortion corrections to the whole DWI
final_dti=${DTI}/dti_finalcor.nii.gz
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

# Step 6. Compute DTI fit on fully corrected DTI
if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
then
	echo "bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m"
	bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m
	
	echo "dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval"
	dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval
fi

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
	cp -f ${DIR}/mri/t1_native_ras.nii ${DTI}/t1_dti_ras.nii
	cp -f ${DIR}/label/LON_3DT1.nii ${DTI}/LON_3DT1_dti.nii
	cp -f ${DIR}/label/RON_3DT1.nii ${DTI}/RON_3DT1_dti.nii
	cp -f ${DIR}/label/m3DT1_brain_mask.nii.gz ${DTI}/m3DT1_brain_mask_dti.nii.gz
	
	fslroi ${final_dti} ${DTI}/b0 0 1
	gunzip -f ${DTI}/b0.nii.gz ${DTI}/m3DT1_brain_mask_dti.nii.gz
	
	# SPM coregister estimation
	# Then reslice T1 and brain mask to DTI space
	matlab -nodisplay <<EOF
	
	%% Load Matlab Path: Matlab 14 and SPM12 needed
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	%% Init of spm_jobman
	spm('defaults', 'PET');
	spm_jobman('initcfg');
	matlabbatch={};
	
	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estimate.source = {'${DTI}/t1_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estimate.other = {
							    '${DTI}/LON_3DT1_dti.nii,1'
							    '${DTI}/RON_3DT1_dti.nii,1'
							    '${DTI}/m3DT1_brain_mask_dti.nii,1'
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
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/LON_3DT1_dti.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/RON_3DT1_dti.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${DTI}/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.source = {'${DTI}/m3DT1_brain_mask_dti.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	spm_jobman('run',matlabbatch);
EOF

# Compute registered seed coordinates
# # # 	Seed_OG = [-29.45; 68.51; 20.01];
# # # 	Seed_OD = [23.48; 68.62; 16.01];
# # # 	Seeds = [Seed_OG Seed_OD];
# # # 	Seeds = [Seeds;ones(1,size(Seeds,2))];
# # # 	nifti = load_nifti('${DTI}/t1_dti_ras.nii');
# # # 	oldnifti = load_nifti('${DTI}/t1_native_ras.nii');
# # # 	T = nifti.vox2ras/oldnifti.vox2ras;
# # # 	Seeds_dti = T * Seeds;
# # # 	Seeds_dti(4,:) = [];
# # # 	fid = fopen('${DTI}/OG.txt','w');
# # # 	fprintf(fid,'%g,%g,%g',Seeds_dti(1,1),Seeds_dti(2,1),Seeds_dti(3,1));
# # # 	fclose(fid);
# # # 	fid = fopen('${DTI}/OD.txt','w');
# # # 	fprintf(fid,'%g,%g,%g',Seeds_dti(1,2),Seeds_dti(2,2),Seeds_dti(3,2));
# # # 	fclose(fid);
# # # EOF
# 	
# # 	rm -f ${DTI}/b0.nii
	
	gzip -f ${DTI}/*.nii
	
	# Remove NaNs
	echo "fslmaths ${DTI}/rt1_dti_ras.nii.gz -nan ${DTI}/rt1_dti_ras.nii.gz"
	fslmaths ${DTI}/rt1_dti_ras.nii.gz -nan ${DTI}/rt1_dti_ras.nii.gz

	echo "fslmaths ${DTI}/rLON_3DT1_dti.nii.gz -nan ${DTI}/rLON_3DT1_dti.nii.gz"
	fslmaths ${DTI}/rLON_3DT1_dti.nii.gz -nan ${DTI}/rLON_3DT1_dti.nii.gz
	
	echo "fslmaths ${DTI}/rRON_3DT1_dti.nii.gz -nan ${DTI}/rRON_3DT1_dti.nii.gz"
	fslmaths ${DTI}/rRON_3DT1_dti.nii.gz -nan ${DTI}/rRON_3DT1_dti.nii.gz
	
	echo "fslmaths ${DTI}/rm3DT1_brain_mask_dti.nii.gz -nan ${DTI}/rm3DT1_brain_mask_dti.nii.gz"
	fslmaths ${DTI}/rm3DT1_brain_mask_dti.nii.gz -nan ${DTI}/rm3DT1_brain_mask_dti.nii.gz
fi

# Step 7bis. Modify manually the brain mask dti_finalcor_brain_mask.nii.gz to include optical nerves --> mdti_finalcor_brain_mask.nii.gz

# Step 8. Performs tractography
	# Step 8.1 Convert images and bvec
if [ ! -e ${DTI}/dti_finalcor.mif ]
then
	# dti
	gunzip -f ${final_dti}
	echo "mrconvert ${DTI}/dti_finalcor.nii ${DTI}/dti_finalcor.mif"
	mrconvert ${DTI}/dti_finalcor.nii ${DTI}/dti_finalcor.mif
	gzip -f ${DTI}/dti_finalcor.nii
	
	# brain mask
	gunzip -f ${DTI}/rm3DT1_brain_mask_dti.nii.gz
	echo "mrconvert ${DTI}/rm3DT1_brain_mask_dti.nii ${DTI}/rm3DT1_brain_mask_dti.mif"
	mrconvert ${DTI}/rm3DT1_brain_mask_dti.nii ${DTI}/rm3DT1_brain_mask_dti.mif
	gzip -f ${DTI}/rm3DT1_brain_mask_dti.nii

	# Optical nerve masks
	gunzip -f ${DTI}/rLON_3DT1_dti.nii.gz
	echo "mrconvert ${DTI}/rLON_3DT1_dti.nii ${DTI}/rLON_3DT1_dti.mif"
	mrconvert ${DTI}/rLON_3DT1_dti.nii ${DTI}/rLON_3DT1_dti.mif
	gzip -f ${DTI}/rLON_3DT1_dti.nii
	
	gunzip -f ${DTI}/rRON_3DT1_dti.nii.gz
	echo "mrconvert ${DTI}/rRON_3DT1_dti.nii ${DTI}/rRON_3DT1_dti.mif"
	mrconvert ${DTI}/rRON_3DT1_dti.nii ${DTI}/rRON_3DT1_dti.mif
	gzip -f ${DTI}/rRON_3DT1_dti.nii
	
	# bvec
	cp ${DTI}/dti.bvec ${DTI}/temp.txt
	cat ${DTI}/dti.bval >> ${DTI}/temp.txt
	matlab -nodisplay <<EOF
	bvecs_to_mrtrix('${DTI}/temp.txt', '${DTI}/bvecs_mrtrix');
EOF
	rm -f ${DTI}/temp.txt
fi

	# Step 8.2 All steps until the response estimate
if [ ! -e ${DTI}/lmax6/response.txt ]
then
	# Calculate tensors
	rm -f ${DTI}/dt.mif
	echo "dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif"
	dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif
	
	# Calculate FA
	rm -f ${DTI}/fa.mif
# 	echo "tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/mdti_finalcor_brain_mask.mif ${DTI}/fa.mif"
# 	tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/mdti_finalcor_brain_mask.mif ${DTI}/fa.mif
	echo "tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/rm3DT1_brain_mask_dti.mif ${DTI}/fa.mif"
	tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/rm3DT1_brain_mask_dti.mif ${DTI}/fa.mif
	
	# Calculate highly anisotropic voxels
	rm -f ${DTI}/sf.mif
	echo "erode ${DTI}/rm3DT1_brain_mask_dti.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif"
	erode ${DTI}/rm3DT1_brain_mask_dti.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif
	
	for lmax in 4 6
	do
		if [ ! -d ${DTI}/lmax${lmax} ]
		then
			mkdir ${DTI}/lmax${lmax}
		else
			rm -rf ${DTI}/lmax${lmax}/*
		fi
		
		# Estimate response function
		echo "estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/lmax${lmax}/response.txt"
		estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/lmax${lmax}/response.txt
	done
fi

	# Step 8.3 Spherical deconvolution
if [ ! -e ${DTI}/lmax6/CSD6.mif ]
then
	for lmax in 4 6
	do	
		# Local computations to reduce bandwidth usage
		rm -f /tmp/${subj}_CSD${lmax}.mif
		csdeconv ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/lmax${lmax}/response.txt -lmax ${lmax} -mask ${DTI}/rm3DT1_brain_mask_dti.mif /tmp/${subj}_CSD${lmax}.mif
		cp -f /tmp/${subj}_CSD${lmax}.mif ${DTI}/lmax${lmax}/CSD${lmax}.mif
		rm -f /tmp/${subj}_CSD${lmax}.mif
	done
fi

# 	# Step 8.4 Fiber tracking from seed origins
# for SeedOrigin in OG OD
# do  
# 	qbatch -N DTI_Trac_${subj}_${SeedOrigin}_${Nfiber} -q M32_q -oe /NAS/tupac/matthieu/Logdir DTI_Tracto_Seed.sh ${SeedOrigin} ${Radius} ${subj} ${DIR}/dti_b1000 ${lmax} ${Nfiber}
# 	sleep 1
# done
# 
	# Step 8.5 Fiber tracking from ROI
for ROI in LON RON
do
	for lmax in 4 6
	do	
		qbatch -N Tract_${subj}_${ROI}_${Nfiber}_${lmax}_b${StrengthField} -q M32_q -oe /NAS/tupac/matthieu/Logdir DTI_Tracto_ROI_ON.sh ${ROI} ${subj} ${DTI} ${lmax} ${Nfiber} ${StrengthField}
	done
done

# 	# Step 8.4 Fiber tracking
# if [ ! -e ${DTI}/whole_brain_${lmax}_${Nfiber}.tck ]
# then
# 	# Stream locally to avoid RAM filling
# 	# Stream locally to avoid RAM filling
# 	# Loop fiber tracking to generate lighter files
# 	Nfile=`echo "scale=0; ${Nfiber} / 10000" | bc -l`
# 	Ifile=1
# 	while [ ${Ifile} -le ${Nfile} ]
# 	do
# 		fID=`printf '%.6d' ${Ifile}`
# 		rm -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck
# 		echo "Streaming whole_brain_${lmax}_${Nfiber}_part${fID}.tck"
# 		streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/mdti_finalcor_brain_mask.mif -mask ${DTI}/mdti_finalcor_brain_mask.mif /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck -num 10000
# 		cp -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck ${DTI}/whole_brain_${lmax}_${Nfiber}_part${fID}.tck
# 		rm -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck
# 		Ifile=$[${Ifile}+1]
# 	done
# 	touch ${DTI}/whole_brain_${lmax}_${Nfiber}.tck
# 	
# 	
# 	# rm -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}.tck
# 	# streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/mdti_finalcor_brain_mask.mif -mask ${DTI}/mdti_finalcor_brain_mask.mif /tmp/${subj}_whole_brain_${lmax}_${Nfiber}.tck -num ${Nfiber}
# 	
# 	# cp -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}.tck ${DTI}/whole_brain_${lmax}_${Nfiber}.tck
# 	# rm -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}.tck
# fi
# 
# 	# Step 8.5 Cut the fiber file into small matlab files
# # if [ ! -e ${DTI}/whole_brain_${lmax}_${Nfiber}_part000001.tck ]
# # then
# #	
# # matlab -nodisplay <<EOF
# # split_fibers('${DTI}/whole_brain_${lmax}_${Nfiber}.tck', '${DTI}', 'whole_brain_${lmax}_${Nfiber}');
# # EOF
# 	
# fi
# 
# 	# Step 9. Save cortical surfaces in volume space
# if [ ! -e ${DIR}/surf/lh.white.ras ]
# then
# 
# mri_convert ${DIR}/mri/T1.mgz ${DIR}/mri/t1_ras.nii --out_orientation RAS
# 
# matlab -nodisplay <<EOF
# surf = surf_to_ras_nii('${DIR}/surf/lh.white', '${DIR}/mri/t1_ras.nii');
# SurfStatWriteSurf('${DIR}/surf/lh.white.ras', surf, 'b');
# 
# surf = surf_to_ras_nii('${DIR}/surf/rh.white', '${DIR}/mri/t1_ras.nii');
# SurfStatWriteSurf('${DIR}/surf/rh.white.ras', surf, 'b');
# EOF
# 
# rm -f ${DIR}/mri/t1_ras.nii
# 
# fi