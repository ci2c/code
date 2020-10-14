#!/bin/bash

SUBJECTS_DIR=/NAS/dumbo/protocoles/LEMP/FS5.3
# SUBJECT_ID=Araujo_Jarmela_Manuel_936649_20120113

# if [ $# -lt  ]
# then
# 	echo ""
# 	echo "Usage: tbss_LONG_LEMP.sh -sd <Subject DIR>"
# 	echo ""
# 	echo "	-sd 					: Subject directory"
# 	echo "Usage: tbss_LONG_LEMP.sh -sd <Subject DIR>"
# 	echo ""
# 	exit 1
# fi
# 
# 
# 
# index=1
# 
# while [ $index -le $# ]
# do
# 	eval arg=\${$index}
# 	case "$arg" in
# 	-h|-help)
# 		echo ""
# 		echo "Usage: tbss_LONG_LEMP.sh -sd <Subject DIR>"
# 		echo ""
# 		echo "	-sd 					: Subject directory"
# 		echo "Usage: tbss_LONG_LEMP.sh -sd <Subject DIR>"
# 		echo ""
# 		exit 1
# 		;;
# 	-sd)
# 		index=$[$index+1]
# 		eval sd=\${$index}
# 		echo "Subject directory : $sd"
# 		;;
# 
# 	esac
# 	index=$[$index+1]
# done
# 
# cd ${SUBJECTS_DIR}
# 
# echo ""
# echo ""
# echo "TBSS - 1ère étape"
# echo ""
# echo ""
# 
# echo "tbss_1_preproc *nii.gz"
# tbss_1_preproc *nii.gz
# 
# echo ""
# echo ""
# echo "TBSS - 2ème étape"
# echo ""
# echo ""
# 
# echo "tbss_2_reg -T"
# tbss_2_reg -T
# 
# echo ""
# echo ""
# echo "TBSS - 3ème étape"
# echo ""
# echo ""
# 
# echo "tbss_3_postreg -S"
# tbss_3_postreg -S

# ## Tweak TBSS for two-timepoints longitudinal study
# 
# # Split all registered FA images for all timepoints subjects
# fslsplit ${SUBJECTS_DIR}/TBSS_FA/stats/all_FA.nii.gz ${SUBJECTS_DIR}/TBSS_FA/stats/FA_reg_ -t
# 
# # Merge only two timepoints per subject and create mean_FA and mean_FA_skeleton
# fslmerge -t ${SUBJECTS_DIR}/TBSS_FA/stats/TwoTimepoints_FA.nii.gz ${SUBJECTS_DIR}/TBSS_FA/stats/FA_reg_*.nii.gz
# fslmaths TwoTimepoints_FA.nii.gz -Tmean mean_FA.nii.gz
# fslmaths mean_FA.nii.gz -bin mean_FA_mask
# tbss_skeleton -i mean_FA.nii.gz -o mean_FA_skeleton.nii.gz
# 
# # Last step before randomise : threshold mean_FA_skeleton
# tbss_4_prestats 0.2
# 
# # Run randomise
# randomise -i all_FA_skeletonised -o tbss -m mean_FA_skeleton_mask -d TBSS_FA.mat -t TBSS_FA.con -e TBSS_FA.grp -n 500 --T2
# 
# # Displaying TBSS results
# tbss_fill tbss_tfce_corrp_tstat1 0.95 mean_FA tbss_fill

# ## Freesurfer's LME model : matlab script & mri_volcluster
# 
# fslmaths all_FA.nii.gz -kernel gauss ${Sigma} -fmean s2_all_FA.nii.gz
# mri_volcluster --in pval_corr_neg.nii.gz --thmin 0.95 --mask mean_FA_mask.nii.gz --out pval_corr_neg_clus.nii.gz --ocn pval_corr_neg_clus_id.nii.gz --labelbase cluster_label --minsizevox 500

# ## SwE estimator : longitudinal study
# #  fslsplit ${SUBJECTS_DIR}/TBSS_FA/Non_parametric_SwE/all_FA.nii.gz ${SUBJECTS_DIR}/TBSS_FA/Non_parametric_SwE/FA_MNI152_ -t
# 
# for subj in $(ls ${SUBJECTS_DIR}/TBSS_FA/Non_parametric_SwE/FA_MNI152_00*.nii.gz)
# do
# 	subjname=`basename ${subj}`
# 	subjname=${subjname%.nii.gz}
# 	mri_convert -it nii ${subj} -ot nifti1 ${SUBJECTS_DIR}/TBSS_FA/Non_parametric_SwE/${subjname}.img
# done

# ## Longitudinal single subject analysis
# 
# # Simple smooth and substraction between images
# mri_morphology ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask.nii.gz erode 1 ${SUBJECTS_DIR}/LONG_single_subject/SingleSubject_mask.nii.gz
# fslsplit ${SUBJECTS_DIR}/LONG_single_subject/all_FA.nii.gz ${SUBJECTS_DIR}/LONG_single_subject/FA/FA_subject_ -t

fwhmvol=2
# Sigma=`echo "${fwhmvol} / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# for FA in $(ls ${SUBJECTS_DIR}/LONG_single_subject/RD/RD_*.nii.gz)
# do
# 	subjname=`basename ${FA}`
# 	subjname=${subjname%.nii.gz}	
# 	fslmaths ${FA} -kernel gauss ${Sigma} -fmean ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_${subjname}.nii.gz
# done
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0001 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0000 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Araujo_T2_T1

# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_RD_subject_0006 -sub ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_RD_subject_0005 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_Dherbecourt_T2_T1
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_RD_subject_0007 -sub ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_RD_subject_0006 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_Dherbecourt_T3_T2
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_RD_subject_0007 -sub ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_RD_subject_0005 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/RD/s${fwhmvol}_Dherbecourt_T3_T1

fslmaths ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0015 -sub ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0014 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_Pouille_T2_T1
# 
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0006 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0005 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Gaudefroy_T2_T1
# 
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0008 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0007 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Gressier_T2_T1
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0009 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0008 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Gressier_T3_T2
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0010 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0009 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Gressier_T4_T3
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0010 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0007 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Gressier_T4_T1
# 
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0016 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0015 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Vichery_T2_T1
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0017 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0016 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Vichery_T3_T2
# fslmaths ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0017 -sub ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_RD_subject_0015 -mul ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/SingleSubject_mask ${SUBJECTS_DIR}/LONG_single_subject/V1/RD/s${fwhmvol}_Vichery_T3_T1

fslmaths ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0024 -sub ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0023 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_Zouaoui_T2_T1
fslmaths ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0025 -sub ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0024 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_Zouaoui_T3_T2
fslmaths ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0026 -sub ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0025 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_Zouaoui_T4_T3
fslmaths ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0026 -sub ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_FA_subject_0023 -mul ${SUBJECTS_DIR}/LONG_single_subject/mean_FA_mask ${SUBJECTS_DIR}/LONG_single_subject/FA/s${fwhmvol}_Zouaoui_T4_T1

# # Smooth and use of fsl_glm + PALM

# fsl_glm -i s2_FA_Araujo.nii.gz -d ../design_Araujo_Jarmela_Manuel.txt --demean --out_cope=s2_COPE_Araujo
# fsl_glm -i s1.5_FA_Cammisuli.nii.gz -d design_Cammisuli_Antonio.txt --demean --out_cope=s1.5_COPE_Cammisuli
# fsl_glm -i s2_FA_Gaudefroy.nii.gz -d ../design_Gaudefroy_Marie_Christine.txt --demean --out_cope=s2_COPE_Gaudefroy
# fsl_glm -i s2_FA_Gressier.nii.gz -d ../design_Gressier_Daniel.txt --demean --out_cope=s2_COPE_Gressier
# fsl_glm -i s2_FA_Renard.nii.gz -d ../design_Renard_Claudine.txt --demean --out_cope=s2_COPE_Renard
# fsl_glm -i s2_FA_Vichery.nii.gz -d ../design_Vichery_Nadege.txt --demean --out_cope=s2_COPE_Vichery
# fsl_glm -i s2_FA_Zouaoui.nii.gz -d ../design_Zouaoui_Mohamed.txt --demean --out_cope=s2_COPE_Zouaoui

# fslmerge -t 4D_s2_COPE s2_COPE_Araujo.nii.gz s2_COPE_Cammisuli.nii.gz s2_COPE_Gaudefroy.nii.gz s2_COPE_Gressier.nii.gz s2_COPE_Renard.nii.gz s2_COPE_Vichery.nii.gz s2_COPE_Zouaoui.nii.gz

# palm -i /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/s2/4D_s2_COPE.nii -d /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/design.csv -t /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/Contrast.csv -vg /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/VarianceGroup.csv -ise -save1-p -o /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/s3/LEMP
# palm -i /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/s2/4D_s2_COPE.nii -d /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/design.csv -t /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/Contrast.csv -eb /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/VarianceGroup.csv -vg auto -ise -save1-p -o /NAS/dumbo/protocoles/LEMP/FS5.3/LONG_single_subject/FA/FSL/s2/LEMP