% Loads Data
load ../Mats_full/Controls/Data_controls.mat
load ../Mats_full/MP/Data_ND.mat

Mean = mean(M_controls, 3);
S = sort(Mean(:));
S(S==0) = [];
L = length(S);
% Leave the 15 highest percentile
p = 15;
Lt = (1 - p/200) * L;
Mean = Mean .* (Mean > S(round(Lt)));

g = graph;
set_matrix(g, sparse(Mean~=0));

h = graph;
line_graph(h, g);
Mh = matrix(h);

SpectC = [];
for i = 1 : size(M_controls, 3)
    disp(['Control ' num2str(i)]);
    M = M_controls(:,:,i);
    f = getWeightsList(g, M);
    W = SpectralGraphWavelet(Mh, f, 1);
    Mout = Weights2Mat(g, W.sc);
    SpectC = cat(3, SpectC, Mout);
end

% SpectND = [];
% for i = 1 : size(M_ND, 3)
%     disp(['ND ' num2str(i)]);
%     M = M_ND(:,:,i);
%     f = getWeightsList(g, M);
%     W = SpectralGraphWavelet(Mh, f, 1);
%     Mout = Weights2Mat(g, W.sc);
%     SpectND = cat(3, SpectND, Mout);
% end