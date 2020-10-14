#!/bin/bash

# # Set up FSL (if not already done so in the running environment)
# FSLDIR=${Soft_dir}/fsl509
# . ${FSLDIR}/etc/fslconf/fsl.sh
# 
# # Set up FreeSurfer (if not already done so in the running environment)
# export FREESURFER_HOME=${Soft_dir}/freesurfer6_0/
# . ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# InputDir=/NAS/tupac/matthieu/DARTEL/A0_81patients
InputDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/DARTEL
# InputSubjectsFile=/NAS/tupac/matthieu/Classification/temp_MRI.txt
# InputSubjectsFile=/NAS/tupac/matthieu/DARTEL/A0_81patients/subjects.M0
InputSubjectsFile=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_36patients/subjects_EQ.PET
# SUBJDIR=/NAS/tupac/matthieu/FS5.3
SUBJDIR=/NAS/tupac/protocoles/COMAJ/FS53

# ## Step 1. Copy T1 data resampled onto native PET space
# if [ -s ${InputSubjectsFile} ]
# then	
# 	while read subject
# 	do
# 		gunzip ${SUBJDIR}/${subject}/pet/BS7_T1.npet.nii.gz
# 		
# # 		## Step 1. Reorient T1 control images near MNI space
# # 		matlab -nodisplay <<EOF
# # 		%% Load Matlab Path: Matlab 14 and SPM12 needed
# # 		cd ${HOME}
# # 		p = pathdef14_SPM12;
# # 		addpath(p);
# # 
# # 		%% Init of spm_jobman
# # 		spm('defaults', 'PET');
# # 		spm_jobman('initcfg');
# # 		matlabbatch={};
# # 				
# # 		%% Step 1. Reorient T1 images near MNI_T1_1mm template
# # 		matlabbatch{end+1}.spm.util.reorient.srcfiles = {
# # 								  '${SUBJDIR}/${subject}/pet.adni/BS7_T1.npet.nii,1'
# # 								};
# # 		matlabbatch{end}.spm.util.reorient.transform.transM = [1 0 0 115
# # 								      0 1 0 100
# # 								      0 0 1 -50
# # 								      0 0 0 1];
# # 		matlabbatch{end}.spm.util.reorient.prefix = 'r';
# # 				
# # 		spm_jobman('run',matlabbatch);
# # EOF
# # 		cp ${SUBJDIR}/${subject}/pet/rBS7_T1.npet.nii ${InputDir}/Template/T1.npet.${subject}.nii
# 
# 		## Copy T1 & PET images for DARTEL processing
# 		cp ${SUBJDIR}/${subject}/pet/BS7_T1.npet.nii ${InputDir}/Template/T1.npet.${subject}.nii
# 		gzip ${SUBJDIR}/${subject}/pet/BS7_T1.npet.nii
# 		
# # 		cp ${SUBJDIR}/${subject}/pet/pvelab_Seg12_l0/PET.BS7.lps.MGRousset.gn.nii.gz ${InputDir}/PET.MGRousset.gn.${subject}.nii.gz
# # 		gunzip ${InputDir}/PET.MGRousset.gn.${subject}.nii.gz
# 		
# 		for RECON in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# 		do
# 			cp ${SUBJDIR}/${subject}/pet_std/${RECON}/PET.lps.BS7.gn.nii.gz ${InputDir}/PET/noPVC/${RECON}/PET.gn.${subject}.nii.gz
# 			gunzip ${InputDir}/PET/noPVC/${RECON}/PET.gn.${subject}.nii.gz				
# 			
# 			cp ${SUBJDIR}/${subject}/pet_std/${RECON}/pvelab_Seg12_l0/PET.BS7.lps.MGRousset.gn.nii.gz ${InputDir}/PET/PVC/${RECON}/PET.MGRousset.gn.${subject}.nii.gz
# 			gunzip ${InputDir}/PET/PVC/${RECON}/PET.MGRousset.gn.${subject}.nii.gz
# 		done
# 		
# 	done < ${InputSubjectsFile}
# fi

# ## Step 2. Segment control subjects
# if [ -s ${InputSubjectsFile} ]
# then	
# 	while read subject
# 	do
# # 		qbatch -q two_job_q -oe /NAS/tupac/matthieu/DARTEL/Logdir -N Seg12_${subject}_DARTEL SPM12_SegmentAvgSubject.sh -d ${InputDir}/Template -subj ${subject}
# 		qbatch -q M32_q -oe ${InputDir}/Logdir -N Seg12_${subject}_DARTEL SPM12_SegmentAvgSubject.sh -d ${InputDir}/Template -subj ${subject}
# 		sleep 1
# 	done < ${InputSubjectsFile}
# fi

# WaitForJobs.sh Seg12_

# ## Step 3. Compute DARTEL Template
# if [ -s ${InputSubjectsFile} ]
# then
# 	matlab -nodisplay <<EOF
# 		
# 	%% Load Matlab Path: Matlab 14 and SPM12 version
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
# 
# 	DARTELTemplate('${InputDir}/Template', '${InputSubjectsFile}');
# EOF
# fi

# ## Step 4. Compute Gm mask
# mri_binarize --i ${InputDir}/Template/DARTEL_Template_0.nii --min 0.2 --o ${InputDir}/Template/DARTEL_Template_0_thresh0.2.nii
# mri_binarize --i ${InputDir}/Template/DARTEL_Template_6.nii --min 0.2 --o ${InputDir}/Template/DARTEL_Template_6_thresh0.2.nii
# 
# mri_and ${InputDir}/Template/DARTEL_Template_0_thresh0.2.nii ${InputDir}/Template/DARTEL_Template_6_thresh0.2.nii ${InputDir}/Template/Mask_GM.nii

# ## Step 5. Apply Inverse Warp from GM mask to each subject PET space
# if [ -s ${InputSubjectsFile} ]
# then
# 	matlab -nodisplay <<EOF
# 		
# 	%% Load Matlab Path: Matlab 14 and SPM12 version
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
# 
# 	DARTELInverseWarp('${InputDir}', '${InputSubjectsFile}');
# EOF
# fi

# ## Step 6. Apply Mask to each PVC PET images : patients and controls
# 
# # if [ -d ${InputDir}/DISvsCN ]
# # then
# #     rm -rf ${InputDir}/DISvsCN/*
# # else
# #     mkdir ${InputDir}/DISvsCN
# # fi
# # 
# ## Patients
# if [ -s /NAS/tupac/matthieu/Classification/subjects_TYPvsATYP.txt ]
# then	
# 	while read subject
# 	do
# # 		mri_convert -rl ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.gn.nii.gz -rt nearest ${InputDir}/wMask_GM_u_rc1.T1.npet.${subject}_DARTEL_Template.nii ${InputDir}/GM.mask.${subject}_DARTEL_Template.nii.gz
# 		for type_norm in ncereb gn
# 		do
# # # 			fslmaths ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.${type_norm}.nii.gz -mas ${InputDir}/GM.mask.${subject}_DARTEL_Template.nii.gz ${InputDir}/DISvsCN/PET.sm8.MGRousset.${type_norm}.mask.${subject}.nii.gz
# # 			cp ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.${type_norm}.nii.gz ${InputDir}/DISvsCN/PET.sm8.MGRousset.${type_norm}.${subject}.nii.gz
# # 			gunzip ${InputDir}/DISvsCN/PET.sm8.MGRousset.${type_norm}.${subject}.nii.gz
# 			cp ${SUBJDIR}/${subject}/pet/pvelab_Seg12_l0/PET.BS7.lps.MGRousset.${type_norm}.nii.gz ${InputDir}/DIS/PET.MGRousset.${type_norm}.${subject}.nii.gz
# 			gunzip ${InputDir}/DIS/PET.MGRousset.${type_norm}.${subject}.nii.gz
# 		done
# 
# 	done < /NAS/tupac/matthieu/Classification/subjects_TYPvsATYP.txt
# fi

# ## Controls
# if [ -s /NAS/tupac/matthieu/Classification/Subjects_control_anon.txt ]
# then	
# 	while read subject
# 	do
#  		
# # 		rm -f ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/rPET.BS7.lps.sm8.MGRousset.gn.nii* \
# # 		${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/rPET.BS7.lps.sm8.MGRousset.ncereb.nii* \
# # 		${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/rPET.BS7.lps.sm8.MGRousset.npons.nii*
# # 		
# # 		gunzip ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.npons.nii.gz \
# #  		${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.ncereb.nii.gz \
# #  		${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.gn.nii.gz
# # 		
# # 		## Step 1. Reorient PET control images near MNI space
# # 		matlab -nodisplay <<EOF
# # 		%% Load Matlab Path: Matlab 14 and SPM12 needed
# # 		cd ${HOME}
# # 		p = pathdef14_SPM12;
# # 		addpath(p);
# # 
# # 		%% Init of spm_jobman
# # 		spm('defaults', 'PET');
# # 		spm_jobman('initcfg');
# # 		matlabbatch={};
# # 				
# # 		%% Step 1. Reorient PET images near MNI_T1_1mm template
# # 		matlabbatch{end+1}.spm.util.reorient.srcfiles = {
# # 								  '${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.gn.nii,1'
# # 								  '${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.ncereb.nii,1'
# # 								  '${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.npons.nii,1'
# # 								};
# # 		matlabbatch{end}.spm.util.reorient.transform.transM = [1 0 0 115
# # 								      0 1 0 100
# # 								      0 0 1 -50
# # 								      0 0 0 1];
# # 		matlabbatch{end}.spm.util.reorient.prefix = 'r';
# # 				
# # 		spm_jobman('run',matlabbatch);
# # EOF
# # 		gzip ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.npons.nii \
# # 		${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.ncereb.nii \
# # 		${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/PET.BS7.lps.sm8.MGRousset.gn.nii
# # 
# # 		mri_convert -rl ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/rPET.BS7.lps.sm8.MGRousset.gn.nii -rt nearest ${InputDir}/wMask_GM_u_rc1.T1.npet.${subject}_DARTEL_Template.nii ${InputDir}/GM.mask.${subject}_DARTEL_Template.nii.gz
# 		for type_norm in ncereb gn
# 		do
# # 			fslmaths ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/rPET.BS7.lps.sm8.MGRousset.${type_norm}.nii -mas ${InputDir}/GM.mask.${subject}_DARTEL_Template.nii.gz ${InputDir}/DISvsCN/PET.sm8.MGRousset.${type_norm}.mask.${subject}.nii.gz
# 			cp ${SUBJDIR}/${subject}/pet.adni/pvelab_Seg12_l0/rPET.BS7.lps.sm8.MGRousset.${type_norm}.nii ${InputDir}/DISvsCN/PET.sm8.MGRousset.${type_norm}.${subject}.nii
# 		done
# 
# 	done < /NAS/tupac/matthieu/Classification/Subjects_control_anon.txt
# fi

# ## Step 7. Normalize masked PET images onto MNI space
# # 
# # if [ -s ${InputSubjectsFile} ]
# # then
# # 	matlab -nodisplay <<EOF
# # 		
# # 	%% Load Matlab Path: Matlab 14 and SPM12 version
# # 	cd ${HOME}
# # 	p = pathdef14_SPM12;
# # 	addpath(p);
# # 
# # 	DARTEL_NormalizeMNI('${InputDir}', '${InputSubjectsFile}');
# # EOF
# # fi
# 
# if [ -s ${InputSubjectsFile} ]
# then
# 	for PVC in noPVC PVC
# 	do
# 		for Recon in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# 		do
# 			qbatch -q one_job_q -oe ${InputDir}/Logdir -N NormMNI_${PVC}_${Recon} DARTEL_NormalizeMNI_noMask.sh ${InputDir} ${InputSubjectsFile} ${PVC} ${Recon}
# 			sleep 1
# 		done
# 	done
# fi

# ## Step 8. Affine registration of DARTEL template 6 GM on TPM GM + register GM_mask on MNI space
# flirt -in ${InputDir}/Mask_GM/TPM_0000.nii.gz -ref ${InputDir}/Mask_GM/DARTEL_Template_6.nii.gz -out ${InputDir}/Mask_GM/TPM2Dartel6 -omat ${InputDir}/Mask_GM/TPM2Dartel6.mat -dof 12
# convert_xfm -omat ${InputDir}/Mask_GM/Dartel6ToTPM.mat -inverse ${InputDir}/Mask_GM/TPM2Dartel6.mat
# flirt -in ${InputDir}/Mask_GM/Mask_GM.nii -ref ${InputDir}/Mask_GM/TPM_0000.nii.gz -out ${InputDir}/Mask_GM/Mask_GM_MNI -init ${InputDir}/Mask_GM/Dartel6ToTPM.mat -applyxfm -interp nearestneighbour

# mri_coreg --mov ${InputDir}/Template/TPM_0000.nii  --reg ${InputDir}/Template/TPM2Dartel6.dof12.lta --regdat ${InputDir}/Template/TPM2Dartel6.dof12.dat \
# --dof 12 --no-ref-mask --ref ${InputDir}/Template/DARTEL_Template_6.nii
# mri_vol2vol --mov ${InputDir}/Template/TPM_0000.nii --targ ${InputDir}/Template/Mask_GM.nii --inv --reg ${InputDir}/Template/TPM2Dartel6.dof12.dat --o ${InputDir}/Template/Mask_GM_MNI.nii --nearest


## Step 9. Smooth normalized PET data with GM mask
# WD=/NAS/tupac/matthieu
# if [ -s /NAS/tupac/matthieu/Classification/temp_MRI.txt ]
# then	
# 	while read subject
# 	do
# 		for type_norm in ncereb gn
# 		do
# 			for fwhmvol in 10 12 14
# # 			for fwhmvol in 6 8
# 			do
# 				Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# # # 				fslmaths ${InputDir}/DISvsCN/wPET.sm8.MGRousset.${type_norm}.mask.${subject}.nii.gz -mas ${InputDir}/Mask_GM/Mask_GM_MNI.nii.gz -kernel gauss ${Sigma} -fmean ${InputDir}/DISvsCN/sm${fwhmvol}wPET.sm8.MGRousset.${type_norm}.mask.${subject}.nii.gz
# # # 				gunzip ${InputDir}/DISvsCN/sm${fwhmvol}wPET.sm8.MGRousset.${type_norm}.mask.${subject}.nii.gz
# 				fslmaths ${InputDir}/DISvsCN/wPET.sm8.MGRousset.${type_norm}.${subject}.nii -mas ${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -kernel gauss ${Sigma} -fmean ${InputDir}/DISvsCN/sm${fwhmvol}wPET.sm8.MGRousset.${type_norm}.${subject}.nodil.nii.gz
# 				gunzip ${InputDir}/DISvsCN/sm${fwhmvol}wPET.sm8.MGRousset.${type_norm}.${subject}.nodil.nii.gz
# # 				fslmaths ${InputDir}/DIS/wPET.MGRousset.${type_norm}.${subject}.nii -mas ${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -kernel gauss ${Sigma} -fmean ${InputDir}/DIS/sm${fwhmvol}wPET.MGRousset.${type_norm}.${subject}.nodil.nii.gz
# # 				gunzip ${InputDir}/DIS/sm${fwhmvol}wPET.MGRousset.${type_norm}.${subject}.nodil.nii.gz
# 			done
# 		done
# 	done < /NAS/tupac/matthieu/Classification/temp_MRI.txt
# fi

# mri_convert ${InputDir}/Template/MNI152_T1_1mm_brain_mask.nii ${InputDir}/Template/MNI152_T1_brain_mask.nii -rl ${InputDir}/Template/TPM_0000.nii -rt nearest
if [ -s ${InputSubjectsFile} ]
then
	while read subject
	do
		for PVC in noPVC PVC
		do
			for Recon in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
			do
				for fwhmvol in 6 10 12 15
				do
# 					if [ “${PVC}” == “noPVC” ]
# 					then
# 						rm -f ${InputDir}/PET/${PVC}/${Recon}/sm${fwhmvol}.wPET.gn.${subject}.nii
# 					elif [ “${PVC}” == “PVC” ]
# 					then
# 						rm -f ${InputDir}/PET/${PVC}/${Recon}/sm${fwhmvol}.wPET.MGRousset.gn.${subject}.nii
# 					fi
					
					qbatch -q three_job_q -oe ${InputDir}/Logdir -N Sm${fwhmvol}_${PVC}_${Recon}_${subject} DARTEL_Smooth_NormalizedPET_Mask.sh ${fwhmvol} ${InputDir} ${subject} ${PVC} ${Recon}
					sleep 1
				done
			done
		done
	done < ${InputSubjectsFile}
fi

# # ## Step 10. FSL randomise TYPvsLANGvsVISUvsEXEvsCN ##
# fslmerge -t ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/Randomise.gn.sm8.3Cov/ANOVA_5grps_gn_fwhm8_3Cov $(cat ${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/glim.MGRousset.gn.fwhm8.txt)
# 
# randomise -i ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/Randomise.gn.sm8.3Cov/ANOVA_5grps_gn_fwhm8_3Cov.nii.gz \
# -o ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/Randomise.gn.sm8.3Cov/randomise \
# -d ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/Randomise.gn.sm8.3Cov/ANOVA_5grps.mat \
# -t ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/Randomise.gn.sm8.3Cov/ANOVA_5grps.con \
# -f ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/Randomise.gn.sm8.3Cov/ANOVA_5grps.fts \
# -m ${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii \
# -n 10000 -T -V

# ## Step 11. Full factorial design TYPvsLANGvsVISUvsEXEvsCN ##
# 
# WD=/NAS/tupac/matthieu
# 
# if [ ! -d ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXE/DARTEL_MGRousset_SubCortMask/TYPvsLANGvsVISUvsEXE.gn.sm10.4Cov ]
# then
# 	mkdir ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXE/DARTEL_MGRousset_SubCortMask/TYPvsLANGvsVISUvsEXE.gn.sm10.4Cov
# fi	
# 
# matlab -nodisplay <<EOF
# %% Load Matlab Path: Matlab 14 and SPM12 needed
# cd ${HOME}
# p = pathdef;
# addpath(p);
# 
# %% Open the text files containing patient groups and covariates %%
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/TYP/glim.MGRousset.gn.fwhm10.txt', 'r');
# TYP = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# %fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/ATYP/glim.MGRousset.gn.fwhm10.txt', 'r');
# %ATYP = textscan(fid,'%s','delimiter','\n');
# %fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/LANG/glim.MGRousset.gn.fwhm10.txt', 'r');
# LANG = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/VISU/glim.MGRousset.gn.fwhm10.txt', 'r');
# VISU = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/EXE/glim.MGRousset.gn.fwhm10.txt', 'r');
# EXE = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# %fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/CN/glim.MGRousset.gn.fwhm10.txt', 'r');
# %CN = textscan(fid,'%s','delimiter','\n');
# %fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/Age_M0_TYPvsLANGvsVISUvsEXE.txt', 'r');
# Age_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/Sex_M0_TYPvsLANGvsVISUvsEXE.txt', 'r');
# Sex_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/MMS_M0_TYPvsLANGvsVISUvsEXE.txt', 'r');
# MMS_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/DD_M0_TYPvsLANGvsVISUvsEXE.txt', 'r');
# DD_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# %% Format the cells of patient groups %%
# NbFilesTYP = size(TYP{1},1);
# NbFilesLANG = size(LANG{1},1);
# NbFilesVISU = size(VISU{1},1);
# NbFilesEXE = size(EXE{1},1);
# %NbFilesATYP = size(ATYP{1},1);
# %NbFilesCN = size(CN{1},1);
# Cell_TYP = cell(NbFilesTYP,1);
# Cell_LANG = cell(NbFilesLANG,1);
# Cell_VISU = cell(NbFilesVISU,1);
# Cell_EXE = cell(NbFilesEXE,1);
# %Cell_ATYP = cell(NbFilesATYP,1);
# %Cell_CN = cell(NbFilesCN,1);
# 
# for k= 1 : NbFilesTYP 
#     Cell_TYP{k,1} = [ TYP{1}{k} ',1' ];
# end
# for k= 1 : NbFilesLANG 
#     Cell_LANG{k,1} = [ LANG{1}{k} ',1' ];
# end
# for k= 1 : NbFilesVISU 
#     Cell_VISU{k,1} = [ VISU{1}{k} ',1' ];
# end
# for k= 1 : NbFilesEXE 
#     Cell_EXE{k,1} = [ EXE{1}{k} ',1' ];
# end
# %for k= 1 : NbFilesATYP 
# %    Cell_ATYP{k,1} = [ ATYP{1}{k} ',1' ];
# %end
# %for k= 1 : NbFilesCN 
# %    Cell_CN{k,1} = [ CN{1}{k} ',1' ];
# %end
# 
# %% Init of spm_jobman %%
# spm('defaults', 'PET');
# spm_jobman('initcfg');
# matlabbatch={};
# 
# %% Compute Full factorial design %%
# matlabbatch{end+1}.spm.stats.factorial_design.dir = {'${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXE/DARTEL_MGRousset_SubCortMask/TYPvsLANGvsVISUvsEXE.gn.sm10.4Cov'};
# matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.name = 'Patient Groups';
# matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.levels = 4;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.dept = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.variance = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(1).levels = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(1).scans = Cell_TYP;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).levels = 2;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).scans = Cell_LANG;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(3).levels = 3;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(3).scans = Cell_VISU;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(4).levels = 4;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(4).scans = Cell_EXE;
# %matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).levels = 2;
# %matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).scans = Cell_ATYP;
# %matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(5).levels = 5;
# %matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(5).scans = Cell_CN;
# matlabbatch{end}.spm.stats.factorial_design.des.fd.contrasts = 1;
# %matlabbatch{end}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.cov(1).c = Age_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Age';
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).c = Sex_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Sex';
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).c = MMS_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'MMS';
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(4).c = DD_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(4).cname = 'DD';
# matlabbatch{end}.spm.stats.factorial_design.cov(4).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(4).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.em = {'${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii,1'};
# matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# 
# spm_jobman('run',matlabbatch);
# 
# EOF

# ## Step 12. SnPM between groups ANOVA : TYPvsLANGvsVISUvsEXEvsCN ##
# 
# WD=/NAS/tupac/matthieu
# 
# if [ ! -d ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/SnPM.LANGvsCN.gn.sm6.3Cov ]
# then
# 	mkdir ${WD}/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/SnPM.LANGvsCN.gn.sm6.3Cov
# fi	
# 
# matlab -nodisplay <<EOF
# %% Load Matlab Path: Matlab 14 and SPM12 needed
# cd ${HOME}
# p = pathdef;
# addpath(p);
# 
# %% Open the text files containing patient groups and covariates %%
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/TYP/glim.MGRousset.gn.fwhm6.txt', 'r');
# TYP = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# %fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/ATYP/glim.MGRousset.gn.fwhm6.txt', 'r');
# %ATYP = textscan(fid,'%s','delimiter','\n');
# %fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/LANG/glim.MGRousset.gn.fwhm6.txt', 'r');
# LANG = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/VISU/glim.MGRousset.gn.fwhm6.txt', 'r');
# VISU = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/EXE/glim.MGRousset.gn.fwhm6.txt', 'r');
# EXE = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/CN/glim.MGRousset.gn.fwhm6.txt', 'r');
# CN = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/Age_M0_LANGvsCN.txt', 'r');
# Age_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/Sex_M0_LANGvsCN.txt', 'r');
# Sex_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/MMS_M0_LANGvsCN.txt', 'r');
# MMS_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# %fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_3Cov_MGRousset_SubCortMask/DD_M0_TYPvsLANGvsVISUvsEXE.txt', 'r');
# %DD_M0 = textscan(fid,'%f','delimiter','\n');
# %fclose(fid);
# 
# %% Format the cells of patient groups %%
# NbFilesTYP = size(TYP{1},1);
# NbFilesLANG = size(LANG{1},1);
# NbFilesVISU = size(VISU{1},1);
# NbFilesEXE = size(EXE{1},1);
# %NbFilesATYP = size(ATYP{1},1);
# NbFilesCN = size(CN{1},1);
# Cell_TYP = cell(NbFilesTYP,1);
# Cell_LANG = cell(NbFilesLANG,1);
# Cell_VISU = cell(NbFilesVISU,1);
# Cell_EXE = cell(NbFilesEXE,1);
# %Cell_ATYP = cell(NbFilesATYP,1);
# Cell_CN = cell(NbFilesCN,1);
# 
# for k= 1 : NbFilesTYP 
#     Cell_TYP{k,1} = [ TYP{1}{k} ',1' ];
# end
# for k= 1 : NbFilesLANG 
#     Cell_LANG{k,1} = [ LANG{1}{k} ',1' ];
# end
# for k= 1 : NbFilesVISU 
#     Cell_VISU{k,1} = [ VISU{1}{k} ',1' ];
# end
# for k= 1 : NbFilesEXE 
#     Cell_EXE{k,1} = [ EXE{1}{k} ',1' ];
# end
# %for k= 1 : NbFilesATYP 
# %    Cell_ATYP{k,1} = [ ATYP{1}{k} ',1' ];
# %end
# for k= 1 : NbFilesCN 
#     Cell_CN{k,1} = [ CN{1}{k} ',1' ];
# end
# 
# %% Init of spm_jobman %%
# spm('defaults', 'PET');
# spm_jobman('initcfg');
# matlabbatch={};
# 
# %% Compute Two-sample T-test SnPM design %
# matlabbatch{end+1}.spm.tools.snpm.des.TwoSampT.DesignName = '2 Groups: Two Sample T test; 1 scan per subject';
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.DesignFile = 'snpm_bch_ui_TwoSampT';
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.dir = {'/NAS/tupac/matthieu/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/SnPM.LANGvsCN.gn.sm6.3Cov'};
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans1 = Cell_LANG;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans2 = Cell_CN;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.cov(1).c = Age_M0{1};
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.cov(1).cname = 'Age';
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.cov(2).c = Sex_M0{1};
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.cov(2).cname = 'Sex';
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.cov(3).c = MMS_M0{1};
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.cov(3).cname = 'MMS';
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.nPerm = 5000;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.vFWHM = [10 10 10];
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.bVolm = 1;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.ST.ST_none = 0;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.masking.im = 1;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.masking.em = {'${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii,1'};
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.globalc.g_omit = 1;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.tools.snpm.des.TwoSampT.globalm.glonorm = 1;
# 
# %% Compute %%
# %matlabbatch{1}.spm.tools.snpm.cp.snpmcfg = {'/NAS/tupac/matthieu/SubCort_Analysis/TYPvsLANGvsVISUvsEXEvsCN/DARTEL_MGRousset_SubCortMask/SnPM.gn.sm6.3Cov/SnPMcfg.mat'};
# 
# %% Define contrasts %%
# 
# spm_jobman('run',matlabbatch);
# 
# EOF

# ## Step 13. ANOVA design ##
# 
# WD=/NAS/tupac/matthieu
# 
# if [ ! -d ${WD}/SubCort_Analysis/TYPvsATYPvsCN/DARTEL_MGRousset_SubCortMask/TYPvsATYPvsCN.gn.sm8.3Cov.ANOVA ]
# then
# 	mkdir ${WD}/SubCort_Analysis/TYPvsATYPvsCN/DARTEL_MGRousset_SubCortMask/TYPvsATYPvsCN.gn.sm8.3Cov.ANOVA
# fi	
# 
# matlab -nodisplay <<EOF
# %% Load Matlab Path: Matlab 14 and SPM12 needed
# cd ${HOME}
# p = pathdef14_SPM12;
# addpath(p);
# 
# %% Open the text files containing patient groups and covariates %%
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/TYP/glim.MGRousset.gn.fwhm8.txt', 'r');
# TYP = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/ATYP/glim.MGRousset.gn.fwhm8.txt', 'r');
# ATYP = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/CN/glim.MGRousset.gn.fwhm8.txt', 'r');
# CN = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/Age_M0_TYPvsATYPvsCN.txt', 'r');
# Age_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/Sex_M0_TYPvsATYPvsCN.txt', 'r');
# Sex_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/MMS_M0_TYPvsATYPvsCN.txt', 'r');
# MMS_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# %% Format the cells of patient groups %%
# NbFilesTYP = size(TYP{1},1);
# NbFilesATYP = size(ATYP{1},1);
# NbFilesCN = size(CN{1},1);
# Cell_TYP = cell(NbFilesTYP,1);
# Cell_ATYP = cell(NbFilesATYP,1);
# Cell_CN = cell(NbFilesCN,1);
# 
# for k= 1 : NbFilesTYP 
#     Cell_TYP{k,1} = [ TYP{1}{k} ',1' ];
# end
# for k= 1 : NbFilesATYP 
#     Cell_ATYP{k,1} = [ ATYP{1}{k} ',1' ];
# end
# for k= 1 : NbFilesCN 
#     Cell_CN{k,1} = [ CN{1}{k} ',1' ];
# end
# 
# %% Init of spm_jobman %%
# spm('defaults', 'PET');
# spm_jobman('initcfg');
# matlabbatch={};
# 
# %% Compute ANOVA design %%
# matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/tupac/matthieu/SubCort_Analysis/TYPvsATYPvsCN/DARTEL_MGRousset_SubCortMask/TYPvsATYPvsCN.gn.sm8.3Cov.ANOVA'};
# matlabbatch{end}.spm.stats.factorial_design.des.anova.icell(1).scans = Cell_TYP;
# matlabbatch{end}.spm.stats.factorial_design.des.anova.icell(2).scans = Cell_ATYP;
# matlabbatch{end}.spm.stats.factorial_design.des.anova.icell(3).scans = Cell_CN;
# matlabbatch{end}.spm.stats.factorial_design.des.anova.dept = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.anova.variance = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.anova.gmsca = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.anova.ancova = 0;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).c = Age_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Age';
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).c = Sex_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Sex';
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).c = MMS_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'MMS';
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.em = {'${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii,1'};
# matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# 
# %% Estimate parameters %%
# matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# 
# %% Define contrasts %%
# matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'CN > TYP';
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [-1 0 1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'CN > ATYP';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [0 -1 1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.consess{3}.tcon.name = 'ATYP > TYP';
# matlabbatch{end}.spm.stats.con.consess{3}.tcon.weights = [-1 1 0 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.consess{4}.tcon.name = 'TYP > ATYP';
# matlabbatch{end}.spm.stats.con.consess{4}.tcon.weights = [1 -1 0 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.delete = 0;
# 
# spm_jobman('run',matlabbatch);
# EOF

# ## Step 14. Two-sample T-test : TYP vs ATYP ##
# 
# WD=/NAS/tupac/matthieu
# 
# if [ ! -d ${WD}/SubCort_Analysis/TYPvsATYPvsCN/DARTEL_MGRousset_SubCortMask/TYPvsCN.gn.sm8.3Cov ]
# then
# 	mkdir ${WD}/SubCort_Analysis/TYPvsATYPvsCN/DARTEL_MGRousset_SubCortMask/TYPvsCN.gn.sm8.3Cov
# fi	
# 
# matlab -nodisplay <<EOF
# %% Load Matlab Path: Matlab 14 and SPM12 needed
# cd ${HOME}
# p = pathdef14_SPM12;
# addpath(p);
# 
# %% Open the text files containing patient groups and covariates %%
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/TYP/glim.MGRousset.gn.fwhm8.txt', 'r');
# TYP = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# %fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/ATYP/glim.MGRousset.gn.fwhm8.txt', 'r');
# %ATYP = textscan(fid,'%s','delimiter','\n');
# %fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/CN/glim.MGRousset.gn.fwhm8.txt', 'r');
# CN = textscan(fid,'%s','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/Age_M0_TYPvsCN.txt', 'r');
# Age_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/Sex_M0_TYPvsCN.txt', 'r');
# Sex_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/MMS_M0_TYPvsCN.txt', 'r');
# MMS_M0 = textscan(fid,'%f','delimiter','\n');
# fclose(fid);
# 
# %fid = fopen('${WD}/SubCort_Analysis/Description_files/TYPvsATYPvsCN/DARTEL_3Cov_MGRousset_SubCortMask/DureeMaladie_M0_TYPvsATYP.txt', 'r');
# %DD_M0 = textscan(fid,'%f','delimiter','\n');
# %fclose(fid);
# 
# %% Format the cells of patient groups %%
# NbFilesTYP = size(TYP{1},1);
# %NbFilesATYP = size(ATYP{1},1);
# NbFilesCN = size(CN{1},1);
# Cell_TYP = cell(NbFilesTYP,1);
# %Cell_ATYP = cell(NbFilesATYP,1);
# Cell_CN = cell(NbFilesCN,1);
# 
# for k= 1 : NbFilesTYP 
#     Cell_TYP{k,1} = [ TYP{1}{k} ',1' ];
# end
# %for k= 1 : NbFilesATYP 
# %    Cell_ATYP{k,1} = [ ATYP{1}{k} ',1' ];
# %end
# for k= 1 : NbFilesCN 
#     Cell_CN{k,1} = [ CN{1}{k} ',1' ];
# end
# 
# %% Init of spm_jobman %%
# spm('defaults', 'PET');
# spm_jobman('initcfg');
# matlabbatch={};
# 
# %% Compute Two-sample T-test design %%
# matlabbatch{end+1}.spm.stats.factorial_design.dir = {'${WD}/SubCort_Analysis/TYPvsATYPvsCN/DARTEL_MGRousset_SubCortMask/TYPvsCN.gn.sm8.3Cov'};
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = Cell_TYP;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 = Cell_CN;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.dept = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.gmsca = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.ancova = 0;
# %matlabbatch{end}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.cov(1).c = Age_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Age';
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).c = Sex_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Sex';
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).c = MMS_M0{1};
# matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'MMS';
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# %matlabbatch{end}.spm.stats.factorial_design.cov(4).c = DD_M0{1};
# %matlabbatch{end}.spm.stats.factorial_design.cov(4).cname = 'diseaseDuration';
# %matlabbatch{end}.spm.stats.factorial_design.cov(4).iCFI = 1;
# %matlabbatch{end}.spm.stats.factorial_design.cov(4).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.em = {'${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii,1'};
# matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# 
# %% Estimate parameters %%
# matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# 
# %% Define contrasts %%
# matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'CN > TYP';
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [-1 1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
# %matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'TYP > ATYP';
# %matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [1 -1 0 0];
# %matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.delete = 0;
# 
# spm_jobman('run',matlabbatch);
# 
# EOF