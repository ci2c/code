function [C, D] = getWavCoeff(S, filt_name)
% Usage : [C, D] = getWavCoeff(S, [FILTER])
%
% Inputs :
%           S          : Graph sequences to filter
%           Filter     : Name of the filter to use. Default 'db2'
%
% Output :
%           C          : Approximation coefficients
%           D          : Detail coefficients
%
% See also getSequences, initGraph, invWavCoeff
%
% Pierre Besson, Oct. 2009

if (nargin < 1) | (nargin > 2)
    error('Invalid usage');
end

if nargin == 1
    filt_name = 'db2';
end


%% Compute the filter matrix
[H, G] = getFilterMat(filt_name, size(S, 2));

C = (H*(S'))';
D = (G*(S'))';