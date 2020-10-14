% List of open inputs
% Segment: Volumes - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/DARTEL_SegSubject_SPM12_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Segment: Volumes - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
