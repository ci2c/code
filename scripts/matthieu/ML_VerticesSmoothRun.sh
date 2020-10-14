#!/bin/bash

CD=/NAS/tupac/matthieu/ML/code/Python
WD=/NAS/tupac/matthieu/ML/code/Python/Structural

# for motif in thickness sqrtsulc fractaldimension gyrification
# do
# 	for FWHM in 0 5 10 15
# 	do
# 		if [ ! -d ${WD}/${motif}/fwhm${FWHM}/accuracy ]
# 		then
# 			mkdir ${WD}/${motif}/fwhm${FWHM}/accuracy
# 		fi
# 		
# 		python ${CD}/BinaryClassification_v2_Smooth.py False "${WD}/${motif}/fwhm${FWHM}" ${motif} ${FWHM}
# 	done
# done

# for motif in CT
# do
# 	for atlas in Destrieux HCP
# 	do
# 		if [ ! -d ${WD}/${motif}/${atlas}/accuracy ]
# 		then
# 			mkdir ${WD}/${motif}/${atlas}/accuracy
# 		fi
# 		
# 		python ${CD}/BinaryClassification_v2b_Atlas.py True "${WD}/${motif}/${atlas}" "${motif}.M0.${atlas}.fsaverage"
# 	done
# done

for motif in CT FD GYR SD
do
# 	for atlas in Desikan Destrieux HCP
	for atlas in Destrieux
	do
		if [ ! -d ${WD}/${motif}/${atlas}/accuracy ]
		then
			mkdir ${WD}/${motif}/${atlas}/accuracy
		fi
		
		python ${CD}/BinaryClassification_v2b_Atlas.py True "${WD}/${motif}/${atlas}" "${motif}.M0.${atlas}.fsaverage"
	done
done