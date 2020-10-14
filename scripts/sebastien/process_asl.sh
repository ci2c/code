#!/bin/bash

if [ $# -lt 2 ]
then
		echo ""
		echo "Usage: process_asl.sh  DATA_RECPAR_DIR RESULT_DIR"
		echo ""
		exit 1
fi

result_dir=$2
Dicom=$1
index=1

if [ -z ${result_dir} ]
then
	echo "doit fournir RESULT_DIR"
	exit 1
fi

rm -rf ${result_dir}
mkdir ${result_dir}

rm -rf ${Dicom}/in_data_SICA
mkdir -p ${Dicom}/in_data_SICA


if [ ! -d ${Dicom}/process ]
then
	mkdir -p ${Dicom}/process
fi

dcm2nii -o ${Dicom} ${Dicom}/*
mv ${Dicom}/*gz ${Dicom}/process

#mkdir -p ${Dicom}/process/temp
#for afile in `ls ${Dicom}/process/*nii.gz`
#do
#index=`echo $afile |sed -n "/[sStTaArR]/s/.*\([0-9]\)\.nii.*/\1/p"`
#echo "fslsplit"
#fslsplit $afile ${Dicom}/process/temp/temp_asl -t
#counter=1
#for tempfile in `ls ${Dicom}/process/temp/*gz`
#do
#j=$(printf "%.4d" $counter)
#mri_convert ${tempfile} ${Dicom}/process/temp/asl_ras_${j}_${index}.nii --out_orientation RAS
#counter=$[$counter+1]
#done
#echo
#echo "fslmerge"
#fslmerge -t ${Dicom}/process/asl_raw_ras_${index} ${Dicom}/process/temp/asl_ras*.nii
#rm -fr ${Dicom}/process/temp/*
#done

#rm -fr ${Dicom}/process/temp

if [ ! -f ${Dicom}/process/diff_map.nii.gz ]
then
echo
for i in `ls ${Dicom}/process/*.nii.gz`
do
echo
echo "correction du volume $i"
echo
echo

index=`echo $i |sed -n "/[aAsSlL]/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${Dicom}/process/raw_ASL_recal_${index}.nii 0
fslmaths ${Dicom}/process/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/process/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${Dicom}/process/Vol_2_mean.nii.gz -sub ${Dicom}/process/Vol_1_mean.nii.gz ${Dicom}/process/diff_map.nii.gz
#gunzip ${Dicom}/diff_map.nii.gz ${Dicom}/Vol_1_mean.nii.gz ${Dicom}/Vol_2_mean.nii.gz
fi

fslmerge -t ${Dicom}/process/asl_raw_all ${Dicom}/process/raw_ASL_recal_1.nii.gz ${Dicom}/process/raw_ASL_recal_2.nii.gz
bet ${Dicom}/process/asl_raw_all.nii.gz ${Dicom}/process/ASLALL_brain -f 0.5 -g 0 -n -m
fslsplit ${Dicom}/process/asl_raw_all.nii.gz ${Dicom}/in_data_SICA/raw_sica -t
#mri_convert ${Dicom}/process/asl_raw_all.nii.gz -ot spm ${Dicom}/in_data_SICA/raw_sica
echo
rm -fr ~/eddy_c*

echo "c'est termine : appuyer sur une touche pour quitter"
read q
