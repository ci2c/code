function DARTEL_Templates(varargin)

spm_jobman('initcfg'); % SPM8 only

NbImgType = size(varargin,2)/2;

CellGM = cell(NbImgType,1);
CellWM = cell(NbImgType,1);

index=1;
for k= 1 : 2 : (size(varargin,2)-1) 
    t=varargin(k);
    CellGM{index,1} =t{1};
    clear t
    t=varargin(k+1);
    CellWM{index,1} = t{1};
    clear t
    index=index+1;
end

matlabbatch{1}.spm.tools.dartel.warp.images = {CellGM CellWM};
matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;

mat_its = 3*ones(6,1);
mat_rparam = [4 2 1e-06;2 1 1e-06;1 0.5 1e-06;0.5 0.25 1e-06;0.25 0.125 1e-06;0.25 0.125 1e-06];
mat_K = [0 0 1 2 4 6];
mat_slam = [16 8 4 2 1 0.5];
for k=1:6
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(k).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(k).rparam = mat_rparam(k,:);
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(k).K = mat_K(k);
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(k).slam = mat_slam(k);
end

matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

fprintf('DARTEL_Template Setup: OK');
fprintf('\n')

spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);