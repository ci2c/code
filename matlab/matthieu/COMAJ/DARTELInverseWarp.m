function DARTELInverseWarp(InputDir, InputSubjectsFile)

% usage : DARTELInverseWarp(InputDir, InputSubjectsFile)
%
% Inputs :
%       InputDir           : Input working directory
%       InputSubjectsFile  : Input file containing list of subjects
%
%   Create Inverse Warp of GM mask to each PET subject space
%
% Matthieu Vanhoutte @ CHRU Lille, May 2016

% close all; clear all;

% InputDir = '/NAS/tupac/matthieu/DARTEL';
% InputSubjectsFile = '/NAS/tupac/matthieu/Classification/temp_MRI.txt';

%% Open the text file containing subjects names
fid = fopen(InputSubjectsFile, 'r');
S = textscan(fid,'%s','delimiter','\n');
fclose(fid);

%% Creation of the cell of subjects' GM flow fields
NbFiles = size(S{1},1);
Cell_Sub_FF = cell(NbFiles,1);
for k= 1 : NbFiles 
    Cell_Sub_FF{k,1} = fullfile(InputDir, [ 'u_rc1.T1.npet.' S{1}{k} '_DARTEL_Template.nii' ]);
end

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Inverse Warped of GM mask onto each subject PET space
matlabbatch{end+1}.spm.tools.dartel.crt_iwarped.flowfields = Cell_Sub_FF;
matlabbatch{end}.spm.tools.dartel.crt_iwarped.images = { fullfile(InputDir, 'Mask_GM', 'Mask_GM.nii') };
matlabbatch{end}.spm.tools.dartel.crt_iwarped.K = 6;
matlabbatch{end}.spm.tools.dartel.crt_iwarped.interp = 0;

spm_jobman('run',matlabbatch);