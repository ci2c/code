#!/bin/bash

Dicom=$1


echo
echo "===================================="
echo "Calcul des cartos et others shits..."
echo "===================================="
echo
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

Mz32=MRIread('${Dicom}/pcasl_32/Vol_1_mean.nii');
Mz8=MRIread('${Dicom}_8c/pcasl_8/Vol_1_mean.nii');
Mzstar=MRIread('${Dicom}/star/Vol_1_mean.nii');
deltaM032=MRIread('${Dicom}/pcasl_32/diff_map32.nii');
deltaM08=MRIread('${Dicom}_8c/pcasl_8/diff_map8.nii');
deltaM0star=MRIread('${Dicom}/star/diff_mapstar.nii');
aslcarto8=aslmapseb(Mz8.vol,deltaM08.vol);
aslcarto32=aslmapseb(Mz32.vol,deltaM032.vol);
aslcartostar=aslmapseb(Mzstar.vol,deltaM0star.vol);
aslcarto8(isnan(aslcarto8))=0;
aslcarto32(isnan(aslcarto32))=0;
aslcartostar(isnan(aslcartostar))=0;
aslcarto32(isinf(aslcarto32))=0;
aslcarto8(isinf(aslcarto8))=0;
aslcartostar(isinf(aslcartostar))=0;
aslcarto32(aslcarto32<-1000)=0;
aslcarto32(aslcarto32>1000)=0;
aslcarto8(aslcarto8<-1000)=0;
aslcarto8(aslcarto8>1000)=0;
aslcartostar(aslcartostar<-1000)=0;
aslcartostar(aslcartostar>1000)=0;
deltaM032.vol=aslcarto32;
deltaM08.vol=aslcarto8;
deltaM0star.vol=aslcartostar;
MRIwrite(deltaM08,'${Dicom}_8c/pcasl_8/ASL8.nii','float');
MRIwrite(deltaM032,'$Dicom/pcasl_32/ASL32.nii','float');
MRIwrite(deltaM0star,'$Dicom/star/ASLstar.nii','float');

deltaM032=MRIread('${Dicom}/pcasl_32/diff_map32.nii');
Imax=max(Mz32.vol(:));
tresh=0.05*Imax;
mask=Mz32.vol > tresh;
zorro=mask.*deltaM032.vol;
aslcarto32bm=aslbm3d(Mz32.vol,zorro);
aslcarto32bm(isnan(aslcarto32bm))=0;
aslcarto32bm(isinf(aslcarto32bm))=0;
aslcarto32bm(aslcarto32bm<-1000)=0;
aslcarto32bm(aslcarto32bm>1000)=0;
deltaM032.vol=aslcarto32bm;
%V=spm_vol('${Dicom}/pcasl_32/Vol_1_mean.nii');
%[Y, XYZ] = spm_read_vols(V);
%Y_out = aslcarto32bm;
%V.fname='${Dicom}/pcasl_32/asl_carto_32_bm.nii';
%V_out = spm_write_vol(V, Y_out);
MRIwrite(deltaM032,'$Dicom/pcasl_32/ASL32bm.nii','float');
EOF

mri_convert $Dicom/pcasl_32/ASL32bm.nii $Dicom/pcasl_32/ASL32bm.mnc
mri_convert ${Dicom}_8c/pcasl_8/ASL8.nii ${Dicom}_8c/pcasl_8/ASL8.mnc
mri_convert $Dicom/pcasl_32/ASL32.nii $Dicom/pcasl_32/ASL32.mnc
mri_convert $Dicom/star/ASLstar.nii $Dicom/star/ASLstar.mnc
mri_convert $Dicom/mri/aparc+aseg.mgz $Dicom/mri/aparc+aseg.mnc
mri_convert ${Dicom}_8c/mri/aparc+aseg.mgz ${Dicom}_8c/mri/aparc+aseg.mnc
mri_convert ${Dicom}/mri/T1.mgz $Dicom/mri/T1.mnc
mri_convert ${Dicom}_8c/mri/T1.mgz ${Dicom}_8c/mri/T1.mnc
mri_convert ${Dicom}/pcasl_32/Vol_1_mean.nii ${Dicom}/pcasl_32/Vol_1_mean.mnc
mri_convert ${Dicom}/star/Vol_1_mean.nii ${Dicom}/star/Vol_1_mean.mnc
mri_convert ${Dicom}_8c/pcasl_8/Vol_1_mean.nii ${Dicom}_8c/pcasl_8/Vol_1_mean.mnc
mritoself ${Dicom}/pcasl_32/Vol_1_mean.mnc $Dicom/mri/T1.mnc $Dicom/mri/trans32 -clobber
mritoself ${Dicom}_8c/pcasl_8/Vol_1_mean.mnc ${Dicom}_8c/mri/T1.mnc ${Dicom}_8c/mri/trans8 -clobber
mritoself ${Dicom}/star/Vol_1_mean.mnc $Dicom/mri/T1.mnc $Dicom/mri/transstar

mincresample -like $Dicom/mri/aparc+aseg.mnc -transformation ${Dicom}/mri/trans32.xfm $Dicom/pcasl_32/ASL32.mnc $Dicom/pcasl_32/ASL32res.mnc -clobber
mincresample -like $Dicom/mri/aparc+aseg.mnc -transformation ${Dicom}/mri/trans32.xfm $Dicom/pcasl_32/ASL32bm.mnc $Dicom/pcasl_32/ASL32bmres.mnc -clobber
mincresample -like $Dicom/mri/aparc+aseg.mnc -transformation $Dicom/mri/transstar.xfm $Dicom/star/ASLstar.mnc $Dicom/star/ASLstarres.mnc -clobber
mincresample -like ${Dicom}_8c/mri/aparc+aseg.mnc -transformation ${Dicom}_8c/mri/trans8.xfm ${Dicom}_8c/pcasl_8/ASL8.mnc ${Dicom}_8c/pcasl_8/ASL8res.mnc -clobber


