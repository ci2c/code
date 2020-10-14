function [SN0,SN1,SN2,SN3,SN4,SN5] = SignalNoise(name,nameb,rzp,rzc)

    %% Récupération des informations DICOM
   
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info); 
    Ima1binfo=dicominfo(nameb);
    Ima1b= dicomread(Ima1binfo); 
    
    
    %% Binarisation de l'image
    level = graythresh(Ima1);
    Ima2 = im2bw(Ima1,level);
    
    %% Labellisation disque et calcul du centre de gravité
    [L,num]=bwlabel(Ima2);
    reg=regionprops(L,'Centroid');  
    CenterIma=[reg.Centroid(1) reg.Centroid(2)];
    
    %% Affichage zones d'intérêt et profils pour l'uniformité
    figure (3)
    subplot(1,2,1)
    imshow(Ima1,[],'InitialMagnification','fit'); hold on
    circle([rzp;rzc;rzc;rzc;rzc;rzc],[CenterIma;CenterIma(1,1) CenterIma(1,2)+(rzp-rzc);CenterIma(1,1) CenterIma(1,2)-(rzp-rzc);CenterIma(1,1)+(rzp-rzc) CenterIma(1,2);CenterIma(1,1)-(rzp-rzc) CenterIma(1,2);CenterIma],'r');
    circle(rzc,[30 30],'g');
    text('fontsize',14);
    text(CenterIma(1,1),CenterIma(1,2),'1','color','red');
    text(CenterIma(1,1),CenterIma(1,2)+(rzp-rzc),'5','color','red');
    text(CenterIma(1,1),CenterIma(1,2)-(rzp-rzc),'3','color','red');
    text(CenterIma(1,1)+(rzp-rzc),CenterIma(1,2),'2','color','red');
    text(CenterIma(1,1)-(rzp-rzc),CenterIma(1,2),'4','color','red');
    text(CenterIma(1,1)-rzp/2,CenterIma(1,2)-rzp/2,'0','color','red');
    text(20,30,'fond','color','green');
    hold off
    subplot(1,2,2)
    imshow(Ima1b,[],'InitialMagnification','fit'); hold on
    circle([rzp;rzc;rzc;rzc;rzc;rzc],[CenterIma;CenterIma(1,1) CenterIma(1,2)+(rzp-rzc);CenterIma(1,1) CenterIma(1,2)-(rzp-rzc);CenterIma(1,1)+(rzp-rzc) CenterIma(1,2);CenterIma(1,1)-(rzp-rzc) CenterIma(1,2);CenterIma],'r');
    circle(rzc,[30 30],'g');
    text('fontsize',14);
    text(CenterIma(1,1),CenterIma(1,2),'1','color','red');
    text(CenterIma(1,1),CenterIma(1,2)+(rzp-rzc),'5','color','red');
    text(CenterIma(1,1),CenterIma(1,2)-(rzp-rzc),'3','color','red');
    text(CenterIma(1,1)+(rzp-rzc),CenterIma(1,2),'2','color','red');
    text(CenterIma(1,1)-(rzp-rzc),CenterIma(1,2),'4','color','red');
    text(CenterIma(1,1)-rzp/2,CenterIma(1,2)-rzp/2,'0','color','red');
    text(20,30,'fond','color','green');
    hold off
    
    %% Extraction des ROIs circulaires d'intérêts
    ROIz1 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2),rzc);
    ROIz2 = RoiCircleCrop(Ima1,CenterIma(1,1)+(rzp-rzc),CenterIma(1,2),rzc);
    ROIz3 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2)-(rzp-rzc),rzc);
    ROIz4 = RoiCircleCrop(Ima1,CenterIma(1,1)-(rzp-rzc),CenterIma(1,2),rzc);
    ROIz5 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2)+(rzp-rzc),rzc);
    ROIz0 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2),rzp);
    ROIzo = RoiCircleCrop(Ima1,30,30,rzc);
    
    ROIz1b = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2),rzc);
    ROIz2b = RoiCircleCrop(Ima1,CenterIma(1,1)+(rzp-rzc),CenterIma(1,2),rzc);
    ROIz3b = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2)-(rzp-rzc),rzc);
    ROIz4b = RoiCircleCrop(Ima1,CenterIma(1,1)-(rzp-rzc),CenterIma(1,2),rzc);
    ROIz5b = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2)+(rzp-rzc),rzc);
    ROIz0b = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2),rzp);
    
    %% Calcul des paramètres de bruit pour les ROIs circulaires
    [SNR Nr Nb] = NoiseParameters(ROIz0,ROIz0b,ROIzo);
    SN0 = [SNR Nr Nb];
    [SNR Nr Nb] = NoiseParameters(ROIz1,ROIz1b,ROIzo);
    SN1 = [SNR Nr Nb];
    [SNR Nr Nb] = NoiseParameters(ROIz2,ROIz2b,ROIzo);
    SN2 = [SNR Nr Nb];
    [SNR Nr Nb] = NoiseParameters(ROIz3,ROIz3b,ROIzo);
    SN3 = [SNR Nr Nb];
    [SNR Nr Nb] = NoiseParameters(ROIz4,ROIz4b,ROIzo);
    SN4 = [SNR Nr Nb];
    [SNR Nr Nb] = NoiseParameters(ROIz5,ROIz5b,ROIzo);
    SN5 = [SNR Nr Nb];
    