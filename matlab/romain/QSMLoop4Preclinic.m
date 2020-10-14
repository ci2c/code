real_folder   = '/NAS/tupac/protocoles/3DMULTIGRE_greg/souris/session-du-08-03-2017/souris1S2/souris1S2_real/' % répertoire contenant la partie réelle des images dicom 
imag_folder   = '/NAS/tupac/protocoles/3DMULTIGRE_greg/souris/session-du-08-03-2017/souris1S2/souris1S2_imaginary/' %répertoire contenant la partie imaginaire des images dicom 
outdir        = '/NAS/tupac/protocoles/3DMULTIGRE_greg/souris/session-du-08-03-2017/souris1S2/resultsFromLoop' %path to output folder
niftiFile     = '/NAS/tupac/protocoles/3DMULTIGRE_greg/souris/session-du-08-03-2017/souris1S2/souris1S2_echo1.nii' %path to magnitude 
maskFile      = '/NAS/tupac/protocoles/3DMULTIGRE_greg/souris/session-du-08-03-2017/souris1S2/souris1S2_mask.nii' %path to mask file (default: [])

%sur le modèle de computeQSM_preclinic('${ir}','${ii}','${OUTDIR}','${ECHO}','${mask}');
hdr = spm_vol(niftiFile);
load(fullfile(outdir,'data.mat'),'iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir');
load(fullfile(outdir,'mask.mat'),'Mask');
noise_level = calfieldnoise(iField, Mask);
iField = iField/noise_level;
iMag = sqrt(sum(abs(iField).^2,4));
hdr.fname = fullfile(outdir,['MagnitudeS.nii']);
spm_write_vol(hdr,iMag);
for nbEcho=1:size(iField,4)
    hdr.fname = fullfile(outdir,['Magnitude1.nii']);
    spm_write_vol(hdr,abs(iField(:,:,:,nbEcho)));

    hdr.fname = fullfile(outdir,['Phase1.nii']);
    spm_write_vol(hdr,angle(iField(:,:,:,nbEcho)));
end
[iFreq_raw N_std] = Fit_ppm_complex(iField);
hdr.fname = fullfile(outdir,['iFreq_raw.nii']);
spm_write_vol(hdr,iFreq_raw(:,:,:));
iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);
hdr.fname = fullfile(outdir,['iFreq.nii']);
spm_write_vol(hdr,iFreq(:,:,:));

%% STEP 2c: Background Field Removal
[hdr,vol]= niak_read_vol(niftiFile);
hdrtmp = hdr;
hdrtmp.info.dimensions = hdrtmp.info.dimensions(1:3);
hdrtmp.details.dim = [3 hdrtmp.info.dimensions(1) hdrtmp.info.dimensions(2) hdrtmp.info.dimensions(3) 1 1 1 1];
  
%Penser à inclure dans le path /NAS/tupas/renaud/QSM/code/online
for radius=0.05:0.05:0.3
    for thres=0.999:-0.005:0.900
        for lambda=6000:1000:14000
            for meth=1:1:4    
                switch meth 
                    case 1
                        hdrtmp.file_name = fullfile(outdir,['QSM_PDF_' num2str(lambda) '_' num2str(radius) '_' num2str(thres) '.nii']);
                    case 2
                        hdrtmp.file_name = fullfile(outdir,['QSM_RESHARP_' num2str(lambda) '_' num2str(radius) '_' num2str(thres) '.nii']);
                    case 3
                        hdrtmp.file_name = fullfile(outdir,['QSM_SHARP_' num2str(lambda) '_' num2str(radius) '_' num2str(thres) '.nii']);
                    case 4
                        hdrtmp.file_name = fullfile(outdir,['QSM_LBV_' num2str(lambda) '_' num2str(radius) '_' num2str(thres) '.nii']);
                end
                if exist(hdrtmp.file_name, 'file') ~= 2              
                    M1 = SMV(Mask, matrix_size, voxel_size, radius)>thres;
                    switch meth 
                        case 1
                            RDF = PDF(iFreq, N_std, Mask,matrix_size,voxel_size, B0_dir).*M1;
                        case 2
                            RDF = RESHARP(iFreq, Mask, matrix_size, voxel_size, radius, 0.01).*M1;
                        case 3
                            RDF = SHARP(iFreq, Mask, matrix_size, voxel_size, radius, 0.03).*M1;
                        case 4
                            RDF = (LBV(iFreq, Mask, matrix_size, voxel_size, 1e-4, 4, 1)+0.05).*M1;
                    end
                    save(fullfile(outdir,'RDF.mat'),'RDF','iFreq','iFreq_raw','iMag','N_std','Mask','matrix_size','voxel_size','delta_TE','CF','B0_dir');
                    cur_path=pwd;
                    cd(outdir);
                    QSM = MEDI_L1('lambda',lambda);
                    cd(cur_path);

                    QSM_t = QSM(:,end:-1:1,:);
                    niak_write_nifti(hdrtmp,QSM_t);
                    clear hdrtmp QSM_t;
                end    
            end
        end
    end
end

%%%QA  for ima in `ls resultsFromLoop/QSM_*_5000_0.3_0.999.nii`; do  echo $ima ; fslstats $ima -n -S ; done
radius=0.02
thres=0.999
lambda=5000
for meth=1:1:4
        M1 = SMV(Mask, matrix_size, voxel_size, radius)>thres;
        switch meth 
            case 1
                file_name = ['QSM_PDF_'];
                RDF = PDF(iFreq, N_std, Mask,matrix_size,voxel_size, B0_dir).*M1;
            case 2
                file_name = ['QSM_RESHARP_'];
                RDF = RESHARP(iFreq, Mask, matrix_size, voxel_size, radius, 0.01).*M1;
            case 3
                file_name = ['QSM_SHARP_'];
                RDF = SHARP(iFreq, Mask, matrix_size, voxel_size, radius, 0.03).*M1;
            case 4
                file_name = ['QSM_LBV_'];
                RDF = (LBV(iFreq, Mask, matrix_size, voxel_size, 1e-4, 4, 1)+0.05).*M1;
        end
        save(fullfile(outdir,'RDF.mat'),'RDF','iFreq','iFreq_raw','iMag','N_std','Mask','matrix_size','voxel_size','delta_TE','CF','B0_dir');
        cur_path=pwd;
        cd(outdir);
        for medi=1:1:6
            switch medi 
                case 1
                    hdrtmp.file_name = [file_name 'MEDIlinear_']; % ok
                    QSM = MEDI_linear('lambda',lambda,'merit',1);
                case 2
                    hdrtmp.file_name = [file_name 'TKD_']; % attention j'ai forcé pour le domaien image (vs; kspace)
                    QSM = TKD(.1);
                case 3
                    hdrtmp.file_name = [file_name 'TSVD_'];
                    QSM = TSVD(.1);
                case 4
                    hdrtmp.file_name = [file_name 'TVSB_']; % attention lambda dans fct_thuilleir bcp plus bas.
                    QSM = TVSB('lambda',lambda);
                case 5
                    hdrtmp.file_name = [file_name 'iSWIM_']; % signification des parametres ?
                    QSM = iSWIM(.1,0);
                case 6
                    hdrtmp.file_name = [file_name 'MEDIl1_'];
                    QSM = MEDI_L1('lambda',lambda);
            end
            hdrtmp.file_name = fullfile(outdir,[hdrtmp.file_name num2str(lambda) '_' num2str(radius) '_' num2str(thres) '.nii'])
            cd(cur_path);

            QSM_t = QSM(:,end:-1:1,:);
            niak_write_nifti(hdrtmp,QSM_t);
            clear hdrtmp QSM_t;
        end
end
                   
%%%QA ls -1 resultsFromLoop/QSM_*_iSWIM_5000_0.02_0.999.nii

