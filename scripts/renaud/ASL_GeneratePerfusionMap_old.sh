#! /bin/bash

SUBJECTS_DIR=/home/notorious/NAS/pierre/Epilepsy/FreeSurfer5.0/Patients_fmri_dti
SUBJ=Bourgeois_Aurelie
asldir=asltest2
ASL=${SUBJECTS_DIR}/${SUBJ}/asl.nii

DIR=${SUBJECTS_DIR}/${SUBJ}

subMethod=2

# =====================================================================================
#                                 Preprocess
# =====================================================================================

echo "cp ${ASL} ${DIR}/${asldir}/asl.nii"
cp ${ASL} ${DIR}/${asldir}/asl.nii
ASL=${DIR}/${asldir}/asl.nii

echo "mkdir ${DIR}/${asldir}/split"
mkdir ${DIR}/${asldir}/split

echo "fslsplit ${ASL} ${DIR}/${asldir}/split/ -t"
fslsplit ${ASL} ${DIR}/${asldir}/split/ -t

# Calibration scan
echo "calibration scan..."
cp ${DIR}/${asldir}/split/0000.nii.gz ${DIR}/${asldir}/aslcal.nii.gz
gunzip ${DIR}/${asldir}/aslcal.nii.gz

# Registration of calibration scan to anatomical space
echo "Registration of calibration scan to anatomical space"
bbregister --init-fsl --mov ${DIR}/${asldir}/aslcal.nii --t1 --s ${SUBJ} --reg ${DIR}/${asldir}/aslcal.reg

# Perform transformation
echo "Perform transformation" 
mri_vol2vol --mov ${DIR}/${asldir}/aslcal.nii --reg ${DIR}/${asldir}/aslcal.reg --fstarg --o ${DIR}/${asldir}/aslcal.anat.nii --interp nearest --no-save-reg

# Motion correct ASL acquisition
echo "Motion correct ASL acquisition"
mri_convert ${ASL} --mid-frame ${DIR}/${asldir}/asl.template.nii
mcflirt -reffile ${DIR}/${asldir}/asl.template.nii -in ${ASL} -o ${DIR}/${asldir}/asl.mc -mats -plots

# Registration fo ASL to anatomical space
echo "Registration fo ASL to anatomical space"
bbregister --init-fsl --mov ${DIR}/${asldir}/asl.template.nii --t1 --s ${SUBJ} --reg ${DIR}/${asldir}/asl.reg

# Generate slice offset
echo "Generate slice offset"
mri_volsynth --temp ${DIR}/${asldir}/asl.template.nii --vol ${DIR}/${asldir}/temp.nii
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	p = pathdef;
	addpath(p);
	
	temp = MRIread('${DIR}/${asldir}/temp.nii'); 
	for i = 1:temp.depth 
	  temp.vol(:,:,i) = i-1; 
	end; 
	MRIwrite(temp, '${DIR}/${asldir}/slc_offset.nii');
	
EOF

# =====================================================================================
#                          Difference image (dM) calculation
# =====================================================================================

# Exclude first 4 frames
echo "Exclude first 4 frames"
set list = `ls ${DIR}/${asldir}/split -1 --color=never | grep vol0 | grep -v 0000 | grep -v 0001 |grep -v 0002 |grep -v 0003`
fslmerge -t ${DIR}/${asldir}/asl.mc.nii.gz $list

# Perform control-tag calculations
echo "Perform control-tag calculations"
if [ ${subMethod} -eq 1 ]
then
  
  echo "Basic subtraction"
  mri_glmfit --y ${DIR}/${asldir}/asl.mc.nii.gz --asl --glmdir ${DIR}/${asldir}/glmfit --nii
  cp -f ${DIR}/${asldir}/glmfit/perfusion/gamma.nii ${DIR}/${asldir}/dM.nii.gz
  
else

  echo "Surround subtraction"

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

  % Load Matlab Path
  p = pathdef;
  addpath(p);
  
  [hdr,vol] = niak_read_vol('${DIR}/${asldir}/asl.mc.nii.gz');
  
  perfno=size(vol,4);
  conidx = 1:2:2*perfno;
  labidx = 2:2:2*perfno;
  
  meanPERFimg=zeros(size(vol,1),size(vol,2),size(vol,3));
  for p=1:perfno
      Vlabimg = vol(:,:,:,labidx(p));
      Vconimg = vol(:,:,:,conidx(p));
      if p<perfno
	  Vconimg = (Vconimg+squeeze(vol(:,:,:,conidx(p+1))))/2;
      end
      perfimg=Vconimg-Vlabimg;
      meanPERFimg=meanPERFimg+perfimg;
  end
  
  meanPERFimg=meanPERFimg./perfno;
  
  hdr.file_name = '${DIR}/${asldir}/dM.nii.gz';
  niak_write_vol(hdr,meanPERFimg);
  
EOF

fi


# =====================================================================================
#                             CBF map calculation
# =====================================================================================

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

  % Load Matlab Path
  p = pathdef;
  addpath(p);
  
  scalefactor=0.98/exp(0.014/0.0442);
  mo = MRIread('${DIR}/${asldir}/aslcal.nii');  
  mo.vol = mo.vol./scalefactor; 
  MRIwrite(mo, '${DIR}/${asldir}/M0a.nii.gz'); 
  
EOF


