function FMRI_CorsicaForNedica(datapath,nedfolder)

load(fullfile(nedfolder,'resClust.mat'),'resClust');
net_comps   = resClust.COI.num;
subjectlist = resClust.subjects;

for k = 1:length(subjectlist)
    
    meanfile  = fullfile(datapath,subjectlist{k},'fmri','spm','meanepi.nii');
    aparcfile = fullfile(datapath,subjectlist{k},'mri','aparc.a2009s+aseg.nii');
    if(~exist(aparcfile,'file'))
        tmpfile = fullfile(datapath,subjectlist{k},'mri','aparc.a2009s+aseg.mgz');
        cmd = sprintf('mri_convert %s %s',tmpfile,aparcfile);
        unix(cmd)
    end
    sicafile = fullfile(nedfolder,subjectlist{k},'sica.mat');
    
    load(sicafile);
    
    FMRI_Corsica(sica,meanfile,aparcfile,fullfile(datapath,subjectlist{k},'fmri','spm'),net_comps,resClust);
    
end