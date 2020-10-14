function SegmentAvgSubject_SPM12(InputDataM0, Subject)

% usage : SegmentAvgSubject_SPM12(InputDataM0, Subject)
%
% Inputs :
%       InputDataM0            : Input working directory
%       Subject                : Name of the subject
%
%   Segment the average subject outputed from Longitudinal Pairwise Registration
%
% Matthieu Vanhoutte @ CHRU Lille, Feb. 2016

% close all; clear all;
% 
% InputDataM0 = '/NAS/tupac/protocoles/COMAJ/Aurelien/dartel/M0';

%% Creation of the average subject name
AvgSubjectName = cellstr(fullfile(InputDataM0, [ 'avg_' Subject '_M0_T1.nii,1' ]));

%% Init of spm_jobman
spm('defaults', 'FMRI');
spm_jobman('initcfg');
matlabbatch={};

%% Segment the average subject
matlabbatch{end+1}.spm.spatial.preproc.channel.vols = AvgSubjectName;
matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{end}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,1'};
matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,2'};
matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,3'};
matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,4'};
matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,5'};
matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,6'};
matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{end}.spm.spatial.preproc.warp.write = [0 0];

spm_jobman('run',matlabbatch);
