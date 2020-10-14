function outfile = ConvertParToNifti(parFile,outdir,outname,r2apath)

if nargin ~= 2 && nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin < 3
    outname = 'fmri.nii';
end

if nargin == 4
    addpath(genpath(r2apath));
end

if ~exist(outdir,'dir')
    cmd = sprintf('mkdir %s',outdir);
    unix(cmd);
end

% Convert to nifti
[pathpar,name,ext] = fileparts(parFile);
pathpar            = [pathpar '/'];
filelist{1}        = [name ext];

options.subaan        = 0;
options.usealtfolder  = 0;
options.altfolder     = '';
options.prefix        = 'epi';
options.pathpar       = pathpar;
options.angulation    = 1;
options.rescale       = 1;
options.usefullprefix = 0;
options.outputformat  = 1;
options.dim           = 4;
options.dti_revertb0  = 0;

outfile = convert_r2a(filelist,options);

cmd = sprintf('mv %s %s','dyn*.nii',outname);
unix(cmd);