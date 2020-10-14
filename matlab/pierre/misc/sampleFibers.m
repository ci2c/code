function tracts_out = sampleFibers(tracts_in, nii_file, fieldname, interp_order)
%
% usage : TRACTS_OUT = sampleFibers(TRACTS_IN, NII_IMAGE, FIELDNAME [, INTERP_ORDER])
%
%   Input :
%        TRACTS_IN       : input tracts structure
%        NII_IN          : input nii image (i.e. '/my/great/image.nii')
%        FIELDNAME       : name of what is sampled along the fibers
%
%   Option :
%        INTERP_ORDER    : interpolation order. Default : 1.
%
%   Output :
%        TRACTS_OUT      : output tracts with added fieldname subfield
%
%	See also f_readFiber_vtk_bin, f_readFiber_tck, FTRtoTracts
%
% Pierre Besson @ CHRU Lille, June 2011

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin == 3
    interp_order = 1;
end

Nfiber = tracts_in.nFiberNr;

% Read nifti
try
    V = spm_vol(nii_file);
catch
    error(['can not load ' nii_file]);
end

Inv_mat = spm_pinv(V.mat);
coordinates = cat(1, tracts_in.fiber.xyzFiberCoord)';
coordinates = [coordinates; ones(1, length(coordinates))];
coordinates = Inv_mat * coordinates;

field = spm_sample_vol(V, double(coordinates(1,:)'), double(coordinates(2,:)'), double(coordinates(3,:)'), interp_order);

clear coordinates V;

% Allocate memory
fieldname_cell = strcat(fieldname, '_mean');
tracts_in.fiber(1).(fieldname) = single(0);
tracts_in.fiber(1).(fieldname_cell) = single(0);
tracts_in.fiber(Nfiber).(fieldname) = 0;
tracts_in.fiber(Nfiber).(fieldname_cell) = 0;

tracts_in.(fieldname).type = 'point';
tracts_in.(fieldname_cell).type = 'cell';

% Loop on fibers
% Lengths = cat(1, tracts_in.fiber.nSelectFiberEndPoint) + 1;
Lengths = cat(1, tracts_in.fiber.nFiberLength);
Lengths = cumsum(double(Lengths));
Lengths = [0; Lengths];

for i = 1 : Nfiber
    tracts_in.fiber(i).(fieldname) = field(Lengths(i) +1 : Lengths(i+1));
    tracts_in.fiber(i).(fieldname_cell) = mean(field(Lengths(i) +1 : Lengths(i+1)));
end

tracts_out = tracts_in;