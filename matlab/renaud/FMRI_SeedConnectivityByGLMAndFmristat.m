function FMRI_SeedConnectivityByGLMAndFmristat(epiFile,outdir,seeds,voxels,motionFile,namerois,TR)

[hdr,vol] = niak_read_vol(epiFile);
dim       = size(vol);

frametimes = [0:dim(4)-1]*TR;

nslices    = dim(3);
sliceorder = [];
space      = round(sqrt(nslices));
for k=1:space
    tmp        = k:space:nslices;
    sliceorder = [sliceorder tmp];
end
st = [0:nslices-1]* (TR ./ nslices);
slicetimes = zeros(1,nslices);
slicetimes(sliceorder) = st;

contrast.C  = 1;
which_stats = '_mag_ef _mag_sd _mag_t';

exclude    = [1 dim(4)];
fwhm_rho   = 15; %15;
n_poly     = 3;
X_cache.TR = TR;
          
for k = 1 : size(seeds,2)
    
    output_file_base = fullfile(outdir,namerois{k});
    ref_times        = frametimes' + slicetimes(voxels(k,3)+1);
    %[df,spatial_av]  = fmrilm(epiFile,[],[],[],exclude);
    %ref_data         = squeeze(extract(voxel,epiFile)) ./ spatial_av*100;
    ref_data         = seeds(:,k);

    confounds = zeros(dim(4),7,nslices);
    confounds(:,1,:) = fmri_interp(ref_times,ref_data,frametimes,slicetimes);

    X = load(motionFile);
    X = repmat(X,[1 1 nslices]);
    confounds(:,2:7,:) = X;

    fmrilm(epiFile, output_file_base, X_cache, contrast, exclude, which_stats, fwhm_rho, n_poly, confounds);
    
end

%figure; view_slices(fullfile(outdir,'seed_mag_t.nii'),maskFile,[],0:11,1,[-6 6]);

