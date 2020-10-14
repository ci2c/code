#!/bin/bash

SD=$1
SUBJ=$2

DIR="${SD}/${SUBJ}"

mri_convert $DIR/mri/aparc+aseg.mgz $DIR/mri/aparc.mnc
echo
echo "Recalage PET"
echo
T1=`ls $DIR/pet/pve_pet/ |grep -i r_t1001.img` 
mri_convert $DIR/pet/pve_pet/$T1 $DIR/pet/T1pet.mnc
mri_convert $DIR/pet/pve_pet/r_volume_MGRousset.img $DIR/pet/rPET.mnc
mri_convert $DIR/mri/orig/001.mgz $DIR/mri/orig/orig.mnc
mritoself -far $DIR/pet/T1pet.mnc $DIR/mri/orig/orig.mnc $DIR/pet/transtoinit -clobber
mincresample -like $DIR/mri/aparc.mnc -transformation $DIR/pet/transtoinit.xfm $DIR/pet/rPET.mnc $DIR/pet/PETrecal.mnc -clobber
echo
echo "Recalage ASL"
echo
mri_convert $DIR/asl/pve_asl/$T1 $DIR/asl/T1asl.mnc
mri_convert $DIR/asl/pve_asl/r_volume_MGRousset.img $DIR/asl/rASL.mnc
mritoself -far $DIR/asl/T1asl.mnc $DIR/mri/orig/orig.mnc $DIR/asl/transtoinit -clobber
mincresample -like $DIR/mri/aparc.mnc -transformation $DIR/asl/transtoinit.xfm $DIR/asl/rASL.mnc $DIR/asl/ASLrecal.mnc -clobber

echo "resultats de l'analyse pour ${DIR}/asl"> ${DIR}/asl/ASLresults.txt
echo "Date de l'analyse : `date +%F`" >> ${DIR}/asl/ASLresults.txt
echo "resultats de l'analyse pour ${DIR}/pet"> ${DIR}/pet/PETresults.txt
echo "Date de l'analyse : `date +%F`" >> ${DIR}/pet/PETresults.txt
echo >> ${DIR}/asl/ASLresults.txt
echo >> ${DIR}/pet/PETresults.txt

indice=1

while [ ${indice} -le 86 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask $DIR/mri/aparc.mnc $DIR/mri/aparc.mnc -sample ${DIR}/mri/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${DIR}/asl/ASLresults.txt
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${DIR}/pet/PETresults.txt
mincstats -mean -stddev ${DIR}/asl/ASLrecal.mnc -mask ${DIR}/mri/mask.mnc -mask_binvalue 1 >> ${DIR}/asl/ASLresults.txt
mincstats -mean -stddev ${DIR}/pet/PETrecal.mnc -mask ${DIR}/mri/mask.mnc -mask_binvalue 1 >> ${DIR}/pet/PETresults.txt
echo >> ${DIR}/asl/ASLresults.txt
echo >> ${DIR}/pet/PETresults.txt
indice=$[$indice+1]
done

indice=1001
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask $DIR/mri/aparc.mnc $DIR/mri/aparc.mnc -sample ${DIR}/mri/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${DIR}/asl/ASLresults.txt
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${DIR}/pet/PETresults.txt
mincstats -mean -stddev ${DIR}/asl/ASLrecal.mnc -mask ${DIR}/mri/mask.mnc -mask_binvalue 1 >> ${DIR}/asl/ASLresults.txt
mincstats -mean -stddev ${DIR}/pet/PETrecal.mnc -mask ${DIR}/mri/mask.mnc -mask_binvalue 1 >> ${DIR}/pet/PETresults.txt
echo >> ${DIR}/asl/ASLresults.txt
echo >> ${DIR}/pet/PETresults.txt
indice=$[$indice+1]
done
indice=2001
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask $DIR/mri/aparc.mnc $DIR/mri/aparc.mnc -sample ${DIR}/mri/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${DIR}/asl/ASLresults.txt
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${DIR}/pet/PETresults.txt
mincstats -mean -stddev ${DIR}/asl/ASLrecal.mnc -mask ${DIR}/mri/mask.mnc -mask_binvalue 1 >> ${DIR}/asl/ASLresults.txt
mincstats -mean -stddev ${DIR}/pet/PETrecal.mnc -mask ${DIR}/mri/mask.mnc -mask_binvalue 1 >> ${DIR}/pet/PETresults.txt
echo >> ${DIR}/asl/ASLresults.txt
echo >> ${DIR}/pet/PETresults.txt
indice=$[$indice+1]
done

Surface_feat.sh $SD $SUBJ
