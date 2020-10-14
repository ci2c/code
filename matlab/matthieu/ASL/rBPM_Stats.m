clear all; close all;

% get, read in SPM.mat
mat = fullfile('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA', 'SPM.mat');
load(mat);

tmaplh_file = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/lh.spmT_0001.fsaverage.mgh';
tmaprh_file = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/rh.spmT_0001.fsaverage.mgh';

Data = SurfStatReadData({tmaplh_file,tmaprh_file});
% Data_lh = SurfStatReadData(tmaplh_file);
% Surflh_file = '/home/global/freesurfer/subjects/fsaverage/surf/lh.pial';
% Surf_lh = SurfStatReadSurf(Surflh_file);
% Surfrh_file = '/home/global/freesurfer/subjects/fsaverage/surf/rh.pial';
% Surf_rh = SurfStatReadSurf(Surfrh_file);
% 
% thresV = 0.01;
% 
% tMap = Data;
% df   = SPM.xX.erdf;
% P    = 1-cdf('T',tMap(:),df)';
% 
% Pspm = spm_Tcdf(tMap,df);
% 
% Pres = double(P<thresV).*tMap;
% 
% fnumleft = size(Surf_lh.tri,1);
% nbleft   = size(Surf_lh.coord,2);
% fnumright = size(Surf_rh.tri,1);
% nbright   = size(Surf_rh.coord,2);
% 
% % SurfStatWriteData('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/lh.Pmap1.fsaverage.mgh',P(1:length(Data_lh))','b');
% % SurfStatWriteData('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/rh.Pmap1.fsaverage.mgh',P(length(Data_lh)+1:end)','b');
% 
% Reslh_file = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/lh.Pmap1.fsaverage';
% Resrh_file = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/rh.Pmap1.fsaverage';
% write_curv(Reslh_file,Pres(1:length(Data_lh))',fnumleft);
% write_curv(Resrh_file,Pres(length(Data_lh)+1:end)',fnumright);
% 
% stmaplh_file = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/lh.PmapThres1.fsaverage';
% cluslh_file  = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/lh.PmapClus1.fsaverage';
% [clus,peak,clusid] = FMRI_SurfCluster(Surflh_file,Reslh_file,tmaplh_file,0.001,150,cluslh_file,stmaplh_file);
% 
% stmaprh_file = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/rh.PmapThres1.fsaverage';
% clusrh_file  = '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/rh.PmapClus1.fsaverage';
% [clus,peak,clusid] = FMRI_SurfCluster(Surfrh_file,Resrh_file,tmaprh_file,0.001,150,clusrh_file,stmaprh_file);
% 
% % % pmapasllhFile = '/home/fatmike/sebastien/ASL_TEP/lh.TEP_hypo_fwhm10_tMapAll.pVal';
% % % pmapaslrhFile = '/home/fatmike/sebastien/ASL_TEP/rh.TEP_hypo_fwhm10_tMapAll.pVal'; 
% % % pmap_lh = SurfStatReadData(pmapasllhFile);
% % % pmap_rh = SurfStatReadData(pmapaslrhFile);
% % % 
% % % pmapr_lh = SurfStatReadData(stmaplh_file);
% % % pmapr_rh = SurfStatReadData(stmaprh_file);
% % % 
% % % pmap_lh = double(pmap_lh<0.05).*pmapr_lh;
% % % pmap_rh = double(pmap_rh<0.05).*pmapr_rh;
% % % write_curv('/home/fatmike/sebastien/ASL_TEP/BPM_analysis/lh.PmapThres005.fsaverage',pmap_lh,fnumleft);
% % % write_curv('/home/fatmike/sebastien/ASL_TEP/BPM_analysis/rh.PmapThres005.fsaverage',pmap_rh,fnumright);

% Compute the FDR Q values
% slm.t    = 1 x v vector of test statistics, v=#vertices.
% slm.df   = degrees of freedom.
% slm.dfs  = 1 x v vector of optional effective degrees of freedom.
% slm.k    = #variates.
% mask     = 1 x v logical vector, 1=inside, 0=outside, 
%          = ones(1,v), i.e. the whole surface, by default.

slm.t = Data;
slm.df   = SPM.xX.erdf;
slm.k   = 1;

load('/home/matthieu/SVN/medial_wall.mat');

qval = SurfStatQ( slm, ~Mask );

Qval_thresh = double(zeros(1,length(qval.Q)));
idx = find(qval.Q <= 0.5);
Qval_thresh(idx) = (1-qval.Q(idx));
Qval_thresh_lh = Qval_thresh(1:163842);
Qval_thresh_rh = Qval_thresh(163843:327684);
SurfStatWriteData('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/lh.FDR_0.5_map1', Qval_thresh_lh , 'b');
SurfStatWriteData( '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BPM_analysis/ANCOVA/rh.FDR_0.5_map1', Qval_thresh_rh , 'b' );
