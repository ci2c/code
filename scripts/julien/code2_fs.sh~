#!/bin/bash

echo '
 

*******************************************************************************
*******************************************************************************
****************************** CODE 2 *****************************************
*******************************************************************************
*******************************************************************************
'

subj=$1


dcm2nii -o /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/ /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*


mv /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*s3DT1TFE* /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/t1.nii

mv /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*RUN1FONCSENSE* /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/run01.nii

mv /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*RUN2FONCSENSE* /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/run02.nii

mv /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*DTI32DIRSENSE* /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/dti.nii

mv /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*correctiondti* /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/dti_cor.nii

mv /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/*FE_EPI64x64* /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/rsfmri.nii

#qbatch -q fs_q -oe /home/louise/NAS/Louise/sophie/CODE2/log/ -N fs_${subj} recon-all -all -sd /home/notorious/NAS/Louise/sophie/CODE2/FS50 -subjid ${subj} -nuintensitycor-3T -i /home/notorious/NAS/Louise/sophie/CODE2/subjects/${subj}/t1.nii

echo '
done !
'
