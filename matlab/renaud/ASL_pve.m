function ASL_pve(t1_path, asl_path, outdir, configfile)

% Performs PVE correction
%
% Usage : ASL_pve(t1_path, pet_path, outdir [, configfile])
% 
% Inputs :
%     t1_path          : path to T1 image (.nii or .img)
%     asl_path         : path to ASL image (.nii or .img)
%     outdir           : output directory
%
% Option :
%     configfile       : path to the configuration file.
%         Default : SVN/matlab/pierre/pve/config_pvec
%
% Renaud Lopes @ CHRU Lille, Mar. 2014

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin == 3
    HOME = getenv('HOME');
    configfile = [HOME, '/SVN/matlab/pierre/pve/config_pvec'];
end

clear matlabbatch
matlabbatch={};

% Step 0. Copy data
%         Check outdir
if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end

V = spm_vol(t1_path);
[Y, XYZ] = spm_read_vols(V);
V.fname = [outdir, '/t1.img'];
spm_write_vol(V, Y);

V = spm_vol(asl_path);
[Y, XYZ] = spm_read_vols(V);
V.fname = [outdir, '/rasl.img'];
spm_write_vol(V, Y);

t1_path = [outdir, '/t1.img'];
pet_path = [outdir, '/rasl.img'];


% Step 1. Segment T1 using SPM

a = spm('version');
a = a(1:4);
if strcmp(a,'SPM8')
    
    matlabbatch{end+1}.spm.tools.preproc8.channel.vols = {[t1_path ',1']};
    matlabbatch{end}.spm.tools.preproc8.channel.biasreg = 0.0001;
    matlabbatch{end}.spm.tools.preproc8.channel.biasfwhm = 60;
    matlabbatch{end}.spm.tools.preproc8.channel.write = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(1).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,1'};
    matlabbatch{end}.spm.tools.preproc8.tissue(1).ngaus = 2;
    matlabbatch{end}.spm.tools.preproc8.tissue(1).native = [1 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(1).warped = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(2).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,2'};
    matlabbatch{end}.spm.tools.preproc8.tissue(2).ngaus = 2;
    matlabbatch{end}.spm.tools.preproc8.tissue(2).native = [1 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(2).warped = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(3).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,3'};
    matlabbatch{end}.spm.tools.preproc8.tissue(3).ngaus = 2;
    matlabbatch{end}.spm.tools.preproc8.tissue(3).native = [1 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(3).warped = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(4).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,4'};
    matlabbatch{end}.spm.tools.preproc8.tissue(4).ngaus = 3;
    matlabbatch{end}.spm.tools.preproc8.tissue(4).native = [1 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(4).warped = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(5).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,5'};
    matlabbatch{end}.spm.tools.preproc8.tissue(5).ngaus = 4;
    matlabbatch{end}.spm.tools.preproc8.tissue(5).native = [1 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(5).warped = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(6).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,6'};
    matlabbatch{end}.spm.tools.preproc8.tissue(6).ngaus = 2;
    matlabbatch{end}.spm.tools.preproc8.tissue(6).native = [0 0];
    matlabbatch{end}.spm.tools.preproc8.tissue(6).warped = [0 0];
    matlabbatch{end}.spm.tools.preproc8.warp.reg = 4;
    matlabbatch{end}.spm.tools.preproc8.warp.affreg = 'mni';
    matlabbatch{end}.spm.tools.preproc8.warp.samp = 3;
    matlabbatch{end}.spm.tools.preproc8.warp.write = [0 0];
    
else
    
    matlabbatch{end+1}.spm.spatial.preproc.channel.vols   = {[t1_path ',1']};
    matlabbatch{end}.spm.spatial.preproc.channel.biasreg  = 0.001;
    matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{end}.spm.spatial.preproc.channel.write    = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,1'};
    matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus  = 1;
    matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,2'};
    matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus  = 1;
    matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,3'};
    matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus  = 2;
    matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,4'};
    matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus  = 3;
    matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,5'};
    matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus  = 4;
    matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,6'};
    matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus  = 2;
    matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{end}.spm.spatial.preproc.warp.mrf         = 1;
    matlabbatch{end}.spm.spatial.preproc.warp.cleanup     = 1;
    matlabbatch{end}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
    matlabbatch{end}.spm.spatial.preproc.warp.affreg      = 'mni';
    matlabbatch{end}.spm.spatial.preproc.warp.fwhm        = 0;
    matlabbatch{end}.spm.spatial.preproc.warp.samp        = 3;
    matlabbatch{end}.spm.spatial.preproc.warp.write       = [0 0];
    
end
    
spm_jobman('run',matlabbatch);

% Step 2. Remove NaN in rasl
V = spm_vol([outdir, '/rasl.img']);
[Y, XYZ] = spm_read_vols(V);
Y(~isfinite(Y(:))) = 0;
spm_write_vol(V, Y);

% Step 3. Rescale prob maps to [0 255]
%         Rename them to _segN.img
%         Create _GMROI.img
Vt1   = spm_vol(t1_path);
Vseg1 = spm_vol([outdir, '/c1t1.nii']);
Vseg2 = spm_vol([outdir, '/c2t1.nii']);
Vseg3 = spm_vol([outdir, '/c3t1.nii']);
delete([outdir, '/c4t1.nii']);
delete([outdir, '/c5t1.nii']);

[Y1, XYZ] = spm_read_vols(Vseg1);
[Y2, XYZ] = spm_read_vols(Vseg2);
[Y3, XYZ] = spm_read_vols(Vseg3);

Y1 = Y1 * 255;
Y2 = Y2 * 255;
Y3 = Y3 * 255;

Y_roi = 51 * double(Y1 > 127.5) + 2 * double(Y2 > 127.5) + 3 * double(Y3 > 127.5);
Vt1.dt = [2 0];

Vt1.fname = [outdir, '/t1_seg1.img'];
spm_write_vol(Vt1, Y1);
Vt1.fname = [outdir, '/t1_seg2.img'];
spm_write_vol(Vt1, Y2);
Vt1.fname = [outdir, '/t1_seg3.img'];
spm_write_vol(Vt1, Y3);

Vt1.fname = [outdir, '/t1_GMROI.img'];
spm_write_vol(Vt1, Y_roi);

% Step 4. Launch pve
mni = round(Vt1.dim(3) / 3);
gmROI_path = [outdir, '/t1_GMROI.img'];
rasl_path  = [outdir, '/rasl.img'];
cmdline = ['/home/gregory/matlab/pvelab-20100419/IBB_wrapper/pve/pve -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', rasl_path, ' ', configfile];
fid = fopen([outdir '/cmdline.txt'], 'w');
fprintf(fid, '%s', cmdline);
fclose(fid);
disp('Performing PVEc. Please wait...');
result = system(cmdline);

% Step 5. Modify header to correct for misalignment
% clear matlabbatch;
% matlabbatch{1}.spm.spatial.coreg.estimate.ref = {[outdir '/t1_GMROI.img,1']};
% matlabbatch{1}.spm.spatial.coreg.estimate.source = {[outdir '/t1_MGRousset.img,1']};
% matlabbatch{1}.spm.spatial.coreg.estimate.other = {
%                                                    [outdir '/t1_Meltzer.img,1']
%                                                    [outdir '/t1_Occu_MG.img,1']
%                                                    [outdir '/t1_Occu_Meltzer.img,1']
%                                                    [outdir '/t1_Virtual_PET.img,1']
%                                                    };
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
% matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% 
% inputs = cell(0, 1);
% spm('defaults', 'PET');
% spm_jobman('serial', matlabbatch, '', inputs{:});
