function FMRI_SeedConnectivityByGLM(dataroot,outdir,prefepi,covariates,seed,namecoi,TR)

%addpath('/home/global/matlab_toolbox/spm12b');

spm('defaults', 'FMRI');

spm_jobman('initcfg'); % SPM8 or spm12

f   = spm_select('FPList', dataroot, ['^' prefepi '.*\.nii$']);

matlabbatch{1}.spm.stats.fmri_spec.dir            = cellstr(outdir);
matlabbatch{1}.spm.stats.fmri_spec.timing.units   = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT      = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = editfilenames(f,'prefix','');

matlabbatch{1}.spm.stats.fmri_spec.sess.cond  = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};

cp = 0;
for k = 1:size(seed,2)
    cp = cp+1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cp).name = namecoi{k};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cp).val  = seed(:,k);
end
for k = 1:size(covariates,2)
    cp = cp+1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cp).name = ['cov' num2str(k)];
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cp).val  = covariates(:,k);
end

matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg   = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf         = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mask             = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';


if strcmp(spm('ver'),'SPM12')
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1)         = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals   = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical  = 1;

    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    for k=1:size(seed,2)
        vectmp    = zeros(1,size(seed,2));
        vectmp(k) = 1;
        matlabbatch{3}.spm.stats.con.consess{k}.tcon.name    = namecoi{k};
        matlabbatch{3}.spm.stats.con.consess{k}.tcon.weights = vectmp;
        matlabbatch{3}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
    end
    matlabbatch{3}.spm.stats.con.delete = 0;
    
elseif strcmp(spm('ver'),'SPM8')
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1)                      = cfg_dep;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname                = 'Select SPM.mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name  = 'filter';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname                = 'fMRI model specification: SPM.mat File';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch         = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output           = substruct('.','spmmat');
    matlabbatch{2}.spm.stats.fmri_est.method.Classical               = 1;

    matlabbatch{3}.spm.stats.con.spmmat(1)                      = cfg_dep;
    matlabbatch{3}.spm.stats.con.spmmat(1).tname                = 'Select SPM.mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name  = 'filter';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{3}.spm.stats.con.spmmat(1).sname                = 'Model estimation: SPM.mat File';
    matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch         = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{3}.spm.stats.con.spmmat(1).src_output           = substruct('.','spmmat');
    for k=1:size(seed,2)
        vectmp    = zeros(1,size(seed,2));
        vectmp(k) = 1;
        matlabbatch{3}.spm.stats.con.consess{k}.tcon.name    = namecoi{k};
        matlabbatch{3}.spm.stats.con.consess{k}.tcon.convec  = vectmp;
        matlabbatch{3}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
    end
    matlabbatch{3}.spm.stats.con.delete = 0;
    
end
    

spm_jobman('run',matlabbatch);


