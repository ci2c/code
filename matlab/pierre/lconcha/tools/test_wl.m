
close all
clear all


[Im, Hdr] = getsigna3('C:/matlab/SNR_Viewer/005/I.001');
[Im2, Hdr] = getsigna3('C:/matlab/SNR_Viewer//007/I.001');

Im = ones(256,256);
Im(200:220,100:120) = 2;
Im(100:120,200:220) = 3;
Im(100:120,100:101) = 4;
Im(200:205,200:220) = 5;
Im(1:2:100,200) = 6;
Im(2:2:102,200) = 7;



Im2 = fliplr(flipud(Im));

%wl_imagesc(Im, [ 20 200]);
%subplot(121)
%imagesc(Im);

%WL_tool;
%axis('equal'); axis('tight'); 

%subplot(122)
%imagesc(Im2);
%axis('equal'); axis('tight'); 


repfactor = 2;

figure
Im = cat(3,Im, Im2);
Im = repmat(Im,[1,1,repfactor]);
Im = Im(:,:,1:end);
i = imagescn(Im,[] , [ 2 2] );
axis('equal');axis('tight'); 
WL_Tool;
PZ_Tool;

ROI_tool;

%figure
%i = imagescn(Im, [], [ 2 3]);
%axis('equal'); axis('tight'); 
%ROI_tool;
