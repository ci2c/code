function F = mapVolume2Surface(V, Surf, interp_order, volfwhm)
% usage : V = mapVolume2Surface(IMAGE, SURFACE, [interp_order, volFWHM])
%
% Inputs :
%    IMAGE            : SPM image structure or path to an image 
%                           (.nii or .img)
%    SURFACE          : SurfStat structure or path to a surface
%
% Options :
%    interp_order     : interpolation order. Default : 3
%                        type help spm_sample_vol for more info
%
%    volfwhm          : FWHM of the Gaussian kernel used to blur input
%                        image. Defaut : 0
%
% Output :
%    V                : Vector of the feature mapped on surface
%
% Pierre Besson @ CHRU Lille, Mar 2012

if nargin ~= 2 && nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

default_interp_order = 3;
default_volfwhm = 0;

% check args
if nargin < 3
    interp_order = default_interp_order;
end

if nargin < 4
    volfwhm = default_volfwhm;
end

if isempty(interp_order)
    interp_order = default_interp_order;
end

if isempty(volfwhm)
    volfwhm = default_volfwhm;
end

% check inputs
if ischar(V)
    V = spm_vol(V);
end

if ischar(Surf)
    Surf = SurfStatReadSurf(Surf);
end

% Get Surface coordinates in matrix coordinates
coordinates = [Surf.coord; ones(1, size(Surf.coord, 2))];
coordinates = spm_pinv(V.mat) * coordinates;

% blur input vol if needed
if volfwhm ~= 0
    fname_smooth = [V.fname(1:end-4), '_smooth_tmp.nii'];
    spm_smooth(V, fname_smooth, [volfwhm volfwhm volfwhm]);
    V_smooth = spm_vol(fname_smooth);
    F =  spm_sample_vol(V_smooth, coordinates(1,:), coordinates(2,:), coordinates(3,:), interp_order);
    delete(fname_smooth);
else
    F =  spm_sample_vol(V, coordinates(1,:), coordinates(2,:), coordinates(3,:), interp_order);
end