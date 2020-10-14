#!/bin/bash

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: Main_antsASLEpilepsy.sh -id <InputDir> -fs <SubjDir> -od <OutputDir> -td <TemplateDir> -f <SubjectsPath>"
	echo ""
	echo "  -id		: Input directory containing the raw data"
	echo "  -fs		: Path to FS output directory"
	echo "  -od		: Output ASL directory"
	echo "  -td		: Template data directory"	
	echo "	-f  		: Path of the file subjects.txt"
	echo ""
	echo "Usage: Main_antsASLEpilepsy.sh -id <InputDir> -fs <SubjDir> -od <OutputDir> -td <TemplateDir> -f <SubjectsPath>"
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
		echo "Usage: Main_antsASLEpilepsy.sh -id <InputDir> -fs <SubjDir> -od <OutputDir> -td <TemplateDir> -f <SubjectsPath>"
		echo ""
		echo "  -id		: Input directory containing the raw data"
		echo "  -fs		: Path to FS output directory"
		echo "  -od		: Output ASL directory"
		echo "  -td		: Template data directory"	
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage: Main_antsASLEpilepsy.sh -id <InputDir> -fs <SubjDir> -od <OutputDir> -td <TemplateDir> -f <SubjectsPath>"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory containing the raw data : ${INPUT_DIR}"
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Path to FS output directory : ${FS_DIR}"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Output ASL directory : ${OUTPUT_DIR}"
		;;
	-td)
		index=$[$index+1]
		eval TEMPLATE_DIR=\${$index}
		echo "Template data directory : ${TEMPLATE_DIR}"
		;;
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file subjects.txt : ${FILE_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: Main_antsASLEpilepsy.sh -id <InputDir> -fs <SubjDir> -od <OutputDir> -td <TemplateDir> -f <SubjectsPath>"
		echo ""
		echo "  -id		: Input directory containing the raw data"
		echo "  -fs		: Path to FS output directory"
		echo "  -od		: Output ASL directory"
		echo "  -td		: Template data directory"	
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage: Main_antsASLEpilepsy.sh -id <InputDir> -fs <SubjDir> -od <OutputDir> -td <TemplateDir> -f <SubjectsPath>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1	 
elif [ -z ${TEMPLATE_DIR} ]
then
	 echo "-td argument mandatory"
	 exit 1	 
elif [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1	 	
fi

# # =====================================================================================
# #            Create output directories and convert T1.mgz into LAS T1.nii.gz
# # =====================================================================================
# 
# if [ -s ${FILE_PATH}/subjects.txt ]
# then
# 	while read SUBJ_ID  
# 	do 
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp ]
# 		then
# 			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp
# 		else
# # 			mv ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp_back
# # 			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp
# 			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/*
# 		fi
# 
# 		echo "mri_convert ${FS_DIR}/${SUBJ_ID}/mri/T1.mgz ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1.nii.gz --out_orientation LAS"
# 		mri_convert ${FS_DIR}/${SUBJ_ID}/mri/T1.mgz ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1.nii.gz --out_orientation LAS
# 
# # ==============================================================
# #       Performs T1 anatomical brain processing : 
# #		1) Brain extraction, 
# #		2) Brain n-tissue segmentation
# #		4) Registration to a template
# # ==============================================================
# 
# 		qbatch -N BP_${SUBJ_ID} -q M64_q -oe ~/Logdir antsBE_SEG_REGTemp.sh -d 3 \
# 		-a ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1.nii.gz \
# 		-e ${TEMPLATE_DIR}/T_template_3DT1.nii \
# 		-m ${TEMPLATE_DIR}/T_templateProbabilityMask.nii.gz \
# 		-p ${TEMPLATE_DIR}/Priors/priors%d.nii.gz \
# 		-t ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz \
# 		-k 1 \
# 		-n 3 \
# 		-w 0.25 \
# 		-o ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_
# 		sleep 1
# 
# 	done < ${FILE_PATH}/subjects.txt
# fi

# # =========================================================================================================
# #     Correct distorsion of ASL 4D files and re-order ASL data for antsASLProcessing.sh : 0-tag 1-control
# # =========================================================================================================
# 
# if [ -s ${FILE_PATH}/subjects.txt ]
# then
# 	while read SUBJ_ID  
# 	do 
# 		qbatch -N DC_${SUBJ_ID} -q fs_q -oe ~/Logdir antsASL_DistorsionsCorrections.sh  \
# 		-id ${INPUT_DIR} \
# 		-od ${OUTPUT_DIR} \
# 		-dn ASLProcessing \
# 		-subj ${SUBJ_ID}
# 		sleep 1
# 	done < ${FILE_PATH}/subjects.txt
# fi

# # =========================================================================================================
# #     Pre-smoothing ASL data for surface projection (FWHM=1.5, sigma=0.6370)
# # =========================================================================================================
# 
# if [ -s ${FILE_PATH}/subjects.txt ]
# then
# 	while read SUBJ_ID  
# 	do 
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface ]
# 		then
# 			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface
# 		else
# 			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/*
# 		fi
# 		
# 		if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm1.5_rasl_distcor.nii.gz ]
# 		then 
# 			${ANTSPATH}antsSmoothImage.R \
# 			--InI ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/rasl_distcor.nii.gz \
# 			--OutI ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm1.5_rasl_distcor.nii.gz \
# 			--dim 4 \
# 			--smoothf 0.6370  
# 		fi
# 	done < ${FILE_PATH}/subjects.txt
# fi	
# 
#     
# # ==================================================================================================
# #     Performs ASL processing based on ANTs tools
# # 	Preprocessing of T1 images using antsCorticalThickness.sh is assumed
# # 	The following steps are performed : 
# # 		1) Calculation of average pCASL image 
# # 		2) Skull stripping of average pCASL image 
# # 		3) Registration of average pCASL image to T1 image 
# # 		4) (Robust) calculation of mean CBF 
# # 		5) Warping tissue priors and labels to ASL space
# # 		6) Warping mean CBF image to T1 space
# # 		7) Calculation of mean CBF (Warped to T1) partial volume correction
# # 		8) Warping mean CBF image and PVC mean CBF image to template space for VBM analysis
# # ==================================================================================================
# 
# # JOBS=`qstat | grep -e CT_ -e DC_ | wc -l`
# # while [ ${JOBS} -ge 1 ]
# # do
# # echo "CT_ or DC_ job not finished"
# # sleep 600
# # JOBS=`qstat | grep -e CT_ -e DC_ | wc -l`
# # done
# 
# if [ -s ${FILE_PATH}/subjects.txt ]
# then
# 	while read SUBJ_ID  
# 	do 
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing ]
# 		then
# 			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing
# 		else
# 			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/*
# 		fi
# 		
# 		## Perform ASL processing		
# 		antsASLProcessing.sh \
# 		${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainExtractionBrain.nii.gz \
# 		${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainExtractionMask.nii.gz \
# 		${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/rasl_distcor.nii.gz \
# 		${TEMPLATE_DIR}/T_template_3DT1.nii \
# 		${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_ \
# 		${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASL \
# 		> ~/Logdir/ASLP_${SUBJ_ID}.txt
# 
# 		
# # 		# Perform ASL processing for volumic study		
# # 		qbatch -N ASLPV_${SUBJ_ID} -q fs_q -oe ~/Logdir 
# # 		antsASLProcessingVolume2.sh \
# # 		-a ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainExtractionBrain.nii.gz \
# # 		-p ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainSegmentationPosteriors%d.nii.gz \
# # 		-g ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainSegmentation.nii.gz \
# # 		-x ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainExtractionMask.nii.gz \
# # 		-s ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/rasl_distcor.nii.gz \
# # 		-e ${TEMPLATE_DIR}/T_template_3DT1.nii \
# # 		-l ${TEMPLATE_DIR}/../FS_5.3/template/mri/aparc.a2009s+aseg.nii.gz \
# # 		-t ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_ \
# # 		-k 1 \
# # 		-o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL \
# # 		> ~/Logdir/ASLV_${SUBJ_ID}.txt
# # 
# # 		## Perform ASL processing for surface study		
# # # 		qbatch -N ASLPS_${SUBJ_ID} -q fs_q -oe ~/Logdir 
# # 		antsASLProcessingSurface.sh \
# # 		-a ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainExtractionBrain.nii.gz \
# # 		-p ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainSegmentationPosteriors%d.nii.gz \
# # 		-g ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainSegmentation.nii.gz \
# # 		-x ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_BrainExtractionMask.nii.gz \
# # 		-s ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm1.5_rasl_distcor.nii.gz \
# # 		-e ${TEMPLATE_DIR}/T_template_3DT1.nii \
# # 		-l ${TEMPLATE_DIR}/../FS_5.3/template/mri/aparc.a2009s+aseg.nii.gz \
# # 		-t ${OUTPUT_DIR}/${SUBJ_ID}/BE_SEG_REGTemp/T1Proc_ \
# # 		-k 1 \
# # 		-o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/ASL \
# # 		> ~/Logdir/ASLS_${SUBJ_ID}.txt
# 	
# 	done < ${FILE_PATH}/subjects.txt
# fi

# ==================================================================================================
#       Project ASL_MeanCBFWToT1.nii.gz and ASL_PVC_MeanCBFWToT1.nii.gz on 
# 	  fsaverage surfaces : FWHM=[0,4,6,8,10,12,15]
# ==================================================================================================

if [ -s ${FILE_PATH}/subjects.txt ]
then
	while read SUBJ_ID  
	do 	
		qbatch -N ASLSP_${SUBJ_ID} -q fs_q -oe ~/Logdir antsASLSurfaceProject.sh ${FS_DIR} ${OUTPUT_DIR} ${SUBJ_ID}
		sleep 1
	done < ${FILE_PATH}/subjects.txt

# 	if [ ! -d ${OUTPUT_DIR}/SurfaceAnalysis_SurfStat ]
# 	then
# 		mkdir -p ${OUTPUT_DIR}/SurfaceAnalysis_SurfStat
# 	else
# 		rm -rf ${OUTPUT_DIR}/SurfaceAnalysis_SurfStat/*
# 	fi
fi

# # ============================================================================================================================================
# # 	Smooth volumic MeanCBFWToTemplate and PVC_MeanCBFWToTemplate (FWHM=[4,6,8,10,12,15] sigma=[1.6986,2.548,3.3973,4.2466,5.0959,6.3699])
# # ============================================================================================================================================
# 
# if [ -s ${FILE_PATH}/subjects.txt ]
# then
# 	while read SUBJ_ID  
# 	do 
# 		fhwm=([1]=4 [2]=6 [3]=8 [4]=10 [5]=12 [6]=15)
# 		i=2
# # 		for sigma in 1.6986 2.548 3.3973 4.246610 5.095915 6.3699
# 		for sigma in 2.548
# 		do
# 			rm -f ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_S${fhwm[i]}MeanCBFWToTemplate.nii ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_S${fhwm[i]}PVC_MeanCBFWToTemplate.nii
# 			
# 			${ANTSPATH}antsSmoothImage.R \
# 			--InI ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASLMeanCBFWarpedToTemplate.nii.gz \
# 			--OutI ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_S${fhwm[i]}MeanCBFWToTemplate.nii.gz \
# 			--dim 3 \
# 			--smoothf ${sigma} 
# 		  
# 			${ANTSPATH}antsSmoothImage.R \
# 			--InI ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_PVC_MeanCBFWToTemplate.nii.gz \
# 			--OutI ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_S${fhwm[i]}PVC_MeanCBFWToTemplate.nii.gz \
# 			--dim 3 \
# 			--smoothf ${sigma}
# 			
# 			gunzip ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_S${fhwm[i]}MeanCBFWToTemplate.nii.gz
# 			gunzip ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_S${fhwm[i]}PVC_MeanCBFWToTemplate.nii.gz
# 		    
# # 			i=$[$i+1]
# 		done
# 	done < ${FILE_PATH}/subjects.txt
# 
# 	if [ ! -d ${OUTPUT_DIR}/VolumeAnalysis_SPM12/ASL_S6_FullFactorial ]
# 	then
# 		mkdir -p ${OUTPUT_DIR}/VolumeAnalysis_SPM12/ASL_S6_FullFactorial
# 	else
# 		rm -rf ${OUTPUT_DIR}/VolumeAnalysis_SPM12/ASL_S6_FullFactorial/*
# 	fi	
# fi

# # =======================================================================
# #      Compute FDR Q-values threshold map and project it on fsaverage
# # =======================================================================
# 
# /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# 	% Load Matlab Path
# 	p = pathdef;
# 	addpath(p);
# 	
# 	VolumicAnalysis;
# EOF
# 	
# # Assign input values of arguments
# OUTPUT_DIR=/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/ASL_S6PVC_FullFactorial
# SUBJ_ID=template
# 
# # Assign new value of SUBJECTS_DIR
# SUBJECTS_DIR=${FS_DIR}
# 
# ## Use volumic inputs Qval_thresh.img
# echo "mri_convert ${OUTPUT_DIR}/Qval_thresh.img ${OUTPUT_DIR}/Qval_thresh.mgz"
# mri_convert ${OUTPUT_DIR}/Qval_thresh.img ${OUTPUT_DIR}/Qval_thresh.mgz
# 
# ## Map on surface Qval_thresh
# for var in Qval_thresh
# do
# 	mri_vol2surf --mov ${OUTPUT_DIR}/${var}.mgz --regheader ${SUBJ_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${OUTPUT_DIR}/lh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
# 	mri_vol2surf --mov ${OUTPUT_DIR}/${var}.mgz --regheader ${SUBJ_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${OUTPUT_DIR}/rh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
# done	