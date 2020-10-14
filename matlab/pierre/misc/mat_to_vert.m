function Vert = mat_to_vert(sphere_obj, Mat);
% Usage: function Vert = mat_to_vert(sphere_obj, Mat);
%
% Convert the spehrical grid in Mat to the vertex list in MINC format
%
% Inputs
%   SPHERE_OBJ   : Sphere (N vertices) on which the values are mapped.
%   MAT          : Spherical grid containing the value of each vertex
%
% Ouput
%   VERT         : values corresponding to each vertex of the sphere
%
%
% Author: Pierre Besson, v.0.2 Dec, 11 2008 
% Change log
%     + Checked bondary conditions
%     + Compatible with FS

% Test validity of expression
if nargin ~= 2
    help mat_to_vert
    error('Incorrect expression')
end

if nargout ~= 1
    help mat_to_vert
    error('Incorrect expression')
end

% Import .obj file
% [tri,coord_obj,nbr,normal] = mni_getmesh(sphere_obj); Use SurfStatReadSurf instead
Surf = SurfStatReadSurf(sphere_obj);
Surf.coord = Surf.coord';

% Convert cartesian coord to conventional spherical coord
[th_coord,phi_coord,R_coord] = cart2sph(Surf.coord(:, 1), Surf.coord(:, 2), Surf.coord(:, 3));
phi_mni = (th_coord >= 0) .* th_coord + (th_coord < 0) .* (2 * pi + th_coord);
th_mni = pi / 2 - phi_coord;
clear th_coord phi_coord R_coord

% Create spherical grid
if size(Mat, 1) ==  size(Mat, 2)
    [phi_grid, th_grid] = sphgrid(size(Mat, 1));
    th_shift = 0;
else
    [phi_grid, th_grid] = sphgrid(size(Mat, 1)-1, size(Mat, 2), 'withpoles');
    th_shift = th_grid(2, 1);
end

% Periodization of the data
Mat_per = repmat(Mat, 3, 3);
%% FINE NO MORE WORK TO DO FOR BONDARY CONDITIONS
% Bondary conditions
%NC = size(Mat, 2);
%Mat_per(:, NC) = flipdim(Mat_per(:, NC), 1);
%Mat_per(:, end-NC:end) = flipdim(Mat_per(:, end-NC:end), 1);
%clear NC;
%%
%
phi_per = [phi_grid - 2*pi, phi_grid, phi_grid + 2*pi; phi_grid - 2*pi, phi_grid, phi_grid + 2*pi; phi_grid - 2*pi, phi_grid, phi_grid + 2*pi];
th_per = [th_grid - pi - th_shift, th_grid - pi - th_shift, th_grid - pi - th_shift; th_grid, th_grid, th_grid; th_grid + pi + th_shift, th_grid + pi + th_shift, th_grid + pi + th_shift];

% Resampling
Vert = interp2(phi_per, th_per, Mat_per, phi_mni, th_mni, 'nearest');
if sum(isnan(Vert)) ~= 0
    warning('NaN values in the output')
end
