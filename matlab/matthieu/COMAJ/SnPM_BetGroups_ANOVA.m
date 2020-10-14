% List of open inputs
% Between group ANOVA; 1 scan per subject: Scans - cfg_files
% Between group ANOVA; 1 scan per subject: Scans - cfg_files
% Between group ANOVA; 1 scan per subject: Scans - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/SnPM_BetGroups_ANOVA_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Between group ANOVA; 1 scan per subject: Scans - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Between group ANOVA; 1 scan per subject: Scans - cfg_files
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Between group ANOVA; 1 scan per subject: Scans - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
