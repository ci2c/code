function blurImage(V_in, S, filename)
% usage : blurImage(V_in, S, filename)
%
% Inputs :
%       V             : Structure image
%       S             : SD of the gaussian blurring kernel
%       filename      : output image file name
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 3
    error('invalid usage');
end

V_out = V_in;
V_out.dt(1) = 64;

if S == 0
    [Y_in, XYZ] = spm_read_vols(V_in);
    % Y_in = 8000 * ( (Y_in - min(Y_in(:))) ./ (max(Y_in(:)) - min(Y_in(:))) );
    Y_in = Y_in - min(Y_in(:));
    Y_in = (Y_in ./ sum(Y_in(:))) * 100000;
    V_out.fname = filename;
    V_out = spm_write_vol(V_out, Y_in);
else
    Extension = round(3 * S);

    FWHM = 2 * sqrt(2 * log(2) ) * S;

    V_out.dim = [V_in.dim(1), V_in.dim(2) + 2 * Extension + 1, V_in.dim(3)];

    A = V_in.mat * [0; -Extension; 0; 1];
    V_out.mat(:, end) = A;

    [Y_in, XYZ] = spm_read_vols(V_in);
    
    % Y_in = 8000 * ( (Y_in - min(Y_in(:))) ./ (max(Y_in(:)) - min(Y_in(:))) );
    Y_in = Y_in - min(Y_in(:));
    Y_in = (Y_in ./ sum(Y_in(:))) * 100000;

    Y = zeros(V_out.dim(1), V_out.dim(2), V_out.dim(3));
    Y(:, Extension + 1 : end - Extension - 1, :) = Y_in;
    
    [path_v, name_v, ext_v] = fileparts(V_in.fname);
    if ~isempty(path_v)
        path_v = [path_v, filesep];
    end

    V_out.fname = [path_v, name_v, '_temp', ext_v];

    V_out = spm_write_vol(V_out, Y);

    spm_smooth(V_out, filename, [FWHM FWHM FWHM]);

    delete([path_v, name_v, '_temp', ext_v]);
end