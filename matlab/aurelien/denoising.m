clear all;

%format long;

[fid,chemin]=uigetfile('','MultiSelect', 'on');
% [fid,chemin]=uigetfile('');


if ~ischar(fid)
    nbfile=size(fid, 2);
else
    nbfile=1;
end
% Volumemag = zeros(128);

for n = 1:nbfile,
    if nbfile > 1,
        file=strcat(chemin, char(fid(n)));   
    else
        file=strcat(chemin, char(fid));
    end
    
        eval(['header' num2str(n) '=dicominfo(file)']);
        h = 1:nbfile;
            slopemag=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.Private_2005_100e']);
            slopereal=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_2.Private_2005_140f.Item_1.Private_2005_100e']);
            interceptreal=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_2.Private_2005_140f.Item_1.Private_2005_100d']);
TR=eval('header1.Private_2005_1030');
%             file=strcat(chemin, char(fid(n)));
            dicomfile=dicomread(file);
            dicomfile=squeeze(dicomfile);
end

NBcoupe = eval('header1.NumberOfFrames');
Volumemag=double(dicomfile);
Vol_denoise = zeros(64);
tic

for Nocoupe = 1:NBcoupe,
    ImageT=Volumemag(:,:,Nocoupe);
    Image_norm = ImageT ./ max(ImageT(:));
%     [CA, CH, CV , CD] = dwt2(ImageT, 'db4');
     %Sigma = median(abs(CD(:))) ./ 0.6745;
    Sigma = 2.5;
    [PSNR, ima_denoise] = BM3D(1, Image_norm, Sigma);
    Vol_denoise(:,:,Nocoupe) = ima_denoise.*max(ImageT(:));

end
toc

cut=NBcoupe./2;
control=Volumemag(:,:,1:cut);
label=Volumemag(:,:,cut+1:end);
% diff_noise=control-label;
carto_diff=Vol_denoise(:,:,1:cut)-Vol_denoise(:,:,cut+1:end);

% CBFnoise=1./((2./0.9).*(control./diff_noise)./((exp(-1.2./0.91)-exp(-1.2./0.53))./(0.91-0.53))).*6000;
CBF_denoise=1./((2./0.9).*(control./carto_diff)./((exp(-1.2./0.91)-exp(-1.2./0.53))./(0.91-0.53))).*6000;

figure, colormap gray
subplot(1,2,1);imagesc(CBFnoise(:,:,1),[0 100]);
subplot(1,2,2);imagesc(CBF_denoise(:,:,1),[0 100]);

CBF_mask=CBF_denoise(:,:,1).*mask;
imagesc(CBF_mask(:,:,1),[0 100]);