function ASLshift_and_flip(V_back, fout, fout1)
% usage : ASLshift_and_flip(V_back, fout, [fout_shifted])
%
% Inputs :
%       V_back            : Input image (3D) of backward acquisition
%       fout              : Name of the ouput file
%
% Option :
%       fout_shifted      : Name of the shifted output image
%
% Shift the image by 1-voxel AP and flip X direction
%
% Pierre Besson @ CHRU Lille, Apr. 2013

if nargin ~= 2 && nargin ~= 3
    error('invalid usage');
end

V = spm_vol(V_back);

Y = spm_read_vols(V);

Y = circshift(Y, [0 -1 0]);
if nargin == 3
    V.fname = fout1;
    spm_write_vol(V,Y);
end

Y = flipdim(Y, 1);

V.fname = fout;
spm_write_vol(V,Y);