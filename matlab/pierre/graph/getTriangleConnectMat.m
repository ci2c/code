function Connectome = getTriangleConnectMat(surf_lh, surf_rh, fibers, ref_vol_native, ref_vol_dti, thresh)
% usage : CONNECTOME = getTriangleConnectMat(Surf_lh, Surf_rh, fibers, ref_vol_native, ref_vol_dti, [threshold])
%
% INPUTS :
% -------
%    Surf_lh           : Path to left hemisphere surface in native space
%                         or structure as returned by SurfStatReadSurf
%    Surf_rh           : Path to right hemisphere surface in native space
%                         or structure as returned by SurfStatReadSurf
%
%    fibers_path       : Path to MRtrix fibers or fibers structure as
%                         returned by f_readFiber_tck
%
%    ref_vol_native    : Path to reference 1mm isotropic volume in native space (.nii) or
%                         header structure as returned by spm_vol
%    
%    ref_volume_dti    : Path to reference 1mm isotropic volume in dti space (.nii) or
%                         header structure as returned by spm_vol
%
% Option :
%    threshold         : Fiber length threshold when importing fibers.
%                         Default : 0
%
% OUTPUT :
% --------
%    Connectome        : Connectome structure
%
% Pierre Besson @ CHRU Lille, February 2013

if nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

if nargin == 5
    thresh = 0;
end

% load data
if ischar(surf_lh)
    surf_lh = SurfStatReadSurf(surf_lh);
end

if ischar(surf_rh)
    surf_rh = SurfStatReadSurf(surf_rh);
end

if ischar(fibers)
    fibers = f_readFiber_tck(fibers, thresh);
end

if ischar(ref_vol_native)
    ref_vol_native = load_nifti(ref_vol_native);
elseif isstruct(ref_vol_native)
    ref_vol_native = load_nifti(ref_vol_native.fname);
end

if ischar(ref_vol_dti)
    ref_vol_dti = load_nifti(ref_vol_dti);
elseif isstruct(ref_vol_dti)
    ref_vol_dti = load_nifti(ref_vol_dti.fname);
end

% convert surfaces to RAS nii
surf_lh = surf_to_ras_nii(surf_lh, ref_vol_dti, ref_vol_native);
surf_rh = surf_to_ras_nii(surf_rh, ref_vol_dti, ref_vol_native);

% get variable size
nfibers = fibers.nFiberNr;
ntri = length(surf_lh.tri) + length(surf_rh.tri);
xyzFibers = cat(1, fibers.fiber.xyzFiberCoord);
ids = cat(1, fibers.fiber.id);

% create connectome
Connectome.selected = sparse(double(nfibers), double(ntri));
% selected = sparse(nfibers, ntri);

disp('starting the loop');
tic;
% for i = 1 : length(surf_lh.tri)
for i = 1 : 500
    Tri = extract_triangle(surf_lh, i);
    [~, selected_temp] = select_fibers_triangle(Tri, fibers, 0.5, xyzFibers, ids);
    Connectome.selected(:,i) = sparse(selected_temp);
    if mod(i, 1000) == 0
        disp(['Done ' num2str(100*i / length(surf_lh.tri), '%1.2f'), ' % in ' num2str(toc, '%1.2f'), ' sec']);
    end
end

% for i = 1 : length(surf_rh.tri)
%     Tri = extract_triangle(surf_rh, i);
%     [~, selected_temp] = select_fibers_triangle(Tri, fibers, 0.5, xyzFibers, ids);
%     Connectome.selected(:, i + length(surf_lh.tri)) = sparse(selected_temp);
%     if mod(i, 1000) == 0
%         disp(['Done ' num2str(100*i / length(surf_rh.tri), '%1.2f'), ' % in ' num2str(toc, '%1.2f'), ' sec']);
%     end
% end

