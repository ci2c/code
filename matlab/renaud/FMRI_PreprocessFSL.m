function FMRI_PreprocessFSL(t1File,epiFile,outdir,fwhm,fslpath)

% usage : FMRI_PreprocessFSL(t1File,epiFile,outdir,[fwhm,fslpath])
%
% Inputs :
%    t1File        : nii file (T1-weighted scan)
%    epiFile       : nii file (fMRI scan)
%    outdir        : output folder
%
% Options :
%    fwhm          : motion parameters or txt file (Default: 6)
%    fslpath       : path to FSL folder (Default: '/home/global/fsl')
%
% Renaud Lopes @ CHRU Lille, Apr 2013

if nargin < 4
    fwhm = 6;
end
if nargin < 5
    fslpath = '/home/global/fsl'
end

% Check directory
if exist(outdir,'dir')
    rmdir(outdir);
end
mkdir(outdir);

sigma = fwhm/2.3548;

% Copy data
cmd = sprintf('cp -f %s %s',t1File,fullfile(outdir,'anat.nii'));
unix(cmd);
cmd = sprintf('cp -f %s %s',epiFile,fullfile(outdir,'fmri.nii'));
unix(cmd);

%--------------------------------------------------------------------------
%                          T1 processing
%--------------------------------------------------------------------------

% skull strip T1
cmd = sprintf('bet %s %s -R -f 0.4',fullfile(outdir,'anat.nii'),fullfile(outdir,'anat_brain'));
unix(cmd);

% segmentation
cmd = sprintf('fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -o %s %s',fullfile(outdir,'anat_brain'),fullfile(outdir,'anat_brain'));
unix(cmd);

%--------------------------------------------------------------------------
%                        FMRI preprocessing
%--------------------------------------------------------------------------

% Extract ref volume
V        = spm_vol(fullfile(outdir,'fmri.nii'));
refframe = floor(length(V)/2);

cmd = sprintf('fslmaths %s %s -odt float',fullfile(outdir,'fmri.nii'),fullfile(outdir,'fmri_prefilt'));
unix(cmd);
cmd = sprintf('fslroi %s %s %f 1',fullfile(outdir,'fmri_prefilt'),fullfile(outdir,'fmri_ref'),refframe);
unix(cmd);

% Motion correction
cmd = sprintf('mcflirt -in %s -out %s -mats -plots -refvol %f -rmsrel -rmsabs',fullfile(outdir,'fmri_prefilt'),fullfile(outdir,'fmri_prefilt_mc'),refframe);
unix(cmd);
cmd = sprintf('fsl_tsplot -i %s -t "MCFLIRT estimated rotations (radians)" -u 1 --start=1 --finish=3 -a x,y,z -w 640 -h 144 -o %s',fullfile(outdir,'fmri_prefilt_mc.par'),fullfile(outdir,'rot.png'));
unix(cmd);
cmd = sprintf('fsl_tsplot -i %s -t "MCFLIRT estimated translations (mm)" -u 1 --start=4 --finish=6 -a x,y,z -w 640 -h 144 -o %s',fullfile(outdir,'fmri_prefilt_mc.par'),fullfile(outdir,'trans.png'));
unix(cmd);
cmd = sprintf('fsl_tsplot -i %s -t "MCFLIRT estimated mean displacement (mm)" -u 1 -w 640 -h 144 -a absolute,relative -o %s',[fullfile(outdir,'fmri_prefilt_mc_abs.rms') ',' fullfile(outdir,'fmri_prefilt_mc_rel.rms')],fullfile(outdir,'disp.png'));
unix(cmd);

% Mean volume
cmd = sprintf('fslmaths %s -Tmean %s',fullfile(outdir,'fmri_prefilt_mc'),fullfile(outdir,'mean_fmri'));
unix(cmd);

% EPI mask
cmd = sprintf('bet2 %s %s -f 0.3 -n -m', fullfile(outdir,'mean_fmri'), fullfile(outdir,'mask'));
unix(cmd);
cmd = sprintf('immv %s %s', fullfile(outdir,'mask_mask'), fullfile(outdir,'mask_fmri') );
unix(cmd);
cmd = sprintf('fslmaths %s -mas %s %s',fullfile(outdir,'fmri_prefilt_mc'),fullfile(outdir,'mask_fmri'),fullfile(outdir,'fmri_prefilt_bet'));
unix(cmd);

cmd      = sprintf('fslstats %s -p 2 -p 98',fullfile(outdir,'fmri_prefilt_bet'));
[values] = bash(cmd);
values   = textscan(values, '%s %s');
val      = str2num(values{2}{1});
val      = val/10;

cmd = sprintf('fslmaths %s -thr %f -Tmin -bin %s -odt char',fullfile(outdir,'fmri_prefilt_bet'),val,fullfile(outdir,'mask_fmri'));
unix(cmd);

cmd      = sprintf('fslstats %s -k %s -p 50',fullfile(outdir,'fmri_prefilt_mc'),fullfile(outdir,'mask_fmri'));
[values] = bash(cmd);
values   = textscan(values, '%s');
val      = str2num(values{1}{1});

cmd = sprintf('fslmaths %s -dilF %s',fullfile(outdir,'mask_fmri'),fullfile(outdir,'mask_fmri'));
unix(cmd);
cmd = sprintf('fslmaths %s -mas %s %s',fullfile(outdir,'fmri_prefilt_mc'),fullfile(outdir,'mask_fmri'),fullfile(outdir,'fmri_prefilt_thres'));
unix(cmd);
cmd = sprintf('fslmaths %s -Tmean %s',fullfile(outdir,'fmri_prefilt_thres'),fullfile(outdir,'mean_fmri'));
unix(cmd);

% Spatial smoothing
cmd = sprintf('fslmaths %s -kernel gauss %f -fmean -mas %s %s', fullfile(outdir,'fmri_prefilt_thres'), sigma, fullfile(outdir,'mask_fmri'), fullfile(outdir,'fmri_prefilt_smooth') );
unix(cmd);

% Grandmean scaling
cmd = sprintf('fslmaths %s -ing 10000 %s -odt float', fullfile(outdir,'fmri_prefilt_smooth'), fullfile(outdir,'fmri_prefilt_intnorm') );
unix(cmd);

% Temporal filtering
cmd = sprintf('fslmaths %s -bptf 25.0 -1 %s',fullfile(outdir,'fmri_prefilt_intnorm'),fullfile(outdir,'fmri_prefilt_tempfilt'));
unix(cmd);

% Output
cmd = sprintf('fslmaths %s %s', fullfile(outdir,'fmri_prefilt_tempfilt'), fullfile(outdir,'filtered_fmri') );
unix(cmd);
cmd = sprintf('fslmaths %s -Tmean %s', fullfile(outdir,'filtered_fmri'), fullfile(outdir,'mean_fmri'));
unix(cmd);
%cmd = sprintf('rm -rf %s', fullfile(outdir,'fmri_prefilt_*'));
%unix(cmd);


%--------------------------------------------------------------------------
%                        Registration
%--------------------------------------------------------------------------

cmd = sprintf('fslmaths %s %s', fullfile(outdir,'anat_brain'), fullfile(outdir,'highres'));
unix(cmd);
cmd = sprintf('fslmaths %s %s', fullfile(outdir,'anat_brain'), fullfile(outdir,'highres'));
unix(cmd);
cmd = sprintf('fslmaths %s %s', fullfile(fslpath,'data/standard/MNI152_T1_2mm_brain'), fullfile(outdir,'standard'));
unix(cmd);
cmd = sprintf('fslmaths %s %s', fullfile(fslpath,'data/standard/MNI152_T1_2mm'), fullfile(outdir,'standard_head'));
unix(cmd);
cmd = sprintf('fslmaths %s %s', fullfile(outdir,'anat'), fullfile(outdir,'highres_head'));
unix(cmd);
cmd = sprintf('fslmaths %s %s', fullfile(fslpath,'data/standard/MNI152_T1_2mm_brain_mask_dil'), fullfile(outdir,'standard_mask'));
unix(cmd);

% Linear registration (fMRI -> T1)
cmd = sprintf('flirt -ref %s -in %s -out %s -omat %s -cost corratio -dof 7 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear', fullfile(outdir,'highres'), fullfile(outdir,'fmri_ref'), fullfile(outdir,'fmri_ref2highres'), fullfile(outdir,'fmri_ref2highres.mat'));
unix(cmd);

cmd = sprintf('convert_xfm -inverse -omat %s %s', fullfile(outdir,'highres2fmri_ref.mat'), fullfile(outdir,'fmri_ref2highres.mat'));
unix(cmd);

% Linear registration (T1 -> standard)
cmd = sprintf('flirt -ref %s -in %s -out %s -omat %s -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear', fullfile(outdir,'standard'), fullfile(outdir,'highres'), fullfile(outdir,'highres2standard'), fullfile(outdir,'highres2standard.mat'));
unix(cmd);

% Non-linear registration (T1 -> standard)
cmd = sprintf('fnirt --in=%s --aff=%s --cout=%s --iout=%s --jout=%s --config=T1_2_MNI152_2mm --ref=%s --refmask=%s --warpres=10,10,10', fullfile(outdir,'highres_head'), fullfile(outdir,'highres2standard.mat'), fullfile(outdir,'highres2standard_warp'), fullfile(outdir,'highres2standard'), fullfile(outdir,'highres2standard_jac'), fullfile(outdir,'standard_head'), fullfile(outdir,'standard_mask'));
unix(cmd);

% Apply transformation file
cmd = sprintf('convert_xfm -inverse -omat %s %s',fullfile(outdir,'standard2highres.mat'),fullfile(outdir,'highres2standard.mat'));
unix(cmd);

cmd = sprintf('convert_xfm -omat %s -concat %s %s', fullfile(outdir,'fmri_ref2standard.mat'), fullfile(outdir,'highres2standard.mat'), fullfile(outdir,'fmri_ref2highres.mat'));
unix(cmd);

cmd = sprintf('applywarp --ref=%s --in=%s --out=%s --warp=%s --premat=%s', fullfile(outdir,'standard'), fullfile(outdir,'fmri_ref'), fullfile(outdir,'fmri_ref2standard'), fullfile(outdir,'highres2standard_warp'), fullfile(outdir,'fmri_ref2highres.mat'));
unix(cmd);

cmd = sprintf('convert_xfm -inverse -omat %s %s',fullfile(outdir,'standard2fmri_ref.mat'),fullfile(outdir,'fmri_ref2standard.mat'));
unix(cmd);

