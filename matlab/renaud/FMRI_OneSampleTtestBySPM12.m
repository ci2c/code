function FMRI_OneSampleTtestBySPM12(outdir,conFiles,nameCon,maskFile)

if nargin < 3
    disp('not enough arguments');
    return;
end

if nargin < 4
    maskFile = '';
end

spm('defaults', 'PET');

spm_jobman('initcfg'); % SPM8 or spm12

matlabbatch = {};

% DESIGN MATRIX
matlabbatch{end+1}.spm.stats.factorial_design.dir                  = cellstr(outdir);
matlabbatch{end}.spm.stats.factorial_design.des.t1.scans           = conFiles;
matlabbatch{end}.spm.stats.factorial_design.cov                    = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none     = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.im             = 0;
matlabbatch{end}.spm.stats.factorial_design.masking.em             = cellstr(maskFile);
matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit         = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm        = 1;

if strcmp(spm('ver'),'SPM12b')
    
    % ESTIMATE
    matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1)      = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{end}.spm.stats.fmri_est.write_residuals  = 0;
    matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;

    % CONTRAST
    matlabbatch{end+1}.spm.stats.con.spmmat(1)             = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{end}.spm.stats.con.consess{1}.tcon.name    = nameCon;
    matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{end}.spm.stats.con.delete                  = 0;

elseif strcmp(spm('ver'),'SPM8')
    
    % ESTIMATE
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1)                      = cfg_dep;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname                = 'Select SPM.mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name  = 'filter';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname                = 'Factorial design specification: SPM.mat File';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch         = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output           = substruct('.','spmmat');
    matlabbatch{2}.spm.stats.fmri_est.method.Classical               = 1;

    % CONTRAST
    matlabbatch{3}.spm.stats.con.spmmat(1)                      = cfg_dep;
    matlabbatch{3}.spm.stats.con.spmmat(1).tname                = 'Select SPM.mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name  = 'filter';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{3}.spm.stats.con.spmmat(1).sname                = 'Model estimation: SPM.mat File';
    matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch         = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{3}.spm.stats.con.spmmat(1).src_output           = substruct('.','spmmat');
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name           = nameCon;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec         = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep        = 'none';
    matlabbatch{3}.spm.stats.con.delete                         = 0;
    
end

spm_jobman('run',matlabbatch);
