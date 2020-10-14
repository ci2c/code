function Connectome = getFastTriangleConnectMatByGPU(surf_lh, surf_rh, fibers, ref_vol_native, ref_vol_dti, thresh)

if nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

if nargin == 5
    thresh = 0;
end

% load data
if ~ischar(surf_lh)
    error('surf_lh must be a path');
end

if ~ischar(surf_rh)
    error('surf_rh must be a path');
end

surf = SurfStatReadSurf({[surf_lh], [surf_rh]});
% surf = SurfStatReadSurf(surf_lh);

if ischar(fibers)
    if strfind(fibers, '.mat') ~= 0
        load(fibers);
    else
        fibers = f_readFiber_tck(fibers, thresh);
    end
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

% Apply the linear transformation matrix
% surf = surf_to_ras_nii(surf, ref_vol_dti, ref_vol_native);
% surf = surf_to_ras_nii(insurf, nifti, oldnifti)
T = ref_vol_dti.vox2ras/ref_vol_native.vox2ras;
surf.coord = [surf.coord; ones(1, length(surf.coord))];
surf.coord = T * surf.coord;
surf.coord(4,:) = [];

clear ref_vol_dti;
clear ref_vol_native;

% get variable
nfibers = int32(fibers.nFiberNr);
tri = int32(surf.tri);
coord = single(surf.coord);
fib_coord = single(cat(1, fibers.fiber.xyzFiberCoord));
ids = int32(cat(1, fibers.fiber.id));

P0=surf.coord(:,surf.tri(:, 1))';
P1=surf.coord(:,surf.tri(:, 2))';
P2=surf.coord(:,surf.tri(:, 3))';

Connectome=sparse(double(fibers.nFiberNr),size(surf.tri,1));
g=gpuDevice(1);

tic;
for fiberNumber=1:fibers.nFiberNr
    D=[single(fibers.fiber(fiberNumber).xyzFiberCoord)]';
    %size(D)
    %fiberNumber
    %size(D)
    a=D(:,2:4:end);
    b=D(:,1:4:end-1);
    gpuC=gpuArray((a-b)');
    b=b';
    %distance max = 0.4 mm car c'est la distance entre deux points (coord 3D) d'une
    %fibre (attention je prends seulement 1 point sur 2
    flag = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)', P1(:,1)', P1(:,2)', P1(:,3)', P2(:,1)', P2(:,2)', P2(:,3)', b(:,1), b(:,2), b(:,3),gpuC(:,1),gpuC(:,2),gpuC(:,3),0.8); 
    Connectome(fiberNumber,gather(find(flag)))=1;  
end
toc

