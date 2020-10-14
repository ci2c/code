% List of open inputs
% Old Normalise: Write: Parameter File - cfg_files
% Old Normalise: Write: Images to Write - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/OldNormalizeWrite_SPM12_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Old Normalise: Write: Parameter File - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Old Normalise: Write: Images to Write - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
