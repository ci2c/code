function CBF = aslmap_new(Mz,deltaM0,outname)

% %
% % help : CBF=aslmap1(Mz,diff)
% % Mz : image control
% % diff : image de différence
% 
% 
% % NSLICE=size(Mz.vol,3);
% % matrix=size(Mz.vol,2);
% % CBF=deltaM0;
% % Vol_denoise=zeros(matrix,matrix,NSLICE);
% % for Nocoupe = 1:NSLICE,
% %     ImageT=deltaM0.vol(:,:,Nocoupe);
% %     Image_norm = ImageT ./ max(ImageT(:));
% %     Sigma = 2.5;
% %     [PSNR, ima_temp] = BM3D(1, Image_norm, Sigma);
% %     Vol_denoise(:,:,Nocoupe) = ima_temp.*max(ImageT(:));
% % 
% % end
% TE=14;
% 
% V1=spm_vol(Mz);
% V2=spm_vol(deltaM0);
% %V3=spm_vol(mask);
% 
% data1=spm_read_vols(V1);
% data2=spm_read_vols(V2);
% %data3=spm_read_vols(V3);
% 
% Z=(1:size(data2,3))';
% B=repmat(Z, [1 size(data2,1) size(data2,2)]);
% C=permute(B,[3 2 1]);
% 
% CBFtemp=(6000*data2.*exp(1.525+(0.035.*(C-1))./1.68))./(2.*0.85.*0.76.*1.68.*data1);
% CBF=CBFtemp;
% %CBF=CBFtemp.*data3;
% 
% V1.fname=outname;
% spm_write_vol(V1,CBF);

% function aslmap_new(Mz,deltaM0,outname)
% 
% %
% % help : CBF=aslmap1(Mz,diff)
% % Mz : image control
% % diff : image de différence
% 
% 
% % NSLICE=size(Mz.vol,3);
% % matrix=size(Mz.vol,2);
% % CBF=deltaM0;
% % Vol_denoise=zeros(matrix,matrix,NSLICE);
% % for Nocoupe = 1:NSLICE,
% %     ImageT=deltaM0.vol(:,:,Nocoupe);
% %     Image_norm = ImageT ./ max(ImageT(:));
% %     Sigma = 2.5;
% %     [PSNR, ima_temp] = BM3D(1, Image_norm, Sigma);
% %     Vol_denoise(:,:,Nocoupe) = ima_temp.*max(ImageT(:));
% % 
% % end
% %TE=14;

V1=spm_vol(Mz);
V2=spm_vol(deltaM0);


data1=spm_read_vols(V1);
data2=spm_read_vols(V2);

data2(~isfinite(data2(:))) = 0;
Z=(1:size(data2,3))';
B=repmat(Z, [1 size(data2,1) size(data2,2)]);
C=permute(B,[3 2 1]);

CBFtemp=6000.*data2.*exp(1.525./1.68)./(2.*0.85.*0.76.*1.68.*data1);

V1.fname=outname;
spm_write_vol(V1,CBFtemp);
