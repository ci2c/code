#!/bin/bash

SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
INPUT_PET_DIR=/NAS/tupac/protocoles/COMAJ/data/nifti_tep
FILE_PATH=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients
# # FILE_PATH=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/Zscores
# # FILE_PATH=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/DARTEL/Description_files
# FILE_PATH=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/FS/Description_files/TwoSample_35pat

# #### 1. Apply Harmonization_PET_surf.sh for each reconstruction of each subject ####
# 
# index=1
# if [ -s ${FILE_PATH}/subjects_EQ.PET_unique ] 
# then	
# 	while read SUBJECT_ID  
# 	do 	
# # 		for RECON in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# # 		for RECON in OT_i6s21_g4 OT_i6s21_g5 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g5 UHD_i8s21_g6
# 		for RECON in UHD_i8s21_g4.5
# 		do
# 			# Do cortical processing
# 			qbatch -q two_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N HPC_${SUBJECT_ID}_${RECON} Harmonization_PET_surf.sh -idPet ${INPUT_PET_DIR} -sd ${SUBJECTS_DIR} \
# 			-subjMri ${SUBJECT_ID} -recon ${RECON} -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg
# 			sleep 1
# # 			
# # 			# Smooth fsaverage data at 3 mm FWHM
# # 			qbatch -q two_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N HPC_sm3_${SUBJECT_ID}_${RECON} Harmonization_PET_surf.sh -idPet ${INPUT_PET_DIR} -sd ${SUBJECTS_DIR} \
# # 			-subjMri ${SUBJECT_ID} -recon ${RECON} -DoSBA -oldSeg
# # 			sleep 1
# # 
# # 			DIR=${SUBJECTS_DIR}/${SUBJECT_ID}
# # 			if [ ! -d ${DIR}/pet/pvelab_Seg12_l0 ]
# # 			then
# # 				echo "${DIR}/pet/pvelab_Seg12_l0 doesn't exist"
# # 			fi
# 			
# # 			# Do subcortical processing once cortical processing is finished
# # 			qbatch -q one_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N HPS_${SUBJECT_ID}_${RECON} Harmonization_PET_surf.sh -idPet ${INPUT_PET_DIR} -sd ${SUBJECTS_DIR} \
# # 			-subjMri ${SUBJECT_ID} -recon ${RECON} -DoPVC -DoIN
# # 			sleep 1
# 		done
# 		index=$[$index+1]
# 	done < ${FILE_PATH}/subjects_EQ.PET_unique
# fi

# #### 2. Compute differences between PET reconstructions ####
#  
# if [ -s ${FILE_PATH}/subjects_EQ.PET ] 
# then	
# 	while read SUBJECT_ID  
# 	do 
# 		DIR=${SUBJECTS_DIR}/${SUBJECT_ID}
# 		
# # 		if [ -d ${DIR}/pet_std/native ]
# # 		then
# # 		    rm -rf ${DIR}/pet_std/native/*
# # 		else
# # 		    mkdir ${DIR}/pet_std/native
# # 		fi
# # 		
# # 		if [ -d ${DIR}/pet_std/common ]
# # 		then
# # 		    rm -rf ${DIR}/pet_std/common/*
# # 		else
# # 		    mkdir ${DIR}/pet_std/common
# # 		fi
# 		
# 		## Compute subtractions between native voxel-wise, native surface and fsaverage surface PET reconstructions
# 		fwhmvol=2
# 		Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# # 		fslmaths ${DIR}/pet_std/OT_i2s21_g2/PET.lps.BS7.gn.nii.gz -mas ${DIR}/pet_std/OT_i2s21_g2/rbrainmask.npet.nii.gz -kernel gauss ${Sigma} \
# # 		-fmean ${DIR}/pet_std/OT_i2s21_g2/PET.lps.BS7.gn.sm${fwhmvol}
# # 		fslmaths ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.nii.gz -mas ${DIR}/pet_std/OT_i2s21_g2/rbrainmask.npet.nii.gz -kernel gauss ${Sigma} \
# # 		-fmean ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.sm${fwhmvol}
# # 		
# 		fwhmsurf=3
# # 		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet_std/OT_i2s21_g2/surf/lh.PET.lps.BS7.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
# # 		--o ${DIR}/pet_std/OT_i2s21_g2/surf/lh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
# # 		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet_std/OT_i2s21_g2/surf/rh.PET.lps.BS7.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
# # 		--o ${DIR}/pet_std/OT_i2s21_g2/surf/rh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
# # 		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
# # 		--o ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGR.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
# # 		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
# # 		--o ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGR.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
# 		
# # 		mv ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGR.gn.fsaverage.sm3.mgh ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm3.mgh
# # 		mv ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGR.gn.fsaverage.sm3.mgh ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm3.mgh
# 		
# # 		for RECON in OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # 		UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g4.5 UHD_i8s21_g5 UHD_i8s21_g6
# 		for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g4.5
# 		do
# 			# Do cortical processing
# 			qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N Diff_${SUBJECT_ID}_${RECON} Harmonization_PET_differences.sh ${DIR} ${RECON} ${Sigma} ${fwhmvol} ${fwhmsurf}
# 			sleep 1
# 
# # 			mv ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGR.gn.fsaverage.sm3.mgh ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm3.mgh
# # 			mv ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGR.gn.fsaverage.sm3.mgh ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm3.mgh
# 		done
# 	done < ${FILE_PATH}/subjects_EQ.PET
# fi

## 3. Compute root of the sum of square differences between PET reconstructions ####

# OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses
# if [ -s ${FILE_PATH}/subjects_EQ.PET ] 
# then	
# 	while read SUBJECT_ID  
# 	do 
# 		DIR=${SUBJECTS_DIR}/${SUBJECT_ID}
# # 		DIR=${SUBJECTS_DIR}/207163_M0_2015-11-16
# # 	
# # # 		if [ ! -d ${DIR}/pet_std/SSD ]
# # # 		then
# # # 			mkdir ${DIR}/pet_std/SSD
# # # 		elif [ -d ${DIR}/pet_std/SSD ]
# # # 		then
# # # 			rm -rf ${DIR}/pet_std/SSD/*
# # # 		fi
# # 		
# 
# # 		## Compute RMSE based on spatial resolution of PET reconstructions ##
# # 		
# # # 		# Estimate spatial smooth for each reconstructed PET data
# # # 		for RECON in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # # 		UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g4.5 UHD_i8s21_g5 UHD_i8s21_g6
# # # 		do
# # # 			3dFWHMx -automask -input ${DIR}/pet_std/${RECON}/PET.lps.nii.gz -2difMAD -out ${DIR}/pet_std/${RECON}/SpatialResolution.txt
# # # 		done
# # 		
# # 		# Write RMSE based on spatial resolution on output text file
# # 		for RECON in OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # 		UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g4.5 UHD_i8s21_g5 UHD_i8s21_g6
# # 		do
# # # 			qbatch -q three_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/Logdir -N SR_${SUBJECT_ID}_${RECON} SPM_RMSE_SpatialResolution.sh ${DIR} ${RECON} ${SUBJECT_ID}
# # # 			sleep 1
# # 
# # 			cat /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD/SpatialResolution/SR_${SUBJECT_ID}_${RECON}.txt >> /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD/SpatialResolution/SR_${RECON}.txt
# # 			echo $'\r' >> /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD/SpatialResolution/SR_${RECON}.txt
# # 		done
# 
# 		## Compute SSD between native surface & fsaverage surface PET reconstructions ##
# # 		for RECON in OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # 		UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g4.5 UHD_i8s21_g5 UHD_i8s21_g6
# 		for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g4.5
# 		do
# #  			# Do cortical processing
# # 			qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N Sqd_${SUBJECT_ID}_${RECON} Harmonization_PET_sqd.sh ${DIR} ${RECON} ${SUBJECT_ID} 10
# # 			sleep 1
# 
# # 			for hemi in lh rh
# # 			do
# # # 				rm -f ${OUTDIR}/SSD/${hemi}.PET.${RECON}.gn.ssd.txt ${OUTDIR}/SSD/${hemi}.PET.${RECON}.MGRousset.gn.ssd.txt \
# # # 				${OUTDIR}/SSD/${hemi}.PET.${RECON}.gn.fsaverage.ssd.txt ${OUTDIR}/SSD/${hemi}.PET.${RECON}.MGRousset.gn.fsaverage.ssd.txt
# # 			
# # 				# Vertex-wise
# # 				cat ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.gn.ssd.${SUBJECT_ID}.txt >> ${OUTDIR}/SSD/${hemi}.PET.${RECON}.gn.ssd.txt
# # 				cat ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.MGRousset.gn.ssd.${SUBJECT_ID}.txt >> ${OUTDIR}/SSD/${hemi}.PET.${RECON}.MGRousset.gn.ssd.txt
# # 				
# # 				cat ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.gn.fsaverage.ssd.${SUBJECT_ID}.txt >> ${OUTDIR}/SSD/${hemi}.PET.${RECON}.gn.fsaverage.ssd.txt
# # 				cat ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.MGRousset.gn.fsaverage.ssd.${SUBJECT_ID}.txt >> ${OUTDIR}/SSD/${hemi}.PET.${RECON}.MGRousset.gn.fsaverage.ssd.txt
# # 			done
# 			
# 			fwhmsurf=10
# 			for hemi in lh rh
# 			do
# # # 				echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.sqd.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.sqd.txt
# # # 				echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.sqd.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.sqd.txt
# # 				
# # 				echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sqd.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sqd.txt
# # 				echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sqd.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sqd.txt
# 
# 				echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sm${fwhmsurf}.sqd.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sm${fwhmsurf}.sqd.txt
# 				echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sm${fwhmsurf}.sqd.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sm${fwhmsurf}.sqd.txt
# 			done
# 		done
# 		
# # # 		## Extract mean PET ROIs from native and fsaverage surface PET reconstructions ##
# # # # 		for RECON in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # # # 		UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g5 UHD_i8s21_g6
# # # 		for RECON in UHD_i8s21_g4.5
# # # 		do
# # # #  			# Do cortical processing
# # # # 			qbatch -q one_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N Sqd_${SUBJECT_ID}_${RECON}_ROI Harmonization_PET_sqd_ROI.sh ${DIR} ${RECON} ${SUBJECT_ID}
# # # # 			sleep 1
# # # 			
# # # 			OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses
# # # 			parcel=Destrieux
# # # 			for hemi in lh rh
# # # 			do
# # # # 				rm -f ${OUTDIR}/SSD/${hemi}.EQ.PET.noPVC.gn.${RECON}.${parcel}.txt ${OUTDIR}/SSD/${hemi}.EQ.PET.PVC.gn.${RECON}.${parcel}.txt \
# # # # 				${OUTDIR}/SSD/${hemi}.EQ.PET.noPVC.gn.fsaverage.${RECON}.${parcel}.txt ${OUTDIR}/SSD/${hemi}.EQ.PET.PVC.gn.fsaverage.${RECON}.${parcel}.txt
# # # 			
# # # 				# Destrieux ROI parcellation
# # # 				echo "${OUTDIR}/SSD/${parcel}/${hemi}.pet.noPVC.gn.${SUBJECT_ID}.${RECON}.sum" >> ${OUTDIR}/SSD/${hemi}.EQ.PET.noPVC.gn.${RECON}.${parcel}.txt
# # # 				echo "${OUTDIR}/SSD/${parcel}/${hemi}.pet.PVC.gn.${SUBJECT_ID}.${RECON}.sum" >> ${OUTDIR}/SSD/${hemi}.EQ.PET.PVC.gn.${RECON}.${parcel}.txt
# # # 				
# # # 				echo "${OUTDIR}/SSD/${parcel}/${hemi}.pet.noPVC.gn.${SUBJECT_ID}.fsaverage.${RECON}.sum" >> ${OUTDIR}/SSD/${hemi}.EQ.PET.noPVC.gn.fsaverage.${RECON}.${parcel}.txt
# # # 				echo "${OUTDIR}/SSD/${parcel}/${hemi}.pet.PVC.gn.${SUBJECT_ID}.fsaverage.${RECON}.sum" >> ${OUTDIR}/SSD/${hemi}.EQ.PET.PVC.gn.fsaverage.${RECON}.${parcel}.txt
# # # 			done
# # # 		done
# 	done < ${FILE_PATH}/subjects_EQ.PET
# fi

## Concatenate sqd surfaces of all subjects from native & fsaverage reconstructions, compute mean then sqrt ##
# for RECON in OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g4.5 UHD_i8s21_g5 UHD_i8s21_g6
# do
# 	for hemi in lh rh
# 	do
# 		mri_concat --f ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sqd.txt --mean --o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sqd.mean.mgh
# 		mris_calc -o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.rmse.mgh ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sqd.mean.mgh sqrt
# 		
# 		mri_concat --f ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sqd.txt --mean --o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sqd.mean.mgh
# 		mris_calc -o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.rmse.mgh ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sqd.mean.mgh sqrt
# 	done
# done

# fwhmsurf=10
# for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g4.5
# do
# 	for hemi in lh rh
# 	do
# 		mri_concat --f ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sm${fwhmsurf}.sqd.txt --mean --o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sm${fwhmsurf}.sqd.mean.mgh
# 		mris_calc -o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sm${fwhmsurf}.rmse.mgh ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.sm${fwhmsurf}.sqd.mean.mgh sqrt
# 		
# 		mri_concat --f ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sm${fwhmsurf}.sqd.txt --mean --o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sm${fwhmsurf}.sqd.mean.mgh
# 		mris_calc -o ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sm${fwhmsurf}.rmse.mgh ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.sm${fwhmsurf}.sqd.mean.mgh sqrt
# 	done
# done

# OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD
# FS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
# for results in TYPvsLANGvsVISUvsEXE_A0_fwhm10_MGR_gn_i10000_TFCE_CT_Cov
# do
# 	for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g4.5
# 	do 
# 		## T_tests
# 		Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${OUTDIR}/lh.concat35.PET.${RECON}.MGRousset.gn.fsaverage.rmse.mgh  \
# 		-rhoverlay ${OUTDIR}/rh.concat35.PET.${RECON}.MGRousset.gn.fsaverage.rmse.mgh  -fminmax 0.2 0.7 -fmid 0.45  -output ${OUTDIR}/${RECON}_RMSE.tiff -template -axial
# 		
# 		## Scales
#  		# T_tests
# # 		Make_montage_scales.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_tstat_fwep.mgz  \
# # 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_tstat_fwep.mgz  -fminmaxl 1 1.19 -fmidl 1.09  -fminmaxr 0.7 1.11 -fmidr 0.905 -output ${PALM_dir}/${results}/${group}_scaled.tiff -template -axial
# 
# 		# T_tests with with cs90
# # 		Make_montage_scales.sh  -fs  ${SUBJECTS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/lh.${group}_tfce_tstat_fwep.cs90.mgh \
# # 		-rhoverlay ${PALM_dir}/${results}/rh.${group}_tfce_tstat_fwep.cs90.mgh -fminmaxl 1 1.73 -fmidl 1.36 -fminmaxr 1 1.33 -fmidr 1.17 -output ${PALM_dir}/${results}/${group}_scaled_cs90.tiff -template -axial
# 	done
# done

# ## Concatenate mean PET ROIs for all subjects from native & fsaverage surface PET reconstructions ##
# WD=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD
# parcel=Destrieux
# # for RECON in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g5 UHD_i8s21_g6
# for RECON in UHD_i8s21_g4.5
# do
# 	for hemi in lh rh
# 	do
# 		for PVC in noPVC PVC
# 		do
# 			python2.7 ${FREESURFER_HOME}/bin/asegstats2table \
# 			--inputs $(cat ${WD}/${hemi}.EQ.PET.${PVC}.gn.${RECON}.${parcel}.txt) \
# 			--meas mean \
# 			--tablefile ${WD}/${parcel}/${hemi}.aparc.${parcel}.${PVC}.gn.meanPet.${RECON}.table
# 			sleep 1
# 			
# 			python2.7 ${FREESURFER_HOME}/bin/asegstats2table \
# 			--inputs $(cat ${WD}/${hemi}.EQ.PET.${PVC}.gn.fsaverage.${RECON}.${parcel}.txt) \
# 			--meas mean \
# 			--tablefile ${WD}/${parcel}/${hemi}.aparc.${parcel}.${PVC}.gn.fsaverage.meanPet.${RECON}.table
# 			sleep 1
# 		done
# 	done
# done

#### 4. Compute paired t-tests between PET reconstructions: PALM analysis ####

# OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses
# fwhmsurf=10
# while read SUBJECT_ID  
# do 
# 	## Compute RMSE based on SQD maps
# 	DIR=${SUBJECTS_DIR}/${SUBJECT_ID}
# # 	for RECON in OT_i6s21_g2 OT_i6s21_g2.4_EQ.PET OT_i6s21_g2.9_Res OT_i6s21_g3.1_EQ.PET_EARL OT_i6s21_g3.3 OT_i6s21_g3.5 OT_i6s21_g4 OT_i6s21_g5 \
# # 	UHD_i8s21_g2 UHD_i8s21_g2.5 UHD_i8s21_g3 UHD_i8s21_g3.3_EQ.PET_EARL UHD_i8s21_g3.5 UHD_i8s21_g4 UHD_i8s21_g4.5 UHD_i8s21_g5 UHD_i8s21_g6
# # 	do
# # 		for hemi in lh rh
# # 		do
# # # 			mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.rmse.mgh ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sqd.mgh sqrt
# # # 			mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.rmse.mgh ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sqd.mgh sqrt
# # 			
# # 			qbatch -q fs_q -oe ${FILE_PATH}/RMSE/Logdir -N ${hemi}_${SUBJECT_ID}_${RECON}_fwhm${fwhmsurf} mris_fwhm --s fsaverage --hemi ${hemi} --smooth-only \
# # 			--i ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.rmse.mgh --fwhm ${fwhmsurf} \
# # 			--o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.rmse.sm${fwhmsurf}.mgh --cortex
# # 			qbatch -q fs_q -oe ${FILE_PATH}/RMSE/Logdir -N ${hemi}_${SUBJECT_ID}_${RECON}_MGRousset_fwhm${fwhmsurf} mris_fwhm --s fsaverage --hemi ${hemi} --smooth-only \
# # 			--i ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.rmse.mgh --fwhm ${fwhmsurf} \
# # 			--o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.mgh --cortex
# # 			sleep 1
# # 		done
# # 	done
# 	
# 	## Compute files including list of RMSE maps for PALM paired t-tests analyses
# 	for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g4.5
# 	do
# 		for hemi in lh rh
# 		do
# 			echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.rmse.sm${fwhmsurf}.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.gn.fsaverage.rmse.sm${fwhmsurf}.txt
# 			echo -e "${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.mgh" >> ${OUTDIR}/SSD/${hemi}.concat35.PET.${RECON}.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.txt
# 		done
# 	done
# done < ${FILE_PATH}/subjects_EQ.PET

# ## Concatenate files of RMSE maps for PALM paired t-tests analyses
# for hemi in lh rh
# do
# # 	cat ${OUTDIR}/SSD/${hemi}.concat35.PET.OT_i6s21_g2.gn.fsaverage.rmse.sm${fwhmsurf}.txt ${OUTDIR}/SSD/${hemi}.concat35.PET.OT_i6s21_g3.1_EQ.PET_EARL.gn.fsaverage.rmse.sm${fwhmsurf}.txt \
# # 	> ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.gn.fsaverage.sm${fwhmsurf}.OT.txt
# # 	cat ${OUTDIR}/SSD/${hemi}.concat35.PET.OT_i6s21_g2.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.txt ${OUTDIR}/SSD/${hemi}.concat35.PET.OT_i6s21_g3.1_EQ.PET_EARL.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.txt \
# # 	> ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.MGRousset.gn.fsaverage.sm${fwhmsurf}.OT.txt
# # 	
# # 	cat ${OUTDIR}/SSD/${hemi}.concat35.PET.UHD_i8s21_g2.gn.fsaverage.rmse.sm${fwhmsurf}.txt ${OUTDIR}/SSD/${hemi}.concat35.PET.UHD_i8s21_g4.5.gn.fsaverage.rmse.sm${fwhmsurf}.txt \
# # 	> ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.gn.fsaverage.sm${fwhmsurf}.UHD.txt
# # 	cat ${OUTDIR}/SSD/${hemi}.concat35.PET.UHD_i8s21_g2.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.txt ${OUTDIR}/SSD/${hemi}.concat35.PET.UHD_i8s21_g4.5.MGRousset.gn.fsaverage.rmse.sm${fwhmsurf}.txt \
# # 	> ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.MGRousset.gn.fsaverage.sm${fwhmsurf}.UHD.txt
# 	
# 	mri_concat --f ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.gn.fsaverage.sm${fwhmsurf}.OT.txt --o ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.noPVC.gn.fsaverage.sm${fwhmsurf}.RMSE_OT.mgh
# 	mri_concat --f ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.MGRousset.gn.fsaverage.sm${fwhmsurf}.OT.txt --o ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.PVC.gn.fsaverage.sm${fwhmsurf}.RMSE_OT.mgh
# 	
# 	mri_concat --f ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.gn.fsaverage.sm${fwhmsurf}.UHD.txt --o ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.noPVC.gn.fsaverage.sm${fwhmsurf}.RMSE_UHD.mgh
# 	mri_concat --f ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.MGRousset.gn.fsaverage.sm${fwhmsurf}.UHD.txt --o ${FILE_PATH}/RMSE/${hemi}.all.subjects.PET.PVC.gn.fsaverage.sm${fwhmsurf}.RMSE_UHD.mgh
# done

# WD=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Paired_ttest_zscores
# WD=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Paired_ttest/TARGETvsSOURCE_35patients
WD=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Paired_ttest/RMSE_35patients
# # DescriptionDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_36patients
# # DescriptionDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/Zscores
# # DescriptionDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients
# DescriptionDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients/RMSE
# Design=Design_palm_Paired_t_tests.csv
# EB=Grp_palm_EB.csv
# # 
# # ## Comparisons between TARGET (i2) and SOURCE reconstructions ##
# # for group in I2vsI6 I2vsI8 I2vsI6g3.1 I2vsI8g4.5
# # do
# # 	for fwhm in 3 10 15
# # 	do
# # # 		for PVC in noPVC PVC
# # 		for PVC in PVC
# # 		do
# # 			
# # 			CD=${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# # # # 			CD=${group}_fwhm${fwhm}_i500_approx_tail_nouncorrected_${PVC}_TFCE
# # # 			if [ ! -d ${WD}/${CD} ]
# # # 			then
# # # 				mkdir ${WD}/${CD}
# # # # 				cp -t ${WD}/${CD} ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Contrasts_palm_SOURCEvsTARGET.csv ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Contrasts_palm_TARGETvsSOURCE.csv \
# # # # 				${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Design_palm_Paired_t_tests.csv ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Grp_palm_EB.csv
# # # 				
# # # 			elif [ -d ${WD}/${CD} ]
# # # 			then
# # # 				rm -rf ${WD}/${CD}/*
# # # # 				cp -t ${WD}/${CD} ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Contrasts_palm_SOURCEvsTARGET.csv ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Contrasts_palm_TARGETvsSOURCE.csv \
# # # # 				${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Design_palm_Paired_t_tests.csv ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Grp_palm_EB.csv
# # # 			fi
# # 			for con in TARGETvsSOURCE SOURCEvsTARGET
# # 			do 
# # # 				## PET TFCE -n 500 -approx tail -nouncorrected ##
# # # 				qbatch -q M32_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_z_lh palm \
# # # 				-i ${DescriptionDir}/lh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.zscore.${group}.mgh \
# # # 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # # 				/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 500 -approx tail -nouncorrected \
# # # 				-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # # 				-d ${WD}/${CD}/${Design} \
# # # 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# # # 				-eb ${WD}/${CD}/${EB} \
# # # 				-logp -o ${WD}/${CD}/palm.${con}.lh
# # # 				sleep 1
# # # 
# # # 				qbatch -q M32_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_z_rh palm \
# # # 				-i ${DescriptionDir}/rh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.zscore.${group}.mgh \
# # # 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # # 				/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 500 -approx tail -nouncorrected \
# # # 				-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # # 				-d ${WD}/${CD}/${Design} \
# # # 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# # # 				-eb ${WD}/${CD}/${EB} \
# # # 				-logp -o ${WD}/${CD}/palm.${con}.rh
# # # 				sleep 1
# # 				
# # 				## PET TFCE -n 10000 ##
# # 				qbatch -q three_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_i10000_lh palm \
# # 				-i ${DescriptionDir}/lh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# # 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 				/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 				-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 				-d ${WD}/${CD}/${Design} \
# # 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# # 				-eb ${WD}/${CD}/${EB} \
# # 				-logp -o ${WD}/${CD}/palm.${con}.lh
# # 				sleep 1
# # 
# # 				qbatch -q three_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_i10000_rh palm \
# # 				-i ${DescriptionDir}/rh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# # 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 				/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 				-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 				-d ${WD}/${CD}/${Design} \
# # 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# # 				-eb ${WD}/${CD}/${EB} \
# # 				-logp -o ${WD}/${CD}/palm.${con}.rh
# # 				sleep 1
# # 			done
# # 		done
# # 	done
# # done
# 
# ## Comparisons between RMSE maps before/after optimal smoothing ##
# for group in RMSE_OT RMSE_UHD
# do
# 	for fwhm in 10
# 	do
# 		for PVC in noPVC PVC
# 		do
# 			
# 			CD=${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# # 			if [ ! -d ${WD}/${CD} ]
# # 			then
# # 				mkdir ${WD}/${CD}
# # # 				cp -t ${WD}/${CD} ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Contrasts_palm_SOURCEvsTARGET.csv ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Contrasts_palm_TARGETvsSOURCE.csv \
# # # 				${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Design_palm_Paired_t_tests.csv ${WD}/I2vsI6_fwhm3_i10000_noPVC_TFCE/Grp_palm_EB.csv
# # 			fi
# 			for con in TARGETvsSOURCE SOURCEvsTARGET
# 			do 
# 				## PET TFCE -n 10000 ##
# 				qbatch -q three_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_i10000_lh palm \
# 				-i ${DescriptionDir}/lh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 				/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# 				-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 				-d ${WD}/${CD}/${Design} \
# 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# 				-eb ${WD}/${CD}/${EB} \
# 				-logp -o ${WD}/${CD}/palm.${con}.lh
# 				sleep 1
# 
# 				qbatch -q three_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_i10000_rh palm \
# 				-i ${DescriptionDir}/rh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 				/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# 				-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# 				-d ${WD}/${CD}/${Design} \
# 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# 				-eb ${WD}/${CD}/${EB} \
# 				-logp -o ${WD}/${CD}/palm.${con}.rh
# 				sleep 1
# 			done
# 		done
# 	done
# done

# # for group in I2vsI6 I2vsI8 I2vsI6g3.1 I2vsI8g4.5
# for group in RMSE_OT RMSE_UHD
# do
# # 	for fwhm in 3 10 15
# 	for fwhm in 10
# 	do
# 		for PVC in noPVC PVC
# # 		for PVC in PVC
# 		do
# # 			cd ${WD}/${group}_fwhm${fwhm}_i500_approx_tail_nouncorrected_${PVC}_TFCE
# 			cd ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# 			for i in palm.*.?h_tfce_tstat_fwep.mgz ; do
# # 			# for i in palm.F.?h_tfce_fstat_fwep.mgz ; do
# # 			# for i in palm.*.?h_tfce_rstat_fwep.mgz ; do
# 				base=${i%.mgz}
# 				mri_convert $i ${base}.nii.gz
# 				echo ${base}.nii.gz `fslstats ${base}.nii.gz -R` >> InfosStats
# 			done
# # 			rm -f ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE/InfosStats
# 		done
# 	done
# done

OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/Snapshots
FS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
for group in RMSE_OT RMSE_UHD
# for group in I2vsI6 I2vsI6g3.1 I2vsI8 I2vsI8g4.5
# for group in I2vsI8g4.5
do
	for fwhm in 10
	do
		for PVC in PVC
# 		for PVC in noPVC PVC
		do
# 			## T_tests
# 			Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white -lhoverlay ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE/palm.TARGETvsSOURCE.lh_tfce_tstat_fwep.mgz  \
# 			-rhoverlay ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE/palm.TARGETvsSOURCE.rh_tfce_tstat_fwep.mgz  -fminmax 1.3 4 -fmid 2.65  \
# 			-output ${OUTDIR}/${group}_fwhm${fwhm}_${PVC}_ptt.tiff -template -axial
			
			## Scales
			# T_tests
			Make_montage_scales.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white -lhoverlay ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE/palm.TARGETvsSOURCE.lh_tfce_tstat_fwep.mgz  \
			-rhoverlay ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE/palm.TARGETvsSOURCE.rh_tfce_tstat_fwep.mgz  -fminmaxl 1.3 4 -fmidl 2.65  -fminmaxr 1.3 4 -fmidr 2.65 -output ${OUTDIR}/${group}_fwhm${fwhm}_${PVC}_ptt_rev.tiff -template -axial

			# T_tests with with cs90
	# 		Make_montage_scales.sh  -fs  ${SUBJECTS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/lh.${group}_tfce_tstat_fwep.cs90.mgh \
	# 		-rhoverlay ${PALM_dir}/${results}/rh.${group}_tfce_tstat_fwep.cs90.mgh -fminmaxl 1 1.73 -fmidl 1.36 -fminmaxr 1 1.33 -fmidr 1.17 -output ${PALM_dir}/${results}/${group}_scaled_cs90.tiff -template -axial
		done
	done
done

# #### 5. Compute paired t-tests between PET reconstructions: SPM analysis ####
# 
# InputDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/DARTEL
# if [ -s ${FILE_PATH}/subjects_EQ.PET ]
# then
# 	for PVC in noPVC PVC
# 	do
# 		for Recon in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# 		do
# 			for fwhmvol in 6 10 12 15
# 			do
# # 				if [ ! -d ${InputDir}/SPM/${Recon}_fwhm${fwhmvol}_${PVC} ]
# # 				then
# # 					mkdir ${InputDir}/SPM/${Recon}_fwhm${fwhmvol}_${PVC}
# # 				elif [ -d ${WD}/${CD} ]
# # 				then
# # 					rm -rf ${InputDir}/SPM/${Recon}_fwhm${fwhmvol}_${PVC}/*
# # 				fi
# 				qbatch -q one_job_q -oe ${InputDir}/Logdir -N pTT_${fwhmvol}_${PVC}_${Recon}_spm12 Paired_ttest_SPM12.sh ${InputDir} ${FILE_PATH}/subjects_EQ.PET ${PVC} ${Recon} ${fwhmvol}
# 				sleep 1
# 			done
# 		done
# 	done
# fi

# #### 6. Compute paired t-tests between PET reconstructions: Freesurfer analysis ####
# 
# # Sample each individual's surface onto the average surface.
# # Compute the difference between each of the pairs in the average surface space.
# # Concatenate the differences into one file.
# # Smooth on the surface (optional)
# # Perform analysis with mri_glmfit on this file
# 
# # if [ -s ${FILE_PATH}/subjects_EQ.PET ] 
# # then
# # 	for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# # 	do
# # 		for hemi in lh rh
# # 		do
# # 			for fwhmsurf in 3 6 10 12 15
# # 			do
# # 				for PVC in noPVC PVC
# # 				do
# # 					qbatch -q three_job_q -oe ${FILE_PATH}/../Logdir -N fwhmsurf_${fwhmsurf}_${PVC}_${RECON}_${hemi}  mri_surf2surf --s fsaverage --hemi ${hemi} --fwhm ${fwhmsurf} \
# # 					--sval ${FILE_PATH}/${hemi}.all.subjects.PET.${PVC}.gn.fsaverage.${RECON}-OT_i2s21_g2.mgh \
# # 					--tval ${FILE_PATH}/${hemi}.all.subjects.fwhm${fwhmsurf}.PET.${PVC}.gn.fsaverage.${RECON}-OT_i2s21_g2.mgh
# # 					sleep 1
# # 				done
# # 			done
# # 		done
# # 	done
# # fi
# 
# WD=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/FS/TwoSample
# # for RECON in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# for RECON in I2vsI6 I2vsI6g3.1 I2vsI8 I2vsI8g4.5
# do
# # 	for fwhmsurf in 3 6 10 12 15
# 	for fwhmsurf in 10
# 	do
# # 		for PVC in noPVC PVC
# 		for PVC in PVC
# 		do
# 			if [ ! -d ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC} ]
# 			then
# 				mkdir ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}
# 			elif [ -d ${WD}/${CD} ]
# 			then
# 				rm -rf ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/*
# 			fi
# 			
# 			for hemi in lh rh
# 			do
# 				qbatch -q two_job_q -oe ${FILE_PATH}/Logdir -N TSTT_${fwhmsurf}_${PVC}_${RECON}_${hemi} FSGD_Harmonization_PET.sh \
# 				${WD} ${RECON} ${fwhmsurf} ${PVC} ${hemi} ${FILE_PATH}
# 				sleep 1
# 			done
# 		done
# 	done
# done

# #### 7. Compute two-sample t-tests between PET reconstructions: PALM analysis ####

# WD=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM
# DescriptionDir=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients
# Design=Design_palm_TARGETvsSOURCE.csv
# 
# for group in I2vsI6 I2vsI8 I2vsI6g3.1 I2vsI8g4.5
# do
# 	for fwhm in 10
# 	do
# # 		for PVC in noPVC PVC
# 		for PVC in PVC
# 		do
# # # 			CD=${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# 			CD=Two_sample_ttest/35patients/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# # 			CD=Two_sample_ttest/${group}_fwhm${fwhm}_i500_approx_tail_nouncorrected_${PVC}_TFCE
# # 			if [ ! -d ${WD}/${CD} ]
# # 			then
# # 				mkdir -p ${WD}/${CD}
# # 				cp -t ${WD}/${CD} ${WD}/Two_sample_ttest/35patients/Contrasts_palm_SOURCEvsTARGET.csv ${WD}/Two_sample_ttest/35patients/Contrasts_palm_TARGETvsSOURCE.csv \
# # 				${WD}/Two_sample_ttest/35patients/Design_palm_TARGETvsSOURCE.csv
# # 				
# # 			elif [ -d ${WD}/${CD} ]
# # 			then
# # 				rm -rf ${WD}/${CD}/*
# # 				cp -t ${WD}/${CD} ${WD}/Two_sample_ttest/35patients/Contrasts_palm_SOURCEvsTARGET.csv ${WD}/Two_sample_ttest/35patients/Contrasts_palm_TARGETvsSOURCE.csv \
# # 				${WD}/Two_sample_ttest/35patients/Design_palm_TARGETvsSOURCE.csv
# # 			fi
# 			for con in TARGETvsSOURCE SOURCEvsTARGET
# 			do 
# # 				## PET TFCE -n 500 -approx tail -nouncorrected ##
# # 				qbatch -q two_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tsttest_${group}_${con}_${fwhm}_${PVC}_lh palm \
# # 				-i ${DescriptionDir}/lh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# # 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 				/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 500 -approx tail -nouncorrected \
# # 				-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 				-d ${WD}/${CD}/${Design} \
# # 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# # 				-logp -o ${WD}/${CD}/palm.${con}.lh
# # 				sleep 1
# # 
# # 				qbatch -q two_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N palm_tsttest_${group}_${con}_${fwhm}_${PVC}_rh palm \
# # 				-i ${DescriptionDir}/rh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# # 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 				/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 500 -approx tail -nouncorrected \
# # 				-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 				-d ${WD}/${CD}/${Design} \
# # 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# # 				-logp -o ${WD}/${CD}/palm.${con}.rh
# # 				sleep 1
# 				
# 				## PET TFCE -n 10000 ##
# 				qbatch -q three_job_q -oe ${WD}/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_i10000_lh palm \
# 				-i ${DescriptionDir}/lh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 				/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# 				-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 				-d ${WD}/${CD}/${Design} \
# 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# 				-logp -o ${WD}/${CD}/palm.${con}.lh
# 				sleep 1
# 
# 				qbatch -q three_job_q -oe ${WD}/Logdir -N palm_tfce_${group}_${con}_${fwhm}_${PVC}_i10000_rh palm \
# 				-i ${DescriptionDir}/rh.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhm}.${group}.mgh \
# 				-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 				/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# 				-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# 				-d ${WD}/${CD}/${Design} \
# 				-t ${WD}/${CD}/Contrasts_palm_${con}.csv \
# 				-logp -o ${WD}/${CD}/palm.${con}.rh
# 				sleep 1
# 			done
# 		done
# 	done
# done
# 
# for group in I2vsI6 I2vsI8 I2vsI6g3.1 I2vsI8g4.5
# do
# # 	for fwhm in 3 6 10
# 	for fwhm in 10
# 	do
# # 		for PVC in noPVC PVC
# 		for PVC in PVC
# 		do
# # 			cd ${WD}/Two_sample_ttest/${group}_fwhm${fwhm}_i500_approx_tail_nouncorrected_${PVC}_TFCE
# # 			cd ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# 			cd ${WD}/Two_sample_ttest/35patients/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE
# 			for i in palm.*.?h_tfce_tstat_fwep.mgz ; do
# # 			# for i in palm.F.?h_tfce_fstat_fwep.mgz ; do
# # 			# for i in palm.*.?h_tfce_rstat_fwep.mgz ; do
# 				base=${i%.mgz}
# 				mri_convert $i ${base}.nii.gz
# 				echo ${base}.nii.gz `fslstats ${base}.nii.gz -R` >> InfosStats
# 			done
# # 			rm -f ${WD}/${group}_fwhm${fwhm}_i10000_${PVC}_TFCE/InfosStats
# 		done
# 	done
# done

#### 8. Compute z-scores of each PET reconstructions and make paired t-test: PALM analysis ####

## 8.1 Zscores based on mean/std of each PET reconstructions paired-group ##

# ## Generate mean/std of each PET reconstructions paired-group
# ref=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_36patients
# for Recon in I2vsI6 I2vsI6g3.1 I2vsI8 I2vsI8g3.3
# do
# 	for fwhmsurf in 10
# 	do
# 		for PVC in noPVC PVC
# 		do
# 			for hemi in lh rh
# 			do
# 				mri_concat --i ${ref}/${hemi}.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhmsurf}.${Recon}.mgh \
# 				--o ${FILE_PATH}/${hemi}.PET.${Recon}.mean.${PVC}.gn.fsaverage.mgh --mean
# 				mri_concat --i ${ref}/${hemi}.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhmsurf}.${Recon}.mgh \
# 				--o ${FILE_PATH}/${hemi}.PET.${Recon}.std.${PVC}.gn.fsaverage.mgh --std
# 			done
# 		done
# 	done
# done

# ## Derive individual Z-score map for each PET reconstruction
# table=("I2vsI6" "I2vsI6g3.1" "I2vsI8" "I2vsI8g3.3")
# if [ -s ${FILE_PATH}/subjects_EQ.PET ] 
# then	
# 	while read SUBJECT_ID  
# 	do 
# 		DIR=${SUBJECTS_DIR}/${SUBJECT_ID}
# 		index=0
# 		for Recon in OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# 		do
# # 			rm -rf ${DIR}/pet_std/${Recon}/surf/tmpdir.fscalc.*
# 			for hemi in lh rh
# 			do
# 				for fwhmsurf in 10
# 				do
# 					for PVC in noPVC PVC
# 					do
# 						if [ “${PVC}” == “noPVC” ]
# 						then
# 							# OT_i2s21_g2
# 							mris_calc -o ${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.demean.mgh \
# 							${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh sub ${FILE_PATH}/${hemi}.PET.${table[index]}.mean.${PVC}.gn.fsaverage.mgh
# 							mris_calc -o ${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.zscore.${table[index]}.mgh \
# 							${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.demean.mgh div ${FILE_PATH}/${hemi}.PET.${table[index]}.std.${PVC}.gn.fsaverage.mgh
# 							rm -f ${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.demean.mgh
# 							
# 							# ${Recon}
# 							mris_calc -o ${DIR}/pet_std/${Recon}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.demean.mgh \
# 							${DIR}/pet_std/${Recon}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh sub ${FILE_PATH}/${hemi}.PET.${table[index]}.mean.${PVC}.gn.fsaverage.mgh
# 							mris_calc -o ${DIR}/pet_std/${Recon}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.zscore.mgh \
# 							${DIR}/pet_std/${Recon}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.demean.mgh div ${FILE_PATH}/${hemi}.PET.${table[index]}.std.${PVC}.gn.fsaverage.mgh
# 							rm -f ${DIR}/pet_std/${Recon}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.demean.mgh
# # 							rm -f ${DIR}/pet_std/${Recon}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.zscore.mgh
# 						elif [ “${PVC}” == “PVC” ]
# 						then
# 							# OT_i2s21_g2
# 							mris_calc -o ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.demean.mgh \
# 							${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh sub ${FILE_PATH}/${hemi}.PET.${table[index]}.mean.${PVC}.gn.fsaverage.mgh
# 							mris_calc -o ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.zscore.${table[index]}.mgh \
# 							${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.demean.mgh div ${FILE_PATH}/${hemi}.PET.${table[index]}.std.${PVC}.gn.fsaverage.mgh
# 							rm -f ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.demean.mgh
# 							
# 							# ${Recon}
# 							mris_calc -o ${DIR}/pet_std/${Recon}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.demean.mgh \
# 							${DIR}/pet_std/${Recon}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh sub ${FILE_PATH}/${hemi}.PET.${table[index]}.mean.${PVC}.gn.fsaverage.mgh
# 							mris_calc -o ${DIR}/pet_std/${Recon}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.zscore.mgh \
# 							${DIR}/pet_std/${Recon}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.demean.mgh div ${FILE_PATH}/${hemi}.PET.${table[index]}.std.${PVC}.gn.fsaverage.mgh
# 							rm -f ${DIR}/pet_std/${Recon}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.demean.mgh
# # 							rm -f ${DIR}/pet_std/${Recon}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.zscore.mgh
# 						fi
# 					done
# 				done
# 			done
# 			index=$[$index+1]
# 		done
# 	done < ${FILE_PATH}/subjects_EQ.PET
# fi

## Do PALM analysis on zscore files (§4.)

# ## 8.2 Zscores based on mean/std of each hemisphere ##
# 
# ## Compute z-maps
# if [ -s ${FILE_PATH}/subjects_EQ.PET ] 
# then	
# 	while read SUBJECT_ID  
# 	do 
# 		for Recon in OT_i2s21_g2 OT_i6s21_g2 OT_i6s21_g3.1_EQ.PET_EARL UHD_i8s21_g2 UHD_i8s21_g3.3_EQ.PET_EARL
# # 		for Recon in OT_i2s21_g2
# 		do
# 			for fwhmsurf in 10
# 			do
# 				for PVC in noPVC PVC
# 				do
# 					qbatch -q two_job_q -oe /NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Logdir -N Z_${fwhmsurf}_${PVC}_${Recon} ComputeZscoreVol_fwhm_ASL.sh \
# 					${SUBJECTS_DIR} ${SUBJECT_ID} ${Recon} ${fwhmsurf} ${PVC}
# 					sleep 1
# 				done
# 			done
# 		done
# 	done < ${FILE_PATH}/subjects_EQ.PET
# fi

## Do PALM analysis on zscore files (§4.)