function Synth = invWavCoeff(S, W, filt_name)
% Usage : Synth = invWavCoeff(S, W, [FILTER])
%
% Inputs :
%           S          : Scaling coefficients at scale j
%           W          : Wavelet coefficients at scale j
%           Filter     : Name of the filter to use. Default 'db2'
%
% Output :
%           SYNTH      : Synthetized signal at scale j-1
%
% See also initGraph, wav_graph_v2, getWavCoeff
%
% Pierre Besson, Oct. 2009

if (nargin ~= 2) & (nargin ~= 3)
    error('Invalid usage');
end

if (size(S, 1) ~= size(W, 1)) | (size(S, 2) ~= size(W, 2))
    error('Scaling and wavelet coefficients matrices sizes must match');
end

% Generate decomposition filters
[H, G] = getFilterMat(filt_name, 2*size(S, 2));

% Get inverse filter
Temp = zeros(2*size(H, 1), size(H, 2));
Temp(1:2:end, :) = H;
Temp(2:2:end, :) = G;
synth_filt = inv(Temp);

% Upsample coeff
Temp = zeros(size(S, 1), 2*size(S,2));
Temp(:, 1:2:end) = S;
Temp(:, 2:2:end) = W;

Synth = (synth_filt * Temp')';