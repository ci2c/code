function CBF = denoiseASL3D(M0,deltaM0)

Direc=uigetdir('','Sélectionner le répertoire contenant les données (fichier diff_map et Vol_mean)');

DirList = dir(Direc);
cd(Direc);
for m=1:length(DirList)
        if ~isempty(strfind(DirList(m).name,'diff_map.nii'))
            DiffFile = DirList(m).name;
        end
    if ~isempty(strfind(DirList(m).name,'Vol_1_mean.nii'))
            M0File = DirList(m).name;
    end
end

Vol_denoise=zeros();
tic
for Nocoupe = 1:9,
    ImageT=img.vol(:,:,Nocoupe);
    Image_norm = ImageT ./ max(ImageT(:));
    Sigma = 2.5;
    [PSNR, ima_denoise] = BM3D(1, Image_norm, Sigma);
    Vol_denoise(:,:,Nocoupe) = ima_denoise.*max(ImageT(:));

end
toc

level=0.05.*max(Mz2(:));
mask=Mz2>level;
Mz2=Mz2.*mask;
deltaM0=img.vol.*mask;
% CBF=(1./((2./0.9).*(Mz./deltaM0).*((exp(-1.7.*0.91)-exp(-1.7.*0.53))./(0.91-0.59)))).*6000;

CBF=1/(2*1.3*exp(-2/1.2)*(exp(2-1.7)/1.15-exp(-1.7/1.3)*(1-0.75/1.3))*(Mz./deltaM0))*6000;
