function Vol_denoise = aslbm3d(Mz,deltaM0)

%
% help : CBF=aslmap1(Mz,diff)
% Mz : image control
% diff : image de différence



Z=(1:size(deltaM0,3))';
B=repmat(Z, [1 size(deltaM0,1) size(deltaM0,2)]);
C=permute(B,[3 2 1]);

CBF=(6000*deltaM0.*exp(1.525+(0.035.*(C-1))./1.68))./(2.*0.85.*1.68.*Mz);
NSLICE=size(Mz,3);
matrix=size(Mz,2);

Vol_denoise=zeros(matrix,matrix,NSLICE);
for Nocoupe = 1:NSLICE,
    ImageT=CBF(:,:,Nocoupe);
    Imin=min(ImageT(:));
    Imax=max(ImageT(:));
    Image_norm = ((ImageT - Imin) ./ (Imax - Imin));
    Sigma = 2.5;
    [PSNR ima_temp] = BM3D(1, Image_norm, Sigma);
    Vol_denoise(:,:,Nocoupe) = (ima_temp.*(Imax - Imin)) + Imin;
% Vol_denoise(:,:,Nocoupe) = ima_temp;

end