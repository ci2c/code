function DARTELTemplate(InputDir, InputSubjectsFile)

% usage : DARTELTemplate(InputDir, InputSubjectsFile)
%
% Inputs :
%       InputDir           : Input working directory
%       InputSubjectsFile  : Input file containing list of subjects
%
%   Create DARTEL template
%
% Matthieu Vanhoutte @ CHRU Lille, Apr. 2016

% close all; clear all;

% InputDir = '/NAS/tupac/matthieu/DARTEL';
% InputSubjectsFile = '/NAS/tupac/matthieu/Classification/temp_MRI.txt';

%% Open the text file containing subjects names
fid = fopen(InputSubjectsFile, 'r');
S = textscan(fid,'%s','delimiter','\n');
fclose(fid);

%% Creation of the cell of subjects for create DARTEL template
NbFiles = size(S{1},1);
Cell_Sub_class1 = cell(NbFiles,1);
Cell_Sub_class2 = cell(NbFiles,1);
for k= 1 : NbFiles 
    Cell_Sub_class1{k,1} = fullfile(InputDir, [ 'rc1T1.npet.' S{1}{k} '.nii,1' ]);
    Cell_Sub_class2{k,1} = fullfile(InputDir, [ 'rc2T1.npet.' S{1}{k} '.nii,1' ]);
end

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Create Template with DARTEL
matlabbatch{end+1}.spm.tools.dartel.warp.images = {
                                                    Cell_Sub_class1
                                                    Cell_Sub_class2
                                                  }';
matlabbatch{end}.spm.tools.dartel.warp.settings.template = 'DARTEL_Template';
matlabbatch{end}.spm.tools.dartel.warp.settings.rform = 0;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{end}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{end}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{end}.spm.tools.dartel.warp.settings.optim.its = 3;

spm_jobman('run',matlabbatch);