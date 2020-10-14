function EPIcutimage(V_forw, V_back)
% usage : EPIcutimage(V_forw, V_back)
%
% Inputs :
%       V_forw        : SPM image strcuture or image path to forward image
%       V_back        : SPM image strcuture or image path to backward image
%
% Correct brain extraction by removing misspositioned non-zero voxels
%
% Corrected images will have the same names as originals
%
% Pierre Besson @ CHRU Lille, Jan. 2012

if nargin ~= 2
    error('invalid usage');
end

if ischar(V_forw)
    V_forw = spm_vol(V_forw);
end

if ischar(V_back)
    V_back = spm_vol(V_back);
end

[Y_forw, XYZ_forw] = spm_read_vols(V_forw);
[Y_back, XYZ_back] = spm_read_vols(V_back);

sum_forw = sum(Y_forw, 2);
sum_back = sum(Y_back, 2);

sum_both = sum_forw~=0 & sum_back~=0;

sum_both = repmat(sum_both, [1 size(Y_forw, 2) 1]);

Y_forw = Y_forw .* sum_both;
Y_back = Y_back .* sum_both;

V_forw = spm_write_vol(V_forw, Y_forw);
V_back = spm_write_vol(V_back, Y_back);