#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_FacialNerveProcess_updated.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift -R <Radius>]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo " "
	echo "Options :"
	echo "  -lmax lmax                   : Maximum harmonic order (default : 6)"
	echo "  -N Nfiber                    : Number of fibers (default : 250000)"
	echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
	echo "                                    (default : Does apply voxel shift)"
	echo "  -R Radius                    : Radius of the seeds for tracking (default : 2)"
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
	echo "Usage: DTI_FacialNerveProcess_updated.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift -R <Radius>]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
vox_shift=1
lmax=6
Nfiber=10000
CutOff=0.1
Radius=3.5
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_FacialNerveProcess_updated.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift -R <Radius>]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo " "
		echo "Options :"
		echo "  -lmax lmax                   : Maximum harmonic order (default : 6)"
		echo "  -N Nfiber                    : Number of fibers (default : 250000)"
		echo "  -no-shift                    : Does not apply the voxel shifting. Used only for Philips images"
		echo "                                    (default : Does apply voxel shift)"
		echo "  -R Radius                    : Radius of the seeds for tracking (default : 2)"
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
		echo "Usage: DTI_FacialNerveProcess_updated.sh  -fs  <SubjDir>  -subj  <SubjName>  [-lmax <lmax>  -N <Nfiber>  -no-shift -R <Radius>]"
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
	-R)
		Radius=`expr $index + 1`
		eval Radius=\${$Radius}
		echo "  |-------> Optional Radius : ${Radius}"
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

DTI=${DIR}/dti_32dir_b2000
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
final_dti=${DTI}/dti_finalcor.nii.gz

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
	V = spm_vol('b0_back.nii');
	Y = spm_read_vols(V);
	
	Y = circshift(Y, [-1 0 0]);
	V.fname = 'sb0_back.nii';
	spm_write_vol(V,Y);
	
	Y = flipdim(Y, 2);
	V.fname = 'rb0_back.nii';
	spm_write_vol(V,Y);
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

# Step 2. Eddy current correction
if [ ! -e ${DTI}/dti_eddycor.ecclog ]
then
	echo "eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0"
	eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0
fi

# Step 3. Rotate bvec
if [ ! -e ${DTI}/dti.bvec_old ]
then
	echo "rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}"
	rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}
fi

# Step 4. Apply distortion corrections to the whole DWI
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

# Step 5. Compute DTI fit on fully corrected DTI
if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
then
	echo "bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m"
	bet ${final_dti} ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m
	
	echo "dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval"
	dtifit --data=${final_dti} --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval
fi

# Step 6. Register T1 to DTI

	# Step 6.1 Brain extraction and creation of brain mask
bet ${DTI}/3DT1.nii.gz ${DTI}/3DT1_brain -n -m -R -f 0.25
fslroi ${final_dti} ${DTI}/b0 0 1
mkdir ${DTI}/ANTs_rigid_bsyn

	# Step 6.2 Compute registration 3DT1 on B0_DTI
antsRegistrationSyNQuick.sh -d 3 -f ${DTI}/b0.nii.gz -m ${DTI}/3DT1.nii.gz -t br -o ${DTI}/ANTs_rigid_bsyn/T12b0

# 	# Step 6.3 Extract facial nerves labels to volumes
# mri_label2vol --label ${DTI}/Facial_Nerve_VII.label --temp ${DTI}/3DT1.nii.gz --identity --o ${DTI}/Facial_Nerve_VII.nii.gz
# mri_label2vol --label ${DTI}/Facial_Nerve_VIII.label --temp ${DTI}/3DT1.nii.gz --identity --o ${DTI}/Facial_Nerve_VIII.nii.gz
# 
# 	# Step 6.4 Apply registration to facial nerves volumes
# antsApplyTransforms -i ${DTI}/Facial_Nerve_VII.nii.gz -r ${DTI}/b0.nii.gz -o ${DTI}/Facial_Nerve_VII_dti.nii.gz -n NearestNeighbor -t ${DTI}/ANTs_rigid_bsyn/T12b01Warp.nii.gz -t ${DTI}/ANTs_rigid_bsyn/T12b00GenericAffine.mat
# antsApplyTransforms -i ${DTI}/Facial_Nerve_VIII.nii.gz -r ${DTI}/b0.nii.gz -o ${DTI}/Facial_Nerve_VIII_dti.nii.gz -n NearestNeighbor -t ${DTI}/ANTs_rigid_bsyn/T12b01Warp.nii.gz -t ${DTI}/ANTs_rigid_bsyn/T12b00GenericAffine.mat

	# Step 6.5 Apply registration to brain mask manually modified to include facial nerves regions
antsApplyTransforms -i ${DTI}/m3DT1_brain_mask.nii.gz -r ${DTI}/b0.nii.gz -o ${DTI}/3DT1_brain_mask_dti.nii.gz -n NearestNeighbor -t ${DTI}/ANTs_rigid_bsyn/T12b01Warp.nii.gz -t ${DTI}/ANTs_rigid_bsyn/T12b00GenericAffine.mat

	# Step 6.6 Remove NaNs
fslmaths ${DTI}/ANTs_rigid_bsyn/T12b0Warped.nii.gz -nan ${DTI}/ANTs_rigid_bsyn/T12b0Warped.nii.gz
fslmaths ${DTI}/3DT1_brain_mask_dti.nii.gz -nan ${DTI}/3DT1_brain_mask_dti.nii.gz
# fslmaths ${DTI}/Facial_Nerve_VII_dti.nii.gz -nan ${DTI}/Facial_Nerve_VII_dti.nii.gz
# fslmaths ${DTI}/Facial_Nerve_VIII_dti.nii.gz -nan ${DTI}/Facial_Nerve_VIII_dti.nii.gz

# Step 7. Performs tractography
	# Step 7.1 Convert images and bvec
if [ ! -e ${DTI}/dti_finalcor.mif ]
then
	# dti
	gunzip -f ${final_dti}
	echo "mrconvert ${DTI}/dti_eddycor.nii ${DTI}/dti_finalcor.mif"
	mrconvert ${DTI}/dti_eddycor.nii ${DTI}/dti_finalcor.mif
	gzip -f ${DTI}/dti_eddycor.nii
	
	# brain mask
	gunzip -f ${DTI}/3DT1_brain_mask_dti.nii.gz
	echo "mrconvert ${DTI}/3DT1_brain_mask_dti.nii ${DTI}/brain_mask.mif"
	mrconvert ${DTI}/3DT1_brain_mask_dti.nii ${DTI}/brain_mask.mif
	gzip -f ${DTI}/3DT1_brain_mask_dti.nii
	
# 	# facial nerve VII
# 	gunzip -f ${DTI}/Facial_Nerve_VII_dti.nii.gz
# 	echo "mrconvert ${DTI}/Facial_Nerve_VII_dti.nii ${DTI}/Facial_Nerve_VII_dti.mif"
# 	mrconvert ${DTI}/Facial_Nerve_VII_dti.nii ${DTI}/Facial_Nerve_VII_dti.mif
# 	gzip -f ${DTI}/Facial_Nerve_VII_dti.nii
# 	
# 	# facial nerve VIII
# 	gunzip -f ${DTI}/Facial_Nerve_VIII_dti.nii.gz
# 	echo "mrconvert ${DTI}/Facial_Nerve_VIII_dti.nii ${DTI}/Facial_Nerve_VIII_dti.mif"
# 	mrconvert ${DTI}/Facial_Nerve_VIII_dti.nii ${DTI}/Facial_Nerve_VIII_dti.mif
# 	gzip -f ${DTI}/Facial_Nerve_VIII_dti.nii
	
	# bvec
	cp ${DTI}/dti.bvec ${DTI}/temp.txt
	cat ${DTI}/dti.bval >> ${DTI}/temp.txt
	matlab -nodisplay <<EOF
	bvecs_to_mrtrix('${DTI}/temp.txt', '${DTI}/bvecs_mrtrix');
EOF
	
	rm -f ${DTI}/temp.txt
		
fi

	# Step 7.2 All steps until the response estimate
if [ ! -e ${DTI}/response.txt ]
then
	# Calculate tensors
	rm -f ${DTI}/dt.mif
	echo "dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif"
	dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif
	
	# Calculate FA
	rm -f ${DTI}/fa.mif
	echo "tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/brain_mask.mif ${DTI}/fa.mif"
	tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/brain_mask.mif ${DTI}/fa.mif
	
	# Calculate highly anisotropic voxels
	rm -f ${DTI}/sf.mif
	echo "erode ${DTI}/brain_mask.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif"
	erode ${DTI}/brain_mask.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif
	
	# Estimate response function
	echo "estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/response.txt"
	estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/response.txt
fi

	# Step 7.3 Spherical deconvolution
if [ ! -e ${DTI}/CSD${lmax}.mif ]
then
	# Local computations to reduce bandwidth usage
	rm -f /tmp/${subj}_CSD${lmax}.mif
	csdeconv ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/response.txt -lmax ${lmax} -mask ${DTI}/brain_mask.mif /tmp/${subj}_CSD${lmax}.mif
	cp -f /tmp/${subj}_CSD${lmax}.mif ${DTI}/CSD${lmax}.mif
	rm -f /tmp/${subj}_CSD${lmax}.mif
fi

	# Step 7.4 Fiber tracking
	# Stream locally to avoid RAM filling
if [ ! -e ${DTI}/Facial_Nerve_VII_${lmax}_${Nfiber}_th${CutOff}.tck ]
then
	rm -f /tmp/${subj}_Facial_Nerve_VII_${lmax}_${Nfiber}_th${CutOff}.tck
	streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/Facial_Nerve_VII_dti.mif -mask ${DTI}/brain_mask.mif /tmp/${subj}_Facial_Nerve_VII_${lmax}_${Nfiber}_th${CutOff}.tck -num ${Nfiber} -cutoff ${CutOff}
		
	cp -f /tmp/${subj}_Facial_Nerve_VII_${lmax}_${Nfiber}_th${CutOff}.tck ${DTI}/Facial_Nerve_VII_${lmax}_${Nfiber}_th${CutOff}.tck
	rm -f /tmp/${subj}_Facial_Nerve_VII_${lmax}_${Nfiber}_th${CutOff}.tck
fi