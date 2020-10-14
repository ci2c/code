function FMRI_TemplateNormalization(spmDir,prefmean,prefepi)

meanFile = spm_select('FPList', spmDir, ['^' prefmean '.*\.nii$']);
epiFiles = spm_select('FPList', spmDir, ['^' prefepi '.*\.nii$']);

a = which('spm_normalise');
[path] = fileparts(a);

VG      = fullfile(path,'templates','EPI.nii');
VF      = meanFile;
matname = '';
VWG     = '';
VWF     = '';
opt_normalize.estimate.smosrc  = 8;
opt_normalize.estimate.smoref  = 0;
opt_normalize.estimate.regtype = 'mni';
opt_normalize.estimate.weight  = '';
opt_normalize.estimate.cutoff  = 25;
opt_normalize.estimate.nits    = 16;
opt_normalize.estimate.reg     = 1;
opt_normalize.estimate.wtsrc   = 0;

if ~exist(fullfile(spmDir,'param_normalize.mat'))
    params_normalize = spm_normalise(VG,VF,matname,VWG,VWF,opt_normalize.estimate);
    save(fullfile(spmDir,'param_normalize.mat'),'params_normalize');
else
    load(fullfile(spmDir,'param_normalize.mat'),'params_normalize');
end

opt_normalize.write.preserve = 0;
opt_normalize.write.bb       = [-78 -112 -50 ; 78 76 85];
opt_normalize.write.vox      = [3 3 3];   
opt_normalize.write.interp   = 3;
opt_normalize.write.wrap     = [0 0 0];

warning('off')
spm_write_sn(meanFile,params_normalize,opt_normalize.write);
for k = 1:size(epiFiles,1)
    spm_write_sn(epiFiles(k,:),params_normalize,opt_normalize.write);
end
