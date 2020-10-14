% List of open inputs
% Factorial design specification: Name - cfg_entry
% Factorial design specification: Levels - cfg_entry
% Factorial design specification: Levels - cfg_entry
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Levels - cfg_entry
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Levels - cfg_entry
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Name - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/home/matthieu/SVN/matlab/matthieu/COMAJ/FullFactorialDesign_SPM8_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(10, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Name - cfg_entry
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Levels - cfg_entry
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Levels - cfg_entry
    inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Scans - cfg_files
    inputs{5, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Levels - cfg_entry
    inputs{6, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Scans - cfg_files
    inputs{7, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Levels - cfg_entry
    inputs{8, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Scans - cfg_files
    inputs{9, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Vector - cfg_entry
    inputs{10, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Name - cfg_entry
end
spm('defaults', 'PET');
spm_jobman('serial', jobs, '', inputs{:});
