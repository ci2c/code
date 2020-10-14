function data = FMRI_ConcatenateRuns(epiDir,prefix,outname)

epiFiles = conn_dir(fullfile(epiDir,[prefix '*.nii']));
nruns    = size(epiFiles,1);

opt_norm.type     = 'mean_var';
opt_norm.ind_time = 2;

data    = [];
nframes = 0;
for k = 1:nruns
    
    [hdr,epi] = niak_read_vol(deblank(epiFiles(k,:)));
    dim = size(epi);
    nframes = nframes+dim(4);

    epi = reshape(epi,dim(1)*dim(2)*dim(3),dim(4))';
    data = [data; niak_normalize_tseries(epi,opt_norm)];
    
end

[hdr,epi] = niak_read_vol(deblank(epiFiles(1,:)));
hdr.file_name = fullfile(epiDir,outname);
hdr.info.dimensions = [dim(1) dim(2) dim(3) nframes];
hdr.details.dim(5)=nframes;
data = data';
data = reshape(data,dim(1),dim(2),dim(3),nframes);
niak_write_vol(hdr,data);