function DARTEL_NormalizeMNI(InputDir, InputSubjectsFile)

% usage : DARTEL_NormalizeMNI(InputDir, InputSubjectsFile)
%
% Inputs :
%       InputDir           : Input working directory
%       InputSubjectsFile  : Input file containing list of subjects
%
%   Normalize PVC PET images to MNI space
%
% Matthieu Vanhoutte @ CHRU Lille, May 2016

% close all; clear all;

% InputDir = '/NAS/tupac/matthieu/DARTEL';
% InputSubjectsFile = '/NAS/tupac/matthieu/Classification/temp_MRI.txt';

%% Open the text file containing subjects names
fid = fopen(InputSubjectsFile, 'r');
S = textscan(fid,'%s','delimiter','\n');
fclose(fid);

%% Creation of the cell of subjects to normalize PVC PET INorm (gn, ncereb, npons) to MNI space
NbFiles = size(S{1},1);
Cell_Sub_flowfield_class1 = cell(NbFiles,1);
Cell_Sub_gn = cell(NbFiles,1);
Cell_Sub_ncereb = cell(NbFiles,1);
Cell_Sub_npons = cell(NbFiles,1);
for k= 1 : NbFiles 
    Cell_Sub_flowfield_class1{k,1} = fullfile(InputDir, [ 'u_rc1.T1.npet.' S{1}{k} '_DARTEL_Template.nii' ]);
    Cell_Sub_gn{k,1} = fullfile(InputDir, 'DISvsCN', [ 'PET.sm8.MGRousset.gn.mask.' S{1}{k} '.nii' ]);
    Cell_Sub_ncereb{k,1} = fullfile(InputDir, 'DISvsCN', [ 'PET.sm8.MGRousset.ncereb.mask.' S{1}{k} '.nii' ]);
    Cell_Sub_npons{k,1} = fullfile(InputDir, 'DISvsCN', [ 'PET.sm8.MGRousset.npons.mask.' S{1}{k} '.nii' ]);
end

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Normalize gray matter class modulated by jacobian rate to MNI space
matlabbatch{end+1}.spm.tools.dartel.mni_norm.template = cellstr(fullfile(InputDir, 'DARTEL_Template_6.nii'));
matlabbatch{end}.spm.tools.dartel.mni_norm.data.subjs.flowfields = Cell_Sub_flowfield_class1;
matlabbatch{end}.spm.tools.dartel.mni_norm.data.subjs.images = { 
                                                                Cell_Sub_gn
                                                                Cell_Sub_ncereb
                                                                Cell_Sub_npons
								}';
matlabbatch{end}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{end}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                                NaN NaN NaN];
matlabbatch{end}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{end}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];

spm_jobman('run',matlabbatch);