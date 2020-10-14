function W_coeff = wav_graph_v2(G, filt_name, J)
% Usage: W_COEFF = wav_graph_v2(G, filt_name, J)
%
% Inputs:
%     G           : Input graph structure 
%     filt_name   : Name of the filter to use. For instance 'db2'
%     J           : Number of decomposition scale
%
% Output:
%    W_COEFF      : Structure containing the following
%
%               * W      : M x M x J matrix of the wavelet coefficients.
%               * S      : M x M x 1 matrix of the scaling coefficients at
%                            scale J.
%               * Seq_S  : Low pass sequences at scale 1 to J. Necessary for the inverse transform.
%               * Seq_W  : High pass sequences at scales 1 to J. Necessary for
%                            inverse transform.
%               * f_name : Name of the decomposition fiters, for example
%                            'db2'
%
% See also: initGraph, inv_wav_graph_v2
%
% Pierre Besson, Oct. 2009

if nargin ~= 3
    error('Invalid usage');
end

% Store variable in output structure
W_coeff.f_name = filt_name;

% Initialization of the sequences
C = getSequences(G, G.w, -1);

% Wavelet loop
W_coeff.W = [];
for i = 1 : J
    [C, D] = getWavCoeff(C, filt_name);
    W_coeff.W = cat(3, W_coeff.W, Weights2Mat(G.g, D(:,1)));
    W_coeff.Seq_W{i} = sparse(D);
%    W_coeff.Seq_S{i} = sparse(C);
%     if i < J
%         C = getSequences(G, C(:,1), -1);
%         C = C(:, 1:2^i:end);
%     end
end

W_coeff.S = sparse(Weights2Mat(G.g, C(:,1)));
W_coeff.Seq_S = sparse(C);

