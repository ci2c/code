function Vol_denoise = denoising_BM3D(vol,Sigma)

Vol_denoise=zeros(576,576,25);
tic
for Nocoupe = 1:25,
    ImageT=vol(:,:,Nocoupe);
    Image_norm = ImageT ./ max(ImageT(:));
%     Sigma = 2.5;
    [PSNR, ima_denoise] = BM3D(1, Image_norm, Sigma);
    Vol_denoise(:,:,Nocoupe) = ima_denoise.*max(ImageT(:));

end
toc