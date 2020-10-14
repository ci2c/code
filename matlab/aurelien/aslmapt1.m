function CBF = aslmapt1(Mz,deltaM0,t1)

%
% help : CBF=aslmap1(Mz,diff)
% Mz : image control
% diff : image de différence


% NSLICE=size(Mz.vol,3);
% matrix=size(Mz.vol,2);
% CBF=deltaM0;
% Vol_denoise=zeros(matrix,matrix,NSLICE);
% for Nocoupe = 1:NSLICE,
%     ImageT=deltaM0.vol(:,:,Nocoupe);
%     Image_norm = ImageT ./ max(ImageT(:));
%     Sigma = 2.5;
%     [PSNR, ima_temp] = BM3D(1, Image_norm, Sigma);
%     Vol_denoise(:,:,Nocoupe) = ima_temp.*max(ImageT(:));
% 
% end
Z=(1:size(delta32.vol,3))';
B=repmat(Z, [1 80 80]);
C=permute(B,[3 2 1]);

if nargin==2
CBF=(6000*deltaM0.*exp(1.525+(0.035.*(C-1))./1.68))./(2.*0.85.*1.68.*Mz);
else
CBF=(6000*deltaM0.*exp(1.525+(0.035.*(C-1))./1.68))./(2.*0.85.*1.68.*Mz);
end
