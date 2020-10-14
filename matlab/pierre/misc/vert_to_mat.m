function Mat = vert_to_mat(sphere_obj, vert, Option, ntheta, nphi);
% Usage: function Mat = vert_to_mat(sphere_obj, vert, Option, [ntheta], [nphi]);
%
% Convert vertices mapped on spherical MNI .obj to a matrix usable for
% spherical filtering
%
% Inputs - Mandatory
%   SPHERE_OBJ   : Sphere (N vertices) on which the values are mapped.
%   VERT         : Text file containing the values corresponding to each
%                  vertex
%   OPTION       : 'wav' to have MAT ready for wavelet analysis
%                      MAT will be a (2^N)+1 x 2^M matrix
%                  'corr' to have MAT ready for filter convolution
%                      MAT will be a (2^N) x (2^N) matrix
% Options
%   NTHETA       : Size of the spherical grid along theta (power of 2)
%   NPHI         : Size of the spherical grid along phi (power of 2)
%
% Ouput
%   MAT          : Spherical grid containing the value of each vertex
%
% The input sphere has to be resampled to fit the dimension condition (be
% power of 2) necessary for surface filtering.
%
% Author: Pierre Besson, v.0.2 Dec, 11 2008
%
% Change log
% v.0.2
%   + Read FS surface
%   + Checked bondary conditions
%   + Added options to specify spherical grid size
%   + Require SurfStat Toolbox

% Test validity of expression
if nargin ~= 3 & nargin ~= 5
    help vert_to_mat
    error('Incorrect expression')
end

if nargin == 5
	XX = log2(ntheta);
	XXX = log2(nphi);
	if ceil(XX) ~= floor(XX) | ceil(XXX) ~= floor(XXX)
		error('NTHETA and NPHI must be power of 2');
	end
	clear XX XXX
end

if nargout ~= 1
    help vert_to_mat
    error('Incorrect expression')
end

% Read vertex values
% Vert = load(vert); Use SurfStatReadData instead
Vert = SurfStatReadData(vert)';


% Import .obj file
% [tri,coord_obj,nbr,normal] = mni_getmesh(sphere_obj); Use SurfStatReadSurf instead
[Surf, ab] = SurfStatReadSurf(sphere_obj);
Surf.coord = Surf.coord';


% Convert cartesian coord to conventional spherical coord (Given that Matlab spherical coordinates are non-conventional)
[th_coord,phi_coord,R_coord] = cart2sph(Surf.coord(:, 1), Surf.coord(:, 2), Surf.coord(:, 3));
phi_mni = (th_coord >= 0) .* th_coord + (th_coord < 0) .* (2 * pi + th_coord);
th_mni = pi / 2 - phi_coord;
clear th_coord phi_coord R_coord

% Define the dimension of MAT
if nargin == 3
	L=size(th_mni, 1);
	N=1;
	if strcmp(Option, 'wav')
	while (2^N+1) .* 2^(N+1) < L
		N = N+1;
	end
	[phi_grid, th_grid] = sphgrid(2^N, 2^(N+1), 'withpoles');
	else
	if strcmp(Option, 'corr')
		N = ceil(log2(L)/2);
		[phi_grid, th_grid] = sphgrid(2^N);
	else
		help vert_to_mat
		error('Invalid ''Option'' argument')
	end
	end
else
    N = ceil(max(log2(ntheta),log2(nphi)));
	if strcmp(Option, 'wav')
		[phi_grid, th_grid] = sphgrid(ntheta, nphi, 'withpoles');
	else
	if strcmp(Option, 'corr')
		[phi_grid, th_grid] = sphgrid(ntheta, nphi);
    end
    end
end

[temp_phi, temp_th] = meshgrid(linspace(-0.1, 2*pi+0.1, 2^(N+1)+1), linspace(-0.1, pi+0.1, 2^(N+1)+1));

% Construct a grid larger than [phi_grid, th_grid] not to have NaN close to
% the grid boundaries
Mat_temp = griddata(phi_mni, th_mni, Vert, temp_phi, temp_th, 'nearest');
% Subsample the large grid to fit [phi_grid, th_grid]
Mat = interp2(temp_phi, temp_th, Mat_temp, phi_grid, th_grid, 'nearest');
if sum(sum(isnan(Mat))) ~= 0
    warning('NaN values in output');
end
