clear all;
close all;

%% Caractérisation de la disorsion radiale sur une coupe axiale %%

    name1='/home/matthieu/NAS/matthieu/Distorsions/Code - AXIAL/IM-0003-000';
    cp=8;
    name3='.dcm';
    name=strcat(name1,int2str(cp),name3);
    Imainfo = dicominfo(name);
    Ima = dicomread(Imainfo);
    x0=Imainfo.ImagePositionPatient(1);
    y0=Imainfo.ImagePositionPatient(2);
    z0=Imainfo.ImagePositionPatient(3);
    op=Imainfo.ImageOrientationPatient;
    dimpix=Imainfo.PixelSpacing;
    
%     % Détermination de la droite de mesure de déformation radiale : choix
%     % de 2 points
%     
%     X = [95;218];
%     Y = [294;191];
%     
%     p = polyfit(X,Y,1);
%     xi = linspace(X(1),X(2),100);
%     yi = polyval(p,xi); 
%     Cgi = [xi' yi'];
%     
%     % Visualisation des cercles limites et de la droite de mesure
%     
%     figure (1)
%     imshow(Ima,[],'InitialMagnification','fit');hold on
%     circle(109.7133,[218 191],'--b',138.9702,[218 191],'--r');
%     plot(X,Y,'.');
%     plot(X,Y,'g');
% %     plot(xi,f,'.g');
%     hold off
    
    % Interpolation des valeurs de déformations suivant l'axe radial
%    
%     CG=zeros(size(Cgi,1),2);    
%     for i=1:size(Cgi,1)
%     
%         CG(i,1)=x0+(Cgi(i,1)-1)*dimpix(1)*op(1)+(Cgi(i,2)-1)*dimpix(2)*op(4);
%         CG(i,2)=y0+(Cgi(i,1)-1)*dimpix(1)*op(2)+(Cgi(i,2)-1)*dimpix(2)*op(5);
%         
%     end
%     
%     r = zeros(size(CG,1),1);
%     for i=1:size(CG,1)
%         r(i) = sqrt(CG(i,1)^2+CG(i,2)^2);
%     end
%            
    load defint;      % Chargement de l'atlas de déformation axial 
    
    xgrille = defintm(3,1).Grille_reguliere_1;
    ygrille = defintm(3,1).Grille_reguliere_2;
    dx = defintm(3,1).Valeurs_deformation_1;
    dy = defintm(3,1).Valeurs_deformation_2;
   
%% Calcul de la d�formation radiale à chaque pixel de l'image à partir de l'atlas et représentation des isocontours de déformation radiale %%
    
    dr = sqrt(dx.^2+dy.^2);
    figure (3)
    imshow(Ima,[],'XData',xgrille(1,:),'YData',ygrille(:,1),'InitialMagnification','fit');hold on
    [C,h] = contour('v6',xgrille,ygrille,dr,0:0.1:1);
    map= jet(length(h));
    for n=1:length(map)
        set(h(n),'edgecolor',map(n,:),'LineWidth',1.5);
        axis on
    end 
    clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
    xlabel('X (mm)');
    ylabel('Y (mm)');
    hold off
    clear C h;