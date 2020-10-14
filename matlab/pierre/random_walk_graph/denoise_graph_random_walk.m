function [output, denoised_rand_seq] = denoise_graph_random_walk(G, filt_name, Sigma)
% Usage: Output = denoise_graph_random_walk(G, [filt_name], [Sigma])
%
% Inputs:
%     G              : Input graph structure 
%     filt_name      : Filter to use. Default : 'sym8'
%     Sigma          : Noise std. dev. Default : Computed using the robust
%                       median estimator
%
% Output:
%     Output      : Denoised graph. It can be a M x 1 vector or a M x M matrix 
%            whether measurements are assigned to nodes or to edges
%
% See also: initGraphRW
%
% Pierre Besson, Nov. 2009

switch nargin
    case 1
        denoised_rand_seq = OWT_SURELET_denoise(G.rand_w, 'sym8');
    case 2
        denoised_rand_seq = OWT_SURELET_denoise(G.rand_w, filt_name);
    case 3
        denoised_rand_seq = OWT_SURELET_denoise(G.rand_w, filt_name, Sigma);
    otherwise
        error('Invalid usage');
end

V_seq = G.rand_e;

% Reconstruction
output = zeros(size(G.W));
N = length(denoised_rand_seq);
for i = 1 : length(output)
%     F = find(V_seq==i);
%     S = [];
%     for k = 1 : length(F)
%         S = [S; std(G.rand_w(max(1, F(k)-4) : min(N, F(k)+4)))];
%     end
%     output(i) = sum(denoised_rand_seq(F) .* S) ./ sum(S);
   output(i) = mean(denoised_rand_seq(V_seq==i));
end