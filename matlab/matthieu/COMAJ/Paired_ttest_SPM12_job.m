function Paired_ttest_SPM12_job(InputDir, InputSubjectsFile, PVC, Recon, fwhmvol)

% usage : Paired_ttest_SPM12_job(InputDir, InputSubjectsFile, PVC, Recon)
%
% Inputs :
%       InputDir           : Input working directory
%       InputSubjectsFile  : Input file containing list of subjects
%       PVC                : String expliciting the use or not of PVC
%       Recon              : Input file containing list of subjects
%       fwhmvol            : Size of the 3D smoothing
%
%   Paired t-test between PET reconstructions
%
% Matthieu Vanhoutte @ CHRU Lille, August 2017

%% Open the text file containing subjects names
fid = fopen(InputSubjectsFile, 'r');
S = textscan(fid,'%s','delimiter','\n');
fclose(fid);
NbFiles = size(S{1},1);

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Compute Paired T-test design %%
matlabbatch{end+1}.spm.stats.factorial_design.dir = cellstr(fullfile(InputDir,'SPM', [ Recon '_fwhm' fwhmvol '_' PVC ]));
for k= 1 : NbFiles
	if strcmp(PVC,'noPVC')==1
		matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(k).scans = {
										  fullfile(InputDir, 'PET', PVC, 'OT_i2s21_g2', [ 'sm' fwhmvol '.wPET.gn.' S{1}{k} '.nii,1' ]);
										  fullfile(InputDir, 'PET', PVC, Recon, [ 'sm' fwhmvol '.wPET.gn.' S{1}{k} '.nii,1' ]);
										  };
	elseif strcmp(PVC,'PVC')==1
		matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(k).scans = {
										  fullfile(InputDir, 'PET', PVC, 'OT_i2s21_g2', [ 'sm' fwhmvol '.wPET.MGRousset.gn.' S{1}{k} '.nii,1' ])
										  fullfile(InputDir, 'PET', PVC, Recon, [ 'sm' fwhmvol '.wPET.MGRousset.gn.' S{1}{k} '.nii,1' ])
										  };
	end
end
matlabbatch{end}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{end}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{end}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
if strcmp(PVC,'noPVC')==1
	matlabbatch{end}.spm.stats.factorial_design.masking.em = { fullfile(InputDir,'Template','MNI152_T1_brain_mask.nii,1') };
elseif strcmp(PVC,'PVC')==1
	matlabbatch{end}.spm.stats.factorial_design.masking.em = { fullfile(InputDir,'Template','Mask_GM_MNI.nii,1') };
end
matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;

%% Estimate parameters %%
matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
 
%% Define contrasts %%
matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'Target > Source';
matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [1 -1 zeros(1,NbFiles)];
matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'Source > Target';
matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [-1 1 zeros(1,NbFiles)];
matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{end}.spm.stats.con.delete = 0;
 
spm_jobman('run',matlabbatch);