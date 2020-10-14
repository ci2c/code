#!/bin/bash

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "FS_dir : $fs"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "subj : $subj"
		;;
	esac
	index=$[$index+1]
done

for SUBJ in ${subj}
do	
	DIR=${fs}/${SUBJ}
	cd ${DIR}
	mkdir ./dti
	cd ${DIR}/dti
	cp ${DIR}/dti.nii.gz ${DIR}/dti/dti.nii.gz
	cp ${DIR}/dti.bvec ${DIR}/dti/dti.bvec
	cp ${DIR}/dti.bval ${DIR}/dti/dti.bval
	

	#####################
	#   Eddy Correct    #
	#####################
	echo "eddy_correct ${DIR}/dti/dti.nii.gz ${DIR}/dti/dti_cor.nii.gz 0"
	eddy_correct ${DIR}/dti/dti.nii.gz ${DIR}/dti/dti_cor.nii.gz 0


	#####################
	#   Correct bvecs   #
	#####################
	echo "rotate_bvecs dti_cor.ecclog dti.bvec"
	rotate_bvecs ${DIR}/dti/dti_cor.ecclog ${DIR}/dti/dti.bvec


	####################
	# Brain ExTraction #
	####################
	echo "bet ${DIR}/dti/dti_cor ${DIR}/dti/dti_cor_brain -F -f 0.5 -g 0 -m"
	bet ${DIR}/dti/dti_cor ${DIR}/dti/dti_cor_brain -F -f 0.5 -g 0 -m


	###################
	#     Dtifit      #
	###################
	echo "dtifit --data=${DIR}/dti/dti_cor.nii.gz --out=${DIR}/dti/dti_cor --mask=${DIR}/dti/dti_cor_brain_mask.nii.gz --bvecs=${DIR}/dti/dti.bvec --bvals=${DIR}/dti/dti.bval"
	dtifit --data=${DIR}/dti/dti_cor.nii.gz --out=${DIR}/dti/dti_cor --mask=${DIR}/dti/dti_cor_brain_mask.nii.gz --bvecs=${DIR}/dti/dti.bvec --bvals=${DIR}/dti/dti.bval


	########################
	#  Coef d'anisotropie  #
	########################
	echo " $SUBJ mri_convert"
	mri_convert -i ${DIR}/dti/dti_cor_L3.nii.gz -o ${DIR}/dti/L3.mnc
	mri_convert -i ${DIR}/dti/dti_cor_L2.nii.gz -o ${DIR}/dti/L2.mnc
	mri_convert -i ${DIR}/dti/dti_cor_L1.nii.gz -o ${DIR}/dti/L1.mnc
	echo " $SUBJ Coef linéaire"	
	minccalc -expression "result=(A[0]-A[1])/sqrt(A[0]*A[0]+A[1]*A[1]+A[2]*A[2])" ${DIR}/dti/L1.mnc ${DIR}/dti/L2.mnc ${DIR}/dti/L3.mnc ${DIR}/dti/Clin.mnc
	minccalc -expression "result=(A[0]-A[1])/(A[0]+A[1]+A[2])" ${DIR}/dti/L1.mnc ${DIR}/dti/L2.mnc ${DIR}/dti/L3.mnc ${DIR}/dti/Clin2.mnc
	
	
	echo " $SUBJ Coef planaire"
	minccalc -expression "result=2*(A[1]-A[2])/sqrt(A[0]*A[0]+A[1]*A[1]+A[2]*A[2])" ${DIR}/dti/L1.mnc ${DIR}/dti/L2.mnc ${DIR}/dti/L3.mnc ${DIR}/dti/Cplan.mnc
	minccalc -expression "result=2*(A[1]-A[2])/(A[0]+A[1]+A[2])" ${DIR}/dti/L1.mnc ${DIR}/dti/L2.mnc ${DIR}/dti/L3.mnc ${DIR}/dti/Cplan2.mnc
	echo " $SUBJ Comp Radiale"
	fslmaths ${DIR}/dti/dti_cor_L2.nii.gz -add ${DIR}/dti/dti_cor_L3.nii.gz -div 2 ${DIR}/dti/Lrad.nii.gz
	mri_convert ${DIR}/dti/Clin.mnc ${DIR}/dti/Clin.nii.gz
	mri_convert ${DIR}/dti/Cplan.mnc ${DIR}/dti/Cplan.nii.gz
	mri_convert ${DIR}/dti/Clin2.mnc ${DIR}/dti/Clin2.nii.gz
	mri_convert ${DIR}/dti/Cplan2.mnc ${DIR}/dti/Cplan2.nii.gz
	rm *.mnc
	

done
