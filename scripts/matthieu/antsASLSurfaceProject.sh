#!/bin/bash

# Assign input values of arguments
FS_DIR=$1
OUTPUT_DIR=$2
SUBJ_ID=$3

# Assign new value of SUBJECTS_DIR
SUBJECTS_DIR=${FS_DIR}

gunzip ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLbrainmask.nii.gz
mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLbrainmask.nii dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLbrainmask_dil.nii

# mask
mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLbrainmask_dil.nii --regheader ${SUBJ_ID} --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.lh.nii --min .00001 --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.lh.nii
mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLbrainmask_dil.nii --regheader ${SUBJ_ID} --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.rh.nii --min .00001 --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.rh.nii

# Use processing inputs
echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLMeanCBFWarpedToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/cbf.mgz"
mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASLMeanCBFWarpedToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/cbf.mgz

echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASL_PVC_MeanCBFWToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/cbf_pvc.mgz"
mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/ASL_PVC_MeanCBFWToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/cbf_pvc.mgz

# # Use volumic inputs without pre-smoothing
# echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASLMeanCBFWarpedToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/cbf.mgz"
# mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASLMeanCBFWarpedToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/cbf.mgz
# 
# echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_PVC_MeanCBFWToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/cbf_pvc.mgz"
# mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Volume/ASL_PVC_MeanCBFWToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/cbf_pvc.mgz
# 
# ## Use volumic inputs with pre-smoothing
# echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/ASLMeanCBFWarpedToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm_cbf.mgz"
# mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/ASLMeanCBFWarpedToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm_cbf.mgz
# 
# echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/ASL_PVC_MeanCBFWToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm_cbf_pvc.mgz"
# mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/ASL_PVC_MeanCBFWToT1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/prefwhm_cbf_pvc.mgz

# ## Freesurfer_write_surf - FreeSurfer I/O function to write a surface file
# matlab -nodisplay <<EOF
#  
# inner_surf = SurfStatReadSurf('${FS_DIR}/${SUBJ_ID}/surf/lh.white');
# outer_surf = SurfStatReadSurf('${FS_DIR}/${SUBJ_ID}/surf/lh.pial');
# 
# mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
# mid_surf.tri = inner_surf.tri;
# 
# freesurfer_write_surf('${FS_DIR}/${SUBJ_ID}/surf/lh.mid', mid_surf.coord', mid_surf.tri);
# 
# inner_surf = SurfStatReadSurf('${FS_DIR}/${SUBJ_ID}/surf/rh.white');
# outer_surf = SurfStatReadSurf('${FS_DIR}/${SUBJ_ID}/surf/rh.pial');
# 
# mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
# mid_surf.tri = inner_surf.tri;
# 
# freesurfer_write_surf('${FS_DIR}/${SUBJ_ID}/surf/rh.mid', mid_surf.coord', mid_surf.tri);
# EOF

## Map on surface cbf, cbf_pvc, prefwhm_cbf and prefwhm_cbf_pvc
for var in cbf cbf_pvc
# for var in cbf cbf_pvc prefwhm_cbf prefwhm_cbf_pvc
do
# 	echo "mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi lh --surf mid --o lh.${var}.w --regheader ${SUBJ_ID} --out_type paint"
# 	mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi lh --surf mid --o lh.${var}.w --regheader ${SUBJ_ID} --out_type paint
# 
# 	echo "mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi rh --surf mid --o rh.${var}.w --regheader ${SUBJ_ID} --out_type paint"
# 	mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi rh --surf mid --o rh.${var}.w --regheader ${SUBJ_ID} --out_type paint
# 	
# 	echo "mris_w_to_curv ${SUBJ_ID} lh ${FS_DIR}/${SUBJ_ID}/surf/lh.${var}.w lh.${var}"
# 	mris_w_to_curv ${SUBJ_ID} lh ${FS_DIR}/${SUBJ_ID}/surf/lh.${var}.w lh.${var}
# 
# 	echo "mris_w_to_curv ${SUBJ_ID} rh ${FS_DIR}/${SUBJ_ID}/surf/rh.${var}.w rh.${var}"
# 	mris_w_to_curv ${SUBJ_ID} rh ${FS_DIR}/${SUBJ_ID}/surf/rh.${var}.w rh.${var}
# 	
# 	cp ${FS_DIR}/${SUBJ_ID}/surf/lh.${var} ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface
# 	cp ${FS_DIR}/${SUBJ_ID}/surf/rh.${var} ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface
# 		
# 	rm -f ${FS_DIR}/${SUBJ_ID}/surf/lh.${var}.w ${FS_DIR}/${SUBJ_ID}/surf/rh.${var}.w
# 	rm -f ${FS_DIR}/${SUBJ_ID}/surf/lh.${var} ${FS_DIR}/${SUBJ_ID}/surf/rh.${var}
# 		
# 	echo "mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fsaverage.${var}.mgh --tfmt curv"
# 	mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fsaverage.${var}.mgh --tfmt curv
# 
# 	echo "mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fsaverage.${var}.mgh --tfmt curv"
# 	mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fsaverage.${var}.mgh --tfmt curv
	
	mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/${var}.mgz --regheader ${SUBJ_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/lh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
	mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/${var}.mgz --regheader ${SUBJ_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/rh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
	
	for FWHM in 4 6 8 10 12 15
	do
# 		echo "mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.${var}.w --regheader ${SUBJ_ID} --out_type paint --surf-fwhm ${FWHM}"
# 		mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.${var}.w --regheader ${SUBJ_ID} --out_type paint --surf-fwhm ${FWHM}
# 
# 		echo "mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.${var}.w --regheader ${SUBJ_ID} --out_type paint --surf-fwhm ${FWHM}"
# 		mri_vol2surf --mov ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/${var}.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.${var}.w --regheader ${SUBJ_ID} --out_type paint --surf-fwhm ${FWHM}
# 	
# 		echo "mris_w_to_curv ${SUBJ_ID} lh ${FS_DIR}/${SUBJ_ID}/surf/lh.fwhm${FWHM}.${var}.w lh.fwhm${FWHM}.${var}"
# 		mris_w_to_curv ${SUBJ_ID} lh ${FS_DIR}/${SUBJ_ID}/surf/lh.fwhm${FWHM}.${var}.w lh.fwhm${FWHM}.${var}
# 
# 		echo "mris_w_to_curv ${SUBJ_ID} rh ${FS_DIR}/${SUBJ_ID}/surf/rh.fwhm${FWHM}.${var}.w rh.fwhm${FWHM}.${var}"
# 		mris_w_to_curv ${SUBJ_ID} rh ${FS_DIR}/${SUBJ_ID}/surf/rh.fwhm${FWHM}.${var}.w rh.fwhm${FWHM}.${var}
# 	
# 		cp ${FS_DIR}/${SUBJ_ID}/surf/lh.fwhm${FWHM}.${var} ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fwhm${FWHM}.${var}
# 		cp ${FS_DIR}/${SUBJ_ID}/surf/rh.fwhm${FWHM}.${var} ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fwhm${FWHM}.${var}
# 		
# 		rm -f ${FS_DIR}/${SUBJ_ID}/surf/lh.fwhm${FWHM}.${var}.w ${FS_DIR}/${SUBJ_ID}/surf/rh.fwhm${FWHM}.${var}.w
# 		rm -f ${FS_DIR}/${SUBJ_ID}/surf/lh.fwhm${FWHM}.${var} ${FS_DIR}/${SUBJ_ID}/surf/rh.fwhm${FWHM}.${var}
# 		
# 		echo "mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv"
# 		mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/lh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv
# 		
# 		echo "mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv"
# 		mri_surf2surf --srcsubject ${SUBJ_ID} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval  ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Surface/rh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv
		
		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/lh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/lh.fwhm${FWHM}.fsaverage.${var}.mgh --mask ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.lh.nii
		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/rh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/rh.fwhm${FWHM}.fsaverage.${var}.mgh --mask ${OUTPUT_DIR}/${SUBJ_ID}/ASLProcessing/Processing/brain.fsaverage.rh.nii
	done
done

