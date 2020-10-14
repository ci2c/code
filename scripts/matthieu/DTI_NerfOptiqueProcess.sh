#!/bin/bash
	
if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: DTI_NerfOptiqueProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -od		: Path to output directory (processing results)"
	echo ""
	echo "Usage: DTI_NerfOptiqueProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	exit 1
fi

index=1

# Set default parameters
# lmax=10
lmax=6
Nfiber=250000
Radius=2
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_NerfOptiqueProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_NerfOptiqueProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
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
		echo "Usage: DTI_NerfOptiqueProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_NerfOptiqueProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
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

# ################################
# ## Step 1. Prepare DTI data in ${OUTPUT_DIR}/${SUBJ_ID}/dti directory
# ################################
# 
# # Prepare DTI data : Rename dti files 
# iteration=1
# if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti ]
# then
# 	mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti
# else
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/*
# fi
# # DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/sources/*DTI64*.nii*)
# DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/sources/*DTI64*.nii*)
# for dti in ${DtiNii}
# do
# 	if [[ ${dti} == *DTI64*.nii ]]
# 	then
# 		gzip ${dti}
# 		dti=${dti}.gz
# 	fi
# 	base=`basename ${dti}`
# 	base=${base%.nii.gz}
# 	fbval=${INPUT_DIR}/${SUBJ_ID}/sources/${base}.bval
# 	fbvec=${INPUT_DIR}/${SUBJ_ID}/sources/${base}.bvec
# 	NbCol=$(cat ${fbval} | wc -w)
# 	if [ ${NbCol} -eq 130 ]
# 	then				
# 		# Copy and rename files from input to output /dti directory
# 		cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${dti}
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
# 		iteration=$[${iteration}+1]
# 	fi
# done
# 	
# # Zip, copy and rename dticorrection file
# DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/sources/*CORRDTI*.nii*)
# if [ -n "${DtiCorr}" ]
# then
# 	if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/sources/*CORRDTI*.nii | wc -l) -gt 0 ]
# 	then
# 		gzip ${INPUT_DIR}/${SUBJ_ID}/sources/*CORRDTI*.nii
# 		DtiCorr=${DtiCorr}.gz
# 	fi 
# 	cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${DtiCorr}
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*CORRDTI*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
# fi	
# 
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
# 
# # Case of one single dti file : rename bvec & bval files
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# 
# ################################
# ## Step 2. Eddy current correction on dti.nii.gz
# ################################
# 
# # Eddy current correction
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ]
# then
# 	echo "eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor 0"
# 	eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor 0
# fi
# 
# ################################
# ## Step 3. Mean B0 frames, merge bval/bvec files and build final eddy corrected dti for multiple files
# ################################
# 
# # Create temp directory in output /dti dir
# mkdir ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp
# 
# # Write in a file all B0 frames from multiple dti and delete B0 frame from bval/bvec files
# fslsplit ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor -t
# 	
# index_B0=0
# dti=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz
# base=`basename ${dti}`
# base=${base%.nii.gz}
# 		
# # Search B0 split frames, unzip and stock path in a temporary file
# for index_B0 in 0 65
# do
# 	if [ ${index_B0} -le 9 ]
# 	then
# 		gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor000${index_B0}.nii.gz
# 		echo "${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor000${index_B0}.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
# 	elif [ ${index_B0} -le 99 ]
# 	then
# 		gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor00${index_B0}.nii.gz
# 		echo "${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor00${index_B0}.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
# 	fi
# done
# 
# # Delete B0 frames from bval/bvec files associated to dti[i>1]
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bval
# awk '{$66="";print}' ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bval > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bval
# 
# # Mean of all B0 frames
# SPM_Mean_Images.sh -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
# 
# # Rename B0 mean file in output /dti dir
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean*.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii
# 
# # Zip B0 mean file
# gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii
# 	
# # Merge of multiple dti files : Mean B0 at first frame and concatenation of all dti frames
# fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor*.nii.gz
# 
# # Delete temp dir in ouput /dti dir
# rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp
# 
# # Case of one single dti file : rename bvec files
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# 
# ################################
# ## Step 4. Rotate bvec and build final bvec file
# ################################
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec_old ]
# then
# # 	echo "rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec"
# 	rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# fi
# 
# mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
# awk '{$66="";print}' ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
# 
# ################################
# ## Step 5. Correct distortions
# ################################
# 
for_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz
rev_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
bval=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
bvec=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
final_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/dti_finalcor.nii.gz
DCDIR=${OUTPUT_DIR}/${SUBJ_ID}/DC
# 
# if [ -e ${rev_dti} ]
# then
# 	# Estimate distortion corrections
# 	if [ ! -e ${DCDIR}/b0_norm_unwarp.nii.gz ]
# 	then
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/DC ]
# 		then
# 			mkdir ${OUTPUT_DIR}/${SUBJ_ID}/DC
# 		else
# 			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DC/*
# 		fi
# 		echo "fslroi ${for_dti} ${DCDIR}/b0 0 1"
# 		fslroi ${for_dti} ${DCDIR}/b0 0 1
# 		echo "fslroi ${rev_dti} ${DCDIR}/b0_back 0 1"
# 		fslroi ${rev_dti} ${DCDIR}/b0_back 0 1
# 		
# 		gunzip -f ${DCDIR}/*gz
# 		
# 		# AP-flip the image for CMTK
# 		matlab -nodisplay <<EOF
# 		cd ${DCDIR}
# 		V = spm_vol('b0_back.nii');
# 		Y = spm_read_vols(V);
# 		Y = flipdim(Y, 2);
# 		V.fname = 'rb0_back.nii';
# 		spm_write_vol(V,Y);
# EOF
# 
# 		# Normalize the signal
# 		S=`fslstats ${DCDIR}/b0.nii -m`
# 		fslmaths ${DCDIR}/b0.nii -div $S -mul 1000 ${DCDIR}/b0_norm -odt double
# 		
# 		S=`fslstats ${DCDIR}/rb0_back.nii -m`
# 		fslmaths ${DCDIR}/rb0_back.nii -div $S -mul 1000 ${DCDIR}/rb0_back_norm -odt double
# 		
# 		# Launch CMTK
# 		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
# 		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
# 		
# 		gzip -f ${DCDIR}/*.nii
# 	fi
# 	
# 	# Apply distortion corrections to the whole DWI
# 	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz ]
# 	then
# 		echo "fslsplit ${for_dti} ${DCDIR}/voltmp -t"
# 		fslsplit ${for_dti} ${DCDIR}/voltmp -t
# 		
# 		for I in `ls ${DCDIR} | grep voltmp`
# 		do
# 			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
# 			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd
# 			
# 			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
# 			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
# 			
# 			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
# 		done
# 		
# 		echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
# 		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
# 		
# 		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
# 		gzip -f ${DCDIR}/*.nii	
# 	fi
# else
# 	# Rename dti_eddycorf.nii.gz to dti_finalcor.nii.gz
# 	echo "mv ${for_dti} ${final_dti}"
# 	mv ${for_dti} ${final_dti}
# fi
# 
# ################################
# ## Step 6. Compute DTI fit on fully corrected DTI
# ################################
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz ]
# then
# 	echo "bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m"
# 	bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m
# 	
# 	echo "dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval"
# 	dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
# fi
# 
# ################################
# ## Step 7. Get freesurfer WM mask
# ################################
# 
# # init_fs5.3
# export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
# . ${FREESURFER_HOME}/SetUpFreeSurfer.sh
# 
# if [ ! -e ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz ]
# then
# 	echo "Freesurfer was not fully processed"
# 	echo "Script terminated"
# 	exit 1
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii.gz ]
# then
# 	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz"
# 	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz
# 	
# 	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz"
# 	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz
# 	
# 	echo "mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz"
# 	mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz
# 	
# 	echo "mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz"
# 	mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz
# 	
# 	echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii --out_orientation LAS"
# 	mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii --out_orientation LAS
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz
# 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii*

# ###############################
# # Step 8. Register T1, WM mask and Seed coordinates to DTI
# ###############################
# 
# # if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_las.nii.gz ]
# # then
# # 	echo "mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_las.nii --out_orientation LAS"
# # 	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_las.nii --out_orientation LAS
# # 	
# # 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_las.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_las.nii
# # 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz
# 		
# 	fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/b0 0 1
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/b0.nii.gz
# # 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz
# 	
# # # 	SPM coregister estimation
# # # 	Then reslice T1 and brain mask to DTI space
# # 	matlab -nodisplay <<EOF
# # 	cd ${HOME}
# # 	p = pathdef;
# # 	addpath(p);
# # 	
# # 	spm('defaults', 'FMRI');
# # 	spm_jobman('initcfg');
# # 	matlabbatch={};
# # 	
# # 	matlabbatch{end+1}.spm.spatial.coreg.estwrite.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_las.nii,1'};
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.other = {
# # 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii,1'
# # 							      };
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.interp = 1;
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.mask = 0;
# # 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
# # 	
# # 	spm_jobman('run',matlabbatch);
# # EOF
# # 	cp ${INPUT_DIR}/${SUBJ_ID}/sources/*3DT1*.nii ${INPUT_DIR}/${SUBJ_ID}/sources/T1.nii
# # 	mri_convert ${INPUT_DIR}/${SUBJ_ID}/sources/T1.nii ${INPUT_DIR}/${SUBJ_ID}/sources/T1_las.nii --out_orientation LAS
# # 	cp ${INPUT_DIR}/${SUBJ_ID}/sources/T1_las.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/T1_dti_las.nii
# 
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/t1_native_ras.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/T1_dti_ras.nii.gz
# 	gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/T1_dti_ras.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/t1_native_ras.nii.gz
# 		
# # 	Seed coordinates to DTI space
# 	matlab -nodisplay <<EOF
# 	cd ${HOME}
# 	p = pathdef;
# 	addpath(p);
# 	
# 	spm('defaults', 'FMRI');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 	
# 	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/b0.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/T1_dti_ras.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.other = {''};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
# 	
# 	spm_jobman('run',matlabbatch);
# 	
# 	Seed_OG = [-29.45; 68.51; 20.01];
# 	Seed_OD = [23.48; 68.62; 16.01];
# 	Seeds = [Seed_OG Seed_OD];
# 	Seeds = [Seeds;ones(1,size(Seeds,2))];
# 	nifti = load_nifti('${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/T1_dti_ras.nii');
# 	oldnifti = load_nifti('${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/t1_native_ras.nii');
# 	T = nifti.vox2ras/oldnifti.vox2ras;
# 	Seeds_dti = T * Seeds;
# 	Seeds_dti(4,:) = [];
# 	fid = fopen('${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/OG.txt','w');
# 	fprintf(fid,'%g,%g,%g',Seeds_dti(1,1),Seeds_dti(2,1),Seeds_dti(3,1));
# 	fclose(fid);
# 	fid = fopen('${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/OD.txt','w');
# 	fprintf(fid,'%g,%g,%g',Seeds_dti(1,2),Seeds_dti(2,2),Seeds_dti(3,2));
# 	fclose(fid);
# EOF
# 	
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/T1_dti_las.nii
# # 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/*.nii
# # 	
# # # 	Remove NaNs
# # 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_las.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_las.nii.gz"
# # 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_las.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_las.nii.gz
# # 	
# # 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz"
# # 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz
# 	
# # fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_las.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_las.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_las.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/OG.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/OD.txt ${INPUT_DIR}/${SUBJ_ID}/sources/T1_dti.nii ${INPUT_DIR}/${SUBJ_ID}/sources/T1.nii

###############################
# Step 9. Performs tractography
###############################

# # 	# Step 9.1 Convert images and bvec
# # if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif ]
# # then
# # 	# dti
# # 	gunzip -f ${final_dti}
# # 	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif"
# # 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif
# # 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii
# # 	
# 	# wm mask
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.nii.gz
# 	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.mif"
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.nii
# 	echo "threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/temp.mif"
# 	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/temp.mif
# 	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000/mrwm_mask_dti.mif
# 	
# # 	echo "average ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -axis 3 - | threshold - - | median3D - - | median3D - ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif"
# # 	average ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -axis 3 - | threshold - - | median3D - - | median3D - ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif
# # 	
# # 	# bvec
# # 	cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
# # 	cat ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
# # 	matlab -nodisplay <<EOF
# # 	bvecs_to_mrtrix('${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt', '${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix');
# # EOF
# # 	
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
# # 		
# # fi
# # 
# # # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif
# # # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix
# # 
# # 	# Step 9.2 All steps until the response estimate
# # if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt ]
# # then
# # 	# Calculate tensors
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif
# # 	echo "dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif"
# # 	dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif
# # 	
# # 	# Calculate FA
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif
# # 	echo "tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif"
# # 	tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif
# # 	
# # 	# Calculate EV
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif
# # 	echo "tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif"
# # 	tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif
# # 	
# # 	# Calculate highly anisotropic voxels
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
# # 	echo "erode ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif"
# # 	erode ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
# # 	
# # 	# Estimate response function
# # 	echo "estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt"
# # 	estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt
# # fi
# # 
# # # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
# # 
# # 	# Step 9.3 Spherical deconvolution
# # if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif ]
# # then
# # 	# Local computations to reduce bandwidth usage
# # 	# csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif
# # 	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
# # 	csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/mrwm_mask_dti.mif /tmp/${SUBJ_ID}_CSD${lmax}.mif
# # 	cp -f /tmp/${SUBJ_ID}_CSD${lmax}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif
# # 	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
# # fi
# # 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif

# 	Step 9.4 Fiber tracking & Cut the fiber file into small matlab files
for SeedOrigin in OG OD
do  
	qbatch -N DTI_Trac_${SUBJ_ID}_${SeedOrigin} -q M32_q -oe /NAS/tupac/matthieu/Logdir DTI_Tracto_Seed.sh ${SeedOrigin} ${Radius} ${SUBJ_ID} ${OUTPUT_DIR}/${SUBJ_ID}/dti_b1000 ${lmax} ${Nfiber}
	sleep 1
done

# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/OG_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/OG_${lmax}_${Nfiber}.vtk
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/OD_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/OD_${lmax}_${Nfiber}.vtk

# ###############################
# # Step 10. Save cortical surfaces in volume space
# ###############################	
# 
# 
# if [ ! -e ${FS_DIR}/${SUBJ_ID}/surf/lh.white.las ]
# then
# 	gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_las.nii.gz
# 	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${FS_DIR}/${SUBJ_ID}/mri/t1_las.nii --out_orientation LAS
# 
# 	matlab -nodisplay <<EOF
# 	surf = surf_to_las_nii('${FS_DIR}/${SUBJ_ID}/surf/lh.white', '${FS_DIR}/${SUBJ_ID}/mri/t1_las.nii');
# 	SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/lh.white.las', surf, 'b');
# 
# 	surf = surf_to_las_nii('${FS_DIR}/${SUBJ_ID}/surf/rh.white', '${FS_DIR}/${SUBJ_ID}/mri/t1_las.nii');
# 	SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/rh.white.las', surf, 'b');
# 
# 	surf = SurfStatReadSurf({'${FS_DIR}/${SUBJ_ID}/surf/lh.white.las','${FS_DIR}/${SUBJ_ID}/surf/rh.white.las'});
# 
# 	ref_vol_native = load_nifti('${FS_DIR}/${SUBJ_ID}/mri/t1_las.nii');
# 
# 	ref_vol_dti = load_nifti('${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_las.nii');
# 
# 	% Apply the linear transformation matrix
# 	T = ref_vol_dti.vox2las/ref_vol_native.vox2las;
# 	surf.coord = [surf.coord; ones(1, length(surf.coord))];
# 	surf.coord = T * surf.coord;
# 	surf.coord(4,:) = [];
# 
# 	SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/white.las', surf, 'b');
# 	save_surface_vtk(surf,'${FS_DIR}/${SUBJ_ID}/surf/white_las.vtk');
# EOF
# fi
# # rm -f ${FS_DIR}/${SUBJ_ID}/mri/t1_las.nii ${FS_DIR}/${SUBJ_ID}/surf/white_las.vtk
# 
# ##############################
# # Step 11. Extract, Coregister and Binarize Optical Nerve masks
# ##############################	
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask.nii.gz ]
# then
# 	mri_label2vol --label ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_T1.label --regheader ${OUTPUT_DIR}/${SUBJ_ID}/dti/T1.nii --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_T1.nii --temp ${OUTPUT_DIR}/${SUBJ_ID}/dti/T1.nii
# 	mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_T1.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask.nii --out_orientation LAS
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_T1.nii
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii.gz ]
# then
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask_dti.nii.gz
# 	cp ${INPUT_DIR}/${SUBJ_ID}/sources/T1_las.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/T1_dti_las.nii
# 	
# 	fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0 0 1
# 	
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask_dti.nii.gz
# 	
# 	# SPM coregister estimation
# 	# Then reslice LON_mask to DTI space
# 	matlab -nodisplay <<EOF
# 	spm('defaults', 'FMRI');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 	
# 	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/T1_dti_las.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.other = {
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask_dti.nii,1'
# 							      };
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
# 	
# 	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.write.source = {
# 							    '${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask_dti.nii,1'
# 							    };
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 1;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
# 	
# 	spm_jobman('run',matlabbatch);
# EOF
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/T1_dti_las.nii
# 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	
# 	# Remove NaNs
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii.gz
# 	mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_maskb_dti.nii.gz
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_maskb_dti.nii*
# 
# ##############################
# # Step 12. Get fibers probability map for each ROI linked to Optical Nerve
# ##############################	
# 
# mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/MRtrix_FA.nii
# mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/MRtrix_FA.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/MRtrix_FA_LAS.nii --out_orientation LAS
# gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rLON_maskb_dti.nii.gz
# for NameRoi in OG
# do  
# 	qbatch -N DTI_Prob_${SUBJ_ID}_${NameRoi} -q M32_q -oe ~/Logdir DTI_Prob_Fibers_ROI.sh ${NameRoi} ${SUBJ_ID} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# 	sleep 1
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/TDI_LON.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/LON.vtk ${OUTPUT_DIR}/${SUBJ_ID}/dti/Prob_LON.nii*
# done
# # WaitForJobs.sh DTI_Prob_${SUBJ_ID}_LON
# # gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii