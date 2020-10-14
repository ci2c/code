#!/bin/bash
	
if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: DTI_HypoAnoProcess_ANTS.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir> -f <ListeROIsPath>"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -od		: Path to output directory (processing results)"
	echo "	-f  		: Path of the file ListeROIs.txt"
	echo ""
	echo "Usage: DTI_HypoAnoProcess_ANTS.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir> -f <ListeROIsPath>"
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
		echo "Usage: DTI_HypoAnoProcess_ANTS.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir> -f <ListeROIsPath>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo "	-f  		: Path of the file ListeROIs.txt"
		echo ""
		echo "Usage: DTI_HypoAnoProcess_ANTS.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir> -f <ListeROIsPath>"
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
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file ListeROIs.txt : ${FILE_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: DTI_HypoAnoProcess_ANTS.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir> -f <ListeROIsPath>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo "	-f  		: Path of the file ListeROIs.txt"
		echo ""
		echo "Usage: DTI_HypoAnoProcess_ANTS.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir> -f <ListeROIsPath>"
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
elif [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

# ################################
# ## Step 1. Prepare DTI data in ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto directory
# ################################
# 
# # Prepare DTI data : Use of temporary directory, calculus of bval/bvec and nii files associated, conversion REC/PAR to nii and rename dti files 
# 
# # Search of dti rec/par files
# Dti=$(ls ${INPUT_DIR}/${SUBJ_ID}/dti[1-9]*.par)
# if [ -n "${Dti}" ]
# then
# 	# Creation of a temporary source directory
# 	if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/DTI ]
# 	then
# 		mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/DTI
# 	else
# 		rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DTI/*
# 	fi
# 	
# 	# Move of dti rec/par in temporary source directory
# 	cp -t ${OUTPUT_DIR}/${SUBJ_ID}/DTI ${INPUT_DIR}/${SUBJ_ID}/dti[1-9]*.rec ${INPUT_DIR}/${SUBJ_ID}/dti[1-9]*.par
# 	
# 	# Search of dti_64dir rec/par files
# 	DtiDir=$(ls ${OUTPUT_DIR}/${SUBJ_ID}/DTI/dti[1-9].par)
# 	
# 	# Calculus of the bval, bvec and nii files from dti_64dir rec/par files
# 	if [ -n "${DtiDir}" ]
# 	then
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ]
# 		then
# 			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto
# 		else
# 			rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*
# 		fi
# 	
# 		for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/DTI/dti[1-9].par)
# 		do
# 			base=`basename ${dti}`
# 			base=${base%.par}
# 			cd ${OUTPUT_DIR}/${SUBJ_ID}/DTI
# 			par2bval.sh ${dti}
# 			fbval=${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.bval
# 			fbvec=${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.bvec
# 			fnii=${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}.nii.gz
# 			NbCol=$(cat ${fbval} | wc -w)
# 			if [ ${NbCol} -ne 65 ]
# 			then
# 				rm -f ${fbval} ${fbvec} ${fnii}
# 			else
# 				# Move files from input to output /dti_tracto directory
# 				mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${fbval} ${fbvec} ${fnii}
# # 				rm -f ${INPUT_DIR}/${SUBJ_ID}/DTI/${base}.par ${INPUT_DIR}/${SUBJ_ID}/DTI/${base}.rec
# 								
# 				cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}_back.rec ${OUTPUT_DIR}/${SUBJ_ID}/DTI/${base}_back.par
# 				dcm2nii -f Y -o ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_back.par
# 				mv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*${base}_back*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_back.nii.gz
# 				rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_back.rec ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_back.par
# 			fi
# 		done
# 	fi
# 	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DTI
# else
# 	if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ]
# 	then
# 		mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto
# 	else
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*
# 	fi
# 	DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/dti[1-9].nii*)
# 	for dti in ${DtiNii}
# 	do
# 		if [[ ${dti} == ${INPUT_DIR}/${SUBJ_ID}/dti[1-9].nii ]]
# 		then
# 			gzip ${dti}
# 			dti=${dti}.gz
# 		fi
# 		base=`basename ${dti}`
# 		base=${base%.nii.gz}
# 		fbval=${INPUT_DIR}/${SUBJ_ID}/${base}.bval
# 		fbvec=${INPUT_DIR}/${SUBJ_ID}/${base}.bvec
# 		NbCol=$(cat ${fbval} | wc -w)
# 		if [ ${NbCol} -eq 65 ]
# 		then				
# 			# Copy files from input to output /dti_tracto directory
# 			cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${fbval} ${fbvec} ${dti}
# 			
# 			# Zip and copy dticorrection file
# 			DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/${base}_back.nii*)
# 			if [ -n "${DtiCorr}" ]
# 			then
# 				if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/${base}_back.nii | wc -l) -gt 0 ]
# 				then
# 					gzip ${INPUT_DIR}/${SUBJ_ID}/${base}_back.nii
# 					DtiCorr=${DtiCorr}.gz
# 				fi 
# 				cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto ${DtiCorr}
# 			fi	
# 		fi
# 	done
# fi	
# 
# # Positioning current work dir as /home/matthieu
# cd
# 
# ################################
# ## Step 2. Eddy current correction on dti[1-9].nii.gz
# ################################
# 
# DCDIR=${OUTPUT_DIR}/${SUBJ_ID}/DC
# if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/DC ]
# then
# 	mkdir ${OUTPUT_DIR}/${SUBJ_ID}/DC
# else
# 	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DC/*
# fi
# 
# for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti[1-9].nii.gz)
# do
# 	base=`basename ${dti}`
# 	base=${base%.nii.gz}
# 
# 	# Eddy current correction
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_eddycor.ecclog ]
# 	then
# 		echo "eddy_correct ${dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_eddycor 0"
# 		eddy_correct ${dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_eddycor 0
# 	fi
# 
# ################################
# ## Step 3. Rotate bvec on dti[1-9].nii.gz
# ################################
# 
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec_old ]
# 	then
# 		echo "rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec"
# 		rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec
# 	fi
# 
# ################################
# ## Step 4. Correct distortions
# ################################
# 
# 	base=dti2
# 	for_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_eddycor.nii.gz
# 	rev_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_back.nii.gz
# 	bval=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bval
# 	bvec=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec
# 	final_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii.gz
# 	
# 	if [ -e ${rev_dti} ]
# 	then
# 		# Estimate distortion corrections
# 		if [ ! -e ${DCDIR}/${base}_b0_norm_unwarp.nii.gz ]
# 		then
# 			echo "fslroi ${for_dti} ${DCDIR}/${base}_b0 0 1"
# 			fslroi ${for_dti} ${DCDIR}/${base}_b0 0 1
# 			echo "fslroi ${rev_dti} ${DCDIR}/${base}_b0_back 0 1"
# 			fslroi ${rev_dti} ${DCDIR}/${base}_b0_back 0 1
# 			
# 			gunzip -f ${DCDIR}/${base}_b0.nii.gz ${DCDIR}/${base}_b0_back.nii.gz
# 			
# 			# Shift the reverse DWI by 1 voxel
# 			# Only for Philips images, for *unknown* reason
# 			# Then AP-flip the image for CMTK
# 			matlab -nodisplay <<EOF
# 			cd ${DCDIR}
# 			EPIshift_and_flip('${base}_b0_back.nii', 'r${base}_b0_back.nii', 's${base}_b0_back.nii');
# EOF
# 
# 			# Normalize the signal
# 			S=`fslstats ${DCDIR}/${base}_b0.nii -m`
# 			fslmaths ${DCDIR}/${base}_b0.nii -div $S -mul 1000 ${DCDIR}/${base}_b0_norm -odt double
# 			
# 			S=`fslstats ${DCDIR}/r${base}_b0_back.nii -m`
# 			fslmaths ${DCDIR}/r${base}_b0_back.nii -div $S -mul 1000 ${DCDIR}/r${base}_b0_back_norm -odt double
# 			
# 			# Launch CMTK
# 			pwd
# 			echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/${base}_jacobian_fwd.nii ${DCDIR}/${base}_b0_norm.nii.gz ${DCDIR}/r${base}_b0_back_norm.nii.gz ${DCDIR}/${base}_b0_norm_unwarp.nii ${DCDIR}/r${base}_b0_back_norm_unwarp.nii ${DCDIR}/${base}_dfield.nrrd"
# 			cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/${base}_jacobian_fwd.nii ${DCDIR}/${base}_b0_norm.nii.gz ${DCDIR}/r${base}_b0_back_norm.nii.gz ${DCDIR}/${base}_b0_norm_unwarp.nii ${DCDIR}/r${base}_b0_back_norm_unwarp.nii ${DCDIR}/${base}_dfield.nrrd
# 			
# 			gzip -f ${DCDIR}/*.nii
# 		fi
# 		
# 		# Apply distortion corrections to the whole DWI
# 		if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii.gz ]
# 		then
# 			echo "fslsplit ${for_dti} ${DCDIR}/voltmp -t"
# 			fslsplit ${for_dti} ${DCDIR}/voltmp -t
# 			
# 			for I in `ls ${DCDIR} | grep voltmp`
# 			do
# 				echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/${base}_b0_norm.nii.gz ${DCDIR}/${base}_dfield.nrrd"
# 				cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/${base}_b0_norm.nii.gz ${DCDIR}/${base}_dfield.nrrd
# 				
# 				echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/${base}_jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
# 				cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/${base}_jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
# 				
# 				rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
# 			done
# 			
# 			echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
# 			fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
# 			
# 			rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
# 			gzip -f ${DCDIR}/*.nii	
# 		fi
# 	else
# 		# Rename ${base}_eddycor.nii.gz to ${base}_finalcor.nii.gz
# 		echo "mv ${for_dti} ${final_dti}"
# 		mv ${for_dti} ${final_dti}
# 	fi
# 
# ################################
# ## Step 5. Compute DTI fit on fully corrected DTI
# ################################
# 
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor_brain_mask.nii.gz ]
# 	then
# 		echo "bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor_brain -F -f 0.25 -g 0 -m"
# 		bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor_brain -F -f 0.25 -g 0 -m
# 		
# 		echo "dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bval"
# 		dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bval
# 	fi
# done
# 
# ################################
# ## Step 7. Get freesurfer WM mask
# ################################
# 
# if [ ! -e ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz ]
# then
# 	echo "Freesurfer was not fully processed"
# 	echo "Script terminated"
# 	exit 1
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii.gz ]
# then
# 	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz"
# 	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz
# 	
# 	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz"
# 	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz
# 	
# 	echo "mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz"
# 	mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz
# 	
# 	echo "mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz"
# 	mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz
# 	
# 	echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii --out_orientation LAS"
# 	mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii --out_orientation LAS
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/white_dil.mgz
# 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*.nii
# fi
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii*
# 
# ################################
# ## Step 8. Register T1, WM mask to DTI
# ################################
# 
# echo "mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_las.nii.gz --out_orientation LAS"
# mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_las.nii.gz --out_orientation LAS
# 
# for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti[1-9].nii.gz)
# do
# 	base=`basename ${dti}`
# 	base=${base%.nii.gz}
# 	bval=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bval
# 	bvec=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec
# 	final_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii.gz
# 	
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii.gz ]
# 	then
# 		cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_las.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_${base}_las.nii.gz
# 		cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_${base}.nii.gz
# 			
# 		fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0 0 1
# # 		gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_${base}_las.nii.gz
# 		
# 		# ANTS affine registration estimation
# 		ANTS 3 -m MI[${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii.gz,${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_${base}_las.nii.gz,1,32] -i 0 -o ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b02t1
# 		
# 		# Then reslice T1 and brain mask to DTI space
# 		WarpImageMultiTransform 3 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_${base}_las.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b02t1Affine.txt -R ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii.gz
# 		WarpImageMultiTransform 3 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b02t1Affine.txt -R ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii.gz
# 		
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/b0.nii.gz
# 		
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/*.nii
# 		
# 		# Remove NaNs
# 		echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii.gz"
# 		fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii.gz
# 		
# 		echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii.gz"
# 		fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii.gz
# 		
# 	fi
# 
# 	# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rt1_${base}_las.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_las.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/wm_mask_${base}.nii* 
# 	# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii* 
# 	# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_${base}_las.nii*
# 
# ################################
# ## Step 9. Performs tractography
# ################################
# 
# 	# Step 9.1 Convert images and bvec
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif ]
# 	then
# 		# dti
# 		gunzip -f ${final_dti}
# 		echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif"
# 		mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif
# 		gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii
# 		
# 		# wm mask
# 		gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii.gz
# 		echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif"
# 		mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif
# 		gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii
# 		echo "threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.mif"
# 		threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.mif
# 		mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif
# 			
# 		# bvec
# 		cp ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt
# 		cat ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}.bval >> ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt
# 		matlab -nodisplay <<EOF
# 		bvecs_to_mrtrix('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base}');
# EOF
# 		
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/temp.txt			
# 	fi
# 
# 	# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif
# 	# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base}
# 
# 	# Step 9.2 All steps until the response estimate
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response_${base}.txt ]
# 	then
# 		# Calculate tensors
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif
# 		echo "dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif"
# 		dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif
# 		
# 		# Calculate FA
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif
# 		echo "tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif"
# 		tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif
# 		
# 		# Calculate EV
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/ev_${base}.mif
# 		echo "tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/ev_${base}.mif"
# 		tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dt_${base}.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/ev_${base}.mif
# 		
# 		# Calculate highly anisotropic voxels
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf_${base}.mif
# 		echo "erode ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf_${base}.mif"
# 		erode ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/fa_${base}.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf_${base}.mif
# 		
# 		# Estimate response function
# 		echo "estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf_${base}.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response_${base}.txt"
# 		estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/sf_${base}.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response_${base}.txt
# 	fi
# 
# 	# Step 9.3 Spherical deconvolution
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}_${base}.mif ]
# 	then
# 		# Local computations to reduce bandwidth usage
# 		# csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response_${base}.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}_${base}.mif
# 		rm -f /tmp/${SUBJ_ID}_CSD${lmax}_${base}.mif
# 		csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/bvecs_mrtrix_${base} ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/response_${base}.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif /tmp/${SUBJ_ID}_CSD${lmax}_${base}.mif
# 		cp -f /tmp/${SUBJ_ID}_CSD${lmax}_${base}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}_${base}.mif
# 		rm -f /tmp/${SUBJ_ID}_CSD${lmax}_${base}.mif
# 	fi
# 
# 	# Step 9.4 Fiber tracking & Cut the fiber file into small matlab files
# # 	qbatch -N DTI_Trac_${SUBJ_ID}_WB_${base} -q M32_q -oe ~/Logdir 
# 	qbatch -N DTI_Trac_${SUBJ_ID}_WB_${base} -q M32_q -oe ~/Logdir  DTI_Tracto_WB.sh ${base} ${SUBJ_ID} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# 	sleep 1
# # done
# 
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

# ###############################
# ## Step 11. Coregister and Binarize Hypothalamus masks
# ###############################	
# 
# if [ -e ${FILE_PATH}/ListeROIs.txt -a -s ${FILE_PATH}/ListeROIs.txt ]
# then
# 	for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti[1-9].nii.gz)
# 	do
# 		base=`basename ${dti}`
# 		base=${base%.nii.gz}
# 		final_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/${base}_finalcor.nii.gz
# 			
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base} ]
# 		then
# 			mkdir ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}
# 		else
# 			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/*
# 		fi
# 	   
# 		while read Roi
# 		do
# 			if [ -s ${FS_DIR}/${SUBJ_ID}/${base}/${Roi}.nii ]
# 			then
# 				echo "mri_convert ${FS_DIR}/${SUBJ_ID}/${base}/${Roi}.nii ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi}_LAS.nii --out_orientation LAS"
# 				mri_convert ${FS_DIR}/${SUBJ_ID}/${base}/${Roi}.nii ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi}_LAS.nii --out_orientation LAS	
# 	
# 				cp -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi}_LAS.nii ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi}_${base}_LAS.nii
# 
# # 				echo "${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi}_${base}_LAS.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/PathsROIs
# 				echo "${Roi}" >> ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt
# 			fi
# 		done < ${FILE_PATH}/ListeROIs.txt
# 
# 		cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/t1_native_las.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/t1_${base}_las.nii.gz
# 			
# 		fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b0 0 1
# 			
# 		gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/t1_${base}_las.nii.gz
# 			
# 		# ANTS affine registration estimation
# 		ANTS 3 -m MI[${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b0.nii,${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/t1_${base}_las.nii,1,32] -i 0 -o ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b02t1
# 		
# 		# Then reslice ROIs to DTI space
# 		while read Roi
# 		do
# 			WarpImageMultiTransform 3 ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi}_${base}_LAS.nii ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}_${base}_LAS.nii ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b02t1Affine.txt -R ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b0.nii
# 		done < ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt
# 				
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/b0.nii
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/*.nii
# 		
# 		while read Roi
# 		do
# 			# Remove NaNs
# 			echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}_${base}_LAS.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}_${base}_LAS.nii.gz"
# 			fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}_${base}_LAS.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}_${base}_LAS.nii.gz
# 			
# 			mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}_${base}_LAS.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}b_${base}_LAS.nii.gz
# 		done < ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt
# 	done
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi1}_LAS.nii
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/${Roi1}_${base}_LAS.nii* ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi1}b_${base}_LAS.nii*

##############################
# Step 12. Get Nb fibers map for each ROI and intersection ROIs
##############################	

# while read Roi1
# do
# 	for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti[1-9].nii.gz)
# 	do
# 		base=`basename ${dti}`
# 		base=${base%.nii.gz}
# 		
# 		gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi1}b_${base}_LAS.nii.gz
# 		
# 		qbatch -N DTI_NbF_${SUBJ_ID}_${base}_${Roi1} -q M32_q -oe ~/Logdir DTI_Nb_Fibers_ROI.sh ${Roi1} ${SUBJ_ID} ${base} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# 		sleep 1
# 	done
# done < ${FILE_PATH}/ListeROIs.txt
# 
# JOBS=`qstat | grep DTI_NbF | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "DTI_NbF pas encore fini"
# sleep 30
# JOBS=`qstat | grep DTI_NbF | wc -l`
# done
# 
# cp ${FILE_PATH}/ListeROIs.txt ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_dti1
# cp ${FILE_PATH}/ListeROIs.txt ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_dti2
# while read Roi1
# do
# 	for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti[1-9].nii.gz)
# 	do
# 		base=`basename ${dti}`
# 		base=${base%.nii.gz}
# 		
# 		tail -n +2 ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ListeROIs.txt > ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/tmp.txt
# 		mv -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/tmp.txt ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ListeROIs.txt
# 		
# 		while read Roi2
# 		do
# 			if [ "${Roi1}" != "${Roi2}" -a -n "${Roi2}" ]
# 			then
# 				gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi2}b_${base}_LAS.nii.gz
# 						
# 				qbatch -N DTI_InterF_${SUBJ_ID}_${base}_${Roi1}_${Roi2} -q M32_q -oe ~/Logdir DTI_Nb_Fibers_Inter_ROI.sh ${Roi1} ${Roi2} ${SUBJ_ID} ${base} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# 				sleep 1
# 			fi
# 		done < ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ListeROIs.txt
# 	done
# done < ${FILE_PATH}/ListeROIs.txt

# JOBS=`qstat | grep DTI_Trac_ | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "DTI_Trac_ pas encore fini"
# sleep 30
# JOBS=`qstat | grep DTI_Trac_ | wc -l`
# done
# 

# for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/dti[1-9].nii.gz)
# do
# 	base=`basename ${dti}`
# 	base=${base%.nii.gz}
# 	
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/*_Color.tck
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/NbFibres_${base}.txt
# 	
# 	if [ -e "${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt" -a -s "${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt" ]
# 	then
# 		
# 		while read Roi
# 		do
# # 			rm -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}bl_${base}_LAS.nii.gz
# 			gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}b_${base}_LAS.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/r${Roi}bl_${base}_LAS.nii.gz
# 		done < ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt
# 		 		
# # 		qbatch -N ${SUBJ_ID}_${base}_DTI_NbF -q M64_q -oe /NAS/dumbo/matthieu/Logdir 
# 		DTI_Nb_Fibers_ROIs.sh ${SUBJ_ID} ${base} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# 		sleep 1
# 	else
# 		echo "Le fichier ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${base}/ROIs.txt n'existe pas ou est vide"
# 	fi
# done

# for fich in $(ls */Connectum*/NbF*)
# do
# 	cat ${fich} | wc -l
# done

# JOBS=`qstat | grep ${SUBJ_ID} | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "${SUBJ_ID} pas encore fini"
# sleep 120
# JOBS=`qstat | grep ${SUBJ_ID} | wc -l`
# done
# 

# gzip ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_dti1/*.nii ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_dti2/*.nii

##############################
# Step 13. Get fonctional correlations between ROIs
##############################	

matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);

	CorrelationROIs('${FS_DIR}','${SUBJ_ID}');
EOF