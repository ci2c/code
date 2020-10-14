function T = getLET(W, k, Sigma, L_f, N1, N2)
% Usage : T = getLET(W, k, Sigma, L_f, [N1], [N2])
%
% Inputs :
%           W          : Wavelet coefficients
%           k          : Function k
%           Sigma      : Noise standard deviation
%           L_f        : Left filter length
%           N1         : Optional. Number of first ring neighbors. If not
%                         provided, set to ones.
%           N2         : Optional. Number of second ring neighbors. If not
%                         provided, set to ones.
%
% Output :
%           T          : Thresholded coefficients
%
% See also initGraph, graphSURELET, wav_graph_v2, getWavCoeff, inv_wav_graph_v2
%
% Pierre Besson, Nov. 2009

if nargin == 0
    T=4;
    return;
end

if (nargin < 4) | (nargin > 6)
    error('Invalid usage');
end

if nargin == 4
    N1 = ones(size(W));
    N2 = N1;
end

if nargin == 5
    N2 = ones(size(W));
end

if (length(W) ~= length(N1)) | (length(W) ~= length(N2)) | (length(N2) ~= length(N1))
    error('W, N1 and N2 must have same sizes');
end

switch k
    case 1
        T = W;
    case 2
        % T = W.*(1-exp(-(W./(3.*(Sigma ./ sqrt(0.5.*(N1+N2))))).^8));
        T = W .* (1 - exp( -(W./(3.*Sigma) ).^8));
    case 3
        T = zeros(size(W));
        T(:, 1:L_f) = W(:, 1:L_f);
    case 4
        T = zeros(size(W));
        T(:, 1:L_f) = W(:, 1:L_f) .* (1 - exp( -(W(:, 1:L_f)./(3.*Sigma) ).^8));
    otherwise
        error('Invalid k');
end