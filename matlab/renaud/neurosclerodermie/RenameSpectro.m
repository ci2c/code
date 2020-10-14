clear all; close all;

%% A DEFINIR

subjdir  = '/NAS/dumbo/protocoles/neurosclerodermie/471018CM310513^X_2013-05-31';
t1File   = fullfile(subjdir,'t1.nii');


%% PROCESS...

outdir   = fullfile(subjdir,'spectro');

fsdat=rdir(fullfile(subjdir,'*act.SDAT'));
fspar=rdir(fullfile(subjdir,'*act.SPAR'));

% create output folder
if ~exist(outdir,'dir')
    cmd = sprintf('mkdir %s',outdir);
    unix(cmd);
end

if length(fsdat)~=length(fspar)
    disp('pas le même nombre de fichier spar et sdat')
    return;
end

for k = 1:length(fsdat)
    
    sdatFile = fsdat(k).name;
    sparFile = fspar(k).name;
    
    MRS_struct = GannetMask_Philips(sparFile,t1File);

    roiname = input('Localisation : ','s');

    % copy spectro
    sdatFile1 = fullfile(outdir,[roiname '.SDAT']); 
    sparFile1 = fullfile(outdir,[roiname '.SPAR']);
    if exist(sdatFile1,'file')
        cmd = sprintf('rm -f %s',sdatFile1);
        unix(cmd);
    end
    if exist(sparFile1,'file')
        cmd = sprintf('rm -f %s',sparFile1);
        unix(cmd);
    end
    cmd = sprintf('cp -rf %s %s',sdatFile,sdatFile1);
    unix(cmd);
    cmd = sprintf('cp -rf %s %s',sparFile,sparFile1);
    unix(cmd);

    % copy mask
    maskFile = fullfile(outdir,[roiname '_mask.nii']);
    if exist(maskFile,'file')
        cmd = sprintf('rm -f %s',maskFile);
        unix(cmd);
    end
    [p,n,e] = fileparts(sdatFile);
    cmd = sprintf('mv %s %s',fullfile(p,[n '_mask.nii']),maskFile);
    unix(cmd);
    
end
