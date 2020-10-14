function X = GetAndApplyLinearTransformation(ima_rec,ima_src,ima_app,do_inverse)

%function X = GetAndApplyLinearTransformation(ima_rec,ima_src,ima_app,[do_inverse])
%
%   ima_rec   : Path to registered image (.nii)
%   ima_src   : Path to source image (.nii)
%   ima_app   : Paths to image to be registered (cell of .nii)
%
% Options
%   do_inverse : Apply the inverse transformation
%
% BE CAREFUL: the images defined in the cell "ima_app" will be erased.
%
% Renaud Lopes @ CHR Lille, Aug 2016


if nargin < 3
    disp('error: not enough arguments');
    return;
end

if nargin < 4
    do_inverse=0;
end

% Read header
src = spm_vol(ima_src);
rec = spm_vol(ima_rec);

% Get linear transformation
X = src.mat*inv(rec.mat);

% Apply transformation
for k = 1:length(ima_app)
    
    nii = nifti(ima_app{k});
    if do_inverse
        nii.mat_intent = 'Scanner';
        nii.mat = inv(X)\nii.mat;
    else
        nii.mat_intent = 'Aligned';
        nii.mat = X\nii.mat;
    end
    create(nii);
    
end

