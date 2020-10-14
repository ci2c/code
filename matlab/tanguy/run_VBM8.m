function run_VBM8(datapath)

warning('initialing spm')
spm('Defaults','fMRI');
spm_jobman('initcfg');


%% Working directory

warning('changing current directory :')
warning(datapath)
cd(datapath)

%% Select list of images in datapath

a = spm_select('FPList', datapath, '.nii');
list = cellstr(a(:,:))

list_m0wrp1=cell(size(list));
list_p=cell(size(list));
for i=1:length(list)
    [path,name,ext]=fileparts(list{i});
    list_m0wrp1{i}=[path '/m0wrp1' name ext];
    list_p{i}=[path '/p' name '_seg8.txt'];
end

%% Prepocessing batch

%% Bias correction, normalization and segmentation

%%
matlabbatch{1}.spm.tools.vbm8.estwrite.data = list;
%%
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii'};
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.ngaus = [2 2 2 3 4 2];
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg = 0.0001;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasfwhm = 60;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.affreg = 'mni';
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.warpreg = 4;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.samp = 3;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp.normhigh.darteltpm = {'/home/global/matlab_toolbox/spm8/toolbox/vbm8/Template_1_IXI550_MNI152.nii'};
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm = 2;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf = 0.15;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.print = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.modulated = 2;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.modulated = 2;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.modulated = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.warped = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.affine = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.native = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps = [0 0];

%% Smoothing



matlabbatch{2}.spm.spatial.smooth.data = list_m0wrp1;
matlabbatch{2}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';


%% Calcul raw volumes

matlabbatch{3}.spm.tools.vbm8.tools.calcvol.data         = cellstr(list_p);
matlabbatch{3}.spm.tools.vbm8.tools.calcvol.calcvol_name = 'raw_volumes.txt';

 
save(fullfile(datapath,'vbm8_processing.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
 
