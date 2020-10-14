

[curv, fnum]=read_curv('lh.asl.curv');
[surf, ab] = SurfStatReadSurf('lh.white');
SurfStatView(curv,surf);
SurfStatColLim([0 200]);
Truc.curv=curv;
save_surface_vtk(surf, 'Test8surf.vtk', 'BINARY', Truc);
mask = SurfStatMaskCut( surf );
SurfStatView1( mask, surf, 'Masked average surface' ); 

lcurv1=read_curv('/home/aurelien/ASL/CPT/freesurfer/aurelien/asl/lh.fsaverage.asl.curv');
lcurv2=read_curv('/home/aurelien/ASL/CPT/freesurfer/pierre/asl/lh.fsaverage.asl.curv');
lcurv3=read_curv('/home/aurelien/ASL/CPT/freesurfer/yann/asl/lh.fsaverage.asl.curv');

surfaverage=SurfStatReadSurf('/home/aurelien/ASL/CPT/freesurfer/fsaverage/surf/lh.white');

diff=lcurv1-lcurv2;
SurfStatViewData(diff,surftemp);
SurfStatView1(diff,surftemp);
SurfStatColLim([-200 200])
mask=SurfStatReadData('lh.thickness.fsaverage.mgh');
aslmask=mask(mask==0);
aslmask=mask==0
aslmask=mask~=0;
diffmask=diff.*aslmask';
lcurv3=read_curv('lh.fsaverage.asl.curv');
diff31=lcurv3-lcurv1;
SurfStatView1(diff31,surftemp);
diffmask=diff31.*aslmask;
diffmask=diff31.*aslmask';
SurfStatView1(diffmask,surftemp);
diff31=lcurv3-lcurv2;
diffmask=diff31.*aslmask';
SurfStatView1(diffmask,surftemp);
