#!/bin/bash

if [ $# -lt 1 ]
then
		echo ""
		echo "Usage: process_asl_multiphase.sh  DATA_RECPAR_DIR"
		echo ""
		exit 1
fi

Dicom=$1

dcm2nii -o ${Dicom} ${Dicom}/*rec

for i in `ls ${Dicom}/*.nii.gz`
do
echo
echo "correction du volume $i"
echo
echo
index=`echo $i |sed -n "s/.*x\([0-9].*\)\.nii.*/\1/p"`
eddy_correct_sge $i ${Dicom}/raw_ASL_recal_${index}.nii 0
fslmaths ${Dicom}/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/Vol_${index}_mean.nii.gz -odt double
done

nbdyn=`ls ${Dicom}/Vol*nii.gz |wc -l`
dyn=`echo "${nbdyn}/2 " | bc`
echo "!!!!!! Nombre de phase : $dyn !!!!!!"
index=1
while [ $index -le $dyn ]
do
echo "phase $index"
lab=$[$index]
cont=$[$lab+$dyn]
mkdir ${Dicom}/phase_${index}
echo "fslmaths ${Dicom}/Vol_${lab}_mean.nii.gz -sub ${Dicom}/Vol_${cont}_mean.nii.gz ${Dicom}/phase_${index}/diff_map_${index}.nii.gz"
fslmaths ${Dicom}/Vol_${cont}_mean.nii.gz -sub ${Dicom}/Vol_${lab}_mean.nii.gz ${Dicom}/phase_${index}/diff_map_${index}.nii.gz
index=$[${index}+1]
done
rm -fr ${Dicom}/*tmp*gz
rm -fr ~/eddy_c*
echo "c'est termine : appuyer sur une touche pour quitter"
read q
