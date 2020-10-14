#!/bin/bash

SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses

DIR=$1
RECON=$2
SUBJECT_ID=$3

if [ ! -d ${OUTDIR}/SSD ]
then
	mkdir ${OUTDIR}/SSD
fi

#### 1. Extract ROI mean values from native surface parcellation (Destrieux) of PET reconstructions ####

parcel=Destrieux
for hemi in lh rh
# for hemi in rh
do
# 	rm -f ${OUTDIR}/SSD/${parcel}/${hemi}.pet.noPVC.gn.${SUBJECT_ID}.${RECON}.sum ${OUTDIR}/SSD/${parcel}/${hemi}.pet.PVC.gn.${SUBJECT_ID}.${RECON}.sum
	
	# No PVC and intensity normalization
	mri_segstats --annot ${SUBJECT_ID} ${hemi} aparc.a2009s --i ${DIR}/pet_std/${RECON}/surf/${hemi}.PET.lps.BS7.gn.mgh --excludeid 0 \
	--sum ${OUTDIR}/SSD/${parcel}/${hemi}.pet.noPVC.gn.${SUBJECT_ID}.${RECON}.sum
	
	# PVC and intensity normalization
	mri_segstats --annot ${SUBJECT_ID} ${hemi} aparc.a2009s --i ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.mgh --excludeid 0 \
	--sum ${OUTDIR}/SSD/${parcel}/${hemi}.pet.PVC.gn.${SUBJECT_ID}.${RECON}.sum
done


#### 2. Extract ROI mean values from fsaverage surface parcellation (Destrieux) of PET reconstructions ####

parcel=Destrieux
for hemi in lh rh
# for hemi in rh
do
# 	rm -f ${OUTDIR}/SSD/${parcel}/${hemi}.pet.noPVC.gn.${SUBJECT_ID}.fsaverage.${RECON}.sum ${OUTDIR}/SSD/${parcel}/${hemi}.pet.PVC.gn.${SUBJECT_ID}.fsaverage.${RECON}.sum
	
	# No PVC and intensity normalization
	mri_segstats --annot fsaverage ${hemi} aparc.a2009s --i ${DIR}/pet_std/${RECON}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.mgh --excludeid 0 \
	--sum ${OUTDIR}/SSD/${parcel}/${hemi}.pet.noPVC.gn.${SUBJECT_ID}.fsaverage.${RECON}.sum
	
	# PVC and intensity normalization
	mri_segstats --annot fsaverage ${hemi} aparc.a2009s --i ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.mgh --excludeid 0 \
	--sum ${OUTDIR}/SSD/${parcel}/${hemi}.pet.PVC.gn.${SUBJECT_ID}.fsaverage.${RECON}.sum
done