function computeQSM_2020(DicomFolder,outdir,magFile,steps,maskFile)

run('/home/global/matlab_toolbox/MEDI_toolbox_2020_01/MEDI_set_path')
% DicomFolder='/NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/01/01026AF/M00/dicom/'
% outdir='/NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/01/01026AF/comparOri/'
% magFile='/NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/01/01026AF/comparOri/real_gre.nii'
% maskFile='/NAS/deathrow/protocoles/predistim/FS60_VB/01026AF/mri/brainmask_ras_r.nii'
% 
% DicomFolder='/NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/02/02004GB/M00/dicom/'
% outdir='/NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/02/02004GB/QSM_2020/'
% magFile='/NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/02/02004GB/QSM/real_gre.nii'

%DicomFolder='/NAS/tupac/protocoles/3DMULTIGRE_greg/ulm/QSM_Sample1/DICOM/'
%outdir='/NAS/tupac/protocoles/3DMULTIGRE_greg/ulm/QSM_Sample1/QSM_rv'
%magFile='/NAS/tupac/protocoles/3DMULTIGRE_greg/ulm/QSM_Sample1/QSM_rv/real_gre.nii'
%maskFile='/NAS/tupac/protocoles/3DMULTIGRE_greg/ulm/QSM_Sample1/QSM/mask.nii'

if nargin < 4
    steps = {'data','mask','noise','normalization','magnitude','fieldmap','unwrapping','fieldremoval','qsm'};
end

if nargin < 5
    maskFile = [];
end

hdr = spm_vol(magFile);

'ICI'
if (any(ismember(steps,'data'))) || (~exist(fullfile(outdir,'data.mat'),'file'))
    steps
    fullfile(outdir,'data.mat')
    %[iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir] = Read_DICOM(DicomFolder);
    %save(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
else
    'merde la ?'
    load(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
end
'ICI'

%% Magnitude

if (any(ismember(steps,'magnitude'))) || (~exist(fullfile(outdir,'magnitude.mat'),'file'))
    iMag = sqrt(sum(abs(iField).^2,4));
    %write_QSM_dir(iMag,DicomFolder,fullfile(outdir,'iMag'));
    %cd(fullfile(outdir,'iMag'))
    %system('dcm2nii *')
    save(fullfile(outdir,'magnitude.mat'),'iMag');
    iMag_t = permute(iMag,[3,1,2]);
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['iMag.nii']);
    iMag_t = iMag_t(:,end:-1:1,end:-1:1);
    %ULM 
    spm_write_vol(hdrtmp,iMag_t);
    %spm_write_vol(hdrtmp,iMag);
    clear hdrtmp iMag_t;
else
    load(fullfile(outdir,'magnitude.mat'),'iMag');
end

%% Mask

if (any(ismember(steps,'mask'))) || (~exist(fullfile(outdir,'mask.mat'),'file'))        
    if isempty(maskFile)
        Mask = BET(iMag, matrix_size, voxel_size);
        %write_QSM_dir(Mask,DicomFolder,fullfile(outdir,'Mask'));
        %cd(fullfile(outdir,'Mask'))
        %system('dcm2nii *')
        save(fullfile(outdir,'mask.mat'),'Mask');
    else
        hh = spm_vol(maskFile);
        Mask = spm_read_vols(hh);
        Mask = Mask(:,end:-1:1,end:-1:1);
        save(fullfile(outdir,'mask.mat'),'Mask');
    end
    if (sum(hdr.dim == size(Mask)) ~= 3)    
        Mask_c = permute(Mask,[3,1,2]); %change row/column order due to differences in representations in DICOM and Matlab
    else
        Mask_c = Mask;
    end
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['Mask.nii']);
    Mask_t = Mask_c(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,Mask_t);
    clear hdrtmp Mask_c Mask_t;    
else
    load(fullfile(outdir,'mask.mat'),'Mask');
end

%% STEP 2a: Field Map Estimation

% Estimate the frequency offset in each of the voxel using a complex fitting
if (any(ismember(steps,'fieldmap'))) || (~exist(fullfile(outdir,'fieldmap.mat'),'file'))
    [iFreq_raw N_std] = Fit_ppm_complex(iField);
    save(fullfile(outdir,'fieldmap.mat'),'iFreq_raw','N_std');
    
    %write_QSM_dir(iFreq_raw,DicomFolder,fullfile(outdir,'iFreq_raw'));
    %cd(fullfile(outdir,'iFreq_raw'))
    %system('dcm2nii *')
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['iFreq_raw.nii']);
    if (sum(hdr.dim == size(iFreq_raw)) ~= 3)
        iFreq_raw_c = permute(iFreq_raw,[3,1,2]); %change row/column order due to differences in representations in DICOM and Matlab
    else
        iFreq_raw_c = iFreq_raw;
    end
    iFreq_raw_t = iFreq_raw_c(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,iFreq_raw_t);
    clear hdrtmp iFreq_raw_c iFreq_raw_t;
else
    load(fullfile(outdir,'fieldmap.mat'),'iFreq_raw','N_std');
end

%% STEP 2b: Spatial phase unwrapping 

if (any(ismember(steps,'unwrapping'))) || (~exist(fullfile(outdir,'unwrapping.mat'),'file'))
    iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);
%     iFreq = unwrapLaplacian(iFreq_raw, matrix_size, voxel_size);
    save(fullfile(outdir,'unwrapping.mat'),'iFreq');
     
    %write_QSM_dir(iFreq,DicomFolder,fullfile(outdir,'iFreq'));
    %cd(fullfile(outdir,'iFreq'))
    %system('dcm2nii *')
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['iFreq.nii']);
    if (sum(hdr.dim == size(iFreq)) ~= 3)
        iFreq_c = permute(iFreq,[3,1,2]); %change row/column order due to differences in representations in DICOM and Matlab
    else
        iFreq_c = iFreq;
    end
    iFreq_t = iFreq_c(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,iFreq_t);
    clear hdrtmp iFreq_c iFreq_t;      
else
    load(fullfile(outdir,'unwrapping.mat'),'iFreq');
end

%% STEP 2c: Background Field Removal
if (any(ismember(steps,'fieldremoval'))) || (~exist(fullfile(outdir,'fieldremoval.mat'),'file'))
    R2s = arlo(TE, abs(iField));
    if (sum(size(R2s)==size(Mask)) ~= 3)
        Mask=permute(Mask,[2,3,1]);%pourquoi ? parce que c'est une lecture de nifti "naturel" pour refaire l'inverse des ....
    end
    Mask_CSF = extract_CSF(R2s, Mask, voxel_size);
    RDF = PDF(iFreq, N_std,Mask,matrix_size,voxel_size, B0_dir);
    %write_QSM_dir(RDF,DicomFolder,fullfile(outdir,'RDF'));
    %cd(fullfile(outdir,'RDF'))
    %system('dcm2nii *')
    save(fullfile(outdir,'fieldremoval.mat'),'RDF');
    
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['RDF.nii']);
    if (sum(hdr.dim == size(RDF)) ~= 3)    
        RDF_c = permute(RDF,[3,1,2]); %change row/column order due to differences in representations in DICOM and Matlab
    else
        RDF_c = RDF;
    end
    RDF_t = RDF_c(:,end:-1:1,end:-1:1);
    spm_write_vol(hdrtmp,RDF_t);
    clear hdrtmp RDF_c RDF_t;
else
    load(fullfile(outdir,'fieldremoval.mat'),'RDF');
end

cd(outdir)
save RDF.mat RDF iFreq iFreq_raw iMag N_std Mask matrix_size...
     voxel_size delta_TE CF B0_dir Mask_CSF;
 
if (any(ismember(steps,'qsm'))) || (~exist(fullfile(outdir,'qsm.mat'),'file'))    
    cur_path=pwd;
    cd(outdir);
    %QSM = MEDI_L1('lambda',1000,'percentage',0.99, 'smv',7);
    QSM = MEDI_L1('lambda',915.64,'lambda_CSF',100);
    cd(cur_path);
    save(fullfile(outdir,'qsm.mat'),'QSM');    
    %write_QSM_dir(QSM,DicomFolder,fullfile(outdir,'QSM'));
    %cd(fullfile(outdir,'QSM'))
    %system('dcm2nii *')
    hdrtmp = hdr;
    hdrtmp.fname = fullfile(outdir,['QSM.nii']);
    qsm1 = int16(QSM*-1000); %par 1000 et par -1 pour avoir le pallidum en hypersignal
    if (sum(hdr.dim == size(QSM)) ~= 3)    
        QSM_c = permute(qsm1,[3,1,2]); %change row/column order due to differences in representations in DICOM and Matlab
    else
        QSM_c = qsm1;
    end
    %QSM_t = QSM_c(:,end:-1:1,end:-1:1);
    QSM_t = QSM_c(end:-1:1,end:-1:1,end:-1:1); %inversion sur l'axe des x pour obtenir comme l'exe
    spm_write_vol(hdrtmp,qsm1(:,end:-1:1,end:-1:1));
    clear hdrtmp QSM_t QSM_c;
else  
    load(fullfile(outdir,'qsm.mat'),'QSM');    
end
 
%for p=0.89:0.02:0.99
%    for s=8:1:11
%        cd(outdir)
%        QSM = MEDI_L1('lambda',1000,'percentage',p,'smv',s);
%        write_QSM_dir(QSM,DicomFolder,fullfile(outdir,strcat('QSM_',num2str(p),'_',num2str(s))));
%        cd(fullfile(outdir,strcat('QSM_',num2str(p),'_',num2str(s))))
%        system('dcm2nii *')        
%    end
%end