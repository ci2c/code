% surf_lh='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/lh.white.ras';
% surf_rh='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/surf/rh.white.ras';
% fibers='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/whole_brain_6_1500000_endpoints.tck';
% fibers='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/whole_brain_6_1500000_part000002.tck'
% ref_vol_native='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_native_ras.nii';
% ref_vol_dti='/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/lohata_enc/dti/t1_dti_ras.nii';
surf_lh='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/surf/lh.white.ras';
surf_rh='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/surf/rh.white.ras';
fibers='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/whole_brain_6_1500000.tck';
ref_vol_native='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/t1_native_ras.nii';
ref_vol_dti='/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/t1_dti_ras.nii';
thresh=0;
fiberNumber=1;

surf = SurfStatReadSurf({[surf_lh], [surf_rh]});

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

T = ref_vol_dti.vox2ras/ref_vol_native.vox2ras;
surf.coord = [surf.coord; ones(1, length(surf.coord))];
surf.coord = T * surf.coord;
surf.coord(4,:) = [];


P0=int8(surf.coord(:,surf.tri(:, 1))'.*1000);
P1=int8(surf.coord(:,surf.tri(:, 2))'.*1000);
P2=int8(surf.coord(:,surf.tri(:, 3))'.*1000);

Connectome=sparse(double(fibers.nFiberNr),size(surf.tri,1));
g=gpuDevice(1);

for fiberNumber=1:fibers.nFiberNr
    D=[int8(fibers.fiber(fiberNumber).xyzFiberCoord .* 1000 )]';
    %size(D)
    %T=pdist2([P0;P1;P2],((D(:,2:1:end))-(D(:,1:1:end-1)))');
    %min(T(:))
    %T2=find(T<0.2);
    a=D(:,2:1:end);
    b=D(:,1:1:end-1);
    %if (size(T2(:),1)>0)
    gpuC=gpuArray((a-b)');
    b=b';    
    fiberNumber
    %fibre (attention je prends seulement 1 point sur 2
    flag = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)', P1(:,1)', P1(:,2)', P1(:,3)', P2(:,1)', P2(:,2)', P2(:,3)', b(:,1), b(:,2), b(:,3),gpuC(:,1),gpuC(:,2),gpuC(:,3),0.2); 
    if (max(flag(:)) > 0)
        [argvalue, argmax] = max(flag);
        %Connectome(fiberNumber,argvalue)=1;  
    end
end

save '/NAS/tupac/protocoles/alexcis/FS53/p_AR28/dti/Connectome_endpoints.mat' Connectome -v7.3
%%%%%
%Pour une fibre
%%%%%
% fiberNumber=543;
% D=[single(fibers.fiber(fiberNumber).xyzFiberCoord)]';
% a=D(:,2:end);
% b=D(:,1:end-1);
% c=a-b;
% gpuC=gpuArray(c);
% flag = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)', P1(:,1)', P1(:,2)', P1(:,3)', P2(:,1)', P2(:,2)', P2(:,3)', b(:,1), b(:,2), b(:,3),gpuC(:,1),gpuC(:,2),gpuC(:,3),0.2);         
% Connectome=gather(sum(flag));          
% 
% nfibersRV = int32(1);
% triRV = int32(surf.tri);
% coordRV = single(surf.coord);
% fib_coordRV = single(cat(1, fibers.fiber(fiberNumber).xyzFiberCoord));
% [iRV, jRV, XRV, YRV, ZRV] = fast_triangle_matrix(coordRV, triRV, fib_coordRV, idsRV, nfibersRV);
% ConnectomeStruct = sparse(iRV+1,jRV+1,ones(size(iRV)),double(nfibersRV),length(surf.tri))
% ConnectomeStruct = full(ConnectomeStruct);
% 
% figure ; hold on;
% plot3(surf.coord(1,surf.tri(find(ConnectomeStruct),:)),surf.coord(2,surf.tri(find(ConnectomeStruct),:)),surf.coord(3,surf.tri(find(ConnectomeStruct),:)),'or')
% plot3(P0(find(Connectome(:)),:),P1(find(Connectome(:)),:),P2(find(Connectome(:)),:),'*g')
% plot3(fibers.fiber(fiberNumber).xyzFiberCoord(:,1),fibers.fiber(fiberNumber).xyzFiberCoord(:,2),fibers.fiber(fiberNumber).xyzFiberCoord(:,3),'r')
% %plot3(fibers.fiber(fiberNumber-1).xyzFiberCoord(:,1),fibers.fiber(fiberNumber-1).xyzFiberCoord(:,2),fibers.fiber(fiberNumber-1).xyzFiberCoord(:,3),'r')
% %plot3(fibers.fiber(fiberNumber+1).xyzFiberCoord(:,1),fibers.fiber(fiberNumber+1).xyzFiberCoord(:,2),fibers.fiber(fiberNumber+1).xyzFiberCoord(:,3),'r')
% hold off;