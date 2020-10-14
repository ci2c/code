function [MeanDia,MaxErrDia,DiaDist,GFd] = GeometricDeformation(name,AngleStep,DiamTh)

    %% Extraction des informations dicom, binarisation et extraction du centre de gravité du disque
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info);
    level = graythresh(Ima1);
    Ima2 = im2bw(Ima1,level);
    [L,num]=bwlabel(Ima2);
    reg=regionprops(L,'Centroid');  
    CenterIma=[reg.Centroid(1) reg.Centroid(2)];
    
    %% Initialisation des variables
    Xbf=[];
    Xhf=[];
    Ybf=[];
    Yhf=[];
    Xf=[];
    Yf=[];
    [X,Y]=meshgrid(1:size(Ima2,2),1:size(Ima2,1));
    
    %% Boucle sur l'angle entre le diamètre et l'axe horizontal de 0 à Pi
    for angle = 0:(AngleStep):pi       
        R0=0;
        Rh=R0;
        Rb=R0;        
        %% Diamètre faisant un angle entre 0 et pi/2
        if (angle <= pi/2) && (angle >= 0)           
            Xh = CenterIma(1)+R0*cos(angle);
            Yh = CenterIma(2)-R0*sin(angle);
            Xb = CenterIma(1)-R0*cos(angle);
            Yb = CenterIma(2)+R0*sin(angle); 
            PixelValueh = interp2(X,Y,Ima2,Xh,Yh);
            PixelValueb = interp2(X,Y,Ima2,Xb,Yb);  
            %% Détermination intersection entre le diamètre haut et le cercle
            while PixelValueh~=0                
                Xhf = Xh;
                Yhf = Yh;
                Rh=Rh+0.1;
                Xh=CenterIma(1)+Rh*cos(angle);
                Yh=CenterIma(2)-Rh*sin(angle);
                PixelValueh = interp2(X,Y,Ima2,Xh,Yh);
            end  
            %% Détermination intersection entre le diamètre bas et le cercle
            while PixelValueb~=0              
                Xbf = Xb;
                Ybf = Yb;
                Rb=Rb+0.1;
                Xb=CenterIma(1)-Rb*cos(angle);
                Yb=CenterIma(2)+Rb*sin(angle);
                PixelValueb = interp2(X,Y,Ima2,Xb,Yb);             
            end    
        %% Diamètre faisant un angle entre pi/2 et pi
        elseif (angle > pi/2) && (angle <= pi)           
            Xh = CenterIma(1)-R0*cos(pi-angle);
            Yh = CenterIma(2)-R0*sin(pi-angle);
            Xb = CenterIma(1)+R0*cos(pi-angle);
            Yb = CenterIma(2)+R0*sin(pi-angle); 
            PixelValueh = interp2(X,Y,Ima2,Xh,Yh);
            PixelValueb = interp2(X,Y,Ima2,Xb,Yb);     
            %% Détermination intersection entre le diamètre haut et le cercle
            while PixelValueh~=0               
                Xhf = Xh;
                Yhf = Yh;
                Rh=Rh+0.1;
                Xh=CenterIma(1)-Rh*cos(pi-angle);
                Yh=CenterIma(2)-Rh*sin(pi-angle);
                PixelValueh = interp2(X,Y,Ima2,Xh,Yh);                
            end             
            %% Détermination intersection entre le diamètre bas et le cercle
            while PixelValueb~=0               
                Xbf = Xb;
                Ybf = Yb;
                Rb=Rb+0.1;
                Xb=CenterIma(1)+Rb*cos(pi-angle);
                Yb=CenterIma(2)+Rb*sin(pi-angle);
                PixelValueb = interp2(X,Y,Ima2,Xb,Yb);               
            end           
        end
        %% tableau des coordonnées x et y des deux intersections de chaque diamètre avec le cercle
        Xf=[Xf [Xbf;Xhf]];
        Yf=[Yf [Ybf;Yhf]];
    end
    
    %% Affichage diamètres définis sur l'image binarisée
    figure (2) 
    imshow(Ima2,[],'InitialMagnification','fit');hold on;
    for i=1:size(Xf,2)
        plot(Xf(:,i),Yf(:,i),'b');
    end
    hold off;
    
    %% Récupération des informations spatiales
    x0=Ima1info.ImagePositionPatient(1);
    y0=Ima1info.ImagePositionPatient(2);
    z0=Ima1info.ImagePositionPatient(3);
    op=Ima1info.ImageOrientationPatient;
    dimpix=Ima1info.PixelSpacing;
    
    %% Calcul des coordonnées 3D des intersections de chaque diamètre avec le cercle et détermination du diamètre
    CGb=zeros(3,size(Xf,2));   
    CGh=zeros(3,size(Xf,2));
    Diam=zeros(1,size(Xf,2));
    
    for i=1:size(Xf,2)
        
        CGb(1,i)=x0+(Xf(1,i)-1)*dimpix(1)*op(1)+(Yf(1,i)-1)*dimpix(2)*op(4);
        CGb(2,i)=y0+(Xf(1,i)-1)*dimpix(1)*op(2)+(Yf(1,i)-1)*dimpix(2)*op(5);  
        CGb(3,i)=z0+(Xf(1,i)-1)*dimpix(1)*op(3)+(Yf(1,i)-1)*dimpix(2)*op(6); 
        
        CGh(1,i)=x0+(Xf(2,i)-1)*dimpix(1)*op(1)+(Yf(2,i)-1)*dimpix(2)*op(4);
        CGh(2,i)=y0+(Xf(2,i)-1)*dimpix(1)*op(2)+(Yf(2,i)-1)*dimpix(2)*op(5);
        CGh(3,i)=z0+(Xf(2,i)-1)*dimpix(1)*op(3)+(Yf(2,i)-1)*dimpix(2)*op(6);
        
        Diam(1,i) = sqrt((CGh(1,i)-CGb(1,i))^2+(CGh(2,i)-CGb(2,i))^2+(CGh(3,i)-CGb(3,i))^2);
        
    end
    
    %% Calcul des paramètres de déformation géométrique
    MeanDia = sum(Diam)/size(Diam,2);
    MaxErrDia = max(abs(Diam-DiamTh));
    DiaDist = (max(Diam)-min(Diam))/mean(Diam)*100;
    GFd = mean(Diam)/DiamTh;