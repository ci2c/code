function FMRI_ApplyGLM2Seed(file_in,motion_file,seeds,fout,prefix,TR,exclude)


for k = 1:size(seeds,2)
    
    if k < 10
        C = ['00' num2str(k)];
    elseif c < 100
        C = ['0' num2str(k)];
    else
        C = num2str(k);
    end
    output_file_base = fullfile(fout,[prefix '_seed_' C]);

    X_cache.TR = TR;
    
    contrast.C  = 1;
    which_stats = [1 1 1 0 0 0 0];
    fwhm_rho    = 15;
    n_poly      = 3;
    
    motion_params = load(motion_file);
    confounds = [seeds(:,k) motion_params];
    clear rot tsl motion_params;

    [DF,P] = fmrilm(file_in, output_file_base, X_cache, contrast, exclude, which_stats, fwhm_rho, n_poly, confounds);
    
end