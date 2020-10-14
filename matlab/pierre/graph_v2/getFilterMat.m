function [H, G] = getFilterMat(filt_name, L)
% Usage : [H, G] = getFilterMat(filt_name, L)
%
% Inputs :
%           filt_name  : Name of the filter to use. For instance 'db2'
%           L          : Signal length
%
% Output :
%           H          : Approximation filter
%           G          : Wavelet filter
%
% See also getSequences, initGraph, wav_graph_v2, getWavCoeff, invWavCoeff
%
% Pierre Besson, Oct. 2009

if nargin ~= 2
    error('Invalid usage');
end

[LO_D, HI_D] = wfilters(filt_name);
filterh = sqrt(2) .* flipdim(LO_D, 2);
filterg = sqrt(2) .* flipdim(HI_D, 2);
[Hedge, Gedge, Pre, Post] = computeEdgeMat( filterh ); % Compute edge filters

N = size(Hedge, 1);
H = zeros(L./2, L);
G = zeros(L./2, L);
H(1:N, 1:size(Hedge, 2)) = Hedge;
G(1:N, 1:size(Gedge, 2)) = Gedge;

for k = N : (L./2 - 1)
    for l = 0 : (L-1)
        try
            H(k+1, l+1) = filterh(l - 2*k + N) ./ sqrt(2);
            G(k+1, l+1) = filterg(l - 2*k + N) ./ sqrt(2);
        catch
            H(k+1, l+1) = 0;
            G(k+1, l+1) = 0;
        end
    end
end