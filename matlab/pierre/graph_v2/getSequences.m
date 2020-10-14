function S = getSequences(G, W, Exp)
% Usage : S = getSequences(G, W, [Exp])
%
% Returns the sequences (mean as a function of the distance from each node)
%
% Inputs :
%           G          : Input graph structure
%           W          : Weigts vector
%           Exp        : If set to 1, zero pad S on the right to have a
%                         power of 2 number of columns
%
% Output :
%           S          : Sequences
%
% See also initGraph, wav_graph_v2
%
% Pierre Besson, Oct. 2009

if (nargin ~= 2) & (nargin ~= 3)
    error('Invalid usage');
end

if nargin ==2
    Exp=0;
end

% Create the weights matrix
L_w = length(W);
R = size(G.T_M, 2) / L_w;

W_m = sparse(zeros(size(G.T_M, 2), R));
W_m(1:L_w, 1) = W;

for i = 2 : R
    W_m(:,i) = circshift(W_m(:,1), (i-1)*L_w);
end

S = G.T_M * W_m;

if (Exp)
    P = nextpow2(size(S, 2));
    S = [S zeros(size(S,1),2^P-size(S,2))];
end