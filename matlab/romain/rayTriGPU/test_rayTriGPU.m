
Connectome = getFastTriangleConnectMat('/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/lh.white.ras', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/rh.white.ras', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/whole_brain_6_1500000_part000010.tck', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_native_ras.nii', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_dti_ras.nii')
surf_lh='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/lh.white.ras'
surf_rh='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/rh.white.ras'
fibers='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/whole_brain_6_1500000_part000010.tck'
ref_vol_native='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_native_ras.nii'
ref_vol_dti='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_dti_ras.nii'
thresh=0

tic; [i, j, X, Y, Z] = fast_triangle_matrix(coord, tri, fib_coord, ids, nfibers); toc

gD = gpuArray(fib_coord(1:200000,:));
P1=surf.coord(:,surf.tri(:, 1))';
P1=surf.coord(:,surf.tri(:, 2))';
P2=surf.coord(:,surf.tri(:, 3))';

gD = gpuArray(D);


coord =  [0 0 0 ; 1 0 0 ; 0 1 0 ; 0 0 1 ; 1 1 0 ; 1 0 1 ; 0 1 1]
tri = [1 2 3 ; 1 4 5 ; 1 6 7 ; 2 3 4 ; 2 4 5 ; 2 5 6 ; 2 6 7]
fib_coord = [1 1 0 ; 1 0 1 ; 0 1 1 ; 0 1 2 ; 2 1 0 ; 1 0 3 ; 4 1 0 ]
ids= [1 1 1 2 2 2 3]
nfibers= 7 

tic; [i, j, X, Y, Z] = fast_triangle_matrix(coord, tri, fib_coord, ids, nfibers); toc

tic
gpuDevice(1);
slab=100000;
for R = 1:slab:size(fib_coord,1)
    if (R+slab < size(fib_coord,1))
        D = gpuArray(fib_coord(R:R+slab));
    else
        D = gpuArray(fib_coord(R:end));        
    end    
    [dist, flag] = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)',P1(:,1)', P1(:,2)', P1(:,3)',P2(:,1)', P2(:,2)', P2(:,3)',or(:,1), or(:,2), or(:,3),gD(:,1),gD(:,2),gD(:,3));
    distances(R:R+slab)=gather(dist);
end
gD = gpuArray(fib_coord(R:));
toc

