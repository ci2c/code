function surf = surf_to_ras_nii(insurf, nifti, oldnifti)
%function surf = surf_to_ras_nii(insurf, nifti, [oldnifti])
%
% insurf   : Path to surface or surface structure as given by SurfStatReadSurf
% nifti    : Path to image or MRI structure as returned by load_nifti or path to .nii image
% oldnifti : Path to image or MRI structure as returned by load_nifti or path to .nii image
%                before spm realignement
%
% Pierre Besson @ CHR Lille, Feb 2011

if nargin ~= 2 && nargin ~= 3
    error('invalid usage');
end

if ischar(nifti)
    nifti = load_nifti(nifti);
end

if nargin == 3 && ischar(oldnifti)
    oldnifti = load_nifti(oldnifti);
end

if ischar(insurf)
    insurf = SurfStatReadSurf(insurf);
end

surf = insurf;

if nargin == 2
    surf.coord(1,:) = surf.coord(1,:) + 128 + nifti.vox2ras(1, end);
    surf.coord(2,:) = surf.coord(2,:) + 128 + nifti.vox2ras(2, end);
    surf.coord(3,:) = surf.coord(3,:) + 128 + nifti.vox2ras(3, end);
else
    surf.coord(1,:) = surf.coord(1,:) + 128 + oldnifti.vox2ras(1, end);
    surf.coord(2,:) = surf.coord(2,:) + 128 + oldnifti.vox2ras(2, end);
    surf.coord(3,:) = surf.coord(3,:) + 128 + oldnifti.vox2ras(3, end);
    T = nifti.vox2ras/oldnifti.vox2ras;
    surf.coord = [surf.coord; ones(1, length(surf.coord))];
    surf.coord = T * surf.coord;
    surf.coord(4,:) = [];
end
    