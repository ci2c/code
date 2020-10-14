function matlabbatch = T1_DartelCreateTemplate(rc1FileList,rc2FileList)

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

matlabbatch{1,1}.spm.tools.dartel.warp.images{1,1} = rc1FileList;
matlabbatch{1,1}.spm.tools.dartel.warp.images{1,2} = rc2FileList;

matlabbatch{1,1}.spm.tools.dartel.warp.settings.template        = 'Template';
matlabbatch{1,1}.spm.tools.dartel.warp.settings.rform           = 0;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(1).its    = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(1).K      = 0;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(1).slam   = 16;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(2).its    = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(2).K      = 0;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(2).slam   = 8;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(3).its    = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(3).K      = 1;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(3).slam   = 4;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(4).its    = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(4).K      = 2;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(4).slam   = 2;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(5).its    = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(5).K      = 4;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(5).slam   = 1;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(6).its    = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(6).K      = 6;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.param(6).slam   = 0.5;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.optim.lmreg     = 0.01;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.optim.cyc       = 3;
matlabbatch{1,1}.spm.tools.dartel.warp.settings.optim.its       = 3;

fprintf(['Running DARTEL: Create Template.\n']);
spm_jobman('run',matlabbatch);
