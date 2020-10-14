function u = EPIcorrmultiscale(V_forward, V_backward, sigmas, scales, Lambda1, Lambda2)
% usage : U = EPIcorrmultiscale(V_forward, V_backward, [SIGMAS, SCALES, LAMBDA1, LAMBDA2])
%
% Inputs :
%       V_forward          : Path to forward readout EPI (2D image)
%                            (displacements toward +y)
%       V_backward         : Path to backward readout EPI (2D image)
%                            (displacements toward -y)
%       SIGMAS             : SD of the blurring kernels. 
%                     Default : 20:-0.25:0 with 25 iterations each sigma
%       SCALES             : Scales to which subsample input images.
%                            Must be a vector of same length as SIGMAS.
%                     Default : 4 for sigma >= 6 ; 2 for 6 > sigmas > 2;
%                               1 for sigmas <= 2
%       LAMBDA1            : Magnitude displacement term. Default : 0
%       LAMBDA2            : Smoothness field term. Default : 1e-3
%
% Outputs :
%       U                  : Output deformation field
%
% Pierre Besson @ CHRU Lille, Dec. 2011

if nargin ~= 2 && nargin ~= 6
    error('invalid usage');
end

if nargin == 2
    sigmas = 20:-0.25:8;
    scales = 4 * ones(size(sigmas));
    sigmas = [sigmas, 12:-0.25:2];
    scales = [scales, 2 * ones(size(12:-0.25:2))];
    sigmas = [sigmas, 4:-0.25:0];
    scales = [scales, ones(size(4:-0.25:0))];
    sigmas = repmat(sigmas, 20, 1);
    scales = repmat(scales, 20, 1);
    sigmas = sigmas(:);
    scales = scales(:);
    Lambda1 = 0;
    Lambda2 = 1e-3;
end

% Get file names
[path_f, name_f, ext_f] = fileparts(V_forward);
[path_b, name_b, ext_b] = fileparts(V_backward);

if ~isempty(path_f)
    path_f = [path_f, filesep];
end

if ~isempty(path_f)
    path_f = [path_f, filesep];
end

% Subsample images
unique_scales = unique(scales);
V_f = spm_vol(V_forward);
size_x = sqrt( sum( V_f.mat(1:3,1) .* V_f.mat(1:3,1) ) );
size_y = sqrt( sum( V_f.mat(1:3,2) .* V_f.mat(1:3,2) ) );
size_z = sqrt( sum( V_f.mat(1:3,3) .* V_f.mat(1:3,3) ) );
for i = 1 : length(unique_scales)
    Factor = unique_scales(i);
    [s, m] = unix(['mri_convert ', V_forward, ' ', path_f, name_f, '_sub', num2str(Factor), ext_f, ' -vs ', num2str(Factor * size_x), ' ', num2str(Factor * size_y), ' ', num2str(size_z)]);
    [s, m] = unix(['mri_convert ', V_backward, ' ', path_b, name_b, '_sub', num2str(Factor), ext_b, ' -vs ', num2str(Factor * size_x), ' ', num2str(Factor * size_y), ' ', num2str(size_z)]);
end

for i = 1 : length(unique_scales)
    disp(['Use subsampling factor ', num2str(unique_scales(end-i+1))]);
    if i == 1
        u = EPIcorrfast([path_f, name_f, '_sub', num2str(unique_scales(end-i+1)), ext_f], [path_b, name_b, '_sub', num2str(unique_scales(end-i+1)), ext_b], sigmas(scales==unique_scales(end-i+1)), Lambda1, Lambda2);
    else
        u = EPIcorrfast([path_f, name_f, '_sub', num2str(unique_scales(end-i+1)), ext_f], [path_b, name_b, '_sub', num2str(unique_scales(end-i+1)), ext_b], sigmas(scales==unique_scales(end-i+1)), Lambda1, Lambda2, u);
    end
    
    figure, imagesc(u)
    
    if i ~= length(unique_scales)
        u = EPIinterpU(u, [path_f, name_f, '_sub', num2str(unique_scales(end-i+1)), ext_f], [path_f, name_f, '_sub', num2str(unique_scales(end-i)), ext_f]);
    end
end

% delete temporary files
for i = 1 : length(unique_scales)
    delete([path_f, name_f, '_sub', num2str(unique_scales(i)), ext_f], [path_b, name_b, '_sub', num2str(unique_scales(i)), ext_b]);
end

disp('ouaip');