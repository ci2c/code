% coord =  [0 0 0 ; 1 0 0 ; 0 1 0 ; 0 0 1 ; 1 1 0 ; 1 0 1 ; 0 1 1]
% tri = [1 2 3 ; 1 4 5 ; 1 6 7 ; 2 3 4 ; 2 4 5 ; 2 5 6 ; 2 6 7]
% fib_coord = [1 1 0 ; 1 0 1 ; 0 1 1 ; 0 1 2 ; 2 1 0 ; 1 0 3 ; 4 1 0 ]
% ids= [1 1 1 2 2 2 3]
% nfibers= 7 
% gD = gpuArray(fib_coord(1:200000,:));
% fibShort = fib_coord(1:100000,:);
% idsShort = ids(1:100000,:);
% nfibersShort= 339;
% tic; [i, j, X, Y, Z] = fast_triangle_matrix(coord, tri, fib_coordShort, idsShort, nfibersShort); toc
%
%Connectome = getFastTriangleConnectMat('/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/lh.white.ras', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/rh.white.ras', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/whole_brain_6_1500000_part000010.tck', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_native_ras.nii', '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_dti_ras.nii')
surf_lh='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/surf/lh.white.ras';
surf_rh='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/surf/rh.white.ras';
fibers='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/whole_brain_6_1500000_part000010.tck';
ref_vol_native='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/t1_native_ras.nii';
ref_vol_dti='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/t1_dti_ras.nii';

surf_lh='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/lh.white.ras'
surf_rh='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/rh.white.ras'
fibers='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/whole_brain_6_1500000_part000010.tck'
ref_vol_native='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_native_ras.nii'
ref_vol_dti='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_dti_ras.nii'
thresh=0

nfibers = int32(fibers.nFiberNr);
tri = int32(surf.tri);
coord = single(surf.coord);
fib_coord = single(cat(1, fibers.fiber.xyzFiberCoord));
ids = int32(cat(1, fibers.fiber.id));

tic; [i, j, X, Y, Z] = fast_triangle_matrix(coord, tri, fib_coord, ids, nfibers); toc

% get variable
nfibers = 1 ;% int32(fibers.nFiberNr);
tri = int32(surf.tri);
coord = single(surf.coord);

P0=surf.coord(:,surf.tri(:, 1))';
P1=surf.coord(:,surf.tri(:, 2))';
P2=surf.coord(:,surf.tri(:, 3))';

for tmpVal=1:10000
    g=gpuDevice(1);
    fib_coord = [single(fibers.fiber(tmpVal).xyzFiberCoord)];
%    ids = [ int32(fibers.fiber(1).id)];
    a=fib_coord(2:end,:);
    b=fib_coord(1:end-1,:);
    c=a-b;
    gpuC=gpuArray(c);
    [dist, flag] = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)', P1(:,1)', P1(:,2)', P1(:,3)', P2(:,1)', P2(:,2)', P2(:,3)', b(:,1), b(:,2), b(:,3),gpuC(:,1),gpuC(:,2),gpuC(:,3));
    %flagT = true(size(c,1),1); 
    %flagT(sum(isnan(dist),2) == size(P0,1)) = false;
    %reset(g);
    %clear gpuC;
    %clear fib_coord dist flag a b c gpuC;   
end

%ResuPierre
poly=surf.tri(Connectome.j(find(Connectome.i==0)),:)                                                       
%ou
poly=surf.tri(j(find(i==0)),:)                                                       
%ou
poly=surf.tri(jRV(find(iRV==0)),:)  

invpoly=poly' 
resuPierre=surf.coord(:,invpoly(:));   
resuPierreInv=resuPierre' 

nfibers = int32(1);
triRV = int32(surf.tri);
coordRV = single(surf.coord);
fib_coordRV = single(cat(1, fibers.fiber(1).xyzFiberCoord));
idsRV = int32(cat(1, fibers.fiber(1).id));

tic; [iRV, jRV, XRV, YRV, ZRV] = fast_triangle_matrix(coordRV, triRV, fib_coordRV, idsRV, nfibersRV); toc

ConnectomeRV.i  = i;
ConnectomeRV.j  = j;
ConnectomeRV.X  = X;
ConnectomeRV.Y  = Y;
ConnectomeRV.Z  = Z;
ConnectomeRV.nx = double(nfibers);
ConnectomeRV.ny = double(length(surf.tri));


%ResuRomain
distR=gather(dist);
flagR=gather(flag);
test=find(flagR==true);
iRV=mod(test(find((distR(test)<2) & (distR(test)>0)>0)),size(flagR,1));
polyRV=surf.tri(iRV,:)                                                       
invpolyRV=polyRV'; 
resuRV=surf.coord(:,invpolyRV(:));   
resuRVInv=resuRV' 

figure ; hold on;
%plot3(surf.coord(1,1:100:end),surf.coord(2,1:100:end),surf.coord(3,1:100:end),'.')
plot3(resuPierreInv(:,1),resuPierreInv(:,2),resuPierreInv(:,3),'or')
%plot3(resuRVInv(:,1),resuRVInv(:,2),resuRVInv(:,3),'*g')
plot3(fibers.fiber(1).xyzFiberCoord(:,1),fibers.fiber(1).xyzFiberCoord(:,2),fibers.fiber(1).xyzFiberCoord(:,3),'r')
hold off;

azerty=surf.coord(:,surf.tri(mod(37228871,431082),:))';

figure ; hold on;
plot3(surf.coord(1,1:1:end),surf.coord(2,1:1:end),surf.coord(3,1:1:end),'.')
for tmpVal=1:10:10000
    plot3(fibers.fiber(tmpVal).xyzFiberCoord(:,1),fibers.fiber(tmpVal).xyzFiberCoord(:,2),fibers.fiber(tmpVal).xyzFiberCoord(:,3),'r');
end
hold off;


P0x=resuPierre(1);
P0y=resuPierre(2);
P0z=resuPierre(3);
P1x=resuPierre(4);
P1y=resuPierre(5);
P1z=resuPierre(6);
P2x=resuPierre(7);
P2y=resuPierre(8);
P2z=resuPierre(9);

orx= b(:,1);
ory= b(:,1);
orz= b(:,1);

Dx=c(1,1);
Dy=c(1,2);
Dz=c(1,3);

[dist, flag] = arrayfun(@rayTriGPU, (P0x,P0y,P0z,P1x,P1y,P1z,P2x,P2x,P2z,Dx,Dy,Dz,orx);
rayTRIGPU(P0x,P0y,P0z,P1x,P1y,P1z,P2x,P2x,P2z,Dx,Dy,Dz,orx)

% tic
% slab=9;
% or=zeros(slab,3);
% for R = 1:slab:size(fib_coord,1)
%     R
%     gpuDevice;
%     if (R+slab < size(fib_coord,1))
%         gD = gpuArray(fib_coord(R:R+slab));
%     else
%         gD = gpuArray(fib_coord(R:end));        
%     end    
%     [dist, flag] = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)',P1(:,1)', P1(:,2)', P1(:,3)',P2(:,1)', P2(:,2)', P2(:,3)',or(:,1), or(:,2), or(:,3),gD(:,1),gD(:,2),gD(:,3));
%     distances(R:R+slab)=gather(dist);
%     flagConnect(R:R+slab)=gatfast_triangleher(flag);
% end
% toc