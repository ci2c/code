function X_d = graphSURELET(G, J, filt_name, Sigma)
% Usage : X_d = graphSURELETCoeff(G, J, [filt_name], [Sigma])
%
% Inputs :
%           G          : Graph structure
%           J          : Decomposition level
%           Sigma      : Optional. Noise std dev, if not provided, use
%                         random walk method to estimate it.
%           filt_name  : Optional. Filter to use. Default : 'db2'
%
% Output :
%           X_d        : Denoised graph
%
% See also initGraph, wav_graph_v2, getWavCoeff, inv_wav_graph_v2
%
% Pierre Besson, Nov. 2009

if (nargin < 2) & (nargin > 4)
    error('Invalid usage');
end

if nargin < 3
    filt_name = 'db2';
end

% L_f = 3 .* (length(wfilters(filt_name)) ./ 2 - 1);
L_f = 2;

if nargin ~= 4
    % Estimate sigma
    disp('Estimating Noise std dev...');
    [C, L] = wavedec(G.rand_w, 1, 'sym8');
    Sigma = median(abs(C(L(2)+1:end))) / 0.6745;
    disp(['Found Sigma = ' num2str(Sigma)]);
end

% Wavelet transform
W_c = wav_graph_v2(G, filt_name, J);

% Set some parameters
L = size(W_c.Seq_W{1},2);
% K = getLET();
K = 2;
C = zeros(K*J,1);

% get the matric C
for i = 1 : J
    for k = 1 : K
        % Compute Fik
        T = getLET(W_c.Seq_W{i}, k, Sigma, L_f);
        dT = get_dLET(W_c.Seq_W{i}, k, Sigma, L_f);
        % dT = get_dLET_2(G, k, Sigma, i, J, L_f, filt_name);
        dT = dT(:,1);
        
        % Set all other sub-bands to zero
        W_c_i{(i-1)*K+k} = W_c;
        I = 1:J;
        I(i) = [];
        for II = 1 : length(I)
            W_c_i{(i-1)*K+k}.Seq_W{I(II)} = zeros(size(W_c_i{(i-1)*K+k}.Seq_W{I(II)}));
        end
        
        % Threshold coeff.
        W_c_i{(i-1)*K+k}.Seq_W{i} = T;
        Mat = inv_wav_graph_v2(G, W_c_i{(i-1)*K+k});
        Fik{(i-1)*K+k} = getWeightsList(G.g, Mat);
        
        C((i-1)*K+k) = Fik{(i-1)*K+k}'*G.w - Sigma.^2 * sum(dT);
    end
end

% get matrix M
M = zeros(K*J, K*J);
for i = 1 : K*J
    for k = 1 : K*J
        M(i,k) = Fik{i}'*Fik{k};
    end
end

a = inv(M) * C;
W_c_thr = W_c;
W_c_thr.Seq_W = [];
for i = 1 : J
    for k = 1 : K
        try 
            W_c_thr.Seq_W{i} = a((i-1)*K+k) * W_c_i{(i-1)*K+k}.Seq_W{i} + W_c_thr.Seq_W{i};
        catch
            W_c_thr.Seq_W{i} = a((i-1)*K+k) * W_c_i{(i-1)*K+k}.Seq_W{i};
        end
    end
end

Mat_th = inv_wav_graph_v2(G, W_c_thr);
X_d = getWeightsList(G.g, Mat);