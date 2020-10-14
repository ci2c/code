function DARTEL_NormalizeMNI_VBM(InputDir, InputSubjectsFile)

% usage : DARTEL_NormalizeMNI_VBM((InputDir, InputSubjectsFile)
%
% Inputs :
%       InputDir           : Input working directory
%       InputSubjectsFile  : Input file containing list of subjects
%
%   Normalize grey matter segmented proba images to MNI space
%
% Matthieu Vanhoutte @ CHRU Lille, September 2016

% close all; clear all;

% InputDir = '/NAS/tupac/matthieu/DARTEL/DIS/DARTEL';
% InputSubjectsFile = '/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/subjects_TYPvsATYP.txt';

%% Open the text file containing subjects names
fid = fopen(InputSubjectsFile, 'r');
S = textscan(fid,'%s','delimiter','\n');
fclose(fid);

%% Creation of the cell of subjects to normalize to MNI space
NbFiles = size(S{1},1);
Cell_Sub_flowfield_class1 = cell(NbFiles,1);
Cell_Sub_class1 = cell(NbFiles,1);
for k= 1 : NbFiles 
    Cell_Sub_flowfield_class1{k,1} = fullfile(InputDir, [ 'u_rc1.T1.npet.' S{1}{k} '_DARTEL_Template.nii' ]);
    Cell_Sub_class1{k,1} = fullfile(InputDir, [ 'c1.T1.npet.' S{1}{k} '.nii' ]);
end

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Normalize gray matter class to MNI space ("Preserve Amount")
matlabbatch{end+1}.spm.tools.dartel.mni_norm.template = cellstr(fullfile(InputDir, 'DARTEL_Template_6.nii'));
matlabbatch{end}.spm.tools.dartel.mni_norm.data.subjs.flowfields = Cell_Sub_flowfield_class1;
matlabbatch{end}.spm.tools.dartel.mni_norm.data.subjs.images = { 
                                                                Cell_Sub_class1
								}';
matlabbatch{end}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{end}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                                NaN NaN NaN];
matlabbatch{end}.spm.tools.dartel.mni_norm.preserve = 1;
matlabbatch{end}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];

spm_jobman('run',matlabbatch);