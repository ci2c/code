#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Main_FSL_ASLProcessing.sh -idc2 <InputDirCODE2> -ide <InputDirEpilepsy> -sd <SubjDir> -tpdir <T1templatedir> -wd <asldirname> -f <SubjectsPath>"
	echo ""
	echo "	-idc2		: Input directory containing raw subjects data from CODE2 protocole "
	echo "	-ide		: Input directory containing raw subjects data from Epilepsy protocole "
	echo "  -sd		: FS5.3 subjects directory "
	echo "  -f       	: Directory containing the subjects_CODE2.txt and subjects_Epilepsy.txt files "
	echo "  -tpdir       	: Directory containing the T_template_3DT1.nii, T_templateProbabilityMask.nii.gz and T_templateSkullStripped.nii.gz files "
	echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
	echo ""
	echo "Usage: Main_FSL_ASLProcessing.sh -idc2 <InputDirCODE2> -ide <InputDirEpilepsy> -sd <SubjDir> -tpdir <T1templatedir> -wd <asldirname> -f <SubjectsPath>"
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Main_FSL_ASLProcessing.sh -idc2 <InputDirCODE2> -ide <InputDirEpilepsy> -sd <SubjDir> -tpdir <T1templatedir> -wd <asldirname> -f <SubjectsPath>"
		echo ""
		echo "	-idc2		: Input directory containing raw subjects data from CODE2 protocole "
		echo "	-ide		: Input directory containing raw subjects data from Epilepsy protocole "
		echo "  -sd		: FS5.3 subjects directory "
		echo "  -f       	: Directory containing the subjects_CODE2.txt and subjects_Epilepsy.txt files "
		echo "  -tpdir       	: Directory containing the T_template_3DT1.nii, T_templateProbabilityMask.nii.gz and T_templateSkullStripped.nii.gz files "
		echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
		echo ""
		echo "Usage: Main_FSL_ASLProcessing.sh -idc2 <InputDirCODE2> -ide <InputDirEpilepsy> -sd <SubjDir> -tpdir <T1templatedir> -wd <asldirname> -f <SubjectsPath>"
		echo ""
		exit 1
		;;
	-idc2)
		index=$[$index+1]
		eval INPUT_DIR_CODE2=\${$index}
		echo "input data CODE2 : ${INPUT_DIR_CODE2}"
		;;	
	-ide)
		index=$[$index+1]
		eval INPUT_DIR_EPILEPSY=\${$index}
		echo "input data epilepsy : ${INPUT_DIR_EPILEPSY}"
		;;
	-sd)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "FS data : ${FS_DIR}"
		;;
	-tpdir)
		index=$[$index+1]
		eval TEMPLATE_DIR=\${$index}
		echo "template dir : ${TEMPLATE_DIR}"
		;;
	-wd)
		index=$[$index+1]
		eval asldir=\${$index}
		echo "ASL working dir : ${asldir}"
		;;
	-f)
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path to the subjects.txt file : ${FILE_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: Main_FSL_ASLProcessing.sh -idc2 <InputDirCODE2> -ide <InputDirEpilepsy> -sd <SubjDir> -tpdir <T1templatedir> -wd <asldirname> -f <SubjectsPath>"
		echo ""
		echo "	-idc2		: Input directory containing raw subjects data from CODE2 protocole "
		echo "	-ide		: Input directory containing raw subjects data from Epilepsy protocole "
		echo "  -sd		: FS5.3 subjects directory "
		echo "  -f       	: Directory containing the subjects_CODE2.txt and subjects_Epilepsy.txt files "
		echo "  -tpdir       	: Directory containing the T_template_3DT1.nii, T_templateProbabilityMask.nii.gz and T_templateSkullStripped.nii.gz files "
		echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
		echo ""
		echo "Usage: Main_FSL_ASLProcessing.sh -idc2 <InputDirCODE2> -ide <InputDirEpilepsy> -sd <SubjDir> -tpdir <T1templatedir> -wd <asldirname> -f <SubjectsPath>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
# if [ -z ${INPUT_DIR_CODE2} ]
# then
# 	 echo "-idc2 argument mandatory"
# 	 exit 1
# fi
# if [ -z ${INPUT_DIR_EPILEPSY} ]
# then
# 	 echo "-ide argument mandatory"
# 	 exit 1
# fi
if [ -z ${FS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi
# if [ -z ${FILE_PATH} ]
# then
# 	 echo "-f argument mandatory"
# 	 exit 1
# fi
# if [ -z ${TEMPLATE_DIR} ]
# then
# 	 echo "-tpdir argument mandatory"
# 	 exit 1
# fi
# if [ -z ${asldir} ]
# then
# 	 echo "-wd argument mandatory"
# 	 exit 1
# fi

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh


# # # =====================================================================================
# # #         Compute ASL pre and post processing from CODE2 and Epilepsy protocoles
# # # =====================================================================================
# 
# if [ -s ${FILE_PATH}/subjects_CODE2.txt ]
# then	
# 	while read SUBJECT_ID  
# 	do 	 
# 		qbatch -q three_job_q -oe ~/Logdir -N SP2_${SUBJECT_ID} FSL_ASLProcessing.sh -id ${INPUT_DIR_CODE2} -sd ${FS_DIR} -subj ${SUBJECT_ID} -tpdir ${TEMPLATE_DIR} -wd ${asldir}
# 		sleep 1
# 	done < ${FILE_PATH}/subjects_CODE2.txt
# fi
# 
# if [ -s ${FILE_PATH}/subjects_Epilepsy.txt ]
# then	
# 	while read SUBJECT_ID  
# 	do 	 
# 		qbatch -q three_job_q -oe ~/Logdir -N SP2_${SUBJECT_ID} FSL_ASLProcessing.sh -id ${INPUT_DIR_EPILEPSY} -sd ${FS_DIR} -subj ${SUBJECT_ID} -tpdir ${TEMPLATE_DIR} -wd ${asldir}
# 		sleep 1
# 	done < ${FILE_PATH}/subjects_Epilepsy.txt
# fi

# # =====================================================================================
# #         Perform surface second level statistical analysis (Freesurfer)
# # =====================================================================================

###############################################
# ANCOVA : mri_glmfit + Clusterwise correction
###############################################

# SUBJECTS_DIR=${FS_DIR}

## Perfusion analysis ##

# ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/lh_concat_fwhm3_cbf_s_oldz.sh
# ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/rh_concat_fwhm3_cbf_s_oldz.sh
# 
# mri_glmfit \
#   --y ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.all.subjects.fwhm3.cbf_s_oldz.mgh \
#   --fsgd ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/g6v2.demean.fsgd dods \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/perfusion_duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.intercept.mtx \
#   --surf fsaverage lh \
#   --cortex \
#   --glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm3.cbf_s.z
# 
# cp ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.all.subjects.fwhm3.cbf_s_oldz.mgh ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm3.cbf_s.z
# 
# for clus_thresh in 1.3 2 2.3 3 3.3 4
# do 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm3.cbf_s.z \
# 	--cache ${clus_thresh} pos \
# 	--cwp  0.05 \
# 	--2spaces
# 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm3.cbf_s.z \
# 	--cache ${clus_thresh} neg \
# 	--cwp  0.05 \
# 	--2spaces
# done
# 
# mri_glmfit \
#   --y ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.all.subjects.fwhm3.cbf_s_oldz.mgh \
#   --fsgd ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/g6v2.demean.fsgd dods \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/perfusion_duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.intercept.mtx \
#   --surf fsaverage rh \
#   --cortex \
#   --glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm3.cbf_s.z
# 
# cp ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.all.subjects.fwhm3.cbf_s_oldz.mgh ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm3.cbf_s.z
# 
# for clus_thresh in 1.3 2 2.3 3 3.3 4
# do 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm3.cbf_s.z \
# 	--cache ${clus_thresh} pos \
# 	--cwp  0.05 \
# 	--2spaces
# 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm3.cbf_s.z \
# 	--cache ${clus_thresh} neg \
# 	--cwp  0.05 \
# 	--2spaces
# done

# ## Cortical thickness analysis ##
# 
# # ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/lh_concat_fwhm10_Thickness.sh
# # ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/rh_concat_fwhm10_Thickness.sh
# 
# mri_glmfit \
#   --y ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.all.subjects.fwhm10.Thickness.mgh \
#   --fsgd ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/g6v2.demean.fsgd dods \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/perfusion_duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.intercept.mtx \
#   --surf fsaverage lh \
#   --cortex \
#   --glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm10.Thickness
# 
# cp ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.all.subjects.fwhm10.Thickness.mgh ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm10.Thickness
# 
# for clus_thresh in 1.3 2 2.3 3 3.3 4
# do 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm10.Thickness \
# 	--cache ${clus_thresh} pos \
# 	--cwp  0.05 \
# 	--2spaces
# 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/lh.g6v2.demean.fwhm10.Thickness \
# 	--cache ${clus_thresh} neg \
# 	--cwp  0.05 \
# 	--2spaces
# done
# 
# mri_glmfit \
#   --y ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.all.subjects.fwhm10.Thickness.mgh \
#   --fsgd ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/g6v2.demean.fsgd dods \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-left.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/control-right.intercept.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/perfusion_duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.age.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.duration.slope.mtx \
#   --C ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/right-left.intercept.mtx \
#   --surf fsaverage rh \
#   --cortex \
#   --glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm10.Thickness
# 
# cp ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.all.subjects.fwhm10.Thickness.mgh ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm10.Thickness
# 
# for clus_thresh in 1.3 2 2.3 3 3.3 4
# do 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm10.Thickness \
# 	--cache ${clus_thresh} pos \
# 	--cwp  0.05 \
# 	--2spaces
# 
#       mri_glmfit-sim \
# 	--glmdir ${FS_DIR}/SurfaceAnalysis_mri_glmfit/V4/DODS/rh.g6v2.demean.fwhm10.Thickness \
# 	--cache ${clus_thresh} neg \
# 	--cwp  0.05 \
# 	--2spaces
# done
  
# freeview -f ${SUBJECTS_DIR}/fsaverage/surf/lh.inflated:annot=aparc.annot:overlay=${SUBJECTS_DIR}/SurfaceAnalysis_mri_glmfit/lh.g6v2.glmdir/control-left.intercept/sig.mgh:overlay_threshold=4,5 -viewport 3d

# # =====================================================================================
# #         Perform surface second level statistical analysis (rBPM)
# # =====================================================================================

# ######################################################
# # ANCOVA (rBPM) + Clusterwise correction (Freesurfer)
# ######################################################

# WD=/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr
# 
# matlab -nodisplay <<EOF
# 	Load Matlab Path: Matlab 14 and SPM5 needed
# 	cd ${HOME}
# 	p = pathdef14_SPM5;
# 	addpath(p);
# 	
# 	%bpm_analysis_surf('ANCOVA','${WD}/master_flist.txt',[1 -1 0 0 0],'T','/NAS/tupac/matthieu/Masks/medial_wall_fsaverage.mat', '${WD}/MOCA', [], '${WD}','CNvsLTLE', [], 1);
# 	%load('${WD}/BPM.mat');
# 	%BPM.contrast(2,:)=[0,1,0,-1,0,0];
# 	%BPM = bpm_con_man_surf(BPM,results.nbleft);
# 	
# 	bpm_analysis_surf('ANCOVA','${WD}/master_flist.txt',[1 -1 0],'T','/NAS/tupac/matthieu/Masks/medial_wall_fsaverage_sym.mat', [], [], '${WD}','LTLEvsRTLE', [], 1);
# 	load('${WD}/BPM.mat');
# 	BPM.contrast(2,:)=[0,-1,1,0];
# 	BPM = bpm_con_man_surf(BPM,results.nbleft);
# 
# 	% bpm_analysis_surf('REGRESSION','${WD}/master_flist.txt',[0 1],'T','/NAS/tupac/matthieu/Masks/medial_wall_fsaverage.mat', '${WD}/DO80_zscore', [], '${WD}','CorrPos_DO80', [], 1);
# 	% load('${WD}/BPM.mat');
# 	% BPM.contrast{2,1}=[0;-1];
# 	% BPM = bpm_con_man_surf(BPM,163842);	
# EOF

# SUBJECTS_DIR=${FS_DIR}

# # for group in LTLE_RTLE LTLE RTLE
# # do
# 	for num_tmap in 1 2
# 	do
# 		for clus_thresh in 13 20 23 30 33 40
# 		do 
# # 			mri_surfcluster --in ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/lh.Tmap${num_tmap} \
# # 			  --csd /home/global/freesurfer5.3/average/mult-comp-cor/fsaverage/lh/cortex/fwhm07/pos/th${clus_thresh}/mc-z.csd \
# # 			  --mask /NAS/tupac/matthieu/Masks/lh.mask.mgh \
# # 			  --cwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.cluster.mgh \
# # 			  --vwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.voxel.mgh \
# # 			  --sum ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.cluster.summary \
# # 			  --ocn ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.ocn.mgh \
# # 			  --oannot ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.ocn.annot \
# # 			  --annot aparc \
# # 			  --csdpdf ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.pdf.dat \
# # 			  --cwpvalthresh 0.05 \
# # 			  --o ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.masked.mgh \
# # 			  --no-fixmni --bonferroni 2 --surf white --no-adjust
# # 
# # 			mri_surfcluster --in ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/rh.Tmap${num_tmap} \
# # 			  --csd /home/global/freesurfer5.3/average/mult-comp-cor/fsaverage/rh/cortex/fwhm07/pos/th${clus_thresh}/mc-z.csd \
# # 			  --mask /NAS/tupac/matthieu/Masks/rh.mask.mgh \
# # 			  --cwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.cluster.mgh \
# # 			  --vwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.voxel.mgh \
# # 			  --sum ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.cluster.summary \
# # 			  --ocn ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.ocn.mgh \
# # 			  --oannot ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.ocn.annot \
# # 			  --annot aparc \
# # 			  --csdpdf ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.pdf.dat \
# # 			  --cwpvalthresh 0.05 \
# # 			  --o ${FS_DIR}/BPM_analysis/LTLEvsRTLEvsCN_bbr_fwhm5_zscores_CTCov_V8bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm7/cache.th${clus_thresh}.pos.sig.masked.mgh \
# # 			  --no-fixmni --bonferroni 2 --surf white --no-adjust
# 			  
# 			mri_surfcluster --in ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/lh.Tmap${num_tmap} \
# 			  --csd /home/global/freesurfer5.3/average/mult-comp-cor/fsaverage_sym/lh/cortex/fwhm08/pos/th${clus_thresh}/mc-z.csd \
# 			  --mask /NAS/tupac/matthieu/Masks/lh.mask.fsaverage_sym.mgh \
# 			  --cwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.cluster.mgh \
# 			  --vwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.voxel.mgh \
# 			  --sum ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.cluster.summary \
# 			  --ocn ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.ocn.mgh \
# 			  --oannot ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.ocn.annot \
# 			  --annot aparc \
# 			  --csdpdf ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.pdf.dat \
# 			  --cwpvalthresh 0.05 \
# 			  --o ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/lh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.masked.mgh \
# 			  --no-fixmni --bonferroni 2 --surf white --no-adjust
# 
# 			mri_surfcluster --in ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/rh.Tmap${num_tmap} \
# 			  --csd /home/global/freesurfer5.3/average/mult-comp-cor/fsaverage_sym/rh/cortex/fwhm08/pos/th${clus_thresh}/mc-z.csd \
# 			  --mask /NAS/tupac/matthieu/Masks/rh.mask.fsaverage_sym.mgh \
# 			  --cwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.cluster.mgh \
# 			  --vwsig ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.voxel.mgh \
# 			  --sum ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.cluster.summary \
# 			  --ocn ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.ocn.mgh \
# 			  --oannot ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.ocn.annot \
# 			  --annot aparc \
# 			  --csdpdf ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.pdf.dat \
# 			  --cwpvalthresh 0.05 \
# 			  --o ${FS_DIR}/BPM_analysis/LTLEvsRTLE_fwhm5_zscores_CTCov_V7bbr/Clusterwise_correction_0.05/C${num_tmap}/rh_pos_noadjust_fwhm8/cache.th${clus_thresh}.pos.sig.masked.mgh \
# 			  --no-fixmni --bonferroni 2 --surf white --no-adjust
# 		done
# 	done
# # done

###################################################
# CORR : Surface rBPM + Clusterwise correction
###################################################
# 
# SUBJECTS_DIR=${FS_DIR}
# # RTLE 
# for group in All_subjects LTLE
# do
# 	for clus_thresh in 13 20 23 30 33 40
# 	do 
# 		mri_surfcluster --in ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/lh.Tmap_pos \
# 		  --csd /home/global/freesurfer5.3/average/mult-comp-cor/fsaverage/lh/cortex/fwhm07/pos/th${clus_thresh}/mc-z.csd \
# 		  --mask ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/lh.mask.mgh \
# 		  --cwsig ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.cluster.mgh \
# 		  --vwsig ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.voxel.mgh \
# 		  --sum ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.cluster.summary \
# 		  --ocn ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.ocn.mgh \
# 		  --oannot ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.ocn.annot \
# 		  --annot aparc \
# 		  --csdpdf ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.pdf.dat \
# 		  --cwpvalthresh 0.05 \
# 		  --o ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/lh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.masked.mgh \
# 		  --no-fixmni --bonferroni 2 --surf white --no-adjust
# 	
# 		mri_surfcluster --in ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/rh.Tmap_pos \
# 		  --csd /home/global/freesurfer5.3/average/mult-comp-cor/fsaverage/rh/cortex/fwhm07/pos/th${clus_thresh}/mc-z.csd \
# 		  --mask ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/rh.mask.mgh \
# 		  --cwsig ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.cluster.mgh \
# 		  --vwsig ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.voxel.mgh \
# 		  --sum ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.cluster.summary \
# 		  --ocn ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.ocn.mgh \
# 		  --oannot ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.ocn.annot \
# 		  --annot aparc \
# 		  --csdpdf ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.pdf.dat \
# 		  --cwpvalthresh 0.05 \
# 		  --o ${FS_DIR}/BPM_analysis/Surfacic_CORR_V2/${group}/Clusterwise_correction/rh_pos_noadjust_fwhm07/cache.th${clus_thresh}.pos.sig.masked.mgh \
# 		  --no-fixmni --bonferroni 2 --surf white --no-adjust
# 	done
# done

# #################################################
# # Visualize overlay LTLE - CT
# #################################################
# 
# mri_binarize --i cache.th13.pos.sig.cluster.mgh --min 0.1 --binval 1 --o cache.th13.pos.sig.cluster_th.mgh
# mri_binarize --i cache.th13.pos.sig.cluster.mgh --min 0.1 --binval 2 --o cache.th13.pos.sig.cluster_th.mgh
# fscalc lh.g6v2.demean.fwhm3.cbf_s.z/control-left.intercept/cache.th13.pos.sig.cluster_th.mgh add lh.g6v2.demean.fwhm10.Thickness/control-left.intercept/cache.th13.pos.sig.cluster_th.mgh \
# --o cache.th13.pos.sig.cluster_cbf_ct.mgh
# mris_seg2annot --seg ./cache.th13.pos.sig.cluster_cbf_ct.mgh --ctab ./Overlay_CBF_CT_CSvsL_LUT.txt --s fsaverage --h lh --o ./lh.CBF_CT.annot

# # =====================================================================================
# #         Perform surface second level statistical analysis (PALM)
# # =====================================================================================

SUBJECTS_DIR=${FS_DIR}

# # WD=/NAS/dumbo/matthieu/ASL_Epilepsy/PALM/ASL
# WD=/NAS/dumbo/matthieu/ASL_Epilepsy/PALM/ASL/Correlations
# # DescriptionDir=/NAS/dumbo/matthieu/ASL_Epilepsy/PALM/Description_files/LTLEvsRTLE
# DescriptionDir=/NAS/dumbo/matthieu/ASL_Epilepsy/PALM/Description_files/Correlations
# 
# # Design=Design_palm_LTLEvsRTLE.csv
# Design=Design_palm_All_patients.csv
# # index=1
# 
# # Correlations between all subjects and neuropsycho score ##
# 
# for group in All_patients LTLE RTLE
# do
# 	for score in AffNeg AffPos BDI BEE EmpAff EmpCog IS PAS RLE SAS ScoGFauxPas SS Stai-Trait TCFS TotalIRI TotalQOLIE TotalTAS
# 	do
# 		for fwhm in 5 10
# 		do
# # 			if [ ! -d ${WD}/${group}/${score}/fwhm${fwhm} ]
# # 			then
# # 				mkdir -p ${WD}/${group}/${score}/fwhm${fwhm}
# # 			fi
# 			
# 			for con in CorrPos CorrNeg
# 			do
# 				## ASL RTLE & LTLE + TFCE : default parameters for pmethod ##
# 				qbatch -q three_job_q -oe /NAS/dumbo/matthieu/ASL_Epilepsy/PALM/Logdir -N palm_${score}_${group}_fwhm${fwhm}_${con}_tfce_lh palm -i ${DescriptionDir}/${group}/lh.all.patients.fwhm${fwhm}.cbf_s.zscore.mgh \
# 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 				/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 500 -approx tail -nouncorrected \
# 				-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D -pearson \
# 				-d ${WD}/${group}/${score}/${Design} \
# 				-t ${WD}/${group}/Contrasts_palm_${con}.csv \
# 				-logp -o ${WD}/${group}/${score}/fwhm${fwhm}/palm.${group}.${score}.fwhm${fwhm}.${con}.lh	
# 				sleep 1
# 
# 				qbatch -q three_job_q -oe /NAS/dumbo/matthieu/ASL_Epilepsy/PALM/Logdir -N palm_${score}_${group}_fwhm${fwhm}_${con}_tfce_rh palm -i ${DescriptionDir}/${group}/rh.all.patients.fwhm${fwhm}.cbf_s.zscore.mgh \
# 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 				/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 500 -approx tail -nouncorrected \
# 				-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D -pearson \
# 				-d ${WD}/${group}/${score}/${Design} \
# 				-t ${WD}/${group}/Contrasts_palm_${con}.csv \
# 				-logp -o ${WD}/${group}/${score}/fwhm${fwhm}/palm.${group}.${score}.fwhm${fwhm}.${con}.rh	
# 				sleep 1
# 			done
# 		done
# 	done
# 
# # 	## PET TYP_ATYP + CT as EV + TFCE : default parameters for pmethod ##
# # 	qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_${group}_tfce_lh palm -i ${DescriptionDir}/lh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 	-evperdat ${DescriptionDir}/lh.all.subjects.fsaverage.sm10.mgh 3 1 \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.lh	
# # 	sleep 1
# # 
# # 	qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_${group}_tfce_rh palm -i ${DescriptionDir}/rh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 	-evperdat ${DescriptionDir}/rh.all.subjects.fsaverage.sm10.mgh 3 1 \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.rh	
# # 	sleep 1
# 
# # 	## CT TYP_ATYP + TFCE : default parameters for pmethod ##
# # 	qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_${group}_tfce_lh palm -i ${DescriptionDir}/lh.all.subjects.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.lh	
# # 	sleep 1
# # 
# # 	qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_${group}_tfce_rh palm -i ${DescriptionDir}/rh.all.subjects.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.rh	
# # 	sleep 1
# done

## Comparisons between LTLE, RTLE and CN groups ##

# # for group in CNvsLTLE CNvsRTLE LTLEvsCN RTLEvsCN
# # for group in F
# for group in LTLEvsRTLE RTLEvsLTLE
# do 
# 	for FWHM in 5 10
# # 	for FWHM in 10
# 	do
# # 		CD=CNvsLTLEvsRTLE_fwhm${FWHM}_0Cov_i10000_pvc_zscores_TFCE_defaults
# 		CD=LTLEvsRTLE_fwhm${FWHM}_0Cov_i10000_pvc_zscores_TFCE_defaults
# 
# # # 		## ASL CNvsLTLEvsRTLE + TFCE : default parameters for pmethod & F-contrast ##
# # # 		qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_tfce_ASL_lh_F_${FWHM}_pvc_z palm -i ${DescriptionDir}/lh.all.subjects.fwhm${FWHM}.cbf_pvc_s.zscore.mgh \
# # # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # # 		-d ${WD}/${CD}/${Design} \
# # # 		-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # # 		-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # # 		-fonly -twotail \
# # # 		-logp -o ${WD}/${CD}/palm.F.lh
# # # 		sleep 1
# # # 			
# # # 		qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_tfce_ASL_rh_F_${FWHM}_pvc_z palm -i ${DescriptionDir}/rh.all.subjects.fwhm${FWHM}.cbf_pvc_s.zscore.mgh \
# # # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # # 		-d ${WD}/${CD}/${Design} \
# # # 		-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # # 		-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # # 		-fonly -twotail \
# # # 		-logp -o ${WD}/${CD}/palm.F.rh
# # # 		sleep 1
# # 		
# # 		# ASL CNvsLTLEvsRTLE + TFCE : default parameters for pmethod ##
# # 		qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_tfce_ASL_lh_${group}_${FWHM}_pvc_z palm -i ${DescriptionDir}/lh.all.subjects.fwhm${FWHM}.cbf_pvc_s.zscore.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # 		sleep 1
# # 			
# # 		qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_tfce_ASL_rh_${group}_${FWHM}_pvc_z palm -i ${DescriptionDir}/rh.all.subjects.fwhm${FWHM}.cbf_pvc_s.zscore.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.rh
# # 		sleep 1
# # 		
# 		## ASL LTLEvsRTLE + TFCE : default parameters for pmethod ##
# 		qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_tfce_ASL_lh_${group}_${FWHM}_pvc_z palm -i ${DescriptionDir}/lh.all.subjects.fwhm${FWHM}.cbf_pvc_s.zscore.mgh \
# 		-s /home/global/freesurfer5.3/subjects/fsaverage_sym/surf/lh.white \
# 		/home/global/freesurfer5.3/subjects/fsaverage_sym/surf/lh.white.avg.area.mgh -n 10000 \
# 		-m /NAS/tupac/matthieu/Masks/lh.mask.fsaverage_sym.mgh -T -tfce2D \
# 		-d ${WD}/${CD}/${Design} \
# 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 		-logp -o ${WD}/${CD}/palm.${group}.lh
# 		sleep 1
# 			
# 		qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_tfce_ASL_rh_${group}_${FWHM}_pvc_z palm -i ${DescriptionDir}/rh.all.subjects.fwhm${FWHM}.cbf_pvc_s.zscore.mgh \
# 		-s /home/global/freesurfer5.3/subjects/fsaverage_sym/surf/rh.white \
# 		/home/global/freesurfer5.3/subjects/fsaverage_sym/surf/rh.white.avg.area.mgh -n 10000 \
# 		-m /NAS/tupac/matthieu/Masks/rh.mask.fsaverage_sym.mgh -T -tfce2D \
# 		-d ${WD}/${CD}/${Design} \
# 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 		-logp -o ${WD}/${CD}/palm.${group}.rh
# 		sleep 1
# 
# # 		## CT CNvsLTLEvsRTLE + TFCE : default parameters for pmethod & F-contrast ##
# # 		qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_tfce_lh_F palm -i ${DescriptionDir}/lh.all.subjects.CT.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 		-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 		-fonly -twotail \
# # 		-logp -o ${WD}/${CD}/palm.F.lh
# # 		sleep 1
# # 	
# # 		qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_tfce_rh_F palm -i ${DescriptionDir}/rh.all.subjects.CT.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 		-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 		-fonly -twotail \
# # 		-logp -o ${WD}/${CD}/palm.F.rh
# # 		sleep 1
# # 
# # 		## CT CNvsLTLEvsRTLE + TFCE : default parameters for pmethod ##
# # 		qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_tfce_lh_${group} palm -i ${DescriptionDir}/lh.all.subjects.CT.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # 		sleep 1
# # 			
# # 		qbatch -q three_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_tfce_rh_${group} palm -i ${DescriptionDir}/rh.all.subjects.CT.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.rh	
# # 		sleep 1
# # 
# # 		## CT LTLEvsRTLE + TFCE : default parameters for pmethod ##
# # 		qbatch -q two_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_tfce_lh_${group} palm -i ${DescriptionDir}/lh.all.subjects.CT.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage_sym/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage_sym/surf/lh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.fsaverage_sym.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # 		sleep 1
# # 	
# # 		qbatch -q two_job_q -oe /NAS/dumbo/matthieu/Logdir -N palm_CT_tfce_rh_${group} palm -i ${DescriptionDir}/rh.all.subjects.CT.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage_sym/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage_sym/surf/rh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.fsaverage_sym.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.rh
# # 		sleep 1
# 
# # 	# 	## ASL CNvsLTLEvsRTLE + CT as EV + TFCE : default parameters for pmethod & F-contrast ##
# # 	# 	qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_ASL_tfce_lh_F_ct palm -i ${DescriptionDir}/lh.all.subjects.fwhm3.cbf_pvc_s.zscore.mgh \
# # 	# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -accel tail -n 500 -nouncorrected \
# # 	# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 	# 	-evperdat ${DescriptionDir}/lh.all.subjects.CT.mgh 5 1 \
# # 	# 	-d ${WD}/${CD}/${Design} \
# # 	# 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# 	-fonly -twotail \
# # 	# 	-logp -o ${WD}/${CD}/palm.F.lh
# # 	# 	sleep 1
# # 	# 		
# # 	# 	qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_ASL_tfce_rh_F_ct palm -i ${DescriptionDir}/rh.all.subjects.fwhm3.cbf_pvc_s.zscore.mgh \
# # 	# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.whiecho ${base}.nii.gz `fslstats ${base}.nii.gz -R` >> InfosStatste \
# # 	# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -accel tail -n 500 -nouncorrected \
# # 	# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 	# 	-evperdat ${DescriptionDir}/rh.all.subjects.CT.mgh 5 1 \
# # 	# 	-d ${WD}/${CD}/${Design} \
# # 	# 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# 	-fonly -twotail \
# # 	# 	-logp -o ${WD}/${CD}/palm.F.rh
# # 	# 	sleep 1
# # 		
# # 		## ASL CNvsLTLEvsRTLE + CT as EV + TFCE : default parameters for pmethod ##
# # 		qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_ASL_tfce_lh_${group}_ct palm -i ${DescriptionDir}/lh.all.subjects.fwhm3.cbf_pvc_s.zscore.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -accel tail -n 500 -nouncorrected \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 		-evperdat ${DescriptionDir}/lh.all.subjects.CT.mgh 5 1 \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # 		sleep 1
# # 	
# # 		qbatch -q M32_q -oe /NAS/dumbo/matthieu/Logdir -N palm_ASL_tfce_rh_${group}_ct palm -i ${DescriptionDir}/rh.all.subjects.fwhm3.cbf_pvc_s.zscore.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -accel tail -n 500 -nouncorrected \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 		-evperdat ${DescriptionDir}/rh.all.subjects.CT.mgh 5 1 \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.rh
# # 		sleep 1
# 	done
# done

# # =====================================================================================
# #         Visualize stats results and make montages
# # =====================================================================================
# 
PALM_dir=/NAS/dumbo/matthieu/ASL_Epilepsy/PALM/ASL/Correlations
# for group in CNvsLTLE CNvsRTLE LTLEvsCN RTLEvsCN
# for group in LTLEvsRTLE RTLEvsLTLE
# for group in F
# for group in All_patients LTLE RTLE
for group in RTLE
do
# 	for score in AffNeg AffPos BDI BEE EmpAff EmpCog IS PAS RLE SAS ScoGFauxPas SS Stai-Trait TCFS TotalIRI TotalQOLIE TotalTAS
	for score in SS
	do
# 		for fwhm in 5 10
		for fwhm in 10
		do
# 			for con in CorrPos CorrNeg
			for con in CorrNeg
			do
				cd ${PALM_dir}/${group}/${score}/fwhm${fwhm}
				
# 				if [ ! -s palm.${group}.${score}.fwhm${fwhm}.${con}.lh_tfce_rstat_fwep.mgz ]
# 				then
# 					echo "palm.${group}.${score}.fwhm${fwhm}.${con}.lh_tfce_rstat_fwep.mgz doesn't exist"
# 				fi
# 				
# 				if [ ! -s palm.${group}.${score}.fwhm${fwhm}.${con}.rh_tfce_rstat_fwep.mgz ]
# 				then
# 					echo "palm.${group}.${score}.fwhm${fwhm}.${con}.rh_tfce_rstat_fwep.mgz doesn't exist"
# 				fi
# 				
# 				for i in palm.${group}.?h_tfce_tstat_fwep.mgz ; do
# 				for i in palm.F.?h_tfce_fstat_fwep.mgz ; do
# 				for i in palm.${group}.${score}.fwhm${fwhm}.${con}.?h_tfce_rstat_fwep.mgz ; do
# 					base=${i%.mgz}
# 					mri_convert $i ${base}.nii.gz
# 					echo ${base}.nii.gz `fslstats ${base}.nii.gz -R` >> InfosStats
# 				done
# 				
# 				thresh_lh=`fslstats palm.${group}.${score}.fwhm${fwhm}.${con}.lh_tfce_rstat_fwep.nii.gz -R | awk '{print $2}'`
# 				thresh_bin_lh=`echo "${thresh_lh}>=1.3" | bc`
# 				if [ ${thresh_bin_lh} -eq 1 ]
# 				then
# 					echo "palm.${group}.${score}.fwhm${fwhm}.${con}.lh_tfce_rstat_fwep.nii.gz is significant: p = ${thresh_lh}"
# 				fi
# 				thresh_rh=`fslstats palm.${group}.${score}.fwhm${fwhm}.${con}.rh_tfce_rstat_fwep.nii.gz -R | awk '{print $2}'`
# 				thresh_bin_rh=`echo "${thresh_rh}>=1.3" | bc`
# 				if [ ${thresh_bin_rh} -eq 1 ]
# 				then
# 					echo "palm.${group}.${score}.fwhm${fwhm}.${con}.rh_tfce_rstat_fwep.nii.gz is significant: p = ${thresh_rh}"
# 				fi
				
				Make_montage_scales.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay palm.${group}.${score}.fwhm${fwhm}.${con}.lh_tfce_rstat_fwep.mgz  \
				-rhoverlay palm.${group}.${score}.fwhm${fwhm}.${con}.rh_tfce_rstat_fwep.mgz  -fminmaxl 1.3 1.4 -fmidl 1.35 -fminmaxr 1.3 1.4 -fmidr 1.35 -output ${group}.${score}.fwhm${fwhm}.${con}_scaled.tiff -template -axial
			done
		done
	done
done



# # # for results in CorrAll_PraxiesGestes_fwhm10_gn_MGRousset_i5000_TFCE_defaults_CT_Cov
# # # do
# # # # 	for group in TYPvsATYP ATYPvsTYP
# # # 	for group in CorrPosPraxiesGestes
# # # 	do 
# # # 		Make_montage_scales.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_rstat_fwep.mgz  \
# # # 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_rstat_fwep.mgz  -fminmaxl 1.3 2.92 -fmidl 2.11  -fminmaxr 0.7 1.98 -fmidr 1.34 -output ${PALM_dir}/${results}/${group}_scaled.tiff -template -axial
# # # 	done
# # # done
# # # 
# # for results in TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i15000 TYPvsLANGvsVISUvsEXEvsNC_3Cov_fwhm15_i15000
# for results in TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i15000
# do
# 	for meas in fractaldimension gyrification sqrtsulc thickness
# 	do
# # 		for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # 		for group in NCvsATYP NCvsTYP NCvsLANG NCvsVISU NCvsEXE
# 		for group in TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
# # 		for group in F
# 		do 
# 			thresh_lh=`fslstats ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
# 			thresh_bin_lh=`echo "${thresh_lh}>1.3" | bc`
# 			thresh_rh=`fslstats ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
# 			thresh_bin_rh=`echo "${thresh_rh}>1.3" | bc`
# 			if [ ${thresh_bin_lh} -eq 1 -o ${thresh_bin_rh} -eq 1 ]
# 			then
# 				## Not scaled
# # 				# F-stat
# # 				Make_montage.sh  -fs  ${SUBJECTS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_fstat_fwep.mgz  \
# # 				-rhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_fstat_fwep.mgz  -fminmax 1.3 4.18 -fmid 2.74  -output ${PALM_dir}/${results}/${meas}/${group}.tiff -template -axial
# 				# T-stat
# 				Make_montage.sh  -fs  ${SUBJECTS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_tstat_fwep.mgz  \
# 				-rhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_tstat_fwep.mgz  -fminmax 1.3 4.18 -fmid 2.74  -output ${PALM_dir}/${results}/${meas}/${group}.tiff -template -axial
# 				## Scaled
# 		# 		Make_montage_scales.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_tstat_fwep.mgz  \
# 		# 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_tstat_fwep.mgz  -fminmaxl 1 1.19 -fmidl 1.09  -fminmaxr 0.7 1.11 -fmidr 0.905 -output ${PALM_dir}/${results}/${group}_scaled.tiff -template -axial
# 			fi
# 		done
# 	done
# done

# # ==========================================================================
# #      Perform volumetric second level statistical analysis (SPM12)
# # ==========================================================================

# if [ ! -d ${FS_DIR}/VolumeAnalysis_SPM12/V2/FullFactorial_s3_cbf_s_zscore ]
# then
# 	mkdir -p ${FS_DIR}/VolumeAnalysis_SPM12/FullFactorial_s3_cbf_s_zscore
# else
# 	rm -rf ${FS_DIR}/VolumeAnalysis_SPM12/FullFactorial_s3_cbf_s_zscore/*
# fi	
# 
## Full factorial design ##

# matlab -nodisplay <<EOF
# 
# 	%% Initialise SPM defaults
# 	%-----------------------------------------------------------------------
# 	spm('defaults', 'FMRI');
# 
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 
# 	matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/V2/FullFactorial_s3_cbf_s_zscore_SubCort'};
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.name = 'Lateralization_Seizure';
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.levels = 3;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.dept = 0;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.variance = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(1).levels = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(1).scans = {
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BDCS26/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BECS20/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BMCS01/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CMCS27/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CRCS17/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CSCS28/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DSCS18/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/HSCS05/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LDCS16/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LJCS02/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LPCS04/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MFCS23/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MSCS19/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/NPCS24/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/PVCS25/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/RBCS03/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/SSCS21/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/750820NB120315/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/561112EC250315/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/710630SD120215/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  };
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).levels = 2;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).scans = {
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DGEG09/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DJEG13/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LHEG23/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LLEG12/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MJEG02/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MMEG03/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MSEG07/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/OAEG01/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VGEG10/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'                                                                 
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Bricout_Josette/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Gerard_Laurent/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Legrand_MarieClaire/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Mezier_Julie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Pais_CarlaMaria/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Pospieszny_Jeanne-Marie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vernieuwe_Frederic/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Dufay_Christine/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Caron_Nathalie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Comyn_Remi/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Derode_Corinne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vanderheeren_Olivier/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 			    						  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Goetgheluck_Marianne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 			    						  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Devloo_Annie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Jean_Baptiste_Joan/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  };
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(3).levels = 3;
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(3).scans = {
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CPED05/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DHED14/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DJED25/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/EOED04/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/FLED06/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/KEED15/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/RAED24/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VPED11/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Decommer_Brigitte/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Doyet_Corinne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Laboureur_Annie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Lefebvre_Paulette/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Salvati_Vincenza/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vilain_Serge/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Dufresne_Patricia/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Aboudou_Salim/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Hermant_Vanhallewyn_Geoffrey/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 									  };
# 	
# 	matlabbatch{end}.spm.stats.factorial_design.des.fd.contrasts = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.cov(1).c = [0;1;1;0;0;1;0;0;0;1;0;0;1;0;1;1;1;1;1;1;0;0;1;0;1;1;1;0;0;1;0;1;1;1;1;0;1;1;0;1;0;1;1;1;0;0;0;0;0;1;1;1;1;1;1;1;1;0;1;0;0];
# 	matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Sex';
# 	matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.cov(2).c = [53.8125;33.3963;22.8939;31.0719;60.4107;37.1198;54.7433;40.5777;25.5715;27.0719;53.3060;50.3682;45.9274;41.6482;31.5510;54.5133;...
# 	51.8467;39.5592;58.3628;43.6222;54.5927;49.2950;44.1588;40.5667;26.4723;24.3504;54.8419;42.0698;42.1191;56.4244;35.4606;56.5585;26.1109;40.5065;59.7372;38.4339;37.0349;36.4627;29.7906;48.6023;42.4312;51.7372;...
# 	53.2101;56.0246;59.1376;49.2512;64.4408;47.7426;35.8111;25.5524;35.7290;47.6879;45.7769;42.7734;63.4196;56.9008;43.8439;60.0602;46.9733;24.7420;30.2998];
# 	matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Age';
# 	matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.cov(3).c = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;52.5927;39.2950;14.1588;37.5667;17.4723;10.3504;21.8419;33.0698;3.1191;32.4244;32.4606;53.5585;...
# 	17.1109;4.5065;49.7372;7.4339;30.0349;35.4627;4.7906;40.6023;24.4312;21.7372;3.2101;12.0246;33.1376;23.2512;59.4408;36.7426;12.8111;20.5524;21.7290;6.6879;6.7769;28.7734;15.4196;3.9008;22.8439;...
# 	12.0602;24.9733;11.7420;10.2998];
# 	matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'Evolution_Duration';
# 	matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# 	matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.masking.em = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/template/TemplateSubCortMask_dil.nii'};
# 	matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# 	matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# 	matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# 	matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# 	matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# 
# 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 	%% RUN
# 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 	spm_jobman('run',matlabbatch);
# EOF

## Two-sample T-test : CS vs LTLE ##

# matlab -nodisplay <<EOF
# 
# %% Initialise SPM defaults
# %--------------------------------------------------------------------------
# spm('defaults', 'FMRI');
# 
# spm_jobman('initcfg');
# matlabbatch={};
# 
# matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/V2/TwoSampleTtest_s3_cbf_s_zscore_CSvsLTLE_SubCort'};
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = {
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BDCS26/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BECS20/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BMCS01/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CMCS27/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CRCS17/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CSCS28/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DSCS18/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/HSCS05/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LDCS16/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LJCS02/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LPCS04/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MFCS23/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MSCS19/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/NPCS24/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/PVCS25/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/RBCS03/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/SSCS21/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/750820NB120315/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/561112EC250315/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/710630SD120215/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 							  };
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 =  {
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DGEG09/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DJEG13/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LHEG23/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LLEG12/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MJEG02/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MMEG03/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MSEG07/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/OAEG01/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VGEG10/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'                                                                 
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Bricout_Josette/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Gerard_Laurent/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Legrand_MarieClaire/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Mezier_Julie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Pais_CarlaMaria/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Pospieszny_Jeanne-Marie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vernieuwe_Frederic/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Dufay_Christine/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Caron_Nathalie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Comyn_Remi/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Derode_Corinne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vanderheeren_Olivier/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 			    					  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Goetgheluck_Marianne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 			    					  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Devloo_Annie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Jean_Baptiste_Joan/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 							  };
# matlabbatch{end}.spm.stats.factorial_design.des.t2.dept = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.gmsca = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.ancova = 0;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).c = [0;1;1;0;0;1;0;0;0;1;0;0;1;0;1;1;1;1;1;1;0;0;1;0;1;1;1;0;0;1;0;1;1;1;1;0;1;1;0;1;0;1;1;1];
# matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Sex';
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).c = [53.8125;33.3963;22.8939;31.0719;60.4107;37.1198;54.7433;40.5777;25.5715;27.0719;53.3060;50.3682;45.9274;41.6482;31.5510;54.5133;...
# 51.8467;39.5592;58.3628;43.6222;54.5927;49.2950;44.1588;40.5667;26.4723;24.3504;54.8419;42.0698;42.1191;56.4244;35.4606;56.5585;26.1109;40.5065;59.7372;38.4339;37.0349;36.4627;29.7906;48.6023;42.4312;51.7372;...
# 53.2101;56.0246];
# matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Age';
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).c = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;52.5927;39.2950;14.1588;37.5667;17.4723;10.3504;21.8419;33.0698;3.1191;32.4244;32.4606;53.5585;...
# 17.1109;4.5065;49.7372;7.4339;30.0349;35.4627;4.7906;40.6023;24.4312;21.7372;3.2101;12.0246];
# matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'Evolution_Duration';
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.em = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/template/TemplateSubCortMask_dil.nii,1'};
# matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'CS > LTLE';
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'LTLE > CS';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.delete = 0;
# 
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# %% RUN
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# spm_jobman('run',matlabbatch);
# 
# EOF

## Two-sample T-test : CS vs RTLE ##

# matlab -nodisplay <<EOF
# 
# %% Initialise SPM defaults
# %--------------------------------------------------------------------------
# spm('defaults', 'FMRI');
# 
# spm_jobman('initcfg');
# matlabbatch={};
# 
# matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/V2/TwoSampleTtest_s3_cbf_s_zscore_CSvsRTLE_SubCort'};
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = {
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BDCS26/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BECS20/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BMCS01/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CMCS27/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CRCS17/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CSCS28/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DSCS18/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/HSCS05/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LDCS16/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LJCS02/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LPCS04/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MFCS23/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MSCS19/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/NPCS24/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/PVCS25/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/RBCS03/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/SSCS21/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/750820NB120315/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/561112EC250315/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/710630SD120215/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 							  };
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 =  {
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CPED05/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DHED14/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DJED25/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/EOED04/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/FLED06/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/KEED15/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/RAED24/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VPED11/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Decommer_Brigitte/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Doyet_Corinne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Laboureur_Annie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Lefebvre_Paulette/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Salvati_Vincenza/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vilain_Serge/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Dufresne_Patricia/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Aboudou_Salim/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Hermant_Vanhallewyn_Geoffrey/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 							  };
# matlabbatch{end}.spm.stats.factorial_design.des.t2.dept = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.gmsca = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.ancova = 0;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).c = [0;1;1;0;0;1;0;0;0;1;0;0;1;0;1;1;1;1;1;1;0;0;0;0;0;1;1;1;1;1;1;1;1;0;1;0;0];
# matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Sex';
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).c = [53.8125;33.3963;22.8939;31.0719;60.4107;37.1198;54.7433;40.5777;25.5715;27.0719;53.3060;50.3682;45.9274;41.6482;31.5510;54.5133;...
# 	51.8467;39.5592;58.3628;43.6222;59.1376;49.2512;64.4408;47.7426;35.8111;25.5524;35.7290;47.6879;45.7769;42.7734;63.4196;56.9008;43.8439;60.0602;46.9733;24.7420;30.2998];
# matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Age';
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).c = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;33.1376;23.2512;59.4408;36.7426;12.8111;20.5524;21.7290;6.6879;6.7769;28.7734;15.4196;3.9008;22.8439;...
# 	12.0602;24.9733;11.7420;10.2998];
# matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'Evolution_Duration';
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.em = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/template/TemplateSubCortMask_dil.nii,1'};
# matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'CS > RTLE';
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0];/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/V2
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'RTLE > CS';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.delete = 0;
# 
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# %% RUN
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# spm_jobman('run',matlabbatch);
# 
# EOF

## Two-sample T-test : LTLE vs RTLE ##

# matlab -nodisplay <<EOF
# 
# %% Initialise SPM defaults
# %--------------------------------------------------------------------------
# spm('defaults', 'FMRI');
# 
# spm_jobman('initcfg');
# matlabbatch={};
# 
# matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/V2/TwoSampleTtest_s3_cbf_s_zscore_RTLEvsLTLE_SubCort'};
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = {
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DGEG09/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DJEG13/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LHEG23/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/LLEG12/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MJEG02/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MMEG03/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/MSEG07/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/OAEG01/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VGEG10/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'                                                                 
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Bricout_Josette/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Gerard_Laurent/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Legrand_MarieClaire/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Mezier_Julie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Pais_CarlaMaria/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Pospieszny_Jeanne-Marie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vernieuwe_Frederic/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Dufay_Christine/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Caron_Nathalie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Comyn_Remi/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Derode_Corinne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vanderheeren_Olivier/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 			    					  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Goetgheluck_Marianne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 			    					  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Devloo_Annie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Jean_Baptiste_Joan/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 							  };
# matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 =  {
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/CPED05/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DHED14/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/DJED25/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/EOED04/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/FLED06/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/KEED15/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/RAED24/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VPED11/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Decommer_Brigitte/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Doyet_Corinne/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Laboureur_Annie/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Lefebvre_Paulette/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Salvati_Vincenza/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vilain_Serge/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Dufresne_Patricia/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Aboudou_Salim/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 								  '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Hermant_Vanhallewyn_Geoffrey/asl/Volumetric_Analyses/s3_cbf_s_zscore.nii,1'
# 							  };
# matlabbatch{end}.spm.stats.factorial_design.des.t2.dept = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 1;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.gmsca = 0;
# matlabbatch{end}.spm.stats.factorial_design.des.t2.ancova = 0;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).c = [0;0;1;0;1;1;1;0;0;1;0;1;1;1;1;0;1;1;0;1;0;1;1;1;0;0;0;0;0;1;1;1;1;1;1;1;1;0;1;0;0];
# matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Sex';
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).c = [54.5927;49.2950;44.1588;40.5667;26.4723;24.3504;54.8419;42.0698;42.1191;56.4244;35.4606;56.5585;26.1109;40.5065;59.7372;38.4339;37.0349;36.4627;29.7906;48.6023;42.4312;51.7372;...
# 53.2101;56.0246;59.1376;49.2512;64.4408;47.7426;35.8111;25.5524;35.7290;47.6879;45.7769;42.7734;63.4196;56.9008;43.8439;60.0602;46.9733;24.7420;30.2998];
# matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Age';
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).c = [52.5927;39.2950;14.1588;37.5667;17.4723;10.3504;21.8419;33.0698;3.1191;32.4244;32.4606;53.5585;...
# 17.1109;4.5065;49.7372;7.4339;30.0349;35.4627;4.7906;40.6023;24.4312;21.7372;3.2101;12.0246;33.1376;23.2512;59.4408;36.7426;12.8111;20.5524;21.7290;6.6879;6.7769;28.7734;15.4196;3.9008;22.8439;...
# 12.0602;24.9733;11.7420;10.2998];
# matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'Evolution_Duration';
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
# matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
# matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
# matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
# matlabbatch{end}.spm.stats.factorial_design.masking.em = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/template/TemplateSubCortMask_dil.nii,1'};
# matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
# matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
# matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
# matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
# matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'LTLE > RTLE';
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'RTLE > LTLE';
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0 0];
# matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
# matlabbatch{end}.spm.stats.con.delete = 0;
# 
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# %% RUN
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# spm_jobman('run',matlabbatch);
# 
# EOF

# # # =======================================================================
# # #      Compute FDR Q-values threshold map and project it on fsaverage
# # # =======================================================================
# 
# TARGET_DIR=/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/FullFactorial_s6_zscore
# 
# /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# 	
# 	% get, read in SPM.mat
# 	  mat = fullfile('${TARGET_DIR}','SPM.mat');
# 	  [p, nm, e, ~] = spm_fileparts(mat);
# 	  load(mat);
# 
# 	% read in original spmT
# 	  V_ori = spm_vol([p filesep 'spmT_0004.nii']);
# 	  t_ori = spm_read_vols(V_ori);
# 	  t_ori(isnan(t_ori)) = 0;
# 
# 	% Compute the FDR Q values
# 	% slm.t    = 1 x v vector of test statistics, v=#vertices.
# 	% slm.df   = degrees of freedom.
# 	% slm.dfs  = 1 x v vector of optional effective degrees of freedom.
# 	% slm.k    = #variates.
# 	% mask     = 1 x v logical vector, 1=inside, 0=outside, 
# 	%          = ones(1,v), i.e. the whole surface, by default.
# 	slm.t = t_ori(:)';
# 	slm.df   = SPM.xX.erdf;
# 	slm.k   = 1;
# 
# 	mask_orig = spm_vol([p filesep SPM.VM.fname]);
# 	mask = logical(spm_read_vols(mask_orig));
# 	mask(isnan(mask)) = 0;
# 	mask_v = mask(:)';
# 
# 	qval = SurfStatQ( slm , mask_v );
# 
# 	% Reformat Q-values volume image
# 	Qval_thresh = double(zeros(1,length(qval.Q)));
# 	idx = find(qval.Q <= 0.05);
# 	Qval_thresh(idx) = (1-qval.Q(idx));
# 	Qval_thresh = reshape(Qval_thresh,size(t_ori));
# 
# 	% write out
# 	  V_ori.fname = [p filesep 'Qval_thresh.nii'];
# 	  spm_write_vol(V_ori, Qval_thresh);
# EOF
# 	
# # Assign input values of arguments
# SUBJ_ID=template
# 
# # Assign new value of SUBJECTS_DIR
# SUBJECTS_DIR=${FS_DIR}
# 
# ## Map on surface Qval_thresh
# for var in Qval_thresh
# do
# 	mri_vol2surf --mov ${TARGET_DIR}/${var}.nii --regheader ${SUBJ_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${TARGET_DIR}/lh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
# 	mri_vol2surf --mov ${TARGET_DIR}/${var}.nii --regheader ${SUBJ_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${TARGET_DIR}/rh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
# done	