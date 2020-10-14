function conn_on_roi(epi,roi,meanfmri,output)
% Computing connectivity on ROI
% Tanguy Hamel @ CHRU Lille, 2014
%%
% TESTING
%%
%epi='/home/tanguy/temp/Nicolas/tmp_seed12/AK123/fmri_12/csvraepi.nii';
%roipath='/home/tanguy/temp/Nicolas/tmp_seed12/AK123/fconn/seed/native'
%roiname='putamen.nii';
%M='/home/tanguy/temp/Nicolas/tmp_seed12/AK123/fmri_12/meanafmri.nii';
%output='/home/tanguy/temp/Nicolas/tmp_seed12/AK123/fconn/seed/native/conn_corsica';

%%
% Computing connectivity on ROI
% Tanguy Hamel @ CHRU Lille, 2014



%% verif


%% arguments preparation

[roipath,roiname,roiext]=fileparts(roi);
roiname=[roiname roiext];




%% Load volumes (epi & roi)

disp(['loading epi' epi])
V=spm_vol(epi);
epi=spm_read_vols(V);
[a b c d]=size(epi);

disp(['loading ROI' roi])
Vroi=spm_vol(roi);
roivol=spm_read_vols(Vroi);

%% 
idx=find(roivol(:)>0);
epi=reshape(epi,a*b*c,d);
seed=mean(epi(idx,:),1);

%% 

conn=corr(epi',seed');
id=find(isnan(conn));

conn(id)=0;
conn=reshape(conn,[a b c]);

%% computing zscore
zconn=0.5 * log( (1+conn)./(1-conn) );


%% Writing volumes (conn & zscore) for roi
Vmean=spm_vol(meanfmri);
Vmean.fname=[output '/C_' roiname];
size(conn)
Vmean
spm_write_vol(Vmean,conn)
Vmean.fname=[output '/zC_' roiname];
spm_write_vol(Vmean,zconn)


