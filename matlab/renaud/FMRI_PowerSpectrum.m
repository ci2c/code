function [mftseries,Y,X] = FMRI_PowerSpectrum(tseries,tr);
%
% _________________________________________________________________________
% SUMMARY FMRI_PowerSpectrum
%
% Compute the power spectrum of one or multiple time series.
%
% SYNTAX:
% [] = FMRI_PowerSpectrum(TSERIES,TR)
%
% _________________________________________________________________________
% INPUTS:
%
% TSERIES       
%       (1D array T*N) one or multiple 1D signal (1st dimension is samples)
%
% TR            
%       (real number, default 1) the repetition time of the time series 
%       (this is of course assuming a regular sampling).
%
% _________________________________________________________________________
% OUTPUTS:
%
% X : Frequency
% Y : Relative energy
%
% _________________________________________________________________________

[nt,n] = size(tseries);
if nargin<2
    tr = 1;
end
M = ceil(sqrt(n));
N = ceil(n/M);
T = linspace(0,tr*nt,nt);
X = linspace(0,1/(2*tr),nt/2+1);

for num_f = 1:n
    
    ftseries = abs(fft(tseries(:,num_f))).^2;
    ftseries = ftseries(1:length(X));    
    Y(:,num_f) = ftseries/sum(ftseries);
    
    [I,J]    = max(Y(:,num_f));
    mftseries(num_f) = X(J);
     
end