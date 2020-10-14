#!/bin/bash

DIR=$1
listFile=$2

declare -a ROIS=('dti_bulbe' 'dti_capsd' 'dti_capsg' 'dti_mesd' 'dti_mesg');

nroi=${#ROIS[@]}

for SUBJ in `cat ${listFile}`
do
	echo "${SUBJ}"

	if [ ! -d ${DIR}/${SUBJ}/dti/results_${SUBJ} ]
	then
		mkdir ${DIR}/${SUBJ}/dti/results_${SUBJ}
	fi
      
	for ((ind = 0; ind < ${nroi}; ind += 1))
	do
	    roi=${ROIS[${ind}]}
	    
	    if [ -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_FA.txt ]
	    then 
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_FA.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_L1.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_L2.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_L3.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_MD.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_MO.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_S0.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_V1.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_V2.txt
	    	rm -f ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_V3.txt
	    fi
	    
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_FA.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_FA.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_L1.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_L1.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_L2.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_L2.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_L3.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_L3.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_MD.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_MD.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_MO.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_MO.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_S0.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_S0.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_V1.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_V1.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_V2.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_V2.txt
	    3dmaskave -mask ${DIR}/${SUBJ}/mri/${roi}.nii -sigma ${DIR}/${SUBJ}/dti/data_corr_V3.nii.gz >> ${DIR}/${SUBJ}/dti/results_${SUBJ}/${roi}_V3.txt
	    
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_FA.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_FA.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_L1.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_L1.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_L2.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_L2.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_L3.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_L3.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_MD.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_MD.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_MO.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_MO.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_S0.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_S0.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_V1.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_V1.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_V2.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_V2.txt
	    #fslstats ${DIR}/${SUBJ}/dti/data_corr_V3.nii.gz -k ${DIR}/${SUBJ}/mri/${roi}.nii -M -S >> ${DIR}/${SUBJ}/dti/${roi}_V3.txt
	    
	done

done
