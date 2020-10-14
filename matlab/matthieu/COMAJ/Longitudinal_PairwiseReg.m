function Longitudinal_PairwiseReg(InputDataM0, InputDataM12, InputTimeDiffFile, InputSubjectsFile)

% usage : Longitudinal_PairwiseReg(InputDataM0, InputDataM12, InputTimeDiffFile, InputSubjectsFile)
%
% Inputs :
%       InputDataM0            : Input directory of M0 T1 nifti images
%       InputDataM12           : Input directory of M12 T1 nifti images
%       InputTimeDiffFile      : Input file containing list of time
%                                differences (M12-M0) between subjects scan
%       InputSubjectsFile      : Input file containing list of subjects
%
%   Compute Longitudinal Pairwise Registration
%
% Matthieu Vanhoutte @ CHRU Lille, Feb. 2016

% close all; clear all;
% 
% InputDataM0 = '/NAS/tupac/protocoles/COMAJ/Aurelien/dartel/M0';
% InputDataM12 = '/NAS/tupac/protocoles/COMAJ/Aurelien/dartel/M12';
% InputTimeDiffFile = '/NAS/tupac/matthieu/Long_MRI/TimeDiff.txt';
% InputSubjectsFile = '/NAS/tupac/matthieu/Long_MRI/Subjects.txt';

%% Open the text file containing subjects names and time difference between
%% the two scans
fid = fopen(InputSubjectsFile, 'r');
S = textscan(fid,'%s','delimiter','\n');
fclose(fid);

fid = fopen(InputTimeDiffFile, 'r');
T = textscan(fid,'%s','delimiter','\n');
fclose(fid);

%% Creation of the cell of subjects for Longitudinal Pairwise Registration
NbFiles = size(S{1},1);
Cell_Sub_M0 = cell(NbFiles,1);
Cell_Sub_M12 = cell(NbFiles,1);
for k= 1 : NbFiles 
    Cell_Sub_M0{k,1} = fullfile(InputDataM0, [ S{1}{k} '_M0_T1.nii,1' ]);
    Cell_Sub_M12{k,1} = fullfile(InputDataM12, [ S{1}{k} '_M12_T1.nii,1' ]);
end

%% Creation of the time differences vector
TimeDiff = [];
for k= 1 : NbFiles 
    TimeDiff = [ TimeDiff str2num(T{1}{k}) ];
end

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Compute Longitudinal Pairwise Registration
matlabbatch{end+1}.spm.tools.longit{1}.pairwise.vols1 = Cell_Sub_M0;
matlabbatch{end}.spm.tools.longit{1}.pairwise.vols2 = Cell_Sub_M12;
matlabbatch{end}.spm.tools.longit{1}.pairwise.tdif = TimeDiff;
matlabbatch{end}.spm.tools.longit{1}.pairwise.noise = NaN;
matlabbatch{end}.spm.tools.longit{1}.pairwise.wparam = [0 0 100 25 100];
matlabbatch{end}.spm.tools.longit{1}.pairwise.bparam = 1000000;
matlabbatch{end}.spm.tools.longit{1}.pairwise.write_avg = 1;
matlabbatch{end}.spm.tools.longit{1}.pairwise.write_jac = 1;
matlabbatch{end}.spm.tools.longit{1}.pairwise.write_div = 1;
matlabbatch{end}.spm.tools.longit{1}.pairwise.write_def = 1;

spm_jobman('run',matlabbatch);