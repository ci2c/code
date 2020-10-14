function [dxn,dyn,Xn,Yn,Ima4,Ima1info,z0]= Correction_TRS(method,nbpts,name,Pf,Xf)

% name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_301/IM-0003-000';
% cp=3;
% name3='.dcm';
% name=strcat(name1,int2str(cp),name3);

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

x=Pf(:,1);
y=Pf(:,2);
dx=Xf(:,1)-x;
dy=Xf(:,2)-y;      
dr=sqrt(dx.^2+dy.^2);

% Test = [x y dx];
% save('Test.txt','Test');

    %% Visualisation des points 3D de déformation suivant chacun des axes et radiale

xv = linspace(min(x),max(x),150);
yv = linspace(min(y),max(y),150);
[Xv,Yv] = meshgrid(xv,yv);
dX = griddata(x,y,dx,Xv,Yv,'cubic');
dY = griddata(x,y,dy,Xv,Yv,'cubic');
dR = griddata(x,y,dr,Xv,Yv,'cubic');

figure(8)
plot3(x,y,dx,'r*');
hold on
surface(Xv,Yv,dX,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des y');
zlabel('Déformation dx');
axis vis3d
grid on
hold off;

figure(9)
plot3(x,y,dy,'r*');
hold on
surface(Xv,Yv,dY,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des y');
zlabel('Déformation dy');
grid on;
hold off;

figure(14)
plot3(x,y,dr,'r*');
hold on
surface(Xv,Yv,dR,'edgecolor','none')
xlabel('Axe des x');
ylabel('Axe des y');
zlabel('Déformation dr');
grid on;
hold off;

    %% Visualisation surfacique de la déformation et pré-interpolation : obtention d'une grille régulière de déformation

xg=linspace(x0-dimpix(1)/2,x0+double(taillec-1)*dimpix(1)+dimpix(1)/2,nbpts);     
yg=linspace(y0-dimpix(2)/2,y0+double(taillel-1)*dimpix(2)+dimpix(2)/2,nbpts);

switch lower(method)
    
    case 'gridfit'
        
        % Utilisation de gridfit

[dxp,xgrid,ygrid]=gridfit(x,y,dx,xg,yg);
dyp=gridfit(x,y,dy,xg,yg);
drp=gridfit(x,y,dr,xg,yg);

figure (10)
hold on
surf(xgrid,ygrid,drp);
plot3(x,y,dr,'*g');
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('dr (mm)');
grid on
hold off;

figure (11)
hold on
surf(xgrid,ygrid,dyp);
plot3(x,y,dy,'*b');
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('dy (mm)');
grid on
hold off

figure (12)
hold on
surf(xgrid,ygrid,dxp);
plot3(x,y,dx,'*r');
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('dx (mm)');
grid on
hold off

    case 'RBF'

        % Utilisation de l'interpolation RBF

[xgrid,ygrid]=meshgrid(xg,yg);
opx=rbfcreate([x'; y'], dx','RBFFunction', 'thinplate','Stats','on','RBFSmooth',0.001); rbfcheck(opx);
dxp = rbfinterp([xgrid(:)'; ygrid(:)'], opx);
dxp = reshape(dxp, size(xgrid));
opy=rbfcreate([x'; y'], dy','RBFFunction', 'thinplate','Stats','on','RBFSmooth',0.001); rbfcheck(opy);
dyp = rbfinterp([xgrid(:)'; ygrid(:)'], opy);
dyp = reshape(dyp, size(xgrid));

end

% clear dx dy dr xg yg 

    %% Interpolation de la déformation et correction 2D

% for j=1:taillel
%     for i=1:taillec
% xn(j,i)=x0+double(i-1)*dimpix(1)*op(1)+double(j-1)*dimpix(2)*op(4);         % Création coord3D fausses en x et y des pixels de la coupe axiale déformée et corrigée   
% yn(j,i)=y0+double(i-1)*dimpix(1)*op(2)+double(j-1)*dimpix(2)*op(5);
%     end
% end
for i=1:taillec
    xn(i)=x0+double(i-1)*dimpix(1);     
end
for j=1:taillel
    yn(j)=y0+double(j-1)*dimpix(2);
end

[Xn,Yn] = meshgrid(xn,yn);

dxn=interp2(xgrid,ygrid,dxp,Xn,Yn,'spline');                    % Interpolation spline 2D des déformations selon x et y aux points de coordonnées de la coupe
dyn=interp2(xgrid,ygrid,dyp,Xn,Yn,'spline');

Xnd=Xn+dxn;                                                     % Obtention des coord3D fausses correspondantes dans l'image déformée
Ynd=Yn+dyn;

% clear dxp dyp drp xgrid ygrid dxn dyn;
% close all;

Ima2=double(Ima1);
Ima3=interp2(Xn,Yn,Ima2,Xnd,Ynd,'cubic');                       % Obtention de l'intensité aux coord3D de la nouvelle image par interpolation bicubique des intensités sur l'image déformée

figure (13)
subplot(121)
imshow(Ima1,[],'InitialMagnification','fit');
subplot(122);
imshow(Ima3,[],'InitialMagnification','fit');
Ima4 = uint16(Ima3);                                            % Ecriture de l'image corrigée dans son format initial