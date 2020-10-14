function vertex2faces()

surf_lh='surf/lh.white.ras';
surf_rh='surf/rh.white.ras';
surf = SurfStatReadSurf({[surf_lh], [surf_rh]});

hdr=load_nifti('rs_fmri/run01/fcarepi.sm6.rh.nii.gz');
data=squeeze(hdr.vol);
hdr=load_nifti('rs_fmri/run01/fcarepi.sm6.lh.nii.gz');
data=[data ; squeeze(hdr.vol)];

P1=(data(surf.tri(:,1),:));
P2=(data(surf.tri(:,2),:));
P3=(data(surf.tri(:,3),:));
resu=mean([P1(:)'; P2(:)'; P3(:)']);

resu2=reshape(resu,size(P1,1),size(P1,2));
save ${OUT_PATH}/ConnectomeFonc mat

end
