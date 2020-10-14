#!/bin/bash

Dicom=$1

dcm2nii -o ${Dicom}/pcasl_8 ${Dicom}/pcasl_8
dcm2nii -o $Dicom/pcasl_32 $Dicom/pcasl_32
dcm2nii -o $Dicom/star $Dicom/star
dcm2nii -o $Dicom/mri/orig -d n -e n -p n $Dicom/mri/orig
dcm2nii -o $Dicom/despot -g n $Dicom/despot
rm $Dicom/despot/*rec $Dicom/despot/*par

echo
echo
for i in `ls ${Dicom}/pcasl_8/*.nii.gz`
do
echo
echo "correction du volume $i"
echo
echo
index=`echo $i |sed -n "/casl/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${Dicom}/pcasl_8/raw_ASL_recal_${index}.nii.gz 0
fslmaths ${Dicom}/pcasl_8/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/pcasl_8/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${Dicom}/pcasl_8/Vol_2_mean.nii.gz -sub ${Dicom}/pcasl_8/Vol_1_mean.nii.gz ${Dicom}/pcasl_8/diff_map8.nii.gz
gunzip ${Dicom}/pcasl_8/diff_map8.nii.gz ${Dicom}/pcasl_8/Vol_1_mean.nii.gz ${Dicom}/pcasl_8/Vol_2_mean.nii.gz


echo
echo
for i in `ls ${Dicom}/pcasl_32/*.nii.gz`
do
echo
echo "correction du volume $i"
echo
echo
index=`echo $i |sed -n "/casl/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${Dicom}/pcasl_32/raw_ASL_recal_${index}.nii.gz 0
fslmaths ${Dicom}/pcasl_32/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/pcasl_32/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${Dicom}/pcasl_32/Vol_2_mean.nii.gz -sub ${Dicom}/pcasl_32/Vol_1_mean.nii.gz ${Dicom}/pcasl_32/diff_map32.nii.gz
gunzip ${Dicom}/pcasl_32/diff_map32.nii.gz ${Dicom}/pcasl_32/Vol_1_mean.nii.gz ${Dicom}/pcasl_32/Vol_2_mean.nii.gz



echo
echo
for i in `ls ${Dicom}/star/*.nii.gz`
do
echo
echo "correction du volume $i"
echo
echo
index=`echo $i |sed -n "/star/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${Dicom}/star/raw_ASL_recal_${index}.nii.gz 0
fslmaths ${Dicom}/star/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/star/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${Dicom}/star/Vol_2_mean.nii.gz -sub ${Dicom}/star/Vol_1_mean.nii.gz ${Dicom}/star/diff_mapstar.nii.gz
gunzip ${Dicom}/star/diff_mapstar.nii.gz ${Dicom}/star/Vol_1_mean.nii.gz ${Dicom}/star/Vol_2_mean.nii.gz



for t132 in `ls ${Dicom}/mri/orig/*32c*.gz`
do
mri_convert $t132 $Dicom/mri/orig/001.mgz
done

for t18 in `ls ${Dicom}/mri/orig/*8c*.gz`
do
mri_convert $t18 $Dicom/mri/orig/002.mgz
done

mv $Dicom/mri/orig/002.mgz ${Dicom}_8c/mri/orig/001.mgz

tem=`basename ${Dicom}`
echo $tem
recon-all -all -subjid $tem -sd /home/aurelien/NAS/sebastien/Master_seb/ -nuintensitycor-3T && recon-all -all -subjid ${tem}_8c -sd /home/aurelien/NAS/sebastien/Master_seb/ -nuintensitycor-3T


#mri_convert ${Dicom}/diff_map.nii ${Dicom}/asl.mgz --out_orientation RAS
#mincresample -like /home/aurelien/ASL/Etude_TI/aal.mnc asl.mnc asl_resample.mnc
#mri_convert *t1* t1.mnc --out_orientation RAS

echo "c'est fini, taper entrée pour quitter"
read q
