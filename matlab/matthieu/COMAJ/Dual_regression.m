clear all; close all;

fsdir = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53';

fid = fopen(fullfile(fsdir,'RS_fmri_AD.txt'),'r');
Lad = textscan(fid,'%s');
fclose(fid);

fid = fopen(fullfile(fsdir,'RS_fmri_EOAD.txt'),'r');
Leoad = textscan(fid,'%s');
fclose(fid);

X = zeros(length(Lad{1})+length(Leoad{1}),2);
X(1:length(Lad{1}),1) = 1;
X(length(Lad{1})+1:end,2) = 1;

save(fullfile(fsdir,'design.mat'),'X','-ascii');

Con = [1 -1;-1 1];
save(fullfile(fsdir,'design.con'),'Con','-ascii');