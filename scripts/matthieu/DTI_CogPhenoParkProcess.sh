#!/bin/bash
	
if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: DTI_CogPhenoParkProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -od		: Path to output directory (processing results)"
	echo ""
	echo "Usage: DTI_CogPhenoParkProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	exit 1
fi

index=1

# Set default parameters
lmax=8
Nfiber=1500000
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_CogPhenoParkProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_CogPhenoParkProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		exit 1
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Path to FS output directory (equivalent to SUBJECTS_DIR) : ${FS_DIR}"
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory containing the rec/par files : ${INPUT_DIR}"
		;;
	-subjid)
		index=$[$index+1]
		eval SUBJ_ID=\${$index}
		echo "Subject ID : ${SUBJ_ID}"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Path to output directory (processing results) : ${OUTPUT_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: DTI_CogPhenoParkProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_CogPhenoParkProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
elif [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${SUBJ_ID} ]
then
	 echo "-subjid argument mandatory"
	 exit 1
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi				

################################
## Step 1. Prepare DTI data in ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto directory
################################

# Prepare DTI data : Use of temporary directory, calculus of bval/bvec and nii files associated, conversion REC/PAR to nii and rename dti files 

# Search of dti rec/par files
Dti=$(ls ${INPUT_DIR}/${SUBJ_ID}/RECPAR/*dti*.par)
if [ -n "${Dti}" ]
then
	# Creation of a temporary source directory
	if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/DTI ]
	then
		mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/DTI
	else
		rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DTI/*
	fi
	
	# Move of dti rec/par in temporary source directory
	cp -t ${OUTPUT_DIR}/${SUBJ_ID}/DTI ${INPUT_DIR}/${SUBJ_ID}/RECPAR/*dti*.rec ${INPUT_DIR}/${SUBJ_ID}/RECPAR/*dti*.par
	
	# Search of dti_64dir rec/par files
	DtiDir=$(ls ${OUTPUT_DIR}/${SUBJ_ID}/DTI/*dti_64*.par)
	
	# Calculus of the bval, bvec and nii files from dti_64dir rec/par files
	if [ -n "${DtiDir}" ]
	then
		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ]
		then
			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto
		else
			rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*
		fi
	
		base=`basename ${DtiDir}`
		base=${base%.par}
		cd ${OUTPUT_DIR}/${SUBJ_ID}/DTI
		par2bval.sh ${DtiDir}
		fbval=${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.bval
		fbvec=${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.bvec
		fnii=${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.nii.gz
		NbCol=$(cat ${fbval} | wc -w)
		if [ ${NbCol} -ne 65 ]
		then
			rm -f ${fbval} ${fbvec} ${fnii}
		else
			# Move files from input to output /dti_tracto directory
			mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${fbval} ${fbvec} ${fnii}
			rm -f ${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.par ${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.rec
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.nii.gz
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bval
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec
		fi

		# Zip, copy and rename dticorrection file
		dcm2nii -f Y -o ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${OUTPUT_DIR}/${SUBJ_ID}/DTI/*dti_corr*.par
		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*dti_corr*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_back.nii.gz
	fi
	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DTI
else
	if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ]
	then
		mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto
	else
		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*
	fi
	DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI64*.nii*)
	if [[ ${DtiNii} == ${INPUT_DIR}/${SUBJ_ID}/*DTI64*.nii ]]
	then
		gzip ${DtiNii}
		DtiNii=${DtiNii}.gz
	fi
	base=`basename ${DtiNii}`
	base=${base%.nii.gz}
	fbval=${INPUT_DIR}/${SUBJ_ID}/${base}.bval
	fbvec=${INPUT_DIR}/${SUBJ_ID}/${base}.bvec
	NbCol=$(cat ${fbval} | wc -w)
	if [ ${NbCol} -eq 65 ]
	then				
		# Copy files from input to output /dti_tracto directory
		cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${fbval} ${fbvec} ${DtiNii}
		
		# Zip and copy dticorrection file
		DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTICORR*.nii*)
		if [ -n "${DtiCorr}" ]
		then
			if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/*DTICORR*.nii | wc -l) -gt 0 ]
			then
				gzip ${INPUT_DIR}/${SUBJ_ID}/*DTICORR*.nii
				DtiCorr=${DtiCorr}.gz
			fi 
			cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${DtiCorr}
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*DTICORR*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_back.nii.gz
		fi	
	fi
fi	

# Positioning current work dir as /home/matthieu
cd

################################
## Step 2. Eddy current correction on dti.nii.gz
################################

# Eddy current correction
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_eddycor.ecclog ]
then
	echo "eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_eddycor 0"
	eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_eddycor 0
fi

################################
## Step 3. Rotate bvec on dti.nii.gz
################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec_old ]
then
	echo "rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec"
	rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec
fi

################################
## Step 4. Correct distortions
################################

for_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_eddycor.nii.gz
rev_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_back.nii.gz
bval=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bval
bvec=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec
final_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii.gz
DCDIR=${OUTPUT_DIR}/${SUBJ_ID}/DC

if [ -e ${rev_dti} ]
then
	# Estimate distortion corrections
	if [ ! -e ${DCDIR}/b0_norm_unwarp.nii.gz ]
	then
		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/DC ]
		then
			mkdir ${OUTPUT_DIR}/${SUBJ_ID}/DC
		else
			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DC/*
		fi
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
		EPIshift_and_flip('b0_back.nii', 'rb0_back.nii', 'sb0_back.nii');
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
	
	# Apply distortion corrections to the whole DWI
	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii.gz ]
	then
		echo "fslsplit ${for_dti} ${DCDIR}/voltmp -t"
		fslsplit ${for_dti} ${DCDIR}/voltmp -t
		
		for I in `ls ${DCDIR} | grep voltmp`
		do
			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd
			
			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
			
			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
		done
		
		echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
		
		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
		gzip -f ${DCDIR}/*.nii	
	fi
else
	# Rename dti_eddycorf.nii.gz to dti_finalcor.nii.gz
	echo "mv ${for_dti} ${final_dti}"
	mv ${for_dti} ${final_dti}
fi

################################
## Step 5. Compute DTI fit on fully corrected DTI
################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor_brain_mask.nii.gz ]
then
	echo "bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor_brain -F -f 0.25 -g 0 -m"
	bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor_brain -F -f 0.25 -g 0 -m
	
	echo "dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bval"
	dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bval
fi

################################
## Step 7. Get freesurfer WM mask
################################

# init_fs5.1
export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

if [ ! -e ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz ]
then
	echo "Freesurfer was not fully processed"
	echo "Script terminated"
	exit 1
fi

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii.gz ]
then
	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz"
	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz
	
	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz"
	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz
	
	echo "mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz"
	mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz
	
	echo "mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz"
	mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz
	
	echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii --out_orientation LAS"
	mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii --out_orientation LAS
	
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz
	
	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*.nii
fi
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii*

################################
## Step 8. Register T1, WM mask to DTI
################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_dti_ras.nii.gz ]
then
	echo "mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_ras.nii --out_orientation RAS"
	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_ras.nii --out_orientation RAS
	
	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_ras.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_dti_ras.nii
	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_dti.nii.gz
	
	fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0 0 1
	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_dti.nii.gz
	
	# SPM coregister estimation
	# Then reslice T1 and brain mask to DTI space
	matlab -nodisplay <<EOF
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
	
	matlabbatch{end+1}.spm.spatial.coreg.estwrite.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estwrite.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estwrite.other = {'${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_dti.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.interp = 4;
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
	
	spm_jobman('run',matlabbatch);
EOF
	
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii
	
	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*.nii
	
	# Remove NaNs
	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_dti_ras.nii.gz"
	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_dti_ras.nii.gz
	
	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_dti.nii.gz"
	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii.gz
fi

# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_dti_las.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_las.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_dti.nii* 
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii* 
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_dti_las.nii*

################################
## Step 9. Performs tractography
################################

	# Step 9.1 Convert images and bvec
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif ]
then
	# dti
	gunzip -f ${final_dti}
	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif"
	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif
	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii
	
	# wm mask
	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii.gz
	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif"
	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif
	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii
	echo "threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.mif"
	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.mif
	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif
	
	# bvec
	cp ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt
	cat ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti.bval >> ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt
	matlab -nodisplay <<EOF
	bvecs_to_mrtrix('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix');
EOF
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt
fi

# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix

	# Step 9.2 All steps until the response estimate
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response.txt ]
then
	# Calculate tensors
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif
	echo "dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif"
	dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif
	
	# Calculate FA
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif
	echo "tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif"
	tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif
	
	# Calculate EV
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/ev.mif
	echo "tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/ev.mif"
	tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/ev.mif
	
	# Calculate highly anisotropic voxels
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf.mif
	echo "erode ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf.mif"
	erode ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf.mif
	
	# Estimate response function
	echo "estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response.txt"
	estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response.txt
fi

	# Step 9.3 Spherical deconvolution
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}.mif ]
then
	# Local computations to reduce bandwidth usage
	# csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}.mif
	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
	csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif /tmp/${SUBJ_ID}_CSD${lmax}.mif
	cp -f /tmp/${SUBJ_ID}_CSD${lmax}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}.mif
	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
fi

	# Step 9.4 Fiber tracking & Cut the fiber file into small matlab files
qbatch -N DTI_Trac_${SUBJ_ID}_WB1 -q M32_q -oe ~/Logdir DTI_Tracto_WB1.sh ${SUBJ_ID} ${OUTPUT_DIR} ${lmax} ${Nfiber}
sleep 1

# ################################
# ## Step 10. Save cortical surfaces in volume space
# ################################	
# 
# if [ ! -e ${FS_DIR}/${SUBJ_ID}/surf/lh.white.ras ]
# then
# 
# mri_convert ${FS_DIR}/${SUBJ_ID}/mri/T1.mgz ${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii --out_orientation RAS
# 
# matlab -nodisplay <<EOF
# surf = surf_to_ras_nii('${FS_DIR}/${SUBJ_ID}/surf/lh.white', '${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii');
# SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/lh.white.ras', surf, 'b');
# 
# surf = surf_to_ras_nii('${FS_DIR}/${SUBJ_ID}/surf/rh.white', '${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii');
# SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/rh.white.ras', surf, 'b');
# 
# % surf = SurfStatReadSurf({'${FS_DIR}/${SUBJ_ID}/surf/lh.white.ras','${FS_DIR}/${SUBJ_ID}/surf/rh.white.ras'});
# % save_surface_vtk(surf,'${FS_DIR}/${SUBJ_ID}/surf/white_ras.vtk');
# EOF
# 
# # rm -f ${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii ${FS_DIR}/${SUBJ_ID}/surf/white_ras.vtk
# 
# fi