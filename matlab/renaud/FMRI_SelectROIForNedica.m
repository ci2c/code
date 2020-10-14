function FMRI_SelectROIForNedica(nedfolder,datapath,sizeVox,csize,cdist)

load(fullfile(nedfolder,'resClust.mat'),'resClust');

subjectlist = resClust.subjects;

if nargin < 6
    cdist = 30;
end
if nargin < 5
    csize = 30;
end
if nargin < 4
    sizeVox = [3 3 3];
end

resClust = FMRI_SelectROI(datapath,subjectlist,'fmri/spm',resClust,sizeVox,csize,cdist);

save(fullfile(nedfolder,'resClust.mat'),'resClust');