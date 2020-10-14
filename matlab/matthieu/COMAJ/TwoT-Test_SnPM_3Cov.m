% List of open inputs
% 2 Groups: Two Sample T test; 1 scan per subject: Vector - cfg_entry
% 2 Groups: Two Sample T test; 1 scan per subject: Name - cfg_entry
% 2 Groups: Two Sample T test; 1 scan per subject: Vector - cfg_entry
% 2 Groups: Two Sample T test; 1 scan per subject: Name - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/TwoT-Test_SnPM_3Cov_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % 2 Groups: Two Sample T test; 1 scan per subject: Vector - cfg_entry
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % 2 Groups: Two Sample T test; 1 scan per subject: Name - cfg_entry
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % 2 Groups: Two Sample T test; 1 scan per subject: Vector - cfg_entry
    inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % 2 Groups: Two Sample T test; 1 scan per subject: Name - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
