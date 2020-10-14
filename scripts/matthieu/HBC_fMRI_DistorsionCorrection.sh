#!/bin/bash

OUTPUT_DIR=/NAS/dumbo/matthieu/Phantom_Correctionfmri_X
SUBJ_ID=S1
DoMC=1

#=========================================
#            Initialization
#=========================================

# if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/fMRI ]
# then
# 	mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/fMRI
# else
# 	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/*
# fi
# 
# FMRI=$(ls ${OUTPUT_DIR}/${SUBJ_ID}/*SpinEcho*PA.nii.gz)
# FMRICorr=$(ls ${OUTPUT_DIR}/${SUBJ_ID}/*SpinEcho*AP.nii.gz)
# if [ -n "${FMRI}" ]
# then
# 	echo "cp ${FMRI} ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/fMRI.nii.gz"
# 	cp ${FMRI} ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/fMRI.nii.gz
# 	
# 	echo "cp ${FMRICorr} ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/fMRI_back.nii.gz"
# 	cp ${FMRICorr} ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/fMRI_back.nii.gz
# else
# 	echo "Le fichier SpinEcho fMRI n'existe pas"
# 	exit 1
# fi

# =========================================================
#            Compute the mean EPI of the timeseries
# =========================================================

if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC ]
then
	mkdir ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC
else
	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/*
fi

cp ${OUTPUT_DIR}/${SUBJ_ID}/REST_PA_10.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/epi.nii.gz

fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/epi -Tmean ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/mean_epi

# =====================================================================================
#            Correction of subject motion : realignment of the timeseries
# =====================================================================================

gunzip ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/*.gz

if [ $DoMC -eq 1 ]
then
# 	${FREESURFER_HOME}/fsfast/bin/
	mc-afni2 --i ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/epi.nii --t ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/mean_epi.nii --o ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/repi.nii --mcdat ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/repi.mcdat

	# Making external regressor from mc params
	mcdat2mcextreg --i ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/repi.mcdat --o ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/mcprextreg
fi

gzip ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/*.nii

# =====================================================================================================
#            EPI distorsion correction : use of cmtk and rigid registration of repi to SpinEcho_PA
# =====================================================================================================

for_fMRI=${OUTPUT_DIR}/${SUBJ_ID}/fMRI/fMRI.nii.gz
rev_fMRI=${OUTPUT_DIR}/${SUBJ_ID}/fMRI/fMRI_back.nii.gz

DCDIR=${OUTPUT_DIR}/${SUBJ_ID}/fMRI/DC
for_wrepi=${DCDIR}/wrepi.nii.gz
distcor_wrepi=${DCDIR}/wrepi_distcor.nii.gz

time_start=`date +%s`

if [ -e ${rev_fMRI} ]
then
	# Estimate distortion corrections
	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/DC/fMRIC0_norm_unwarp.nii.gz ]
	then
		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/DC ]
		then
			mkdir ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/DC
		else
			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/DC/*
		fi	
		
		echo "fslroi ${for_fMRI} ${DCDIR}/fMRI0 0 1"
		fslroi ${for_fMRI} ${DCDIR}/fMRI0 0 1
		echo "fslroi ${rev_fMRI} ${DCDIR}/fMRI0_back 0 1"
		fslroi ${rev_fMRI} ${DCDIR}/fMRI0_back 0 1
				
		gunzip -f ${DCDIR}/*gz

		# Shift the reverse DWI by 1 voxel
		# Only for Philips images, for *unknown* reason
		# Then AP-flip the image for CMTK
				
		matlab -nodisplay <<EOF
		cd ${DCDIR}
		V = spm_vol('fMRI0_back.nii');
		Y = spm_read_vols(V);
		
		Y = circshift(Y, [-1 0 0]);
		V.fname = 'sfMRI0_back.nii';
		spm_write_vol(V,Y);
		
		Y = flipdim(Y, 2);
		V.fname = 'rfMRI0_back.nii';
		spm_write_vol(V,Y);
EOF

		# Normalize the signal
		S=`fslstats ${DCDIR}/fMRI0.nii -m`
		fslmaths ${DCDIR}/fMRI0.nii -div $S -mul 1000 ${DCDIR}/fMRI0_norm -odt double
		
		S=`fslstats ${DCDIR}/rfMRI0_back.nii -m`
		fslmaths ${DCDIR}/rfMRI0_back.nii -div $S -mul 1000 ${DCDIR}/rfMRI0_back_norm -odt double
		
		# Launch CMTK
		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/fMRI0_norm.nii.gz ${DCDIR}/rfMRI0_back_norm.nii.gz ${DCDIR}/fMRI0_norm_unwarp.nii ${DCDIR}/rfMRI0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/fMRI0_norm.nii.gz ${DCDIR}/rfMRI0_back_norm.nii.gz ${DCDIR}/fMRI0_norm_unwarp.nii ${DCDIR}/rfMRI0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
		
		gzip -f ${DCDIR}/*.nii
	fi
	
	# Register repi to SpinEcho_PA
	if [ ! -e ${for_wrepi} ]
	then
		${FSLDIR}/bin/flirt -dof 6 -interp sinc -in ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/mean_epi -ref ${DCDIR}/fMRI0_norm -omat ${DCDIR}/mean_epi2SE_PA.mat -out ${DCDIR}/mean_epi2SE_PA
		${FSLDIR}/bin/applywarp --rel --interp=spline -i ${OUTPUT_DIR}/${SUBJ_ID}/fMRI/MC/repi -r ${DCDIR}/fMRI0_norm --premat=${DCDIR}/mean_epi2SE_PA.mat -o ${for_wrepi}
	fi
			
	# Apply distortion corrections to the whole RS_PA repi
	if [ ! -e ${distcor_wrepi} ]
	then
		echo "fslsplit ${for_wrepi} ${DCDIR}/voltmp -t"
		fslsplit ${for_wrepi} ${DCDIR}/voltmp -t
		
		for I in `ls ${DCDIR} | grep voltmp`
			do
			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/fMRI0_norm.nii.gz ${DCDIR}/dfield.nrrd"
			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/fMRI0_norm.nii.gz ${DCDIR}/dfield.nrrd
			
			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
			
			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
		done
				
		echo "fslmerge -t ${distcor_wrepi} ${DCDIR}/*ucorr_jac.nii.gz"
		fslmerge -t ${distcor_wrepi} ${DCDIR}/*ucorr_jac.nii.gz
		
		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
		gzip -f ${DCDIR}/*.nii	
	fi
else
	echo "Le fichier ${rev_fMRI} n'existe pas"
	exit 1
fi

time_end=`date +%s`
time_elapsed=$((time_end - time_start))

echo
echo "--------------------------------------------------------------------------------------"
echo " Done with CMTK processing pipeline"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s"
echo "--------------------------------------------------------------------------------------"