function CBF = aslbm3d(Mz,deltaM0)

%
% help : CBF=aslmap1(Mz,diff)
% Mz : image control
% diff : image de différence


NSLICE=size(Mz,3);
matrix=size(Mz,2);
% CBF=deltaM0;
Vol_denoise=zeros(matrix,matrix,NSLICE);
for Nocoupe = 1:NSLICE
    ImageT=deltaM0(:,:,Nocoupe);
    Imin=min(min(ImageT))
    Imax=max(max(ImageT))
    Image_norm = (ImageT - Imin) ./ (Imax - Imin);
    [PSNR ima_temp] = BM3D(1, Image_norm, 2.5);
    Vol_denoise(:,:,Nocoupe) = (ima_temp.*(Imax - Imin)) + Imin;
    
end
Z=(1:size(deltaM0,3))';
B=repmat(Z, [1 size(deltaM0,1) size(deltaM0,2)]);
C=permute(B,[3 2 1]);

CBF=(6000*Vol_denoise.*exp(1.525+(0.035.*(C-1))./1.68))./(2.*0.85.*1.68.*Mz);
disp('ouaiche')
