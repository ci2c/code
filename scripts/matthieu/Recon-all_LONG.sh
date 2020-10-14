#!/bin/bash

export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
# SUBJECTS_DIR=/NAS/tupac/matthieu/FS5.3
INPUT_DIR=/NAS/tupac/protocoles/COMAJ/data/nifti
# INPUT_DIR=/NAS/tupac/matthieu/Siemens/BaselData/Nifti
# FILE_PATH=/NAS/tupac/protocoles/COMAJ/FS53/Description_files
FILE_PATH=/NAS/tupac/matthieu/LME
# FILE_PATH=/NAS/tupac/matthieu/CAT_A0/subjectsFiles

# # ## Step1. cross-sectionally process all time points with the default workflow ##
# #
# # # # verif on file LONG that all MRI original have classical dimensions 256x256x160
# # # while read LINE
# # # do
# # # 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# # # 	NbTP=$(echo ${LINE} | awk '{print $2}')
# # # 	for i in `seq 1 ${NbTP}`;
# # # 	do
# # # 		j=$[$i+2]
# # # 		TP=$(echo ${LINE} | cut -d" " -f$j)
# # # 		SUBJECT_ID=$(ls ${INPUT_DIR} | grep -E "^${SUBJ_ID}_${TP}")
# # # 		dim_MRIorig_x=$(mri_info ${INPUT_DIR}/${SUBJECT_ID}/*s3DT1_ISO_1mm_HR*/*s3DT1ISO1mmHRSENSE*.nii.gz | grep "dimensions" | awk '{print $2}')
# # # 		dim_MRIorig_y=$(mri_info ${INPUT_DIR}/${SUBJECT_ID}/*s3DT1_ISO_1mm_HR*/*s3DT1ISO1mmHRSENSE*.nii.gz | grep "dimensions" | awk '{print $4}')
# # # 		dim_MRIorig_z=$(mri_info ${INPUT_DIR}/${SUBJECT_ID}/*s3DT1_ISO_1mm_HR*/*s3DT1ISO1mmHRSENSE*.nii.gz | grep "dimensions" | awk '{print $6}')
# # #
# # # 		if [ ${dim_MRIorig_x} -ne 256 ] || [ ${dim_MRIorig_y} -ne 256 ] || [ ${dim_MRIorig_z} -ne 160 ]
# # # 		then
# # # 			echo "${SUBJECT_ID} orig MRI has not classic dimensions 256x256x160: ${dim_MRIorig_x}x${dim_MRIorig_y}x${dim_MRIorig_z}"
# # # 		fi
# # # 	done
# # # done < /NAS/tupac/protocoles/COMAJ/FS53/Description_files/LONG/Long_COMAJ_base
# # #
# # recon-all on all patients specified in file
# # if [ -s ${FILE_PATH}/subjects_edit_bis ]
# if [ -s ${FILE_PATH}/subjects_NC_Basel_bis ]
# then
# 	while read SUBJECT_ID
# 	do
# # 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} ]
# 		if [ ! -d /NAS/tupac/matthieu/Logdir/${SUBJECT_ID} ]
# 		then
# # 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID}
# 			mkdir /NAS/tupac/matthieu/Logdir/${SUBJECT_ID}
# 		fi
# # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N fs_${SUBJECT_ID} Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID}/*s3DT1_ISO_1mm_HR* -v "5.3_3T"
# # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N fs_${SUBJECT_ID} Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID}/*_s3DT1_ISO_1mm_HR -v "5.3_3T"
# # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N fs_${SUBJECT_ID}_edit Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID}/*_s3DT1_ISO_1mm_HR -v "5.3_edit"
#
# 		qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir/${SUBJECT_ID} -N fs_${SUBJECT_ID} Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID} -v "5.3_3T"
# 		sleep 1
# 	done < ${FILE_PATH}/subjects_NC_Basel_bis
# fi
# #
# # # # recon-all on all patients specified in file LONG
# # # while read LINE
# # # do
# # # 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# # # 	NbTP=$(echo ${LINE} | awk '{print $2}')
# # # 	for i in `seq 1 ${NbTP}`;
# # # 	do
# # # 		j=$[$i+2]
# # # 		TP=$(echo ${LINE} | cut -d" " -f$j)
# # # 		SUBJECT_ID=$(ls ${INPUT_DIR} | grep -E "^${SUBJ_ID}_${TP}")
# # # 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} ]
# # # 		then
# # # 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID}
# # # 		fi
# # # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N fs_${SUBJECT_ID} Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID}/*_s3DT1_ISO_1mm_HR -v "5.3_3T"
# # # 		sleep 1
# # # 	done
# # # done < /NAS/tupac/protocoles/COMAJ/FS53/Description_files/LONG/Long_COMAJ

# ## Step2. Create an unbiased template from all time points for each subject and process it with recon-all ##
#
# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	NbTP=$(echo ${LINE} | awk '{print $2}')
# 	ls ${SUBJECTS_DIR} | grep -E "^${Index}_M0" | grep -v -E "long.${Index}$"
# 	if [ ${NbTP} -eq 1 ]
# 	then
# 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} ]
# 		then
# 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}
# 		fi
# 		TP1=$(echo ${LINE} | awk '{print $3}')
# 		SUBJ_TP1=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP1}" | grep -v -E "long.${SUBJ_ID}$")
# # 		# -notal-check for 207050bis
# # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N fs_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} -all -notal-check
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N fs_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} -all
# 		sleep 1
# 	elif [ ${NbTP} -eq 2 ]
# 	then
# 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} ]
# 		then
# 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}
# 		fi
# 		TP1=$(echo ${LINE} | awk '{print $3}')
# 		SUBJ_TP1=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP1}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP2=$(echo ${LINE} | awk '{print $4}')
# 		SUBJ_TP2=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP2}" | grep -v -E "long.${SUBJ_ID}$")
# 		# # edit brainmask
# 		# qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N brainmask2_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# 		# -tp ${SUBJ_TP2} -autorecon-pial
# # # # 		# edit wm for 207077
# # # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N wm_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# # # 		-tp ${SUBJ_TP2} -autorecon2-wm -autorecon3
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N fs_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# 		-tp ${SUBJ_TP2} -all
# 		sleep 1
# 	elif [ ${NbTP} -eq 3 ]
# 	then
# 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} ]
# 		then
# 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}
# 		fi
# 		TP1=$(echo ${LINE} | awk '{print $3}')
# 		SUBJ_TP1=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP1}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP2=$(echo ${LINE} | awk '{print $4}')
# 		SUBJ_TP2=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP2}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP3=$(echo ${LINE} | awk '{print $5}')
# 		SUBJ_TP3=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP3}" | grep -v -E "long.${SUBJ_ID}$")
# 		# edit brainmask
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N brainmask3_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# 		-tp ${SUBJ_TP2} -tp ${SUBJ_TP3} -autorecon-pial
# # # 	# edit wm for 207134
# # # 	qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N wm_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# # # 	-tp ${SUBJ_TP2} -tp ${SUBJ_TP3} -autorecon2-wm -autorecon3
# # 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N fs_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# # 		-tp ${SUBJ_TP2} -tp ${SUBJ_TP3} -all
# 		sleep 1
# 	elif [ ${NbTP} -eq 4 ]
# 	then
# 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} ]
# 		then
# 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}
# 		fi
# 		TP1=$(echo ${LINE} | awk '{print $3}')
# 		SUBJ_TP1=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP1}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP2=$(echo ${LINE} | awk '{print $4}')
# 		SUBJ_TP2=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP2}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP3=$(echo ${LINE} | awk '{print $5}')
# 		SUBJ_TP3=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP3}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP4=$(echo ${LINE} | awk '{print $6}')
# 		SUBJ_TP4=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP4}" | grep -v -E "long.${SUBJ_ID}$")
# 		# edit brainmask
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N brainmask4_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# 		-tp ${SUBJ_TP2} -tp ${SUBJ_TP3} -tp ${SUBJ_TP4} -autorecon-pial
# 		# qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N fs_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# 		# -tp ${SUBJ_TP2} -tp ${SUBJ_TP3} -tp ${SUBJ_TP4} -all
# 		sleep 1
# 	elif [ ${NbTP} -eq 5 ]
# 	then
# 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} ]
# 		then
# 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}
# 		fi
# 		TP1=$(echo ${LINE} | awk '{print $3}')
# 		SUBJ_TP1=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP1}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP2=$(echo ${LINE} | awk '{print $4}')
# 		SUBJ_TP2=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP2}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP3=$(echo ${LINE} | awk '{print $5}')
# 		SUBJ_TP3=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP3}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP4=$(echo ${LINE} | awk '{print $6}')
# 		SUBJ_TP4=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP4}" | grep -v -E "long.${SUBJ_ID}$")
# 		TP5=$(echo ${LINE} | awk '{print $7}')
# 		SUBJ_TP5=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP5}" | grep -v -E "long.${SUBJ_ID}$")
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID} -N fs_base_${SUBJ_ID} recon-all -sd ${SUBJECTS_DIR} -base ${SUBJ_ID} -tp ${SUBJ_TP1} \
# 		-tp ${SUBJ_TP2} -tp ${SUBJ_TP3} -tp ${SUBJ_TP4} -tp ${SUBJ_TP5} -all
# 		sleep 1
# 	fi
# done < ${FILE_PATH}/Long_COMAJ_base_ter

# # WaitForJobs.sh fs_base_
#
## Step3. "-long" longitudinally process all timepoints ##

while read LINE
do
	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
	NbTP=$(echo ${LINE} | awk '{print $2}')
	for i in `seq 1 ${NbTP}`;
	do
		j=$[$i+2]
		TP=$(echo ${LINE} | cut -d" " -f$j)
		SUBJ_TP=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}_${TP}_long ]
		then
			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}_${TP}_long
		fi
# 		# edit wm for 207134_M2
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}_${TP}_long -N wm_${SUBJ_ID}_${TP}_long recon-all -sd ${SUBJECTS_DIR} -long ${SUBJ_TP} \
# 		${SUBJ_ID} -autorecon2-wm -autorecon3
		# normal use
		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}_${TP}_long -N fs_${SUBJ_ID}_${TP}_long recon-all -sd ${SUBJECTS_DIR} -long ${SUBJ_TP} \
		${SUBJ_ID} -all
		# # qcache use
		# qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJ_ID}_${TP}_long -N fs_${SUBJ_ID}_${TP}_long recon-all -sd ${SUBJECTS_DIR} -long ${SUBJ_TP} \
		# ${SUBJ_ID} -qcache
		sleep 1
	done
done < ${FILE_PATH}/Long_COMAJ_base_ter
