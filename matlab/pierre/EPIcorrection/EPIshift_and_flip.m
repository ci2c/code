function EPIshift_and_flip(V_back, fout, fout1, no_shift)
% usage : EPIshift_and_flip(V_back, fout, [fout_shifted, no_shift])
%
% Inputs :
%       V_back            : Input image (3D) of backward acquisition
%       fout              : Name of the ouput file
%
% Option :
%       fout_shifted      : Name of the shifted output image
%       no_shift          : Set 1 to not shift the image by 1-voxel LR
%                           Default : does the shift
%
%
% Flip along Y direction
%
% Pierre Besson @ CHRU Lille, Jan. 2013

if nargin ~= 2 && nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin ~= 4
    no_shift = 0;
end

V = spm_vol(V_back);

Y = spm_read_vols(V);

if no_shift ~= 0
    Y = circshift(Y, [-1 0 0]);
    V.fname = fout1;
    spm_write_vol(V,Y);
end

Y = flipdim(Y, 2);
V.fname = fout;
spm_write_vol(V,Y);