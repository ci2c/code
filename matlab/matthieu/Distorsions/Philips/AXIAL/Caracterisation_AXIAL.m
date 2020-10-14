function [dX,dY,dR,Xv,Yv,Ima1info,z0]= Caracterisation_AXIAL(name,Pf,Xf,Cgt)


    %% Récupération info image concernée dans le fichier header

Ima1info=dicominfo(name);
Ima1= dicomread(Ima1info);
x0=Ima1info.ImagePositionPatient(1);
y0=Ima1info.ImagePositionPatient(2);
z0=Ima1info.ImagePositionPatient(3);
op=Ima1info.ImageOrientationPatient;
dimpix=Ima1info.PixelSpacing;
taillel=Ima1info.Rows;
taillec=Ima1info.Columns;

    %% Calcul de la déformation radiale et suivant x et y

%% En coord3D  
x=Pf(:,1);
y=Pf(:,2);
dx=Xf(:,1)-x;
dy=Xf(:,2)-y;      
dr=sqrt(dx.^2+dy.^2);

%% En coordonnées pixel
xp=Cgt(:,1);
yp=Cgt(:,2);


    %% Visualisation des points 3D de déformation suivant chacun des axes et radiale

%% En coord3D
xv = linspace(min(x),max(x),150);
yv = linspace(min(y),max(y),150);
[Xv,Yv] = meshgrid(xv,yv);
dX = griddata(x,y,dx,Xv,Yv,'cubic');
dY = griddata(x,y,dy,Xv,Yv,'cubic');
dR = griddata(x,y,dr,Xv,Yv,'cubic');

figure(9)
plot3(x,y,dx,'ro');
hold on
surface(Xv,Yv,dX,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des y');
zlabel('Déformation dx');
axis vis3d
grid on
hold off;

figure(10)
plot3(x,y,dy,'ro');
hold on
surface(Xv,Yv,dY,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des y');
zlabel('Déformation dy');
grid on;
hold off;


%% Caractéristiques de déformation radiale
[maxr,indra] = max(dr);
coordrmx = Pf(indra,:);
[minr,indrb] = min(dr);
coordrmn = Pf(indrb,:);
moyr=mean(dr);
sdr = std(abs(dr));

figure(11)
plot3(x,y,dr,'ro');
hold on
surface(Xv,Yv,dR,'edgecolor','none')
title('Caractérisation de la déformation radiale','FontSize',14);
texte1 = ['Maximum de distorsion radiale : ', num2str(maxr),' mm'];
texte2 = ['Minimum de distorsion radiale : ', num2str(minr),' mm'];
texte3 = ['Moyenne de distorsion radiale : ', num2str(moyr),' mm'];
texte4 = ['Ecart-type de distorsion radiale : ', num2str(sdr),' mm'];
annotation('textbox', [.005 .15 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
           'String', texte1);
annotation('textbox', [.005 .1 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
           'String', texte2);
annotation('textbox', [.005 .05 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
           'String', texte3);
annotation('textbox', [.005 0 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
           'String', texte4);
xlabel('Axe des X (mm)','FontSize',14);
ylabel('Axe des Y (mm)','FontSize',14);
zlabel('Déformation dr (mm)','FontSize',14);
grid on;
hold off;

%% En coordonnées pixel
xpi = linspace(min(xp),max(xp),150);
ypi = linspace(min(yp),max(yp),150);
[Xp,Yp] = meshgrid(xpi,ypi);
% dX = griddata(x,y,dx,Xv,Yv,'cubic');
% dY = griddata(x,y,dy,Xv,Yv,'cubic');
dRp = griddata(xp,yp,dr,Xp,Yp,'cubic');   
    
    %% Calcul de la déformation radiale à chaque pixel de l'image et représentation des isocontours de déformation radiale
    
%% Représentation des isocontours de déformation radiale
figure (12)
% imshow(Ima1,[],'XData',Xv(1,:),'YData',Yv(:,1),'InitialMagnification','fit');
imshow(Ima1,[],'InitialMagnification','fit');hold on
[C,h] = contour('v6',Xp,Yp,dRp,0:0.1:1);
map= jet(length(h));
for n=1:length(map)
    set(h(n),'edgecolor',map(n,:),'LineWidth',1);
    axis on
end 
clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
xlabel('Axe des X','FontSize',14);
ylabel('Axe des Y','FontSize',14);
title('Représentation des isocontours de déformation radiale','FontSize',14);
plot(Cgt(:,1),Cgt(:,2),'.r','MarkerSize',16);
hold off
clear C h;
