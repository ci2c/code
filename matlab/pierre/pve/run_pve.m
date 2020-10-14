function run_pve(t1_path, pet_path, outdir, configfile, fsdir, labels)
% Performs PVE correction
%
% Usage : run_pve(t1_path, pet_path, outdir [, configfile, fsdir, labels])
% 
% Inputs :
%     t1_path          : path to T1 image (.nii or .img)
%     pet_path         : path to PET image (.nii or .img)
%     outdir           : output directory
%
% Option :
%     configfile       : path to the configuration file.
%         Default : SVN/matlab/pierre/pve/config_pvec
%     Intensity Normalization:
%       fsdir            : Freesurfer directory (Default: '')
%       labels           : label number of aparc.a2009s+aseg.mgz  (Default: -1)
%
% Pierre Besson @ CHRU Lille, Apr. 2012  
% Added: Intensity normalization, Renaud Lopes @ CHRU Lille, Nov. 2012

if nargin ~= 3 && nargin ~= 4 && nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

if nargin == 3
    HOME = getenv('HOME');
    configfile = [HOME, '/SVN/matlab/pierre/pve/config_pvec'];
end

% Step 0. Copy data
%         Check outdir
if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end

V = spm_vol(t1_path);
[Y, XYZ] = spm_read_vols(V);
V.fname = [outdir, '/t1.img'];
spm_write_vol(V, Y);

V = spm_vol(pet_path);
[Y, XYZ] = spm_read_vols(V);
V.fname = [outdir, '/pet.img'];
spm_write_vol(V, Y);

t1_path = [outdir, '/t1.img'];
pet_path = [outdir, '/pet.img'];


% Step 1. Register & resample PET to T1
%         Segment T1 using SPM8 new segment function

spm_jobman('initcfg');
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[t1_path ',1']};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pet_path ',1']};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
matlabbatch{2}.spm.tools.preproc8.channel.vols = {[t1_path ',1']};
matlabbatch{2}.spm.tools.preproc8.channel.biasreg = 0.0001;
matlabbatch{2}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{2}.spm.tools.preproc8.channel.write = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(1).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,1'};
matlabbatch{2}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{2}.spm.tools.preproc8.tissue(1).native = [1 0];
matlabbatch{2}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(2).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,2'};
matlabbatch{2}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{2}.spm.tools.preproc8.tissue(2).native = [1 0];
matlabbatch{2}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(3).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,3'};
matlabbatch{2}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{2}.spm.tools.preproc8.tissue(3).native = [1 0];
matlabbatch{2}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(4).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,4'};
matlabbatch{2}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{2}.spm.tools.preproc8.tissue(4).native = [1 0];
matlabbatch{2}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(5).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,5'};
matlabbatch{2}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{2}.spm.tools.preproc8.tissue(5).native = [1 0];
matlabbatch{2}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(6).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,6'};
matlabbatch{2}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{2}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{2}.spm.tools.preproc8.tissue(6).warped = [0 0];
matlabbatch{2}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{2}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{2}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{2}.spm.tools.preproc8.warp.write = [0 0];

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});

% Step 2. Remove NaN in rpet
V = spm_vol([outdir, '/rpet.img']);
[Y, XYZ] = spm_read_vols(V);
Y(~isfinite(Y(:))) = 0;
spm_write_vol(V, Y);

% Optional Step: Intensity Normalization
if nargin > 4
    
    cmd = sprintf('mri_convert %s %s --out_orientation LAS',fullfile(fsdir,'mri','aparc.a2009s+aseg.mgz'),fullfile(outdir,'label.nii'));
    unix(cmd);
    
    Vlab   = spm_vol(fullfile(outdir,'label.nii'));
    labvol = spm_read_vols(Vlab);
    Vpet   = spm_vol(fullfile(outdir,'rpet.img'));
    pet    = spm_read_vols(Vpet);
    dim    = size(pet);
    pet    = pet(:);
    ind    = [];
    for k = 1:length(labels)
        ind = [ind; find(labvol(:)==labels(k))];
    end
    nval = mean(pet(ind));
    pet  = pet ./ nval;
    pet  = reshape(pet,dim(1),dim(2),dim(3));
    spm_write_vol(Vpet, pet);
    
end

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
rpet_path  = [outdir, '/rpet.img'];
cmdline = ['/home/gregory/matlab/pvelab-20100419/IBB_wrapper/pve/pve -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', rpet_path, ' ', configfile];
fid = fopen([outdir '/cmdline.txt'], 'w');
fprintf(fid, '%s', cmdline);
fclose(fid);
disp('Performing PVEc. Please wait...');
[status, result] = unix(cmdline);

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
Vref = spm_vol([outdir '/rpet.img']);
Vsrc = spm_vol([outdir '/t1_MGRousset.img']);
Y = spm_read_vols(Vsrc);
Vsrc.mat = Vref.mat;
spm_write_vol(Vsrc, Y);