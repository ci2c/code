function FMRI_EPIshift_and_flip(V_back, fout, flip, fout1)

% usage : EPIshift_and_flip(V_back, fout, [fout_shifted, no_shift])
%
% Inputs :
%       V_back            : Input image (3D) of backward acquisition
%       fout              : Name of the ouput file
%                           Shift the image by 1-voxel LR and 1+voxel AP
%
% Option :
%       fout_flipped      : Name of the flipped output image
%       flip              : Set 1 to flip the image along Y direction
%                           Default : do not the flip
%
%
% Renaud Lopes @ CHRU Lille, Mar. 2018


if nargin ~= 2 && nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin < 3
    flip = 0;
end

V = spm_vol(V_back);

Y = spm_read_vols(V);

Y = circshift(Y, [-1 0 0]);
Y = circshift(Y, [0 1 0]);
V.fname = fout;
spm_write_vol(V,Y);

if flip ~= 0
    Y = flipdim(Y, 2);
    V.fname = fout1;
    spm_write_vol(V,Y);
end