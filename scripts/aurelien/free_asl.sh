#!/bin/bash

SD=$1
SUBJ=$2

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}


dcm2nii -g n -o ${DIR} ${DIR}/*rec
rm -fr ${DIR}/co*3dt1*.nii
rm -fr ${DIR}/o*3dt1*.nii
rm -fr ${DIR}/o*t13d*.nii
rm -fr ${DIR}/co*t13d*.nii
echo
echo
for te in `ls ${DIR}`
do
if [ -d $te ]
then
	dcm2nii -o $DIR/$te $DIR/$te/*
fi

mkdir -p ${DIR}/mri/orig
mkdir ${DIR}/asl ${DIR}/pet
for d in `ls ${DIR}/*3dt1*.nii`
do
cp ${d} ${DIR}/3dt1.nii
done

for i in `ls ${DIR}/*star*.nii`
do
echo
echo "========================="
echo "correction du volume $i"
echo "========================="
echo
index=`echo $i |sed -n "/star/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${Dicom}/raw_ASL_recal_${index}.nii 0
fslmaths ${Dicom}/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${Dicom}/Vol_2_mean.nii.gz -sub ${Dicom}/Vol_1_mean.nii.gz ${Dicom}/mean.nii.gz
gunzip ${Dicom}/mean.nii.gz
gunzip ${Dicom}/Vol_1_mean.nii.gz
echo
echo

echo "Recalage ASL sur T1..."
echo
echo
matlab -nodisplay <<EOF >> ${Dicom}/recalage_SPM.log
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${Dicom}

matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {'${Dicom}/3dt1.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {'${Dicom}/mean.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 2;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

nrun = 1;
inputs = cell(0, nrun);
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF


echo
echo "========================="
echo "conversion des fichiers"
echo "========================="
echo

for d in `ls ${Dicom}/*3dt1*.nii`
do
mri_convert ${d} ${Dicom}/3dt1.mnc
done

for f in `ls ${Dicom}/*t13d*.nii`
do
mri_convert ${f} ${Dicom}/3dt1.mnc
done

mri_convert ${Dicom}/rmean.nii ${Dicom}/rmean.mnc --out_orientation RAS
echo "================="
echo "On fait des trucs"
echo "================="

cp ${Dicom}/3dt1.mnc ${Dicom}/mri/orig
mri_convert ${Dicom}/mri/orig/3dt1.mnc ${Dicom}/mri/orig/001.mgz --out_orientation RAS
rm ${Dicom}/mri/orig/3dt1.mnc
recon-all -all -subjid ${subj} -sd ${study} -nuintensitycor-3T
recon-all -qcache -subjid ${subj} -sd ${study}
mri_convert ${study}/${subj}/mri/aparc+aseg.mgz ${study}/${subj}/mri/aparc+aseg.mnc -odt int
mincresample -like ${Dicom}/3dt1.mnc ${Dicom}/rmean.mnc ${Dicom}/asl_to_t1.mnc -clobber
echo
echo "===================================="
echo "Calcul des cartos et others shits..."
echo "===================================="
echo
matlab -nodisplay <<EOF >> ${Dicom}/surf_log
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${Dicom}
Mz=load_nifti('Vol_1_mean.nii');
deltaM0=load_nifti('mean.nii');
aslcarto=aslmap(Mz.vol,deltaM0.vol);
deltaM0.vol=aslcarto;
save_nifti(deltaM0,'${Dicom/ASL.nii}');
EOF

echo
echo "==================================="
echo "on va extraire des ROIs au pif"
echo "==================================="
indice=1

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask /home/aurelien/ASL/Etude_TI/aal.mnc /home/aurelien/ASL/Etude_TI/aal.mnc -sample ${Dicom}/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results.txt

mincstats -mean -stddev ${Dicom}/asl_to_t1.mnc -mask ${Dicom}/mask.mnc -mask_binvalue 1 >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
indice=$[$indice+1]
done
indice=1001
while [ ${indice} -le 1035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask /home/aurelien/ASL/Etude_TI/aal.mnc /home/aurelien/ASL/Etude_TI/aal.mnc -sample ${Dicom}/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results.txt

mincstats -mean -stddev ${Dicom}/asl_to_t1.mnc -mask ${Dicom}/mask.mnc -mask_binvalue 1 >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
indice=$[$indice+1]
done
indice=2001
while [ ${indice} -le 2035 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask /home/aurelien/ASL/Etude_TI/aal.mnc /home/aurelien/ASL/Etude_TI/aal.mnc -sample ${Dicom}/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results.txt

mincstats -mean -stddev ${Dicom}/asl_to_t1.mnc -mask ${Dicom}/mask.mnc -mask_binvalue 1 >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
indice=$[$indice+1]
done

nline=`cat /tmp/stderr |wc -l`
if [ $nline -gt 3 ]
then
echo |cat /home/aurelien/SVN/scripts/aurelien/rage_guy
echo "Fuck No !!! Y'a une erreur, Va vite voir ce qui s'est passé dans /tmp/stderr"
else
echo |cat /home/aurelien/SVN/scripts/aurelien/fyeah
echo "Fuck yeah, c'est termine !!! Allez champion, va vite voir les resultats dans ${Dicom}"
fi
echo
echo "taper entrée pour quitter"
read q
echo "Kthxbye"
