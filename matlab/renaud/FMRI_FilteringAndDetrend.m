function FMRI_FilteringAndDetrend(epiFile,opts)

V       = spm_vol(epiFile);
vol     = spm_read_vols(V);
dim     = size(vol);
tseries = reshape(vol,dim(1)*dim(2)*dim(3),dim(4));

% NORMALIZATION
if(opts.normalize == 1)
    opt_norm.type = 'mean_var';
    opt_norm.ind_time = 2;
    tseries = niak_normalize_tseries(tseries,opt_norm);
end

% FILTERING
if(opts.filtering == 1)
    opt_filter.tr = opts.TR;
    opt_filter.hp = opts.hp;
    opt_filter.lp = opts.lp;
    tseries = niak_filter_tseries(tseries,opt_filter);
end

% DETRENDING
if(opts.detrend == 1)
    
    X = trend_matrix(opt.infile,opts.TR);
    
    % - calcul des betas
    X       = X';
    tseries = tseries';
    beta    = tseries*X'*pinv(X*X');
    % - calcul des residus
    tseries = tseries - beta*X;
    tseries = tseries';
    
end