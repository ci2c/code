magn   = '/home/fatmike/aurelien/SWI/test09/f20111214_12514774_14122011_1251470_7_1_swi3dnosenseV42SWI3DNOSENSE741027AD141211^Xs007a001x1.nii';
realima = '/home/fatmike/aurelien/SWI/test09/f20111214_12514774_14122011_1251470_7_1_swi3dnosenseV42SWI3DNOSENSE741027AD141211^Xs007a001x2.nii';
imaginaryima = '/home/fatmike/aurelien/SWI/test09/f20111214_12514774_14122011_1251470_7_1_swi3dnosenseV42SWI3DNOSENSE741027AD141211^Xs007a001x3.nii';

V=spm_vol(magn);
[pathstr, name] = fileparts(magn);

[hdr,vol]  = niak_read_nifti(magn);
% [hdr,pmask] = niak_read_nifti(phase);
[hdr1 imagin] = niak_read_nifti(realima);
[hdr2 realp] = niak_read_nifti(imaginaryima);

Icomplex=complex(realp, imagin);

H=fspecial('gaussian',[9 9],1);
smoothima=imfilter(Icomplex,H);

Ifilt=Icomplex./smoothima;
phasemask=angle(Ifilt);
mask=zeros(size(vol,1),size(vol,2),size(vol,3));
I=phasemask < 0;
U=phasemask > 0;
mask(I)=1-(abs(phasemask(I))./pi);
mask(U) =1;
SWIima=vol.*(mask.^7);
% subplot(1,2,1); imagesc(SWIima(:,:,15)); title('SWI'); axis equal
% subplot(1,2,2); imagesc(vol(:,:,15)); title('magnitude native'); axis equal
% colormap gray

V.fname=[pathstr filesep 'swi.nii'];
spm_write_vol(V,SWIima);