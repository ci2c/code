function computeQSM_preclinic(DicomFolder,outdir,niftiFile,maskFile)

%%
% usage : computeQSM(DicomFolder,outdir,magFile,[steps])
%
% Estimation of quantitative susceptibility maps from multi-TE sequence
% 
% Inputs :
%    DicomFolder   : dicom files of 3D GRE sequence
%    outdir        : path to output folder
%    niftiFile       : path to magnitude of 1st echo (.nii)
% 
% Options
%    maskFile      : path to mask file (default: [])
%
% Romain Viard @ CHRU Lille, Nov 2016

%% INIT
if nargin < 4
    maskFile = [];
end
%clear all; close all;

%carte T2
%/home/romain/Downloads/NiftyFit-QtCreator/fit-apps/fit_qt2 
%-source /home/romain/Downloads/QSM_8/Maud_U1171_Phy-1t__E7_P1_2.16.756.5.5.100.346844782.378.1473697091.2/20160912_1330303DMGET2starmapcoro8echoess458753a001.nii 
%-TEs 4 10 16 22 28 34 40 46 
%-t2map  /home/romain/Downloads/QSM_8/Maud_U1171_Phy-1t__E7_P1_2.16.756.5.5.100.346844782.378.1473697091.2/T2.nii 
%-res /home/romain/Downloads/QSM_8/Maud_U1171_Phy-1t__E7_P1_2.16.756.5.5.100.346844782.378.1473697091.2/res.nii 
%-syn /home/romain/Downloads/QSM_8/Maud_U1171_Phy-1t__E7_P1_2.16.756.5.5.100.346844782.378.1473697091.2/syn.nii



%% CONFIG
indir  = '/NAS/tupac/protocoles/3DMULTIGRE_greg/souris/Micro-IRM-Test-multi-echoes/BRUKER/Kuchcinski.FH1/5';
outdir = fullfile(indir,'result_brucker');

%RV_Bruker indir  = '/home/romain/Downloads/QSM';
%indir  = '/NAS/tupac/protocoles/3DMULTIGRE_greg/tube/tube8/tube8_s1/tube8_s1_bruker/';
%outdir = fullfile(indir,'results_1mm_Th005');
%indir = '/NAS/tupac/renaud/QSM/CD6_7j/Data_Bruker/6/';
%outdir = fullfile('/NAS/tupac/renaud/QSM/CD6_7j/Data_Bruker/6/','results_1mm_Th005');

%NE fonctionne pas 
%dicomdir_real = '/home/romain/Downloads/QSM_2/Maud_U1171_SM_C6_2__E6_P2_real/';
%dicomdir_imag = '/home/romain/Downloads/QSM_2/Maud_U1171_SM_C6_2__E6_P3_imag/';
%[iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir]=Read_DICOM(dicomdir)

%% Read data
if ~exist(fullfile(outdir,'data.mat'),'file')
    %[iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir] = Read_Bruker_DICOM('/home/romain/Downloads/QSM/Maud_U1171_SM_C6_1__E6_P1_2.16.756.5.5.100.346844782.9742.1468838134.1/');
    %[iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir] = Read_Bruker_DICOM('/home/romain/Downloads/QSM_3/Maud_U1171_Phy-1t__E6_P4_2.16.756.5.5.100.346844782.4483.1473697678.3','/home/romain/Downloads/QSM_3/Maud_U1171_Phy-1t__E6_P5_2.16.756.5.5.100.346844782.4483.1473698543.4');    
    [iField voxel_size matrix_size TE delta_TE CF Affine3D B0_dir TR NumEcho]=Read_Bruker_raw_staticMatrix(indir);% Read_Bruker_raw(indir);
    save(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
else
    load(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
end

% provide a Mask here if possible
Mask = genMask_Preclinique(iField, voxel_size);

% provide a noise_level here if possible
noise_level = calfieldnoise(iField, Mask);

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
RDF = PDF(iFreq, N_std, Mask, matrix_size, voxel_size, B0_dir);
save(fullfile(outdir,'RDF.mat'),'RDF','iFreq','iFreq_raw','iMag','N_std','Mask','matrix_size','voxel_size','delta_TE','CF','B0_dir');

cur_path=pwd;
cd(outdir);
QSM = MEDI_L1('lambda',1000);
cd(cur_path);

[hdr,vol]= niak_read_vol(niftiFile);
hdrtmp = hdr;
hdrtmp.info.dimensions = hdrtmp.info.dimensions(1:3);
hdrtmp.details.dim = [3 hdrtmp.info.dimensions(1) hdrtmp.info.dimensions(2) hdrtmp.info.dimensions(3) 1 1 1 1];
hdrtmp.file_name = fullfile(outdir,['QSM_PDF_MEDIL1.nii']);
QSM_t = QSM(:,end:-1:1,:);
niak_write_nifti(hdrtmp,QSM_t);
clear hdrtmp QSM_t;
