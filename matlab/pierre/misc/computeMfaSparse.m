function Mfa = computeMfaSparse(FA, S)
% usage : Mfa = computeMfaSpare(FA, S);
%
% INPUT :
% -------
%    FIBERS_PATH       : Path to fibers (i.e. '/my/great/fibers.tck')
%
%    FA_PATH           : Path to FA volume (i.e. '/my/volume/fa.nii')
%
%    Connectome        : Input connectome structure
%
% OUTPUT :
% --------
%    Mfa               : FA weighted connectivity matrix
%
% Pierre Besson @ CHRU Lille, Nov. 2011

% To obtain FA and S
% Selection = cat(2,Connectome.region.selected); Tract = f_readFiber_tck('whole_brain_8_150000.tck'); Tract = sampleFibers(Tract, 'fa.nii', 'FA'); FA = cat(1, Tract.fiber.FA_mean); save SFA FA Selection

if nargin ~= 2
    error('invalid usage');
end

% Mfa = sparse(nROI, nROI);
nROI = size(S, 2);
S2 = double(S') * double(S);
S2 = tril(S2, -1);
S = logical(S);
[i, j] = find(S2~=0);
Max = length(i);
mean_FA = zeros(Max, 1);

parfor k = 1 : Max
    S2 = S(:,i(k)) & S(:,j(k));
    mean_FA(k) = mean(FA(S2));
end

Mfa = sparse(i,j,mean_FA, nROI, nROI);

Mfa = Mfa + Mfa';