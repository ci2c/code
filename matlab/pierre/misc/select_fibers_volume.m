function tracts = select_fibers_volume(V, tracts, label, xyzFibers, ids)
% 
% function tracts_out = select_fibers_volume(V, tracts, [label, xyzFibers, ids])
%
% Inputs :
%      V             : Path to .nii volume or SPM structure
%      tracts        : tracts structure as provided by f_readFiber*
%
% Options :
%      label         : number of the label of interest (default : non-zero values)
%      xyzFibers     : fibers coordinates (must be provided with ids)
%      ids           : fibers ids (must be provided with xyzFibers)
%
% Output :
%       tracts_out   : fiber structure intersecting the label
% 
% Pierre Besson, Feb. 2012

if nargin ~= 2 && nargin ~= 3 && nargin ~= 5
    error('invalid usage');
end

if nargin < 5
    xyzFibers = cat(1, tracts.fiber.xyzFiberCoord);
    ids = cat(1, tracts.fiber.id);
end

if ischar(V)
    V = spm_vol(V);
end

xyzFibers = [xyzFibers, ones(length(xyzFibers), 1)]';
xyzFibers = spm_pinv(V.mat) * xyzFibers;

T = round(spm_sample_vol(V, xyzFibers(1,:)', xyzFibers(2,:)', xyzFibers(3,:)', 0));

if nargin ~= 2 && ~isempty(label)
    s_ids = unique(ids(T==label));
    % ids(T~=label) = [];
else
    s_ids = unique(ids(T~=0));
    % ids(T==0) = [];
end

% ids = unique(ids);
ids(ismember(ids, s_ids)) = [];
tracts.fiber(ids) = [];
tracts.nFiberNr = length(tracts.fiber);

for i = 1 : tracts.nFiberNr
    tracts.fiber(i).id(:) = i;
end