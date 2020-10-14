function Normals = getSurfNormals(Surf)
% usage : function Normals = getSurfNormals(Surf)
%
% Returns vertices normals of a Surf structure
%
% See also SurfStatReadSurf, save_surface_vtk
%
% Pierre Besson @ CHRU Lille, Mar 2012

assert(nargin==1, 'invalid usage');

if size(Surf.tri, 1) < size(Surf.tri, 2)
    Surf.tri = Surf.tri';
end

v=size(Surf.coord,2);

u1 = Surf.coord(:,Surf.tri(:,1));
d1 = Surf.coord(:,Surf.tri(:,2))-u1;
d2 = Surf.coord(:,Surf.tri(:,3))-u1;
c  = cross(d1,d2,1);
Normals = zeros(3,v);
for j = 1:3
    for k = 1:3
        AAA = accumarray(Surf.tri(:,j),c(k,:)')';
        try
            Normals(k,:) = Normals(k,:) + AAA;
        catch
            Normals(k,:) = Normals(k,:) + [AAA, zeros(1, length(Normals)-length(AAA))];
        end
    end
end

Normals = Normals ./ (ones(3,1)*sqrt(sum(Normals.^2,1)));