% List of open inputs
% Normalise: Estimate: Data - cfg_repeat
% Normalise: Estimate: Template Image - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/NormalizeEstimate_SPM8_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Normalise: Estimate: Data - cfg_repeat
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Normalise: Estimate: Template Image - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
