#!/bin/bash

if [ $# -lt 1 ]
then
		echo ""
		echo "Usage: process_asl.sh  DATA_RECPAR_DIR RESULT_DIR"
		echo ""
		exit 1
fi

result_dir=$2
Dicom=$1
index=1

if [ ! -d ${result_dir} ]
then
	mkdir -p ${result_dir}
else
	rm -fr ${result_dir}/*
fi

if [ ! -d ${Dicom}/in_data_SICA ]
then
	mkdir -p ${Dicom}/in_data_SICA
else
	rm -fr ${Dicom}/in_data_SICA/*
fi

if [ ! -d ${Dicom}/process ]
then
	mkdir -p ${Dicom}/process
fi

dcm2nii -o ${Dicom} ${Dicom}/*
mv ${Dicom}/*gz ${Dicom}/process
mkdir -p ${Dicom}/process/temp
for afile in `ls ${Dicom}/process/*nii.gz`
do
index=`echo $afile |sed -n "/[sStTaArR]/s/.*\([0-9]\)\.nii.*/\1/p"`
echo "fslsplit"
fslsplit $afile ${Dicom}/process/temp/temp_asl -t
counter=1
for tempfile in `ls ${Dicom}/process/temp/*gz`
do
j=$(printf "%.4d" $counter)
mri_convert ${tempfile} ${Dicom}/process/temp/asl_ras_${j}_${index}.nii --out_orientation RAS
counter=$[$counter+1]
done
echo
echo "fslmerge"
fslmerge -t ${Dicom}/process/asl_raw_ras_${index} ${Dicom}/process/temp/asl_ras*.nii
rm -fr ${Dicom}/process/temp/*
done

#rm -fr ${Dicom}/process/temp

if [ ! -f ${Dicom}/process/diff_map.nii ]
then
echo
for i in `ls ${Dicom}/process/asl_raw_ras*.nii.gz`
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
bet $Dicom/process/Vol_1_mean $Dicom/process/Vol_1_mean_brain  -f 0.5 -g 0 -n -m
gunzip ${Dicom}/process/diff_map.nii.gz ${Dicom}/process/Vol_1_mean.nii.gz ${Dicom}/process/Vol_2_mean.nii.gz $Dicom/process/Vol_1_mean_brain_mask.nii.gz

matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
aslmapseb('${Dicom}/process/Vol_1_mean.nii','${Dicom}/process/diff_map.nii','${Dicom}/asl.nii','$Dicom/process/Vol_1_mean_brain_mask.nii');
EOF
echo "c'est fini"
