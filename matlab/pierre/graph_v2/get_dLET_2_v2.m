function dT = get_dLET_2(G, k, Sigma, I, J, L_f, filt_name, N1, N2)
% Usage : dT = get_dLET_2(G, k, Sigma, I, J, L_f, filt_name, [N1], [N2])
%
% Inputs :
%           G          : Graph structure
%           k          : Function identifiant
%           Sigma      : Noise standard deviation
%           I          : Number of the sub-band of interest
%           J          : Number on decomposition level
%           L_f        : Left filter length
%           filt_name  : Filter to use
%           N1         : Optional. Number of first ring neighbors. If not
%                         provided, set to ones.
%           N2         : Optional. Number of second ring neighbors. If not
%                         provided, set to ones.
%
% Output :
%           dT         : Derivative of thresholded coefficients
%
% See also initGraph, graphSURELET, wav_graph_v2, getWavCoeff, inv_wav_graph_v2
%
% Pierre Besson, Nov. 2009

if (nargin < 7) | (nargin > 9)
    error('Invalid usage');
end

if nargin == 7
    N1 = ones(size(G.w));
    N2 = N1;
end

if nargin == 8
    N2 = ones(size(G.w));
end

if (length(G.w) ~= length(N1)) | (length(G.w) ~= length(N2))
    error('W, N1 and N2 must have same sizes');
end

Delta = 1e-6;

%% f(x+h)
G.w = G.w + Delta;
G.Mat = Weights2Mat(G.g, G.w);

W_c_2 = wav_graph_v2(G, filt_name, J);

I_l = 1:J;
I_l(I) = [];

if ~isempty(I_l)
    W_c_2.Seq_W{I_l} = zeros(size(W_c_2.Seq_W{I_l}));
end
    
W_c_2.Seq_W{I} = getLET(W_c_2.Seq_W{I}, k, Sigma, L_f);
Mat_2 = inv_wav_graph_v2(G, W_c_2);

%% f(x-h)
G.w = G.w - 2*Delta;
G.Mat = Weights2Mat(G.g, G.w);

W_c_1 = wav_graph_v2(G, filt_name, J);

I_l = 1:J;
I_l(I) = [];

if ~isempty(I_l)
    W_c_1.Seq_W{I_l} = zeros(size(W_c_1.Seq_W{I_l}));
end
W_c_1.Seq_W{I} = getLET(W_c_1.Seq_W{I}, k, Sigma, L_f);
Mat_1 = inv_wav_graph_v2(G, W_c_1);

%% Compute derivative
dT = (getWeightsList(G.g, Mat_2) - getWeightsList(G.g, Mat_1)) ./ (2.*Delta);