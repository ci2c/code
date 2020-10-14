#!/bin/bash

Study=$1
InputDir=$2
SUBJECT_ID=$3
Long=$4
FWHM=$5

if [ $Study -eq 1 ]
then
	for hemi in lh rh
	do
		for motif in thickness sqrtsulc fractaldimension gyrification
# 		for motif in thickness
		do
			if [ ${Long} -eq 1 ]
			then
				ConvertGiftiToMgh.sh ${Long} ${InputDir} s15mm.${hemi}.${motif}.resampled.rorig.lia.${SUBJECT_ID}.gii ${hemi} \
				${motif} 15 ${SUBJECT_ID}
			elif [ ${Long} -eq 0 ]
			then
				ConvertGiftiToMgh.sh ${Long} ${InputDir} s15mm.${hemi}.${motif}.resampled.orig.lia.${SUBJECT_ID}.gii ${hemi} \
				${motif} 15 ${SUBJECT_ID}
			fi
		done
		
		for motif in fractaldimension gyrification
		do
			for FWHM in 20 25
			do
				if [ ${Long} -eq 1 ]
				then
					ConvertGiftiToMgh.sh ${Long} ${InputDir} s${FWHM}mm.${hemi}.${motif}.resampled.rorig.lia.${SUBJECT_ID}.gii ${hemi} \
					${motif} ${FWHM} ${SUBJECT_ID}
				elif [ ${Long} -eq 0 ]
				then
					ConvertGiftiToMgh.sh ${Long} ${InputDir} s${FWHM}mm.${hemi}.${motif}.resampled.orig.lia.${SUBJECT_ID}.gii ${hemi} \
					${motif} ${FWHM} ${SUBJECT_ID}
				fi
			done
		done
	done
elif [ $Study -eq 0 ]
then
	for hemi in lh rh
	do
		for motif in thickness sqrtsulc fractaldimension gyrification
		do
			if [ ${FWHM} -eq 0 ]
			then
				if [ ! -s /NAS/tupac/matthieu/CAT_A0/surf/${hemi}.${motif}.fsaverage.s${FWHM}mm.orig.lia.${SUBJECT_ID}.mgh ]
				then
					ConvertGiftiToMgh.sh 0 ${InputDir} ${hemi}.${motif}.resampled.orig.lia.${SUBJECT_ID}.gii ${hemi} \
					${motif} ${FWHM} ${SUBJECT_ID}
				fi
		
			else
				if [ ! -s /NAS/tupac/matthieu/CAT_A0/surf/${hemi}.${motif}.fsaverage.s${FWHM}mm.orig.lia.${SUBJECT_ID}.mgh ]
				then
					ConvertGiftiToMgh.sh 0 ${InputDir} s${FWHM}mm.${hemi}.${motif}.resampled.orig.lia.${SUBJECT_ID}.gii ${hemi} \
					${motif} ${FWHM} ${SUBJECT_ID}
				fi
			fi
		done
		
# 		for motif in fractaldimension gyrification
# 		do
# 			for FWHM in 20 25
# 			do
# 				if [ ! -s /NAS/tupac/matthieu/CAT_A0/surf/${hemi}.${motif}.fsaverage.s${FWHM}mm.orig.lia.${SUBJECT_ID}.mgh ]
# 				then
# 					ConvertGiftiToMgh.sh 0 ${InputDir} s${FWHM}mm.${hemi}.${motif}.resampled.orig.lia.${SUBJECT_ID}.gii ${hemi} \
# 					${motif} ${FWHM} ${SUBJECT_ID}
# 				fi
# 			done
# 		done
	done
fi