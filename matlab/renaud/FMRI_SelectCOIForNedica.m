function FMRI_SelectCOIForNedica(nedfolder,opt_choice,TempDir)

if nargin < 2
    opt_choice = 'auto';
end
if nargin < 3
    TempDir = '/home/renaud/SVN/matlab/renaud/noi_templates';
end

load(fullfile(nedfolder,'resClust.mat'),'resClust');

resClust = FMRI_SelectInterestClasses(nedfolder,TempDir,resClust,opt_choice);

save(fullfile(nedfolder,'resClust.mat'),'resClust');
