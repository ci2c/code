function Normals = getSurfTriNormals(Surf)
% usage : function Normals = getSurfTriNormals(Surf)
%
% Returns triangles normals of a Surf structure
%
% See also SurfStatReadSurf, save_surface_vtk
%
% Pierre Besson @ CHRU Lille, May 2013

assert(nargin==1, 'invalid usage');

u1 = Surf.coord(:,Surf.tri(:,1));
d1 = Surf.coord(:,Surf.tri(:,2))-u1;
d2 = Surf.coord(:,Surf.tri(:,3))-u1;
Normals = cross(d1,d2,1);
Normals = (Normals ./ (ones(3,1) * sqrt(sum(Normals.^2, 1))))';