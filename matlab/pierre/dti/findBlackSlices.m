function Bad_Slice = findBlackSlices(dti_path, mask_path)
% usage : BAD_SLICES = findBlackSlices(DTI, BRAINMASK)
%
% INPUT :
% -------
%    DTI           : Path to DTI
%    BRAINMASK     : Mask of the brain
%
% OUTPUT :
% --------
%    BLACK_SLICES  : z-score of each slice
%
% Pierre Besson @ CHRU Lille, Feb. 2011

if nargin ~= 2
    error('Invalid usage');
end

dti = load_nifti(dti_path);
Mask = load_nifti(mask_path);
MaskW = sum(Mask.vol, 1);
MaskW = squeeze(sum(MaskW, 2));

% Compute slice-wise mean
[ni, nj, nk, nl] = size(dti.vol);

Slice_mean = zeros(nk, nl-1);

for l = 1 : nl-1
    Vol = dti.vol(:,:,:,l+1) .* (Mask.vol~=0);
    Vol = sum(Vol, 1);
    Vol = squeeze(sum(Vol, 2));
    Slice_mean(:,l) = Vol ./ MaskW;
end


Slice_zs = zeros(nk, nl-1);
for l = 1 : nl-1
    C = 1 : nl-1;
    C(l) = [];
    M = mean(Slice_mean(:, C), 2);
    S = std(Slice_mean(:, C)')';
    Slice_zs(:, l) = (Slice_mean(:, l) - M) ./ S;
end

Slice_zs(isnan(Slice_mean)) = 0;

Bad_Slice = Slice_zs;

