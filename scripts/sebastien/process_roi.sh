#!/bin/bash

Dicom=$1

echo
echo "==================================="
echo "on va extraire des ROIs au pif"
echo "==================================="
indice=1

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results_32c.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_32c.txt
echo >> ${Dicom}/results_32c.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/pcasl_32/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_32c.txt
mincstats -mean -stddev ${Dicom}/pcasl_32/ASL32res.mnc -mask ${Dicom}/pcasl_32/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_32c.txt
echo >> ${Dicom}/results_32c.txt
indice=$[$indice+1]
done

indice=1001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results_32c.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_32c.txt
echo >> ${Dicom}/results_32c.txt
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/pcasl_32/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_32c.txt
mincstats -mean -stddev ${Dicom}/pcasl_32/ASL32res.mnc -mask ${Dicom}/pcasl_32/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_32c.txt
echo >> ${Dicom}/results_32c.txt
indice=$[$indice+1]
done

indice=2001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results_32c.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_32c.txt
echo >> ${Dicom}/results_32c.txt
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/pcasl_32/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_32c.txt
mincstats -mean -stddev ${Dicom}/pcasl_32/ASL32res.mnc -mask ${Dicom}/pcasl_32/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_32c.txt
echo >> ${Dicom}/results_32c.txt
indice=$[$indice+1]
done

indice=1

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results_32bmc.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_32bmc.txt
echo >> ${Dicom}/results_32bmc.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/pcasl_32/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_32bmc.txt
mincstats -mean -stddev ${Dicom}/pcasl_32/ASL32bmres.mnc -mask ${Dicom}/pcasl_32/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_32bmc.txt
echo >> ${Dicom}/results_32bmc.txt
indice=$[$indice+1]
done

indice=1001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results_32bmc.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_32bmc.txt
echo >> ${Dicom}/results_32bmc.txt
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/pcasl_32/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_32bmc.txt
mincstats -mean -stddev ${Dicom}/pcasl_32/ASL32bmres.mnc -mask ${Dicom}/pcasl_32/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_32bmc.txt
echo >> ${Dicom}/results_32bmc.txt
indice=$[$indice+1]
done

indice=2001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results_32bmc.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_32bmc.txt
echo >> ${Dicom}/results_32bmc.txt
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/pcasl_32/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_32bmc.txt
mincstats -mean -stddev ${Dicom}/pcasl_32/ASL32bmres.mnc -mask ${Dicom}/pcasl_32/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_32bmc.txt
echo >> ${Dicom}/results_32bmc.txt
indice=$[$indice+1]
done


indice=1

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results_star.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_star.txt
echo >> ${Dicom}/results_star.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/star/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_star.txt
mincstats -mean -stddev ${Dicom}/star/ASLstarres.mnc -mask ${Dicom}/star/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_star.txt
echo >> ${Dicom}/results_star.txt
indice=$[$indice+1]
done

indice=1001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results_star.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_star.txt
echo >> ${Dicom}/results_star.txt
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/star/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_star.txt
mincstats -mean -stddev ${Dicom}/star/ASLstarres.mnc -mask ${Dicom}/star/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_star.txt
echo >> ${Dicom}/results_star.txt
indice=$[$indice+1]
done

indice=2001

echo "resultats de l'analyse pour ${Dicom}">> ${Dicom}/results_star.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results_star.txt
echo >> ${Dicom}/results_star.txt
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}/mri/aparc+aseg.mnc ${Dicom}/mri/aparc+aseg.mnc -sample ${Dicom}/star/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results_star.txt
mincstats -mean -stddev ${Dicom}/star/ASLstarres.mnc -mask ${Dicom}/star/mask.mnc -mask_binvalue 1 >> ${Dicom}/results_star.txt
echo >> ${Dicom}/results_star.txt
indice=$[$indice+1]
done

indice=1

echo "resultats de l'analyse pour ${Dicom}_8c"> ${Dicom}_8c/results_8c.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}_8c/results_8c.txt
echo >> ${Dicom}_8c/results_8c.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}_8c/mri/aparc+aseg.mnc ${Dicom}_8c/mri/aparc+aseg.mnc -sample ${Dicom}_8c/pcasl_8/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}_8c/results_8c.txt
mincstats -mean -stddev ${Dicom}_8c/pcasl_8/ASL8res.mnc -mask ${Dicom}_8c/pcasl_8/mask.mnc -mask_binvalue 1 >> ${Dicom}_8c/results_8c.txt
echo >> ${Dicom}_8c/results_8c.txt
indice=$[$indice+1]
done

indice=1001

echo "resultats de l'analyse pour ${Dicom}_8c">> ${Dicom}_8c/results_8c.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}_8c/results_8c.txt
echo >> ${Dicom}_8c/results_8c.txt
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}_8c/mri/aparc+aseg.mnc ${Dicom}_8c/mri/aparc+aseg.mnc -sample ${Dicom}_8c/pcasl_8/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}_8c/results_8c.txt
mincstats -mean -stddev ${Dicom}_8c/pcasl_8/ASL8res.mnc -mask ${Dicom}_8c/pcasl_8/mask.mnc -mask_binvalue 1 >> ${Dicom}_8c/results_8c.txt
echo >> ${Dicom}_8c/results_8c.txt
indice=$[$indice+1]
done

indice=2001

echo "resultats de l'analyse pour ${Dicom}_8c">> ${Dicom}_8c/results_8c.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}_8c/results_8c.txt
echo >> ${Dicom}_8c/results_8c.txt
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask ${Dicom}_8c/mri/aparc+aseg.mnc ${Dicom}_8c/mri/aparc+aseg.mnc -sample ${Dicom}_8c/pcasl_8/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}_8c/results_8c.txt
mincstats -mean -stddev ${Dicom}_8c/pcasl_8/ASL8res.mnc -mask ${Dicom}_8c/pcasl_8/mask.mnc -mask_binvalue 1 >> ${Dicom}_8c/results_8c.txt
echo >> ${Dicom}_8c/results_8c.txt
indice=$[$indice+1]
done

echo |cat /home/aurelien/SVN/scripts/aurelien/troll_face
echo "Fuck yeah, Bastard c'est termine !!! Allez champion, va vite voir les resultats dans ${Dicom}"
read q
