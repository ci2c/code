function fwhm = spm_est_smoothness_surf(BPM)
% Estimation of smoothness based on [residual] images
% FORMAT [fwhm,VRpv] = spm_est_smoothness(VResI,[VM]);
%
% P     - filenames of [residual] images
% PM    - filename of mask image
%
% fwhm  - estimated FWHM in all image directions
% VRpv  - handle of Resels per Voxel image
%_______________________________________________________________________
%  
% spm_est_smoothness returns a spatial smoothness estimator based on the
% variances of the normalized spatial derivatives as described in K.
% Worsley, (1996). Inputs are a mask image and a number of [residual]
% images. Output is a global estimate of the smoothness expressed as the
% FWHM of an equivalent Gaussian point spread function. An estimate of
% resels per voxels (see spm_spm) is written as an image file ('RPV.img')
% to the current directory.
%
% The mask image specifies voxels, used in smoothness estimation, by
% assigning them non-zero values. The dimensions, voxel sizes, orientation 
% of all images must be the same. The dimensions of the images can be of
% dimensions 0, 1, 2 and 3.
% 
% Note that 1-dim images (lines) must exist in the 1st dimension and
% 2-dim images (slices) in the first two dimensions. The estimated fwhm
% for any non-existing dimension is infinity.
%
% 
% Ref:
% 
% K. Worsley (1996). An unbiased estimator for the roughness of a
% multivariate Gaussian random field. Technical Report, Department of
% Mathematics and Statistics, McGill University
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Stefan Kiebel
% $Id: spm_est_smoothness.m 3057 2009-04-09 06:26:50Z volkmar $


% assign input argumants
%-----------------------------------------------------------------------

V = BPM.E ;
VM = BPM.mask;

% intialise
%-----------------------------------------------------------------------
V = double(SurfStatReadData(V));

load(VM);
VM = ~Mask;

%-Initialise RESELS per voxel image
%-----------------------------------------------------------------------
% VRpv  = struct('fname','RPV.img',...
% 			'dim',		VM.dim(1:3),...
% 			'dt',		[spm_type('float64') spm_platform('bigend')],...
% 			'mat',		VM.mat,...
% 			'pinfo',	[1 0 0]',...
% 			'descrip',	'spm_spm: resels per voxel');
% VRpv  = spm_create_vol(VRpv);


% dimensionality of image
%-----------------------------------------------------------------------
N     = 2 - sum(size(VM) == 1);
if N == 0
	fwhm = Inf;
	return
end

% find vertices within mask
%-----------------------------------------------------------------------
I = find(VM);


% compute variance of normalized derivatives in all directions
%-----------------------------------------------------------------------

v     = zeros(length(I),N);
ssq   = zeros(length(I),1);
for i = 1:size(V,1) % for all residual images
	 
    d = V(i,I)';
    dx = [diff(d);0];
	
	v(:, 1) = v(:, 1) + dx.^2;

	ssq  = ssq + d.^2;

end

% normalise derivatives
%-----------------------------------------------------------------------
for i = 1:N
	v(:,i)     = v(:,i)./ssq;
end

% eliminate zero variance voxels
%-----------------------------------------------------------------------
I      = find(isnan(v'));
v(I,:) = [];
I      = find(isinf(v'));
v(I,:) = [];
    

% resels per voxel (resel) 
% resels = resels/voxel = 1/prod(FWHM)
% FWHM   = sqrt(4.ln2/|dv/dx|))
% fwhm   = 1/FWHM
%-----------------------------------------------------------------------

fwhm   = sqrt(v./(4*log(2)));
resel  = prod(fwhm,2);
% for  i = 1:VM.dim(3)
% 	d  = NaN*ones(VM.dim(1:2));
% 	I  = find(Iz == i);
% 	if ~isempty(I)
% 		d(sub2ind(VM.dim(1:2), Ix(I), Iy(I))) = resel(I);
% 	end
% 	VRpv = spm_write_plane(VRpv, d, i);
% end

% global equivalent FWHM {prod(1/FWHM) = (unbiased) RESEL estimator}
%-----------------------------------------------------------------------
fwhm   = mean(fwhm );
RESEL  = mean(resel);
fwhm   = fwhm*((RESEL/prod(fwhm)).^(1/N));
FWHM   = 1./fwhm;
fwhm   = FWHM;




