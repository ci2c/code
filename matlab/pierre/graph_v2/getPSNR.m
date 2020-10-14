function PSNR = getPSNR(Signal, Noisy)
% Usage : PSNR = getPSNR(SIGNAL, NOISY)
%
% Computes the PSNR between the signal and the noisy signal
%
% Inputs :
%           SIGNAL     : Original (noise free) signal
%           NOISY      : Noisy version
% Output :
%           PSNR       : Computed as 10*log10(Imax^2 / MSE)
%
% Pierre Besson, Oct. 2009

if nargin ~= 2
    error('Invalid usage');
end

MSE = mean((Signal - Noisy).^2);
Imax = max(Signal);
Imin = min(Signal);
PSNR = 10*log10((Imax - Imin).^2 / MSE);