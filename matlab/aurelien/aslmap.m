function CBF = aslmapt1(Mz,deltaM0,t1)

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
CBF=(6000*deltaM0*exp(1.65+(0.035*(1.525*(C-1)))./1.3))/(2.*0.8.*1.3.*Mz);

else
CBF=1/(2*1.3*exp(-2/1.2)*(exp(2-t1)/1.15-exp(-t1/1.3)*(1-0.75/1.3))*(Mz./deltaM0))*6000;

end
