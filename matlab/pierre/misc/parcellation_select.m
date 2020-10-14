function Parc = parcellation_select(Surf, label, tri_label)
% 
% function Parc = parcellation_select(Surf, label, tri_label)
%
% Inputs :
%      Surf       : surface structre as returned by SurfStatReadSurf
%
%      label      : vector of vertices of interest (binary)
%
%      tri_label  : vector of triangles of interest (binary)
%
% Output :
%       Parc      : surface element as delimited by the label
% 
% Pierre Besson, 2010

if nargin ~= 2 && nargin ~=3
    error('invalid usage');
end

if length(Surf.coord) ~= length(label)
    error('Surf.coord and label should have same length');
end

if nargin == 2
    tri_label = getTriangleLabel(Surf, label);
end

% Fill triangles
Tri_label = repmat(tri_label, 1, 3);
Label = unique(Surf.tri(Tri_label~=0));


Parc = Surf;
Parc.coord = Parc.coord(:, Label);
Parc.tri = Parc.tri(tri_label~=0, :);
label = zeros(size(label));
label(Label) = 1 : length(Label);
Parc.tri = label(Parc.tri);