function QSM_ConvertBinToNii(magFile,outdir)

%%
% usage : QSM_ConvertBinToNii('/path/magnitude_echo1.nii','/path_output');
%
% Convert bin file to nifti file
% 
% Inputs :
%    magFile     : nifti file of magnitude image
%    outdir      : output folder
%    sizeVox     : voxels size
%
% Renaud Lopes @ CHRU Lille, Nov 2016
%
%%

% Read magnitude image
hdr = spm_vol(magFile);

matrix_size = hdr.dim;

% Convert...

tmpFile = fullfile(outdir,'temporary_dir_for_intermediate_files','Mask.bin');
if exist(tmpFile,'file')
    fid = fopen(tmpFile);
    if (fid>0)
        A = fread(fid, inf, 'int32');
        fclose(fid);
        M = reshape(A, matrix_size);
        M = M(:,end:-1:1,end:-1:1);
        hdr.fname = fullfile(outdir,'Mask.nii');
        spm_write_vol(hdr,M);
    end
end

tmpFile = fullfile(outdir,'temporary_dir_for_intermediate_files','RDF.bin');
if exist(tmpFile,'file')
    fid = fopen(tmpFile);
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        M = reshape(A, matrix_size);
        M = M(:,end:-1:1,end:-1:1);
        hdr.fname = fullfile(outdir,'RDF.nii');
        spm_write_vol(hdr,M);
    end
end

tmpFile = fullfile(outdir,'temporary_dir_for_intermediate_files','iFreq.bin');
if exist(tmpFile,'file')
    fid = fopen(tmpFile);
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        M = reshape(A, matrix_size);
        M = M(:,end:-1:1,end:-1:1);
        hdr.fname = fullfile(outdir,'iFreq.nii');
        spm_write_vol(hdr,M);
    end
end

tmpFile = fullfile(outdir,'temporary_dir_for_intermediate_files','iFreq_raw.bin');
if exist(tmpFile,'file')
    fid = fopen(tmpFile);
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        M = reshape(A, matrix_size);
        M = M(:,end:-1:1,end:-1:1);
        hdr.fname = fullfile(outdir,'iFreq_raw.nii');
        spm_write_vol(hdr,M);
    end
end

tmpFile = fullfile(outdir,'temporary_dir_for_intermediate_files','recon_QSM_06.bin');
if exist(tmpFile,'file')
    fid = fopen(tmpFile);
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        M = reshape(A, matrix_size);
        M = M(:,end:-1:1,end:-1:1);
        hdr.fname = fullfile(outdir,'QSM_rec.nii');
        spm_write_vol(hdr,M);
    end
end

