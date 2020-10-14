clear all; close all;

% dataroot = '/home/fatmike/renaud/alexis/data_ju';
fsdir    = '/home/matthieu/NAS/matthieu/Alexithymie';
rem_beg  = 5;
outname  = '/home/matthieu/SPM';
TR       = 2.4;

%% AR 28

subj = 'AR28';
datapath = fullfile(fsdir,subj);
load(fullfile(fsdir,subj,['sots_' subj '.mat']),'sot'); 
Alexis_FirstLevelSPM(datapath,outname,rem_beg,sot,TR)
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);


% %% CD15
% 
% subj    = 'CD15';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% DG21
% 
% subj    = 'DG21';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% ED24
% 
% subj    = 'ED24';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% EH23
% 
% subj    = 'EH23';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% GM13
% 
% subj    = 'GM13';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% HB20
% 
% subj    = 'HB20';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% HB27
% 
% subj    = 'HB27';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% ID19
% 
% subj    = 'ID19';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% IS17
% 
% subj    = 'IS17';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% JN26
% 
% subj    = 'JN26';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% LG10
% 
% subj    = 'LG10';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% NC12
% 
% subj    = 'NC12';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% NR22
% 
% subj    = 'NR22';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% SG18
% 
% subj    = 'SG18';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% SL25
% 
% subj    = 'SL25';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% SL29
% 
% subj    = 'SL29';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% SM07
% 
% subj    = 'SM07';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);
% 
% 
% %% VC04
% 
% subj    = 'VC04';
% datapath = fullfile(fsdir,subj,'fmri');
% load(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
% RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR);

