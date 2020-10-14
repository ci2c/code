function [sig_c,t_c,t_u,z_c,z_u] = FMRI_CorrectSignalOnSurface(sig,mask,p,visu)

% usage : [sig_c,z_c,z_u,t_c,t_u] = FMRI_CorrectSignalOnSurface(sig,mask,[p])
%
% Inputs :
% sig               (1D array). Treated as un uncorrelated gaussian random
%                   field
% mask              (1D array). Binary mask of the vertex to be included in the
%                   analysis.
%
% Options :
% p                 (optional, default 0.05) p-value for threshold of the
%                   statistical map.
%
% Outputs :
% sig_c             (1D array). Same as sig, but the distribution of the
%                   vertex inside mask have been corrected to zero mean and
%                   unit variance by fitting a gaussian function on the
%                   empirical distribution in the surface.
% z_c               two-tailed thresholded sig_c by a Bonferroni corrected threshold.
% z_u               two-tailed thresholded sig_c by an uncorrected threshold.
% t_c               value of the Bonferroni corrected threshold.
% t_u               value of the uncorrected threshold.
%
% Renaud Lopes @ CHRU Lille, Mar 2012

global X Y

if nargin < 3
    p = 0.05;
end

if nargin < 4
    visu = 0;
end

% Histogram computation and normalization
M     = sig(mask);
M     = M(:);
[Y,X] = hist(M,length(M)/100);
Y     = Y/(length(M)*(max(X)-min(X)))*length(X);

% Gaussian parameters fitting.
par = fminsearch('gaussien',[median(M);1.4826*median(abs(M-median(M)))]);
%par = fminsearch('gaussien',[mean(M);std(M)]);

if visu
    [err,val] = gaussien(par);
    figure
    bar(X,Y); hold on; plot(X,val,'r');
    title('Empirical distribution and fitted gaussian function');
end

% Signal correction
sig_c       = zeros(size(sig));
sig_c(mask) = (sig(mask) - par(1))/par(2);

% Threshold computation
if nargout > 1
    t_c = st_normal_inverse_cdf(p/(2*sum(mask(:)>0)));
    t_u = st_normal_inverse_cdf(p/2);
end

% Thresolded volumes

if nargout >3
    z_c       = zeros(size(mask));
    z_c(mask) = abs(sig_c(mask))>=t_c;
    z_u       = zeros(size(mask));
    z_u(mask) = abs(sig_c(mask))>=t_u;
end
