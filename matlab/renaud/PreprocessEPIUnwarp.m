function PreprocessEPIUnwarp(corfile,type,shift)

% usage : nrrd2nii(corfile, shift)
%
% Inputs :
%       corfile       : path to reverse image
%       shift         : 1 if shift, 0 elsewhere (Default: 0)
%       type          : 'ASL' or 'FMRI' or 'DTI' (Default: 'FMRI')
%
% Renaud Lopes @ CHRU Lille, Jan. 2013

if nargin < 1
    error('invalid usage');
end

if nargin < 3
    shift = 0;
end
if nargin < 2
    type = 'FMRI';
end

% Shit epi volume
if (shift == 1)
    V         = spm_vol(corfile);
    vol       = spm_read_vols(V);
    vol1      = vol;
    if (strcmp(type,'ASL'))
        vol1(:,1:end-1,:) = vol(:,2:end,:);
    elseif (strcmp(type,'FMRI') || strcmp(type,'DTI'))
        vol1(1:end-1,:,:) = vol(2:end,:,:);
    end
    [path,name,ext] = fileparts(corfile);
    shiftfile = fullfile(path,['s' name ext]);
    V.fname   = shiftfile; 
    spm_write_vol(V,vol1);
    corfile   = shiftfile;
end

% Reorient epi volume
spm('Defaults','fMRI');
spm_jobman('initcfg'); 
matlabbatch = {};
matlabbatch{1}.spm.util.reorient.srcfiles         = {corfile};
if (strcmp(type,'ASL'))
    matlabbatch{1}.spm.util.reorient.transform.transM = [-1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
elseif (strcmp(type,'FMRI') || strcmp(type,'DTI'))
    matlabbatch{1}.spm.util.reorient.transform.transM = [1 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 1];
end
matlabbatch{1}.spm.util.reorient.prefix           = 'r';
spm_jobman('run',matlabbatch);
