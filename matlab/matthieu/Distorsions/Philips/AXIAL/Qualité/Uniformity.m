function [Uniz0,Uniz1,Uniz2,Uniz3,Uniz4,Uniz5,UniP1,UniP2] = Uniformity(name,rzp,rzc)

    %% Récupération des informations DICOM
   
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info);  
    
    %% Binarisation de l'image
    level = graythresh(Ima1);
    Ima2 = im2bw(Ima1,level);
    
    %% Labellisation disque et calcul du centre de gravité
    [L,num]=bwlabel(Ima2);
    reg=regionprops(L,'Centroid');  
    CenterIma=[reg.Centroid(1) reg.Centroid(2)];
    
    %% Calcul coordonnées extrêmités profils horizontaux et verticaux
    Xhor = [CenterIma(1,1)-rzp;CenterIma(1,1)+rzp];
    Yhor = [CenterIma(1,2);CenterIma(1,2)];
    Xver = [CenterIma(1,1);CenterIma(1,1)];
    Yver = [CenterIma(1,2)-rzp;CenterIma(1,2)+rzp];   
    
    %% Affichage zones d'intérêt et profils pour l'uniformité
    figure (1)
    imshow(Ima1,[],'InitialMagnification','fit'); hold on
    circle([rzp;rzc;rzc;rzc;rzc;rzc],[CenterIma;CenterIma(1,1) CenterIma(1,2)+(rzp-rzc);CenterIma(1,1) CenterIma(1,2)-(rzp-rzc);CenterIma(1,1)+(rzp-rzc) CenterIma(1,2);CenterIma(1,1)-(rzp-rzc) CenterIma(1,2);CenterIma],'r');
    text('fontsize',14);
    text(CenterIma(1,1),CenterIma(1,2),'1','color','red');
    text(CenterIma(1,1),CenterIma(1,2)+(rzp-rzc),'5','color','red');
    text(CenterIma(1,1),CenterIma(1,2)-(rzp-rzc),'3','color','red');
    text(CenterIma(1,1)+(rzp-rzc),CenterIma(1,2),'2','color','red');
    text(CenterIma(1,1)-(rzp-rzc),CenterIma(1,2),'4','color','red');
    text(CenterIma(1,1)-rzp/2,CenterIma(1,2)-rzp/2,'0','color','red');
    plot(Xhor,Yhor,'g');
    plot(Xver,Yver,'b');
    hleg = legend('P1','P2');
    hold off
    
    %% Extraction des ROIs circulaires d'intérêts
    ROIz1 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2),rzc);
    ROIz2 = RoiCircleCrop(Ima1,CenterIma(1,1)+(rzp-rzc),CenterIma(1,2),rzc);
    ROIz3 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2)-(rzp-rzc),rzc);
    ROIz4 = RoiCircleCrop(Ima1,CenterIma(1,1)-(rzp-rzc),CenterIma(1,2),rzc);
    ROIz5 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2)+(rzp-rzc),rzc);
    ROIz0 = RoiCircleCrop(Ima1,CenterIma(1,1),CenterIma(1,2),rzp);
   
    %% Calcul des paramètres d'uniformité pour les ROIs cicurlaires et les profils
    [Uni1 Uni2 NUni] = UniformityParameters('ROI',ROIz0);
    Uniz0 = [Uni1 Uni2 NUni];
    [Uni1 Uni2 NUni] = UniformityParameters('ROI',ROIz1);
    Uniz1 = [Uni1 Uni2 NUni];
    [Uni1 Uni2 NUni dCB] = UniformityParameters('ROI',ROIz2,ROIz1,ROIz0);
    Uniz2 = [Uni1 Uni2 NUni dCB];
    [Uni1 Uni2 NUni dCB] = UniformityParameters('ROI',ROIz3,ROIz1,ROIz0);
    Uniz3 = [Uni1 Uni2 NUni dCB];
    [Uni1 Uni2 NUni dCB] = UniformityParameters('ROI',ROIz4,ROIz1,ROIz0);
    Uniz4 = [Uni1 Uni2 NUni dCB];
    [Uni1 Uni2 NUni dCB] = UniformityParameters('ROI',ROIz5,ROIz1,ROIz0);
    Uniz5 = [Uni1 Uni2 NUni dCB];
    [Uni1 Uni2 NUni dCH dCB] = UniformityParameters('profil_vert',ROIz1,ROIz0,ROIz3,ROIz5);
    UniP1 = [Uni1 Uni2 NUni dCH dCB];
    [Uni1 Uni2 NUni dCG dCD] = UniformityParameters('profil_horiz',ROIz1,ROIz0,ROIz4,ROIz2);
    UniP2 = [Uni1 Uni2 NUni dCG dCD];
