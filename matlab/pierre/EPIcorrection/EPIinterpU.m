function U_out = EPIinterpU(U_in, V_in, V_out)
% usage : U_out = EPIinterpU(U_in, V_in, V_out)
%
% Inputs :
%       U_in          : Input displacement field
%       V_in          : SPM image structure or path on which U_in was computed
%       V_on          : SPM image structure or path on which interpolate U_in
%
% Options :
%       U_out         : Interpolarted displacement field
%
%
% Pierre Besson @ CHRU Lille, Dec. 2011

if nargin ~= 3
    error('invalid usage');
end

if isstr(V_in)
    V_in = spm_vol(V_in);
end

if isstr(V_out)
    V_out = spm_vol(V_out);
end

[Y_out, XYZ_out] = spm_read_vols(V_out);
[Y_in, XYZ_in] = spm_read_vols(V_in);

F = TriScatteredInterp(XYZ_in(1,:)', XYZ_in(2,:)', U_in(:), 'nearest');

U_out = F(XYZ_out(1,:)', XYZ_out(2,:)');

U_out = reshape(U_out, size(Y_out));
U_out(~isfinite(U_out)) = 0;
U_out(:,end-1) = U_out(:, end-2);
U_out(:,end) = U_out(:, end-2);

% Voxels dim ratio
y_size_in = sqrt( sum( V_in.mat(1:3,2) .* V_in.mat(1:3,2) ) );
y_size_out = sqrt( sum( V_out.mat(1:3,2) .* V_out.mat(1:3,2) ) );

U_out = U_out .* y_size_in ./ y_size_out;