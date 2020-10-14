#!/bin/bash

Dicom=$1

echo
echo "==================================="
echo "on va extraire des ROIs au pif"
echo "==================================="
indice=1

mkdir ${Dicom}/results
mri_convert ${Dicom}/mri/aparc+aseg.mgz ${Dicom}/mri/aparc+aseg.mnc
mri_convert ${Dicom}/asl/pve_out/t1_MGRousset.img ${Dicom}/asl/asl_MGRousset.mnc

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results/results.txt
echo >> ${Dicom}/results/results.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/mri/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results/results.txt
mincstats -mean -stddev ${Dicom}/asl/asl_MGRousset.mnc -mask ${Dicom}/mri/mask.mnc -mask_binvalue 1 >> ${Dicom}/results/results.txt
echo >> ${Dicom}/results/results.txt
indice=$[$indice+1]
done

indice=1001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results/results.txt
echo >> ${Dicom}/results/results.txt
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/mri/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results/results.txt
mincstats -mean -stddev ${Dicom}/asl/asl_MGRousset.mnc -mask ${Dicom}/mri/mask.mnc -mask_binvalue 1 >> ${Dicom}/results/results.txt
echo >> ${Dicom}/results/results.txt
indice=$[$indice+1]
done

indice=2001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results/results.txt
echo >> ${Dicom}/results/results.txt
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/mri/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results/results.txt
mincstats -mean -stddev ${Dicom}/asl/asl_MGRousset.mnc -mask ${Dicom}/mri/mask.mnc -mask_binvalue 1 >> ${Dicom}/results/results.txt
echo >> ${Dicom}/results/results.txt
indice=$[$indice+1]
done

echo "Allez champion, va vite voir les resultats dans ${Dicom}/results"
read q
