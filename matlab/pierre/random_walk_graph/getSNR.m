function SNR = getSNR(Signal, Noisy)
% Usage : SNR = getSNR(SIGNAL, NOISY)
%
% Computes the SNR between the signal and the noisy signal
%
% Inputs :
%           SIGNAL     : Original (noise free) signal
%           NOISY      : Noisy version
% Output :
%           SNR       : Computed as 10*log10(var(Sig) / var(Nois - Sig))
%
% Pierre Besson, Nov. 2009

if nargin ~= 2
    error('Invalid usage');
end

Temp_1 = var(Signal - Noisy);
Temp_2 = var(Signal);
SNR = 10*log10(Temp_2 ./ Temp_1);