#!/bin/bash

FILE_PATH=$1
FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3"
DATA_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data"
cpt=1

if [ -s ${FILE_PATH}/IRMf_cohorte.txt ]
then	
	while read SUBJECT_ID
	do
	
##################################
#T1
##################################
#Apply Recon-all càd FS5.3
#	mkdir "${DATA_PATH}/${SUBJECT_ID}/v2/nifti"
#	dcm2nii -o ${DATA_PATH}/${SUBJECT_ID}/v2/nifti ${DATA_PATH}/${SUBJECT_ID}/v2/*/*.*../.

#qbatch -q U1404 -oe /home/christine/log/ -N fs_${SUBJ}enc recon-all -all -sd /NAS/dumbo/protocoles/IRMf_memoire/FS5.3 -subjid ${SUBJ}_enc -nuintensitycor-3T -i /NAS/dumbo/protocoles/IRMf_memoire/data/${SUBJ}/T1_enc.nii.gz

#(\d*.\d)  Left-Hippocampus
#SUBJECT_ID=gunther
#grep "Left-Hippocampus" ${FS_PATH}/${SUBJECT_ID}_enc/stats/aseg.stats
#VolumeT1="${FS_PATH}/${SUBJECT_ID}_enc/mri/T1.mgz"
#Segmentation="${FS_PATH}/${SUBJECT_ID}_enc/mri/aparc.a2009s+aseg.mgz"
#BrainMask="${FS_PATH}/${SUBJECT_ID}_enc/mri/brainmask.mgz"
#Whitematter="${FS_PATH}/${SUBJECT_ID}_enc/mri/wm.mgz"
#Surfacelh="${FS_PATH}/${SUBJECT_ID}_enc/surf/lh.pial"
#Surfacerh="${FS_PATH}/${SUBJECT_ID}_enc/surf/rh.pial"
#freeview $VolumeT1 $Whitematter $Segmentation -f $Surfacelh -f $Surfacerh&

##################################
#DTI
##################################
#tracto cerveau entier PrepareSurfConnectome_4_IRMfmemoire.sh
		#mv dti.nii.gz etc..
		#! Verif des volumes dti avec freeview (bien 32 frames ?) et format de bvec et bval....
			#find ../../ -iname "b0_norm_unwarp.nii.gz" | xargs rm -f

#		# Step 1. Correct distortions
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/distorsion_correction/b0_norm_unwarp.nii.gz 
#		# Step 2. Eddy current correction
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/dti_eddycor.ecclog
#		# Step 3. Rotate bvec
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/dti.bvec_old
#		# Step 4. Apply distortion corrections to the whole DWI
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/dti_finalcor.nii.gz 
#		# Step 5. Compute DTI fit on fully corrected DTI
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/dti_finalcor_brain_mask.nii.gz
#		# Step 6. Get freesurfer WM mask
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/wm_mask.nii.gz
#		# Step 7. Register T1 to DTI
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/rt1_dti_ras.nii.gz 
#		# Step 8. Performs tractography
#			#Step 8.1 Convert images and bvec
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/dti_finalcor.mif 
#			#Step 8.2 All steps until the response estimate
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/response.txt
#			#Step 8.3 Spherical deconvolution
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/CSD*.mif
#			#Step 8.4 Fiber tracking
#			#Step 8.5 Merge the fiber files into unique matlab files"
#		rm ${FS_PATH}/${SUBJECT_ID}_enc/dti/whole_brain_6_1500.tck
#		
#		echo "qbatch -q two_job_q -oe /NAS/dumbo/romain/log -N Tracto_${SUBJECT_ID}_RV /home/romain/SVN/scripts/romain/PrepareSurfConnectome_4_IRMfmemoire.sh -fs ${FS_PATH} -subj ${SUBJECT_ID}_enc -las"
#		qbatch -q two_job_q -oe /NAS/dumbo/romain/log -N Tracto_${SUBJECT_ID}_RV /home/romain/SVN/scripts/romain/PrepareSurfConnectome_4_IRMfmemoire.sh -fs ${FS_PATH} -subj ${SUBJECT_ID}_enc -las

#######################################################HRSC High Resolution Structural Connectome
#Apres la tractography lance LaunchShape, LaunchGraph, LaunchGraphSubCort, et LaunchSubSampling (cf. /home/notorious/NAS/pierre/Epilepsy/FreeSurfer5.0/Patients_Sophie)
#qbatch -q two_job_q -oe /NAS/dumbo/romain/log/ -N HRSC_${SUBJECT_ID} /home/romain/SVN/scripts/romain/HRSC.sh ${FS_PATH} ${SUBJECT_ID}
#en tmp ne lance que la fonction getSurfaceConnectome
#qbatch -j 1487278 1487279 1487280 1487281 -q two_job_q -oe /NAS/dumbo/romain/log/ -N RV4getSurface_${SUBJECT_ID} getSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID}_enc 

#######################################################Subsample
#qbatch -q two_job_q -oe /NAS/dumbo/romain/log/ -N ${SUBJECT_ID}_SubSamp /home/romain/SVN/scripts/romain/SubsampleSurfaceConnectome.sh -fs ${FS_PATH} -subj ${SUBJECT_ID}_enc

##################################
#RestingState
##################################
#Pré-ttt
SUBJECT_ID=comblez
DATA_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data"
RS_FILE="${DATA_PATH}/${SUBJECT_ID}/resting_state.nii.gz"
RS_FILE=`find ${DATA_PATH}/${SUBJECT_ID}/resting_state_dcm -iname "*.nii.gz"`
qbatch -q one_job_q -oe /NAS/dumbo/romain/log -N rst_RV_${SUBJECT_ID} /home/romain/SVN/scripts/romain/FMRI_PreprocessingVolumeAndSurface.sh -sd ${FS_PATH} -subj ${SUBJECT_ID}_enc -epi ${RS_FILE} -o resting_state -fwhmsurf 6 -fwhmvol 6 -acquis interleaved -rmframe 3 -tr 2.4 -doCompCor -doFilt 0.008 0.1 -doSPMNorm -doGMS -v 5.3

#ttt-Resting State -> Connectome fonctionnel
#qbatch -q  two_job_q -oe /NAS/dumbo/romain/log -N ${SUBJECT_ID}_fConn /home/notorious/NAS/renaud/scripts/cogphenopark/Launch_FMRIConnectome.sh
#qbatch -q  two_job_q -oe /NAS/dumbo/romain/log -N ${SUBJECT_ID}_fConn /home/romain/SVN/scripts/renaud/FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd ${FS_PATH} -subj ${SUBJECT_ID}_enc -epi ${FS_PATH}/${SUBJECT_ID}_enc/resting_state/run01/fcarepi_al.nii -omat algoRL -odir ${FS_PATH}/${SUBJECT_ID}_enc/resting_state/ 

##################################
#fMRI
##################################
###############################################Pré-ttt de l'analyse individuelle
#		SUBJECT_ID=vanpoucke
#		FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3"
#		DATA_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data"
#		RS_FILE="${DATA_PATH}/${SUBJECT_ID}/resting_state.nii.gz"
#		RS_FILE=`find ${DATA_PATH}/${SUBJECT_ID}/resting_state_dcm -iname "*.nii.gz"`

#		rm -rf ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV
#		mkdir ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV
#		mkdir ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV/mots
#		cp ${FS_PATH}/${SUBJECT_ID}_enc/fmri/fmri_enc_mot.nii.gz ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV/fmri_enc_mot.nii.gz
#		qbatch -q three_job_q -oe /NAS/dumbo/romain/log -N prettt_mot_indiv_${SUBJECT_ID} ~/SVN/scripts/romain/FMRI_PreprocessingVolumeAndSurface.sh -sd ${FS_PATH} -subj ${SUBJECT_ID}_enc -epi ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV/fmri_enc_mot.nii.gz -o fmri_RV/mots -fwhmsurf 6 -fwhmvol 6 -acquis ascending -rmframe 3 -tr 2 -doSPMNorm -doAnalysis -v 5.3

#	sleep 3

#		mkdir ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV/visages
#		cp ${FS_PATH}/${SUBJECT_ID}_enc/fmri/fmri_enc_visage.nii.gz ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV/fmri_enc_visage.nii.gz
		qbatch -q three_job_q -oe /NAS/dumbo/romain/log -N prettt_vis_indiv_${SUBJECT_ID} ~/SVN/scripts/romain/FMRI_PreprocessingVolumeAndSurface.sh -sd ${FS_PATH} -subj ${SUBJECT_ID}_enc -epi ${FS_PATH}/${SUBJECT_ID}_enc/fmri_RV/fmri_enc_visage.nii.gz -o fmri_RV/visages -fwhmsurf 6 -fwhmvol 6 -acquis ascending -rmframe 3 -tr 2 -doSPMNorm -doAnalysis -v 5.3

###############################################Pré-ttt pour l'analyse de second niveau
#		IOpath="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/${SUBJECT_ID}_enc";
#		echo 	"qbatch -q three_job_q -oe /NAS/dumbo/romain/log -N RV_${SUBJECT_ID}_RV /home/romain/SVN/scripts/romain/run_normalizeFMRI.sh ${IOpath} ${cpt}"
#		qbatch -q three_job_q -oe /NAS/dumbo/romain/log -N prettt42ndLevel__${SUBJECT_ID}_RV /home/romain/SVN/scripts/romain/run_normalizeFMRI.sh ${IOpath} ${cpt}
#		cpt=`expr ${cpt} + 1`

	sleep 2
	done < ${FILE_PATH}/IRMf_cohorte.txt
fi
