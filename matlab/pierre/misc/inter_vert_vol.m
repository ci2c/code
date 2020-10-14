function Vert = inter_vert_vol(vol, surf_coord, fname)
% usage : VERT = inter_vert_vol(VOL, SURF_COORD, [FNAME])
% Interpolate the values of VOL at each vertex whose coordinates are
% SURF_COORD and return the values as the vector VERT.
% Print the values in the file FNAME if provided.

if nargin ~= 2 & nargin ~= 3
    help inter_vert_vol
    error('Incorrect use');
end

if size(surf_coord, 1) < size(surf_coord, 2)
    surf_coord = surf_coord';
end

vol = rotate_to_surf(vol);
Size = size(vol);

Ix = (-Size(1)/2 + 1) : 1 : Size(1)/2;
Iy = -Size(2)/2 : 1 : (Size(2)/2 - 1);
Iz = (-Size(3)/2 + 1) : 1 : Size(3)/2;


[Gx, Gy, Gz] = meshgrid(Ix, Iy, Iz);

Vert = interp3(Gx, Gy, Gz, vol, surf_coord(:, 1), surf_coord(:, 2), surf_coord(:, 3), 'cubic');
if nargin == 3
    File=fopen(fname, 'w');
    fprintf(File, '%f\n', Vert);
    fclose(File);
end