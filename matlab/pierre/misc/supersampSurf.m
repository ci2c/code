function surf_out = supersampSurf(surf)
% usage : surf_out = supersampSurf(surf)
%
% Add nodes to the surface and increase the number of faces by 3
%
% Pierre Besson @ CHRU Lille, Oct. 2013

if nargin ~= 1 || nargout ~= 1
    error('invalid usage');
end

tri   = double(surf.tri);
coord = double(surf.coord);

n_point = length(coord);
n_face  = length(tri);

x_s1  = coord(1, tri(:,1));
x_s2  = coord(1, tri(:,2));
x_s3  = coord(1, tri(:,3));
y_s1  = coord(2, tri(:,1));
y_s2  = coord(2, tri(:,2));
y_s3  = coord(2, tri(:,3));
z_s1  = coord(3, tri(:,1));
z_s2  = coord(3, tri(:,2));
z_s3  = coord(3, tri(:,3));

x_bari = (x_s1 + x_s2 + x_s3) ./ 3;
y_bari = (y_s1 + y_s2 + y_s3) ./ 3;
z_bari = (z_s1 + z_s2 + z_s3) ./ 3;
coord_bari = [x_bari; y_bari; z_bari];
n_bari = length(coord_bari);

coord_out = [coord, coord_bari];

id_bari = n_point+1 : n_point+n_bari;
% id_bari = repmat(id_bari, 3, 1);
% id_bari = id_bari(:);

tri_out = [];
for ii = 1 : n_face
    temp = [tri(ii,1), tri(ii,2), n_point+ii];
    tri_out = [tri_out; temp];
    temp = [tri(ii,1), n_point+ii, tri(ii,3)];
    tri_out = [tri_out; temp];
    temp = [tri(ii,2), tri(ii,3), n_point+ii];
    tri_out = [tri_out; temp];
end

surf_out.coord = coord_out;
surf_out.tri = tri_out;