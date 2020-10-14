function Out = normalize_features(M, Mask)
%
% usage : Out = normalize_features(M, [Mask])
%
%   Input :
%        M        : n_subjects x n_vertex feature matrix
%
%   Option :
%        Mask     : 1 x n_vertex mask. Set mask = 1 for usefull vertices,
%                                          mask = 0 otherwise
%
% Normalize histograms of the rows of M using robust alignment on the
% N(100, 100)
%
% Pierre Besson @ CHRU Lille, Apr. 2013

if nargin ~= 1 && nargin ~= 2
    error('invalid usage');
end

if nargin == 1
    Mask = ones(1, size(M, 2));
end

n_vertex = size(M, 2);

pctile50 = 100;
pctile25 = 93.2653;
pctile75 = 106.7438;

pctileM50 = median(M(:, Mask==1), 2);
pctileM25 = prctile(M(:, Mask==1), 25, 2);
pctileM75 = prctile(M(:, Mask==1), 75, 2);

pctileM50 = repmat(pctileM50, 1, n_vertex);
pctileM25 = repmat(pctileM25, 1, n_vertex);
pctileM75 = repmat(pctileM75, 1, n_vertex);

Out = (M - pctileM50) ./ (pctileM75 - pctileM25);
Out = Out .* (pctile75 - pctile25) + pctile50;

Out(:, Mask==0) = 0;