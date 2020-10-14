function [perfnum,glcbf] = ASL_ProcessSubj(aslFile,t1File,pvename,minTR,Delaytime,TE,Labeltime,opts)

% function preprocesses ASL data - requires SPM8 and ASLtbx
%
% Usage : ASL_RunPVE(t1_path, pet_path, outdir [, configfile])
% 
% Inputs :
%     aslFile        : ASL file (.nii)
%     t1File         : T1 file (.nii)
%     minTR          : TR value
%     Delaytime      : delay time
%     TE             : TE value
%     Labeltime      : labeling time
%
% Option :
%     opts           : variables (structure)
%                       - realign: 0 no, 1 yes (Default: 1)
%                       - smooth: 0 no, 1 yes (Default: 1)
%                       - fwhm: smoothing value (Default: 6)
%                       - FirstimageType: 0 label, 1 control (Default: 0)
%                       - SubtractionType: 0 simple subtraction; 1 surround
%                       subtraction; 2 sinc subtraction (Default: 0)
%                       - SubtractionOrder: 1: control-label; 0:
%                       label-control (Default: 1)
%                       - Flag (Default: [1 1 1 0 0 0 0])
%                       - Timeshift: only invalid for sinc interpolation, it's a value between
%                       0 and 1 to shift the labeled image forward or backward. (Default: 0.5)
%                       - AslType: 0 means PASL, 1 means CASL (Default: 1)
%                       - labeff: labeling efficiency, 0.95 for PASL, 0.68
%                       for CASL, 0.85 for pCASL (Default: 0.85)
%                       - MagType: indicator for magnet field strength, 1
%                       for 3T, 0 for 1.5T (Default: 1)
%
% Renaud Lopes @ CHRU Lille, Apr. 2013

spm('Defaults','fMRI');
spm_jobman('initcfg'); 
clear matlabbatch

if nargin < 8
    realign          = 1;
    smooth           = 1;
    fwhm             = 6;
    FirstimageType   = 0;
    SubtractionType  = 0;
    SubtractionOrder = 1;
    Flag             = [1 1 1 0 0 0 0];
    Timeshift        = 0.5;
    AslType          = 1;
    labeff           = 0.85;
    MagType          = 1;
else
    realign          = opts.realign;
    smooth           = opts.smooth;
    fwhm             = opts.fwhm;
    FirstimageType   = opts.FirstimageType;
    SubtractionType  = opts.SubtractionType;
    SubtractionOrder = opts.SubtractionOrder;
    Flag             = opts.Flag;
    Timeshift        = opts.Timeshift;
    AslType          = opts.AslType;
    labeff           = opts.labeff;
    MagType          = opts.MagType;
end

[outdir,n,e] = fileparts(aslFile);

if ~strcmp(e,'.nii')
    fprintf('ERROR: require nifti volume (.nii)\n');
    return;
end

tic; %start timer...

% if(nargin==6)
%     segnormSub(t1File);
%     segnormwriteSub(t1File,{t1File}, 1);
% end

% Processing...
fprintf('Processing...\n');
V       = spm_vol(aslFile(1,:));
nslices = V(1).dim(3);
clear V;
    
Filename = deblank (aslFile(1,:));
Filename = vol4DSub(Filename);
if length(Filename(:,1)) < 2 %single 3D image - we need 4D!
    fprintf('ERROR: %s requires multiple volumes\n',which(mfilename));
    fprintf('  Either select a 4D image or a series of 3D volumes.\n');
    return;
end;
fprintf('Pre-proocessing %d volume\n',length(Filename(:,1)));

% 1 - motion correct ASL images
if realign == 1
    
    spm_realign_asl(Filename); 
    [meanname, Filename] = applyRealignSub(Filename);
    
    [pa,na,ex] = fileparts(meanname);
    cmd = sprintf('bet %s %s -m -n -f 0.4',fullfile(pa,[na '.nii']),fullfile(outdir,'asl'));
    unix(cmd);
    cmd = sprintf('gunzip -f %s',fullfile(outdir,'asl_mask.nii.gz'));
    unix(cmd);
      
    % coregister ASL to T1 image
    coregSub(meanname, t1File, Filename);    
    
end

% 2 - smooth with fwhm_mm FWHM Gaussian
if smooth == 1
    Filename = smoothSub(Filename, fwhm);
end

% 3 - conduct CBF estimates...

Slicetime = (minTR-Labeltime*1000-Delaytime*1000)/nslices;
M0img     = [];
M0roi     = [];
maskimg   = fullfile(outdir,'asl_mask.nii');
M0csf     = [];
M0wm      = [];

[perfnum,glcbf] = asl_perf_subtract(char(Filename),FirstimageType, SubtractionType,...
           SubtractionOrder,Flag,Timeshift,AslType,labeff,MagType,Labeltime,Delaytime,Slicetime,TE,M0img,M0roi,maskimg,M0csf,M0wm);

[p,na,e] = fileparts(Filename{1}); 
cmd = sprintf('mri_convert %s %s',fullfile(outdir,['meanPERF_' num2str(SubtractionType) '_' na '.img']),fullfile(outdir,['meanPERF_' num2str(SubtractionType) '_' na '.nii']));
unix(cmd);
cmd = sprintf('rm -f %s %s',fullfile(outdir,['meanPERF_' num2str(SubtractionType) '_' na '.img']),fullfile(outdir,['meanPERF_' num2str(SubtractionType) '_' na '.hdr']));
unix(cmd);

cmd = sprintf('mri_convert %s %s',fullfile(outdir,['meanCBF_' num2str(SubtractionType) '_' na '.img']),fullfile(outdir,['meanCBF_' num2str(SubtractionType) '_' na '.nii']));
unix(cmd);
cmd = sprintf('rm -f %s %s',fullfile(outdir,['meanCBF_' num2str(SubtractionType) '_' na '.img']),fullfile(outdir,['meanCBF_' num2str(SubtractionType) '_' na '.hdr']));
unix(cmd);

fprintf('reslice meanPERF.nii\n');
resliceSub(t1File,fullfile(outdir,['meanPERF_' num2str(SubtractionType) '_' na '.nii']));
resliceSub(t1File,fullfile(outdir,['meanCBF_' num2str(SubtractionType) '_' na '.nii']));

fprintf('correction volume partiel\n');

asl_path = fullfile(outdir,['rmeanPERF_' num2str(SubtractionType) '_' na '.nii']);
outpve   = fullfile(outdir,pvename);

ASL_RunPVE(t1File,asl_path,outpve);

file_to_copy = fullfile(outdir,pvename,'rpet.hdr');
file_out     = fullfile(outdir,pvename,'t1_MGRousset.hdr');
copyfile(file_to_copy,file_out,'f');

fprintf('Done processing in %0.3fsec\n',toc);
%%END function asl_process

function [sesvols] = vol4DSub(sesvol1);
% input: filename from single image in 4D volume, output: list of filenames for all volumes in 4D dataset
%  example 4D file with 3 volumes input= 'img.nii', output= {'img.nii,1';'img.nii,2';'img.nii,3'}
[pth,nam,ext,vol] = spm_fileparts( deblank (sesvol1));
sesname = fullfile(pth,[nam, ext]);
hdr = spm_vol(sesname);
nvol = length(hdr);
if (nvol < 2), fprintf('Error 4D fMRI data required %s\n', sesname); return; end;
sesvols = cellstr([sesname,',1']);
for vol = 2 : nvol
        sesvols = [sesvols; [sesname,',',int2str(vol)]  ];
end;
%%END subfunction vol4DSub

function [longname] = addprefix4DSub(prefix, shortname);
% input: filenames from single image in 4D volume, output: list of filenames for all volumes in 4D dataset
%  example 4D file with 3 volumes input= {'img.nii,1';'img.nii,2';'img.nii,3'}, output= {'simg.nii,1';'simg.nii,2';'simg.nii,3'}
nsessions = length(shortname(:,1));
longname = cell(nsessions,1);
for s = 1 : nsessions 
	[pth,nam,ext,vol] = spm_fileparts(strvcat( deblank (shortname(s,:))) );
	sesname = fullfile(pth,[prefix, nam, ext,vol]);
    longname(s,1) = {sesname};
end;
%%END subfunction addprefix4DSub

function [longname] = addprefix(prefix, shortname);
%adds path if not specified
[pth,nam,ext,vol] = spm_fileparts(shortname);
longname = fullfile(pth,[prefix nam, ext]);
if exist(longname)~=2; fprintf('Warning: unable to find image %s - cd to approrpiate working directory?\n',longname); end;
longname = [longname, ',1'];
%%END subfunction addprefix

function resliceSub(anat,map)
fprintf('Reslicing map image.\n');
matlabbatch{1}.spm.spatial.coreg.write.ref             = {anat};
matlabbatch{1}.spm.spatial.coreg.write.source          = {map};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask   = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch); 
%%END subfunction reslice

function [meanname, outname] =applyRealignSub(inname)
fprintf('Reslicing %d image with motion correction parameters.\n',length(inname(:,1)));
matlabbatch{1}.spm.spatial.realign.write.data =inname;
matlabbatch{1}.spm.spatial.realign.write.roptions.which = [2 1]; 
matlabbatch{1}.spm.spatial.realign.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch); %make mean motion corrected
meanname = addprefix('mean', strvcat(deblank (inname(1,:))  ) );
outname = addprefix4DSub('r', inname); %add 'r'ealigned prefix

%%END subfunction applyRealignSub

function coregSub(meanname, T1name, inname)
fprintf('Coregistering %s to %s, and applying transforms to %d images.\n',meanname,T1name,length(inname(:,1)) );
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {T1name};
matlabbatch{1}.spm.spatial.coreg.estimate.source ={meanname};
matlabbatch{1}.spm.spatial.coreg.estimate.other = inname;
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
spm_jobman('run',matlabbatch); %make mean motion corrected
%%END subfunction coregSub

function outname = smoothSub(inname, FWHMmm);
fprintf('Smoothing %d image[s] with a %fmm FWHM Gaussian kernel\n',length(inname(:,1)),FWHMmm);
matlabbatch{1}.spm.spatial.smooth.data = inname;
matlabbatch{1}.spm.spatial.smooth.fwhm = [FWHMmm FWHMmm FWHMmm];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run',matlabbatch);
outname = addprefix4DSub('s', inname); %add 's'moothed prefix
%%END subfunction smoothSub

function segnormSub(t1);
%estimate normalization based on unified segmentation normalization of T1
fprintf('Unified segmentation normalization of %s\n',t1);
matlabbatch{1}.spm.spatial.preproc.data = {t1};
matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 0];
matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
matlabbatch{1}.spm.spatial.preproc.output.biascor = 0;
matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{1}.spm.spatial.preproc.opts.tpm = {fullfile(spm('Dir'),'tpm','grey.nii');fullfile(spm('Dir'),'tpm','white.nii');fullfile(spm('Dir'),'tpm','csf.nii')};
matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2;2;2;4];
matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};
spm_jobman('run',matlabbatch);
%%END subfunction segnormSub

function segnormwriteSub(t1,mod, mm);
%reslice ASL/fMRI data based on previous segmentation-normalization
[pth,nam,ext,vol] = spm_fileparts( deblank (t1));
fprintf('Applying unified segmentation normalization parameters from %s to %d image[s], resliced to %fmm\n',t1,length(mod(:,1)),mm);
matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {fullfile(pth,[ nam, '_seg_sn.mat'])};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = mod;
matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50; 78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [mm mm mm];
matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
spm_jobman('run',matlabbatch);
%%END subfunction segnormwriteSub


function outname = maskSub(inname, Thresh);
mask = fullfile(spm('Dir'),'apriori','brainmask.nii');
[pth,nam,ext,vol] = spm_fileparts( inname(1,:));
innameX = fullfile(pth,[nam, ext]); %remove volume label
outname = fullfile(pth,['msk' nam, ext]);
tempname = fullfile(pth,['sk' nam, ext]); 
fprintf('Masking %s with %s at a threshold of %g, resulting in %s\n',innameX,mask,Thresh,outname);
%1 Reslice mask to match image
copyfile(mask,tempname); %move mask - user may not have write permission to SPM folder
matlabbatch{1}.spm.spatial.coreg.write.ref = {innameX};
matlabbatch{1}.spm.spatial.coreg.write.source = {tempname};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'm';
spm_jobman('run',matlabbatch);
delete(tempname);
%2 Apply mask to image
VImg = spm_vol(innameX);
Img = spm_read_vols(VImg);
VMsk = spm_vol(outname); 
MskImg = spm_read_vols(VMsk);
delete(outname); %<- this was the mask, we will overwrite it with masked image
VImg.fname = outname; %we will overwrite the mask
for x = 1 : size(Img,1)
	for y = 1 : size(Img,2)
		for z = 1 : size(Img,3)
			if MskImg(x,y,z) < Thresh
				Img(x,y,z) = 0;
			end;
		end; %z 
	end; %y 
end; %x 
spm_write_vol(VImg,Img);

%spm_write_vol(v,ave);

%%END subfunction maskSub

function [longname] = FullpathSub(prefix, shortname);
% input: appends path to all files (if required)
nsessions = length(shortname(:,1));
longname = cell(nsessions,1);
for s = 1 : nsessions 
	[pth,nam,ext,vol] = spm_fileparts(strvcat( deblank (shortname(s,:))) );
    if length(pth)==0; pth=pwd; end;
	sname = fullfile(pth,[prefix, nam, ext]);
    if exist(sname)~=2; fprintf('Warning: unable to find image %s - cd to approrpiate working directory.\n',sname); end;
	sname = fullfile(pth,[prefix, nam, ext,vol]);
    longname(s,1) = {sname};
end;
%%END subfunction FullpathSub