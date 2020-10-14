function computeQSM_preclinic(real_folder,imag_folder,outdir,niftiFile,maskFile)

%%
% usage : computeQSM_preclinic(real_folder,imag_folder,outdir,niftiFile,maskFile)
%
% Estimation of quantitative susceptibility maps from multi-TE sequence
% 
% Inputs :
%    real_folder   : répertoire contenant la partie réelle des images dicom 
%    imag_folder   : répertoire contenant la partie imaginaire des images dicom 
%    outdir        : path to output folder
%    niftiFile     : path to magnitude 
% 
% Options
%    maskFile      : path to mask file (default: [])
%
% Romain Viard @ CHRU Lille, Jan 2017


%% INIT

% iFreq_tmp=load_nii('/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/session4/s4_clot20/QSMResults_maskN/iFreq_corr.nii');
% iFreq_tmp=iFreq_tmp.img;
% real_folder='/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/session4/s4_clot20/s4_clot20_real';
% imag_folder='/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/session4/s4_clot20/s4_clot20_imagin';
% outdir='/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/session4/s4_clot20/test_iFreq_corr';
% niftiFile='/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/session4/s4_clot20/s4_clot20_echo1.nii';
% maskFile='/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/session4/s4_clot20/s4_clot20_maskN.nii'


if nargin < 5
    maskFile = [];
end

%% CONFIG
hdr = spm_vol(niftiFile);
%% Read data
if ~exist(fullfile(outdir,'data.mat'),'file')
    %[iField voxel_size matrix_size TE delta_TE CF Affine3D B0_dir TR NumEcho]= Read_Bruker_raw_staticMatrix(BruckerFolder);
    [iField, CF, B0_dir, Affine3D, TE, delta_TE, matrix_size, voxel_size] = Read_Bruker_DICOM(real_folder, imag_folder);
    save(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
else
    load(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
end

% provide a Mask here if possible
if (~exist(fullfile(outdir,'mask.mat'),'file'))
    
    if isempty(maskFile)
        Mask = genMask_Preclinique(iField, voxel_size);
        save(fullfile(outdir,'mask.mat'),'Mask');
    else
        hh = spm_vol(maskFile);
        Mask = spm_read_vols(hh);
        Mask = Mask(:,end:-1:1,:);
        save(fullfile(outdir,'mask.mat'),'Mask');
    end
    hdrtmp=hdr;
    fullfile(outdir,['Mask.nii'])
    hdrtmp.fname = fullfile(outdir,['Mask.nii']);
    Mask_t = Mask(:,end:-1:1,:);
    spm_write_vol(hdrtmp,Mask_t);
   
    % clear hdrtmp Mask_t;
else
    load(fullfile(outdir,'mask.mat'),'Mask');
end

% provide a noise_level here if possible
noise_level = calfieldnoise(iField, Mask)

% Normalize signal intensity by noise to get SNR %%%
iField = iField/noise_level;

% Generate the Magnitude image %%%%
iMag = sqrt(sum(abs(iField).^2,4));
hdr.fname = fullfile(outdir,['MagnitudeS.nii']);
spm_write_vol(hdr,iMag);

for nbEcho=1:size(iField,4)
    hdr.fname = fullfile(outdir,['Magnitude' num2str(nbEcho) '.nii']);
    spm_write_vol(hdr,abs(iField(:,:,:,nbEcho)));

    hdr.fname = fullfile(outdir,['Phase' num2str(nbEcho) '.nii']);
    spm_write_vol(hdr,angle(iField(:,:,:,nbEcho)));
end

% STEP 2a: Field Map Estimation
% Estimate the frequency offset in each of the voxel using a complex fitting
[iFreq_raw N_std] = Fit_ppm_complex(iField);
hdr.fname = fullfile(outdir,['iFreq_raw.nii']);
spm_write_vol(hdr,iFreq_raw(:,:,:));

% STEP 2b: Spatial phase unwrapping %%%%
iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);
hdr.fname = fullfile(outdir,['iFreq.nii']);
spm_write_vol(hdr,iFreq(:,:,:));

%% STEP 2c: Background Field Removal
radius = 0.2;
y_smv=SMV(Mask, matrix_size, voxel_size, radius);
hdr.fname = fullfile(outdir,['SMV.nii']);
yyy = y_smv(:,end:-1:1,:);
spm_write_vol(hdr,yyy(:,:,:));
M1 = y_smv>0.999;
yyy = M1(:,end:-1:1,:);
hdr.fname = fullfile(outdir,['M1.nii']);
spm_write_vol(hdr,yyy(:,:,:));
RDF = PDF(iFreq, N_std, Mask,matrix_size,voxel_size, B0_dir).*M1;
   
save(fullfile(outdir,'RDF.mat'),'RDF','iFreq','iFreq_raw','iMag','N_std','Mask','matrix_size','voxel_size','delta_TE','CF','B0_dir');

hdr.fname = fullfile(outdir,['RDF.nii']);
spm_write_vol(hdr,RDF(:,end:-1:1,:));
    
cur_path=pwd;
cd(outdir);
QSM = MEDI_L1('lambda',2000);
cd(cur_path);

[hdr,vol]= niak_read_vol(niftiFile);
hdrtmp = hdr;
hdrtmp.info.dimensions = hdrtmp.info.dimensions(1:3);
hdrtmp.details.dim = [3 hdrtmp.info.dimensions(1) hdrtmp.info.dimensions(2) hdrtmp.info.dimensions(3) 1 1 1 1];
hdrtmp.file_name = fullfile(outdir,['QSM_PDF_MEDIL1.nii']);
QSM_t = QSM(:,end:-1:1,:)*-1;
niak_write_nifti(hdrtmp,QSM_t);
clear hdrtmp QSM_t;

V=spm_vol(fullfile(outdir,['QSM_PDF_MEDIL1.nii']));
volspm = spm_read_vols(V);
V.fname = fullfile(outdir,['QSM_PDF_MEDIL1_spm.nii']);
spm_write_vol(V,volspm);

