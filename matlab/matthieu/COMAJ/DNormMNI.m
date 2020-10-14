% List of open inputs
% Normalise to MNI Space: Dartel Template - cfg_files
% Normalise to MNI Space: Select according to - cfg_choice
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/DNormMNI_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Normalise to MNI Space: Dartel Template - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Normalise to MNI Space: Select according to - cfg_choice
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
