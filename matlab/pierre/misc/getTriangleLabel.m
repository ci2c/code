function Tri_ROI = getTriangleLabel(Surf, Vertex_label)
% 
% Usage : TRI_ROI = getTriangleLabel(SURF, VERTEX_LABEL)
%
% Inputs :
%      SURF        : surface structure as returned by SurfStatReadSurf
%
%      label       : vector of vertices labels
%
% Output :
%       TRI_ROI    : Labels assigned to triangles
% 
% Pierre Besson @ CHRU Lille, Mar. 2011

if nargin ~=2
    error('invalid usage');
end

Tri_ROI = double(Vertex_label(Surf.tri));
Tri_ROI = double(sum(Tri_ROI, 2) > 1);