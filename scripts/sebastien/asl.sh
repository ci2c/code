#!/bin/bash

study=$1
subj=$2
Dicom="$study/$subj"

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
t1map=MRIread('$Dicom/despot/carto.nii');
delta8=MRIread('$Dicom/pcasl_8/diff_map8.nii');
delta32=MRIread('$Dicom/pcasl_32/diff_map32.nii');
deltastar=MRIread('$Dicom/star/diff_mapstar.nii');
Mz8=MRIread('$Dicom/pcasl_8/Vol_1_mean.nii');
Mz32=MRIread('$Dicom/pcasl_32/Vol_1_mean.nii');
Mzstar=MRIread('$Dicom/star/Vol_1_mean.nii');
aslcarto8=aslmap(Mz8.vol,delta8.vol);
aslcarto32=aslmap(Mz32.vol,delta32.vol);
aslcartostar=aslmap(Mzstar.vol,deltastar.vol);
aslcarto(isnan(aslcarto))=0;
aslcarto(isinf(aslcarto))=0;
deltaM0.vol=aslcarto;
MRIwrite(deltaM0,'ASL.nii');
EOF

