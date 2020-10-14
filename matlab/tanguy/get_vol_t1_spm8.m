function [v_sg,v_sb,v_lcr,v_it]=get_vol_t1_spm8(anatpath)

% This function calculates the volume of gray matter, white matter, CSF and
% the intracranial volume of a subject.
%
% The first step is the T1 segmentation (with SPM8)
% The second one allows to calculate the volumes and write the txt file
% Tanguy Hamel @ CHRU Lille, 2014


%% T1 segmentation

T1=fullfile(anatpath,'t1.nii');
disp(['T1 file :' T1]);

disp('runing SPM8 segmentation')
disp('segment_t1_by_SPM8(T1)')


segment_t1_by_SPM8(T1)

%% Calculating volumes


% On genere le facteur en fonction du T1
v_T1=spm_vol([anatpath '/t1.nii']);
factor=(abs(det(v_T1.mat)))/1000;

%On charge les masques 
l_v_sg = spm_read_vols(spm_vol(fullfile(anatpath,'/c1t1.nii')));
l_v_sb = spm_read_vols(spm_vol(fullfile(anatpath,'/c2t1.nii')));
l_v_lcr = spm_read_vols(spm_vol(fullfile(anatpath,'/c3t1.nii')));

% Calcul des volumes
v_sg = factor*sum(l_v_sg(:));
v_sb = factor*sum(l_v_sb(:));
v_lcr = factor*sum(l_v_lcr(:));
v_it = v_sg + v_sb + v_lcr;




