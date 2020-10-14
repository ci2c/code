function Mat = inv_wav_graph_v2(G, W_coeff, J_back)
% Usage: MAT = inv_wav_graph_v2(G, W_COEFF, [J])
%
% Inputs:
%     G           : Graph structure as provided by initGraph
%     W_COEFF     : Structure provided by wav_graph_v2
%     J           : Optional, number of synthesis scales. Default : number
%                    of decomposition scales (go back to scale 0)
%
% Output:
%     MAT         : Synthetized connectivity matrix
%
% See also: initGraph, wav_graph_v2
%
% Pierre Besson, Oct. 2009

if (nargin ~= 2) & (nargin ~= 3)
    error('Invalid usage');
end

% Test the wavelet structure
try
    W_coeff.f_name;
    W_coeff.W;
    W_coeff.S;
    W_coeff.Seq_W;
    W_coeff.Seq_S;
catch
    error('W_COEFF not valid. Please refer to wav_graph_v2');
end

J = size(W_coeff.W, 3);
if nargin == 2
    J_back = size(W_coeff.W, 3);
else
    if (J_back > J) | (J_back < 0)
        error('J provided is greater than the maximum decomposition scale or is less than 0.');
    end
end

% Test the graph structure
try
    G.Mat;
    G.g;
    G.w;
    G.T_M;
    G.L_max;
    G.L_min;
catch
    error('G not valid. Please refer to initGraph');
end

C = W_coeff.Seq_S;
for i = J : -1 : J-J_back+1
    D = W_coeff.Seq_W{i};
    C = invWavCoeff(C, D, W_coeff.f_name);
end

Mat = Weights2Mat(G.g, C(:,1));