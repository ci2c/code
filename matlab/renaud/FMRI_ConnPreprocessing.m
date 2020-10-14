function tseries = FMRI_ConnPreprocessing(tseries,TR,motionfile,opt)

% NORMALIZE
opt_norm.type     = 'mean_var';
opt_norm.ind_time = 2;
tseries = niak_normalize_tseries(tseries,opt_norm);

% FILTERING
if(opt.filtering == 1)
    opt_filter.tr = TR;
    opt_filter.hp = 0.1;
    opt_filter.lp = 0.01;
    tseries = niak_filter_tseries(tseries,opt_filter);
end

% DETRENDING
if(opt.detrend == 1)
    
    % Create temporal trends:
    X          = [];
    n_temporal = 3;
    Nf         = size(tseries,1);
    n_spline   = round(n_temporal*TR*Nf/360);
    keep       = 1:Nf;
    n          = length(keep);
    if n_spline>=0 
       trend = ((2*keep-(max(keep)+min(keep)))./(max(keep)-min(keep)))';
       if n_spline<=3
          temporal_trend = (trend*ones(1,n_spline+1)).^(ones(n,1)*(0:n_spline));
       else
          temporal_trend = (trend*ones(1,4)).^(ones(n,1)*(0:3));
          knot           = (1:(n_spline-3))/(n_spline-2)*(max(keep)-min(keep))+min(keep);
          for k = 1:length(knot)
             cut            = keep'-knot(k);
             temporal_trend = [temporal_trend (cut>0).*(cut./max(cut)).^3];
          end
       end
    else
       temporal_trend = [];
    end 
    X       = [X temporal_trend];
    
    % Motions parameters
    motions = load(motionfile);
    X       = [X motions];
    
    % - calcul des betas
    X       = X';
    tseries = tseries';
    beta    = tseries*X'*pinv(X*X');
    % - calcul des residus
    tseries = tseries - beta*X;
    tseries = tseries';
    
end