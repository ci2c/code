function output = denoise_RWImage(Image, filt_name, Sigma)
% Usage: Output = denoise_RWImage(Image, [filt_name, Sigma])
%
% Inputs:
%     Image          : Input image structure 
%     filt_name      : Filter to use. Defaut : 'sym8'
%     Sigma          : Noise std dev. Default : use median method
%
% Output:
%     Output      : Denoised image
%
% See also: RWImage
%
% Pierre Besson, Nov. 2009

if (nargin < 1) || (nargin > 3)
    error('Invalid usage');
end

tic;
if nargin == 1
    denoised_rand_seq = OWT_SURELET_denoise(Image.rand_w);
elseif nargin == 2
    denoised_rand_seq = OWT_SURELET_denoise(Image.rand_w, filt_name);
elseif nargin == 3
    denoised_rand_seq = OWT_SURELET_denoise(Image.rand_w, filt_name, Sigma);
end

disp(['Denoising done in ' num2str(toc) ' sec.']);

V_seq = Image.rand_e;
M_check = Image.M_select;

% Reconstruction
disp('Reconstructing image...');
tic;
% output = zeros(size(Image.Image));
% 
% for i = 1 : numel(output)
%     output(i) = mean(denoised_rand_seq(V_seq==i));
% end
N = numel(Image.Image);
output = ReconstructImage(denoised_rand_seq', V_seq', N);
output(:) = output(:) ./ M_check(:);
output = reshape(output, size(M_check, 1), size(M_check, 2));

disp(['Done in ' num2str(toc) ' sec.']);
