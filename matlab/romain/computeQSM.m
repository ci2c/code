function computeQSM(DicomFolder,outdir,magFile,steps,maskFile)

%%
% usage : computeQSM(DicomFolder,outdir,magFile,[steps])
%
% Estimation of quantitative susceptibility maps from multi-TE sequence
% 
% Inputs :
%    DicomFolder   : dicom files of 3D GRE sequence
%    outdir        : path to output folder
%    magFile       : path to magnitude of 1st echo (.nii)
% 
% Options
%    steps         : processing steps (default: all)
%    maskFile      : path to mask file (default: [])
%
% Romain Viard @ CHRU Lille, Nov 2016
%   Updates: Renaud Lopes @ CHRU Lille, Nov 2016

%QSM_Analysis.sh -i /NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/3T_recherche/session4/s4_clot0_20_40_60/s4_3T_clot0_20_40_60_average2_DCM -o /NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/3T_recherche/session4/s4_clot0_20_40_60/QSM_average2 -echo /NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/3T_recherche/session4/s4_clot0_20_40_60/s4_3T_clot0_20_40_60_average2_nii/s4_3T_clot0_20_40_60_average2_echo1.nii -m /NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/3T_recherche/session4/s4_clot0_20_40_60/s4_3T_clot0_20_40_60_average2_nii/s4_3T_clot0_20_40_60_average2_mask.nii -dosmv -r 1

%% INIT

if nargin < 4
    steps = {'data','mask','noise','normalization','magnitude','fieldmap','unwrapping','fieldremoval','qsm'};
end

if nargin < 5
    maskFile = [];
end

hdr = spm_vol(magFile);
vol = spm_read_vols(hdr);


%% Read data

if (any(ismember(steps,'data'))) || (~exist(fullfile(outdir,'data.mat'),'file'))
    [iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir] = Read_Philips_DICOM(DicomFolder);
    save(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
else
    load(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
end


%% Provide a Mask here if possible

if (any(ismember(steps,'mask'))) || (~exist(fullfile(outdir,'mask.mat'),'file'))
    
    if isempty(maskFile)
        Mask = genMask(iField, voxel_size);
        save(fullfile(outdir,'mask.mat'),'Mask');
    else
        hh = spm_vol(maskFile);
        Mask = spm_read_vols(hh);
        Mask = Mask(:,end:-1:1,end:-1:1);
        save(fullfile(outdir,'mask.mat'),'Mask');
    end
    
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['Mask.nii']);
    Mask_t = Mask(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,Mask_t);
    clear hdrtmp Mask_t;
    
else
    load(fullfile(outdir,'mask.mat'),'Mask');
end


%% Provide a noise_level here if possible

if (any(ismember(steps,'noise'))) || (~exist(fullfile(outdir,'noise.mat'),'file'))
    noise_level = calfieldnoise(iField, Mask);
    save(fullfile(outdir,'noise.mat'),'noise_level');
else
    load(fullfile(outdir,'noise.mat'),'noise_level');
end


%% Normalize signal intensity by noise to get SNR %%%

if (any(ismember(steps,'normalization'))) || (~exist(fullfile(outdir,'normalization.mat'),'file'))
    iField = iField/noise_level;
    save(fullfile(outdir,'normalization.mat'),'iField');
    
%     hdrtmp = hdr;
%     hdrtmp.fname = fullfile(outdir,['iField.nii']);
%     iField_t = iField(:,end:-1:1,end:-1:1);
%     spm_write_vol(hdrtmp,iField_t);
%     clear hdrtmp iField_t;
else
    load(fullfile(outdir,'normalization.mat'),'iField');
end


%% Generate the Magnitude image %%%%

if (any(ismember(steps,'magnitude'))) || (~exist(fullfile(outdir,'magnitude.mat'),'file'))
    iMag = sqrt(sum(abs(iField).^2,4));
    save(fullfile(outdir,'magnitude.mat'),'iMag');
    
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['iMag.nii']);
    iMag_t = iMag(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,iMag_t);
    clear hdrtmp iMag_t;
else
    load(fullfile(outdir,'magnitude.mat'),'iMag');
end


%% STEP 2a: Field Map Estimation

% Estimate the frequency offset in each of the voxel using a complex fitting
if (any(ismember(steps,'fieldmap'))) || (~exist(fullfile(outdir,'fieldmap.mat'),'file'))
    [iFreq_raw N_std] = Fit_ppm_complex(iField);
    save(fullfile(outdir,'fieldmap.mat'),'iFreq_raw','N_std');
    
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['iFreq_raw.nii']);
    iFreq_raw_t = iFreq_raw(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,iFreq_raw_t);
    clear hdrtmp iFreq_raw_t;
else
    load(fullfile(outdir,'fieldmap.mat'),'iFreq_raw','N_std');
end


%% STEP 2b: Spatial phase unwrapping 

if (any(ismember(steps,'unwrapping'))) || (~exist(fullfile(outdir,'unwrapping.mat'),'file'))
    iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);
%     iFreq = unwrapLaplacian(iFreq_raw, matrix_size, voxel_size);
    save(fullfile(outdir,'unwrapping.mat'),'iFreq');
     
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['iFreq.nii']);
    iFreq_t = iFreq(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,iFreq_t);
    clear hdrtmp iFreq_t;
else
    load(fullfile(outdir,'unwrapping.mat'),'iFreq');
end


%% STEP 2c: Background Field Removal

if (any(ismember(steps,'fieldremoval'))) || (~exist(fullfile(outdir,'fieldremoval.mat'),'file'))
%     RDF = PDF(iFreq, N_std, Mask, matrix_size, voxel_size, B0_dir);
    
    radius = 4;
    M1 = SMV(Mask, matrix_size, voxel_size, radius)>0.999;
    RDF = PDF(iFreq, N_std, Mask,matrix_size,voxel_size, B0_dir).*M1;
    
%     radius = 4;
%     M1 = SMV(Mask, matrix_size, voxel_size, radius)>0.999;
%     RDF_LBV = (LBV(iFreq, Mask, matrix_size, voxel_size, 1e-4,4,1)+0.05).*M1;
%     RDF_SHARP = SHARP(iFreq, Mask, matrix_size, voxel_size, radius,0.03).*M1;
%     RDF_RESHARP = RESHARP(iFreq, Mask, matrix_size, voxel_size, radius, 0.01).*M1;
%     RDF_PDF = PDF(iFreq, N_std, Mask,matrix_size,voxel_size, B0_dir).*M1;

    save(fullfile(outdir,'fieldremoval.mat'),'RDF');
    
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['RDF.nii']);
    RDF_t = RDF(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,RDF_t);
    clear hdrtmp RDF_t;
else
    load(fullfile(outdir,'fieldremoval.mat'),'RDF');
end

save(fullfile(outdir,'RDF.mat'),'RDF','iFreq','iFreq_raw','iMag','N_std','Mask','matrix_size','voxel_size','delta_TE','CF','B0_dir');


%% QSM estimation

if (any(ismember(steps,'qsm'))) || (~exist(fullfile(outdir,'qsm.mat'),'file'))
    
    cur_path=pwd;
    cd(outdir);
    QSM = MEDI_L1('lambda',1000);
    cd(cur_path);

    save(fullfile(outdir,'qsm.mat'),'QSM');
    
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['QSM.nii']);
    QSM_t = QSM(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,QSM_t);
    clear hdrtmp QSM_t;
    
else
    
    load(fullfile(outdir,'qsm.mat'),'QSM');
    
end

    