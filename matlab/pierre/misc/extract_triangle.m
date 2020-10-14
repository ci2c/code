function surf = extract_triangle(surf, tri_id)
% 
% function triangle = extract_triangle(surf, tri_id)
%
% Inputs :
%      surf       : surface structure as returned by SurfStatReadSurf
%
%      tri_id     : ID of triangle to extract
%
% Output :
%       triangle  : surface structure containing only one triangle
% 
% Pierre Besson @ CHRU Lille, Feb. 2013

if nargin ~= 2
    error('invalid usage');
end

ntri = length(surf.tri);

if tri_id > ntri
    error('tri ID must not be superior to the number of triangles in surf');
end

tri = surf.tri(tri_id, :);

coord = surf.coord(:,tri(1));
coord = [coord, surf.coord(:,tri(2))];
coord = [coord, surf.coord(:,tri(3))];

surf.tri = [1 2 3];
surf.coord = coord;