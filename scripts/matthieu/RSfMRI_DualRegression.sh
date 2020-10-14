#!/bin/bash

###################################################
## Prepare input data for GIFT
###################################################

# fsdir=/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53
# # # fsdir=/home/notorious/NAS/tanguy/tanguy_dumbo/tep_fog/tep_fog/tep_fog/tep_fog/freesurfer
# # # fsdir=/NAS/dumbo/protocoles/cervelet-FreeSurf/FS53
# # 
# # while read subject  
# # do 
# # 	echo -e "${fsdir}/${subject}/fmri/run01/warepi_sm6_al.nii.gz" >> ${fsdir}/RS_fmri_controls_AD.txt
# # done < ${fsdir}/../Controls_AD.txt
# # 
# # fsdir=/NAS/tupac/protocoles/healthy_volunteers/FS53
# # 
# # while read subject  
# # do 
# # 	echo -e "${fsdir}/${subject}/fmri/run01/warepi_sm6_al.nii.gz" >> /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53/RS_fmri_controls_EOAD.txt
# # done < /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Controls_EOAD.txt
# # 
# # fsdir=/NAS/tupac/protocoles/COMAJ/FS53
# # 
# # while read subject  
# # do 
# # 	echo -e "${fsdir}/${subject}/fmri/run01/warepi_sm6_al.nii.gz" >> /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53/RS_fmri_EOAD.txt
# # done < /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/EOAD.txt
# 
# index=1
# while read subject  
# do 
# 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N PreGIFT_${index} PreProcessing_GIFT.sh ${subject}
# 	index=$[$index+1]
# 	sleep 1
# # done < ${fsdir}/RS_fmri_AD.txt
# done < ${fsdir}/RS_fmri_controls_EOAD.txt
# 
# index=1
# while read subject  
# do 
# 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N PreGIFT_${index} PreProcessing_GIFT.sh ${subject}
# 	index=$[$index+1]
# 	sleep 1
# # done < ${fsdir}/RS_fmri_Controls.txt
# # done < ${fsdir}/RS_fmri_cervelet.txt
# # done < ${fsdir}/RS_fmri_EOAD.txt
# done < ${fsdir}/RS_fmri_EOAD.txt
# # done < ${fsdir}/RS_fmri_Nan.txt
# 
# index=1
# while read subject  
# do 
# 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N PreGIFT_${index} PreProcessing_GIFT.sh ${subject}
# 	index=$[$index+1]
# 	sleep 1
# # done < ${fsdir}/RS_fmri_Controls.txt
# # done < ${fsdir}/RS_fmri_cervelet.txt
# # done < ${fsdir}/RS_fmri_EOAD.txt
# done < ${fsdir}/RS_fmri_controls_AD.txt
# 
# # # dual_regression /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks/melodic_IC.nii.gz 1 /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53/design.mat FS53/design.con 5000 /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Dual_regression/ `cat /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53/RS_fmri_AD.txt` `cat /NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53/RS_fmri_EOAD.txt`
# 
# ################################################################################################
# ## Launch GIFT dual regression analysis : First set the input file "Input_data_subjects_GIFT.m"
# ################################################################################################
# 
# /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# 	% Load Matlab Path
# 	cd /home/matthieu
# 	p = pathdef11_SPM12;
# 	addpath(p);
# 
# 	icatb_batch_file_run('/home/matthieu/SVN/matlab/matthieu/COMAJ/Input_data_subjects_GIFT.m');
#  
# EOF
# 
###################################################
## Randomise group analysis
###################################################

GIFT_dir=/NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5
# # GIFT_dir=/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/GIFT/batch_results_v3
# # GIFT_dir=/home/notorious/NAS/tanguy/tanguy_dumbo/tep_fog/tep_fog/tep_fog/tep_fog/GIFT/batch_results_v2
# 
# mkdir ${GIFT_dir}/ICA_subjects_br
# 
# for subj in $(ls ${GIFT_dir}/RS__sub*_component_ica_s1_.nii)
# do
# 	subjname=`basename ${subj}`
# 	subjname=${subjname%.nii}
# 	fslsplit ${subj} ${GIFT_dir}/ICA_subjects_br/${subjname} -t
# done
# 
# ## COMAJ ##
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_EXE1_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0000.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0000.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_EXE1_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0000.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_EXE1_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0000.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_EXE2_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0030.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0030.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_EXE2_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0030.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_EXE2_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0030.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_SAL_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0006.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0006.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_SAL_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0006.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_SAL_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0006.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN_post_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0008.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0008.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN_post_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0008.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN_post_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0008.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_antiDMN_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0014.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0014.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_antiDMN_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0014.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_antiDMN_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0014.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_MOTOR_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0017.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0017.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_MOTOR_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0017.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_MOTOR_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0017.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU1_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0019.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0019.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU1_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0019.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU1_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0019.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU2_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0021.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0021.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU2_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0021.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU2_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0021.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU3_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0038.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0038.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU3_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0038.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_VISU3_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0038.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_AUDI1_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0020.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0020.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_AUDI1_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0020.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_AUDI1_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0020.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_AUDI2_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0023.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0023.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_AUDI2_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0023.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_AUDI2_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0023.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTL1_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0033.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0033.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTL1_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0033.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTL1_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0033.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTL2_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0034.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0034.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTL2_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0034.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTL2_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0034.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTR_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0036.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0036.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTR_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0036.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_ATTR_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0036.nii.gz)
# 
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN_AD_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..17}_component_ica_s1_0035.nii.gz ${GIFT_dir}/ICA_subjects_br/RS__sub0{57..85}_component_ica_s1_0035.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN_AD_CS $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{01..30}_component_ica_s1_0035.nii.gz)
# fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN_CS_EOAD $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub0{31..85}_component_ica_s1_0035.nii.gz)
# 
# rm -f ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_*.nii.gz
# # mkdir ${GIFT_dir}/Randomise
# 
# for group in AD_EOAD AD_CS CS_EOAD
# do
# 	for network in EXE1 EXE2 SAL DMN_post antiDMN MOTOR VISU1 VISU2 VISU3 AUDI1 AUDI2 ATTL1 ATTL2 ATTR DMN
# 	do
# 		qbatch -N ICA_${network}_${group} -q three_job_q -oe /NAS/tupac/matthieu/Logdir randomise -i ${GIFT_dir}/ICA_subjects_br/dr_stage2_${network}_${group} -o ${GIFT_dir}/Randomise/dr_stage3_${network}_${group} -m ${GIFT_dir}/Randomise/MNI152_T1_2mm_brain_mask_rl_epi.nii -d ${GIFT_dir}/Randomise/design_${group}.mat -t ${GIFT_dir}/Randomise/design_${group}.con -n 5000 -T -V
# # 		qbatch -N ICA_${network}_${group} -q three_job_q -oe /NAS/tupac/matthieu/Logdir randomise -i ${GIFT_dir}/ICA_subjects_br/dr_stage2_${network}_${group} -o ${GIFT_dir}/Randomise_AgeCorr/dr_stage3_${network}_${group} -m ${GIFT_dir}/Randomise_AgeCorr/MNI152_T1_2mm_brain_mask_rl_epi.nii -d ${GIFT_dir}/Randomise_AgeCorr/design_${group}.mat -t ${GIFT_dir}/Randomise_AgeCorr/design_${group}.con -n 5000 -T -V -D 
# 	done
# done

# # Compute thresholded p-maps & T-stat maps with MNI coordinates of significant clusters
# for group in AD_EOAD CS_EOAD
# do
# 	for network in EXE1 EXE2 SAL DMN_post ATTL1 ATTL2 ATTR DMN
# 	do
# # 		for con in 1 2
# # 		do
# # 			fslmaths ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat${con}.nii.gz -thr 0.95 -bin -mul ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}.nii.gz ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_thresh_tstat${con}
# # 			cluster --in=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_thresh_tstat${con} --thresh=0.0001 --oindex=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}_cluster_index --olmax=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}_lmax.txt --osize=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}_cluster_size --mm
# # 		done
# 		mri_binarize --i ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat1.nii.gz --min 0.95 --binval 3 --o ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat1_thresh.nii.gz
# 		mri_binarize --i ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat2.nii.gz --min 0.95 --binval 1 --o ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat2_thresh.nii.gz
# 	done
# done
# 
# for group in AD_CS
# do
# 	for network in EXE1 EXE2 SAL DMN_post ATTL1 ATTL2 ATTR DMN
# 	do
# # 		for con in 1 2
# # 		do
# # 			fslmaths ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat${con}.nii.gz -thr 0.95 -bin -mul ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}.nii.gz ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_thresh_tstat${con}
# # 			cluster --in=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_thresh_tstat${con} --thresh=0.0001 --oindex=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}_cluster_index --olmax=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}_lmax.txt --osize=${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tstat${con}_cluster_size --mm
# # 		done
# 		mri_binarize --i ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat1.nii.gz --min 0.95 --binval 1 --o ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat1_thresh.nii.gz
# 		mri_binarize --i ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat2.nii.gz --min 0.95 --binval 3 --o ${GIFT_dir}/Randomise/dr_stage3_${network}_${group}_tfce_corrp_tstat2_thresh.nii.gz
# 	done
# done

# # Project thresholded maps on fsaverage 
# for group in AD_EOAD AD_CS CS_EOAD
# do
# 	# Add all contrasts thresholded maps
# 	# DMN
# 	fslmaths /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_DMN_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_DMN_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	/NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_DMN_${group}_tfce_corrp_thresh.nii.gz
# 	# EXE
# 	fslmaths /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_EXE1_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_EXE2_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_EXE1_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_EXE2_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	/NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_EXE_${group}_tfce_corrp_thresh.nii.gz
# 	# SAL
# 	fslmaths /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_SAL_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_SAL_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	/NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_SAL_${group}_tfce_corrp_thresh.nii.gz
# 	# ATTL
# 	fslmaths /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTL1_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTL2_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTL1_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTL2_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	/NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTL_${group}_tfce_corrp_thresh.nii.gz
# 	# ATTR
# 	fslmaths /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTR_${group}_tfce_corrp_tstat1_thresh.nii.gz \
# 	-add /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTR_${group}_tfce_corrp_tstat2_thresh.nii.gz \
# 	/NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_ATTR_${group}_tfce_corrp_thresh.nii.gz
# 	
# 	for network in DMN EXE SAL ATTL ATTR
# 	do
# 		# Register thresholded maps on MNI305
# 		mri_vol2vol --targ ${FREESURFER_HOME}/average/mni305.cor.mgz \
# 		--mov /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_${network}_${group}_tfce_corrp_thresh.nii.gz \
# 		--reg ${FREESURFER_HOME}/average/mni152.register.dat \
# 		--o /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_${network}_${group}_tfce_corrp_thresh.MNI305.nii.gz \
# 		--interp nearest
# 		
# 		# Project MNI305 maps on fsaverage
# 		mri_vol2surf --mov /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_${network}_${group}_tfce_corrp_thresh.MNI305.nii.gz \
# 		--regheader fsaverage \
# 		--interp nearest \
# 		--projfrac 0.5 \
# 		--hemi lh \
# 		--o /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/lh.${network}_${group}.fsaverage.mgh \
# 		--noreshape \
# 		--cortex \
# 		--surfreg sphere.reg
# 		
# 		mri_vol2surf --mov /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/dr_stage3_${network}_${group}_tfce_corrp_thresh.MNI305.nii.gz \
# 		--regheader fsaverage \
# 		--interp nearest \
# 		--projfrac 0.5 \
# 		--hemi rh \
# 		--o /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/rh.${network}_${group}.fsaverage.mgh \
# 		--noreshape \
# 		--cortex \
# 		--surfreg sphere.reg
# 	done
# done

# # Make montage
# for group in AD_EOAD AD_CS CS_EOAD
# do
# 	for network in DMN EXE SAL ATTL ATTR
# 	do
# # 		qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N Tiff_${network}_${group} 
# 		Make_montage.sh -fs ${FREESURFER_HOME}/subjects  -subj fsaverage -surf white \
# 		-lhoverlay /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/lh.${network}_${group}.fsaverage.mgh  \
# 		-rhoverlay /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/rh.${network}_${group}.fsaverage.mgh \
# 		-fminmax 1 8 -fmid 2 -output /NAS/tupac/protocoles/COMAJ/GIFT/batch_results_v5/Randomise/${network}_${group}_1to8.tiff \
# 		-template -axial
# 	done
# done

# # Localize anatomical regions from MNI coordinates
# for group in AD_EOAD AD_CS CS_EOAD
# do
# 	for network in EXE1 EXE2 SAL ATTL1 ATTL2 ATTR DMN
# 	do
# 		for con in 1 2
# 		do
# # 			sed '1d' ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax.txt | cut -f 3,4,5 | sed -e 's/\t/,/g' > ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_CoordMNI.txt
# 			while read Coord3D  
# 			do 
# # 				atlasquery -a "Harvard-Oxford Cortical Structural Atlas" -c ${Coord3D} >> ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_AnatLoc.txt
# 				atlasquery -a "Harvard-Oxford Subcortical Structural Atlas" -c ${Coord3D} >> ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_AnatLocSub.txt
# 			done < ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_CoordMNI.txt
# # 			paste ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_CoordMNI.txt ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_AnatLoc.txt > ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_results.txt
# 			paste ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_CoordMNI.txt ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_AnatLocSub.txt > ${GIFT_dir}/Results/dr_stage3_${network}_${group}_tstat${con}_lmax_resultsSub.txt	
# 		done
# 	done
# done

# # ## TEP_FOG ##
# # 
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN1 $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0017.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_DMN2 $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0035.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_SMN $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0018.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_FPNl $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0029.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_FPNr $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0026.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_FPN1 $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0019.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_FPN2 $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0010.nii.gz)
# # fslmerge -t ${GIFT_dir}/ICA_subjects_br/dr_stage2_Motor $(ls ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_0025.nii.gz)
# # 
# # rm -f ${GIFT_dir}/ICA_subjects_br/RS__sub*_component_ica_s1_*.nii.gz
# # 
# # # mkdir ${GIFT_dir}/Randomise
# # 
# # # cp ${FSLDIR}/data/standard/MNI152lin_T1_2mm_brain_mask.nii.gz ${GIFT_dir}/ICA_subjects_br
# # # bet /home/notorious/NAS/tanguy/tanguy_dumbo/tep_fog/tep_fog/tep_fog/tep_fog/freesurfer/ALIBERT_GUY/rsfmri/run01/ws6arepi_al_nan.nii.gz /home/notorious/NAS/tanguy/tanguy_dumbo/tep_fog/tep_fog/tep_fog/tep_fog/GIFT/batch_results_v1/ICA_subjects_br/epi_brain.nii.gz -F -m
# # # mri_convert -rl /home/notorious/NAS/tanguy/tanguy_dumbo/tep_fog/tep_fog/tep_fog/tep_fog/GIFT/batch_results_v1/ICA_subjects_br/epi_brain_mask.nii.gz ${GIFT_dir}/ICA_subjects_br/MNI152lin_T1_2mm_brain_mask.nii.gz ${GIFT_dir}/Randomise/MNI152lin_T1_2mm_brain_mask_rl.nii.gz
# # 
# # for network in DMN1 DMN2 SMN FPNl FPNr FPN1 FPN2 Motor
# # do
# # 	qbatch -N ICA_${network} -q three_job_q -oe /NAS/dumbo/matthieu/Logdir randomise -i ${GIFT_dir}/ICA_subjects_br/dr_stage2_${network} -o ${GIFT_dir}/Randomise/dr_stage3_${network} -m ${GIFT_dir}/Randomise/MNI152_T1_2mm_brain_mask_rl_epi.nii -d ${GIFT_dir}/Randomise/design.mat -t ${GIFT_dir}/Randomise/design.con -n 5000 -T -V
# # done
# # 
# cd ${GIFT_dir}/Randomise_AgeCorr
# cd ${GIFT_dir}/Randomise
for i in dr_stage3_*_tfce_corrp_tstat?.nii.gz ; do
  echo $i `fslstats $i -R`
done