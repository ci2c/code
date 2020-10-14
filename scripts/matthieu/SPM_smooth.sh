#!/bin/bash	

DIR=/NAS/tupac/matthieu/Siemens/Siemens_Validation_Scenium/Nifti
# # DIR=/NAS/tupac/matthieu/Siemens/Siemens_GE_Validation
# # DIR=/NAS/tupac/matthieu/RAW_DATA/ZUREK_MICHEL_2016-01-27/OSEM_TOF_Validation/Validation_07112016/Validation
# # DIR=/NAS/tupac/matthieu/Siemens/Scenium/Nifti
# # DIR=/NAS/tupac/matthieu/Siemens/207138_GE_Siemens_validation/Siemens
# # fwhmvol=2.3152
# # ImgName=ZUREK_MICHEL_20160127_3367376_020_OSEM_TOF_i6_s21_g2_9_Res

# ## Use of FSL gaussian smooth
# Sigma=`echo "${fwhmvol} / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# # fslmaths ${DIR}/${ImgName}.nii -kernel gauss ${Sigma} -fmean ${DIR}/FSL/207138.sm${fwhmvol}.nii.gz
# fslmaths ${DIR}/${ImgName}.nii -kernel gauss ${Sigma} -fmean ${DIR}/OSEM_TOF_i6_s21_z2_72_g2_CT5_3_25.sm${fwhmvol}.nii.gz

# # Estimate spatial smooth in particular case of PET data
# # 3dFWHMx -automask -input ${DIR}/FSL/207138.sm${fwhmvol}.nii.gz -2difMAD -out ${DIR}/FSL/OSEM_i3_s24_z2.72_g${fwhmvol}_CT5_3.25.txt
# 3dFWHMx -automask -input ${DIR}/${ImgName}.nii -2difMAD -out ${DIR}/OSEM_TOF_i6_s21_g2_9_Res.txt
# 3dFWHMx -automask -input ${DIR}/OSEM_TOF_i6_s21_z2_72_g2_CT5_3_25.sm${fwhmvol}.nii.gz -2difMAD -out ${DIR}/OSEM_TOF_i6_s21_z2_72_g2_CT5_3_25.sm${fwhmvol}.txt
# 3dFWHMx -automask -input ${DIR}/OSEM_TOF_i6_s21_z2_72_g2_CT5_3_25.sm${fwhmvol}.nii.gz -2difMAD

# # Compute difference image between smooth methods
# fslmaths ${DIR}/${ImgName}.nii -sub ${DIR}/FSL/207138.sm${fwhmvol}.nii.gz ${DIR}/FSL/Sub.sm${fwhmvol}.nii.gz
# fslstats ${DIR}/FSL/Sub.sm${fwhmvol}.nii.gz -R


# #### Registration of i2s21g2 onto T1 and compute brainmask in PET native space ####
# DIR=$1
# 
# ## Set up FSL (if not already done so in the running environment) ##
# FSLDIR=${Soft_dir}/fsl50
# . ${FSLDIR}/etc/fslconf/fsl.sh
# 
# ## Set up FreeSurfer (if not already done so in the running environment) ##
# export FREESURFER_HOME=${Soft_dir}/freesurfer6_b/
# export FSFAST_HOME=${Soft_dir}/freesurfer6_b/fsfast
# export MNI_DIR=${Soft_dir}/freesurfer6_b/mni
# . ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# mri_binarize --i ${DIR}/brainmask.mgz --min 0.1 --o ${DIR}/brainmask_bin.nii.gz
# mri_morphology ${DIR}/brainmask_bin.nii.gz dilate 1 ${DIR}/brainmask_bin.dil1.nii.gz

# mri_coreg --mov ${DIR}/*OT_i2s21_g2-00-OPTOF_000_000_ctm_v.nii --reg ${DIR}/register.dof6.lta --regdat ${DIR}/register.dof6.dat --dof 6 --no-ref-mask --ref ${DIR}/T1.mgz
# mri_vol2vol --mov ${DIR}/*OT_i2s21_g2-00-OPTOF_000_000_ctm_v.nii --targ ${DIR}/T1.mgz --o ${DIR}/rT1.nii.gz --inv --reg ${DIR}/register.dof6.dat --no-save-reg
# mri_vol2vol --mov ${DIR}/*OT_i2s21_g2-00-OPTOF_000_000_ctm_v.nii --targ ${DIR}/brainmask_bin.dil1.nii.gz --o ${DIR}/rbrainmask_bin.dil1.nii.gz --inv --reg ${DIR}/register.dof6.dat \
# --nearest --no-save-reg

# #### Compute masked absolute difference between reconstructions ####
# # for SUBJ in SC GJ DG JB
# # for SUBJ in DESMARCHELIER_GERARD GRYCKO_JACQUELINE JORISSE_BEATRICE SEGERS_CHRISTOPHE ZUREK_MICHEL
# for SUBJ in CANDELIER_DOMINIQUE_2016-03-10 CANESSE_SYLVIE_2016-09-19 COLPAERT_ROGER_2016-10-05 DEGAND_PHILIPPE_2016-04-29 DUARTE_MARIA_2016-09-06 JONES_WILFRIED_2016-10-04 LAOUAR_FATMA_2016-10-11 SIFFRAY_SANDRINE_2016-03-01 SOLBES_BERNADETTE_2016-03-03 VABANDON_FRANCOISE_2016-10-10
for SUBJ in CANESSE_SYLVIE_2016-09-19 COLPAERT_ROGER_2016-10-05 DEGAND_PHILIPPE_2016-04-29 DUARTE_MARIA_2016-09-06 JONES_WILFRIED_2016-10-04
do
# # 	mkdir ${DIR}/Nifti/${SUBJ}
# # 	/home/global/mriconvert_22072015/mcverter -o ${DIR}/Nifti/${SUBJ} -f nifti -n ${DIR}/${SUBJ}/*
# # # 	/home/global/mriconvert_22072015/mcverter -o ${DIR}/Nifti/${SUBJ} -f nifti -n ${DIR}/${SUBJ}/DICOMS-OT_i3s21_g1.3/*
# # # 	/home/global/mriconvert_22072015/mcverter -o ${DIR}/Nifti/${SUBJ} -f nifti -n ${DIR}/${SUBJ}/DICOMS-OT_i3s21_g1.4/*
# 
# # 	for recon in OSEM_TOF_i2_s21_z2_72_g2_CT5_3_25 OSEM_TOF_i6_s21_z2_72_g2_CT5_3_25 OSEM_TOF_i6_s21_g2_4_EQ_PET OSEM_TOF_i6_s21_g2_9_Res OSEM_TOF_i6_s21_g3_1_EQ_PET_EARL OSEM_TOF_i6_s21_g3_3 OSEM_TOF_i6_s21_g3_5
# # 	for recon in OSEM_TOF_i3_s21_g1_6 OSEM_TOF_i3_s21_g1_7 OSEM_TOF_i3_s21_g1_8 OSEM_TOF_i3_s21_g1_9 OSEM_TOF_i3_s21_g2
# # 	for recon in 00-OPTOF_000_000_ctm_v
# # 	for recon in OT_i3s21_g1_5 OT_i3s21_g1_6 OT_i3s21_g1_7_Res OT_i3s21_g1_8 OT_i3s21_g1_9 OT_i3s21_g2 OT_i3s21_g3_4_EQ_PET OT_i3s21_g5_3_EQ_PET_EARL
# # 	for recon in OT_i3s21_g1_2 OT_i3s21_g1_3 OT_i3s21_g1_4
	for recon in OT_i6s21_g2-00-OPTOF_000_000_ctm_v OT_i6s21_g2_4_EQ_PET-00-OPTOF_000_000_ctm_v OT_i6s21_g2_9_Res-00-OPTOF_000_000_ctm_v \
	OT_i6s21_g3_1_EQ_PET_EARL-00-OPTOF_000_000_ctm_v OT_i6s21_g3_3-00-OPTOF_000_000_ctm_v OT_i6s21_g3_5-00-OPTOF_000_000_ctm_v
	do
# # 		# Estimate spatial smooth in particular case of PET data
# # 		3dFWHMx -automask -input ${DIR}/Nifti/${SUBJ}/*${recon}*.nii -2difMAD -out ${DIR}/Nifti/${SUBJ}/${recon}.txt
# # # 		3dFWHMx -automask -input ${DIR}/*${recon}.nii -2difMAD -out ${DIR}/${recon}.txt
# 	
# 		# Compute brain masked absolute difference between images
# 		# fslmaths ${DIR}/${SUBJ}/*${recon}.nii -sub ${DIR}/${SUBJ}/*OSEM_TOF_i2_s21_z2_72_g2_CT5_3_25.nii -abs -mas ${DIR}/${SUBJ}/rbrainmask_bin.dil1.nii.gz ${DIR}/${SUBJ}/Subtraction/${recon}_i2.abs.mask
# 		
		# Compute brain masked square difference between images
		fslmaths ${DIR}/${SUBJ}/*${recon}.nii -sub ${DIR}/${SUBJ}/*OT_i2s21_g2-00-OPTOF_000_000_ctm_v.nii -sqr -mas ${DIR}/${SUBJ}/rbrainmask_bin.dil1.nii.gz ${DIR}/${SUBJ}/Subtraction/${recon}_i2.sqr.mask
# 		fslmaths ${DIR}/${SUBJ}/*${recon}.nii -sub ${DIR}/${SUBJ}/*OSEM_TOF_i2_s21_z2_72_g2_CT5_3_25.nii -sqr -mas ${DIR}/${SUBJ}/rbrainmask_bin.dil1.nii.gz ${DIR}/${SUBJ}/Subtraction/${recon}_i2.sqr.mask
	done
	gunzip ${DIR}/${SUBJ}/Subtraction/*.nii.gz
done

# matlab -nodisplay <<EOF
# 	
# 	%% Load Matlab Path: Matlab 14 and SPM12 version
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
# 	
# 	V=spm_vol('OSEM_TOF_i6-i2_abs.mask.nii');
# 	V = spm_read_vols(V_i6);	
# 	S = sum(V_i6(:));
# 	
# 	fid = fopen(fullfile(outdir, [ 'NbFibres_' SeqDti '.txt']), 'a');
#         fprintf(fid, '%s_2_%s %d\n', NamesHypoth{i}, Names{j}, Tmp(i,j).nFiberNr);
#         fclose(fid);   
# EOF

# 
# ## Use of FS gaussian smooth
# mri_fwhm --smooth-only --fwhm ${fwhmvol} --i ${DIR}/ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii --o ${DIR}/FS/207138.sm${fwhmvol}.nii.gz
# 
# # Estimate spatial smooth in particular case of PET data
# 3dFWHMx -automask -input ${DIR}/FS/207138.sm${fwhmvol}.nii.gz -2difMAD -out ${DIR}/FS/OSEM_i3_s24_z2.72_g${fwhmvol}_CT5_3.25.txt
# 
# # Compute difference image between smooth methods
# fslmaths ${DIR}/${ImgName}.nii -sub ${DIR}/FS/207138.sm${fwhmvol}.nii.gz ${DIR}/FS/Sub.sm${fwhmvol}.nii.gz
# fslstats ${DIR}/FS/Sub.sm${fwhmvol}.nii.gz -R
# 
# ## Use of SPM gaussian smooth
# matlab -nodisplay <<EOF
# 	
# 	%% Load Matlab Path: Matlab 14 and SPM12 version
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
# 
# 	%% Init of spm_jobman
# 	spm('defaults', 'PET');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 			
# 	%% Step 1. Smooth PET data
# 	matlabbatch{end+1}.spm.spatial.smooth.data = {'${DIR}/ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii,1'};
# 	matlabbatch{end}.spm.spatial.smooth.fwhm = [${fwhmvol} ${fwhmvol} ${fwhmvol}];
# 	matlabbatch{end}.spm.spatial.smooth.dtype = 0;
# 	matlabbatch{end}.spm.spatial.smooth.im = 0;
# 	matlabbatch{end}.spm.spatial.smooth.prefix = 'sm${fwhmvol}_';
# 
# 	spm_jobman('run',matlabbatch);
# EOF
# 
# mv ${DIR}/sm${fwhmvol}_ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii ${DIR}/SPM/sm${fwhmvol}_ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii
# 
# # Estimate spatial smooth in particular case of PET data
# 3dFWHMx -automask -input ${DIR}/SPM/sm${fwhmvol}_ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii -2difMAD -out ${DIR}/SPM/OSEM_i3_s24_z2.72_g${fwhmvol}_CT5_3.25.txt
# 
# # Compute difference image between smooth methods
# fslmaths ${DIR}/${ImgName}.nii -sub ${DIR}/SPM/sm${fwhmvol}_ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii ${DIR}/SPM/Sub.sm${fwhmvol}.nii.gz
# fslstats ${DIR}/SPM/Sub.sm${fwhmvol}.nii.gz -R
# 
# ## Use of AFNI gaussian smooth
# 3dmerge -1blur_fwhm ${fwhmvol}.0 -prefix ${DIR}/AFNI/blur${fwhmvol}.nii ${DIR}/ZUREK_MICHEL_20160127_3367376_002_OSEM_i3_s24_z2_72_g0_CT5_3_25.nii
# 
# # Estimate spatial smooth in particular case of PET data
# 3dFWHMx -automask -input ${DIR}/AFNI/blur${fwhmvol}.nii -2difMAD -out ${DIR}/AFNI/OSEM_i3_s24_z2.72_g${fwhmvol}_CT5_3.25.txt
# 
# # Compute difference image between smooth methods
# fslmaths ${DIR}/${ImgName}.nii -sub ${DIR}/AFNI/blur${fwhmvol}.nii ${DIR}/AFNI/Sub.sm${fwhmvol}.nii.gz
# fslstats ${DIR}/AFNI/Sub.sm${fwhmvol}.nii.gz -R