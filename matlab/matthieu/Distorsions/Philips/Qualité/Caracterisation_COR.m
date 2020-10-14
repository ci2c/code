function [dX,dZ,dR,Xv,Zv,Ima1info,y0]= Caracterisation_COR(name,Pf,Xf,Cgt)


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
z=Pf(:,3);
dx=Xf(:,1)-x;
dz=Xf(:,3)-z;      
dr=sqrt(dx.^2+dz.^2);

%% En coordonnées pixel
xp=Cgt(:,1);
zp=Cgt(:,2);


    %% Visualisation des points 3D de déformation suivant chacun des axes et radiale

%% En coord3D
xv = linspace(min(x),max(x),150);
zv = linspace(min(z),max(z),150);
[Xv,Zv] = meshgrid(xv,zv);
dX = griddata(x,z,dx,Xv,Zv,'cubic');
dZ = griddata(x,z,dz,Xv,Zv,'cubic');
dR = griddata(x,z,dr,Xv,Zv,'cubic');

figure(9)
plot3(x,z,dx,'ro');
hold on
surface(Xv,Zv,dX,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des z');
zlabel('Déformation dx');
axis vis3d
grid on
hold off;

figure(10)
plot3(x,z,dz,'ro');
hold on
surface(Xv,Zv,dZ,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des z');
zlabel('Déformation dz');
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
plot3(x,z,dr,'ro');
hold on
surface(Xv,Zv,dR,'edgecolor','none')
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
ylabel('Axe des Z (mm)','FontSize',14);
zlabel('Déformation dr (mm)','FontSize',14);
grid on;
hold off;

%% En coordonnées pixel
xpi = linspace(min(xp),max(xp),150);
zpi = linspace(min(zp),max(zp),150);
[Xp,Zp] = meshgrid(xpi,zpi);
% dX = griddata(x,y,dx,Xv,Yv,'cubic');
% dY = griddata(x,y,dy,Xv,Yv,'cubic');
dRp = griddata(xp,zp,dr,Xp,Zp,'cubic');   
    
    %% Calcul de la déformation radiale à chaque pixel de l'image et représentation des isocontours de déformation radiale
    
figure (12)
% imshow(Ima1,[],'XData',Xv(1,:),'YData',Yv(:,1),'InitialMagnification','fit');
imshow(Ima1,[],'InitialMagnification','fit');hold on
[C,h] = contour('v6',Xp,Zp,dRp,0:0.1:1);
map= jet(length(h));
for n=1:length(map)
    set(h(n),'edgecolor',map(n,:),'LineWidth',1);
    axis on
end 
clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
xlabel('Axe des X','FontSize',14);
ylabel('Axe des Z','FontSize',14);
title('Représentation des isocontours de déformation radiale dans le plan coronal','FontSize',14);
plot(Cgt(:,1),Cgt(:,2),'.r','MarkerSize',16);
hold off
clear C h;
