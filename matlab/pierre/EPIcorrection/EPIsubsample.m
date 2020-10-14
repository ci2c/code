function EPIsubsample(V_in, Factor, V_out_name)
% usage : EPIsubsample(V_in, Factor, V_out_name)
%
% Inputs :
%       V_in          : SPM image structure or path to input image
%       Factor        : Downsampling factor, i.e. 4 means that 1 voxel out
%                         of 4 is kept in each direction
%                       Must be a power of 2
%       V_out_name    : Name of subsampled volume
%
%
%
% Pierre Besson @ CHRU Lille, Dec. 2011

if nargin ~= 3
    error('invalid usage');
end

if isstr(V_in)
    V_in = spm_vol(V_in);
end

if Factor == 1
    [Y_in, XYZ_in] = spm_read_vols(V_in);
    V_in.fname = V_out_name;
    V_out = spm_write_vol(V_in, Y_in);
    return
end

V_out.dim = [length(1 : Factor : V_in.dim(1)), length(1 : Factor : V_in.dim(2)), length(1 : V_in.dim(3))];

V_out.mat = V_in.mat;

S = sqrt(sum(V_out.mat(1:3, 1:3)));

Rotation = V_out.mat(1:3,1:3) ./ repmat(S, 3, 1);

S(1) = S(1) * Factor;
S(2) = S(2) * Factor;

V_out.mat(1:3,1:3) = Rotation * diag(S);

S_orig = V_in.mat * [1;1;1;1];
S_orig = S_orig(1:3);

% V_out.mat(1:3, end) = S_orig - V_out.mat(1:3,1:3) * [1;1;1] + sign(diag(V_out.mat(1:3,1:3))) .* Factor .* [0.5; 0.5; 0];
V_out.mat(1:3, end) = S_orig - V_out.mat(1:3,1:3) * [1; 1; 1];

V_out.dt = V_in.dt;

V_out.pinfo = V_in.pinfo;

V_out.fname = V_out_name;

V_out = spm_create_vol(V_out);

[Y_in, XYZ_in] = spm_read_vols(V_in);

% Y_out = Y_in(1:Factor:end, 1:Factor:end, :);
Y_out = Y_in;

i = 2;
while i <= Factor
    Y_out = dwt2(Y_out, 'haar');
    i = i * 2;
end


V_out = spm_write_vol(V_out, Y_out);