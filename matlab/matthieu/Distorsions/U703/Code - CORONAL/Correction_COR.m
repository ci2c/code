function [dxn,dzn,Xn,Zn,Ima4,Ima1info,y0]= Correction_COR(method,nbpts,name,Pf,Xf)

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

    %% Calcul de la déformation radiale et suivant x et z

x=Pf(:,1);
z=Pf(:,3);
dx=Xf(:,1)-x;
dz=Xf(:,3)-z;      
dr=sqrt(dx.^2+dz.^2);

% Test = [x y dx];
% save('Test.txt','Test');

    %% Visualisation des points 3D de déformation suivant chacun des axes et radiale

zg=linspace(z0-double(taillel-1)*dimpix(2)-dimpix(2)/2,z0+dimpix(2)/2,nbpts);    
xg=linspace(x0-dimpix(1)/2,x0+double(taillec-1)*dimpix(1)+dimpix(1)/2,nbpts);

switch lower(method)
    
    case 'gridfit'
        
    % Utilisation de gridfit
        
[dzp,xgrid,zgrid]=gridfit(x,z,dz,xg,zg);
dxp=gridfit(x,z,dx,xg,zg);
drp=gridfit(x,z,dr,xg,zg);

figure (10)
hold on
surf(xgrid,zgrid,drp);
plot3(x,z,dr,'*g');
xlabel('Axe des x');
ylabel('Axe des z');
zlabel('dr');
grid on
hold off;

figure (11)
hold on
surf(xgrid,zgrid,dxp);
plot3(x,z,dx,'*b');
xlabel('Axe des x');
ylabel('Axe des z');
zlabel('dx');
grid on
hold off

figure (12)
hold on
surf(xgrid,zgrid,dzp);
plot3(x,z,dz,'*r');
xlabel('Axe des y');
ylabel('Axe des z');
zlabel('dz');
grid on
hold off

    case 'RBF'

        % Utilisation de l'interpolation RBF

[xgrid,zgrid]=meshgrid(xg,zg);
opx=rbfcreate([x'; z'], dx','RBFFunction', 'thinplate','Stats','on','RBFSmooth',0.001); rbfcheck(opx);
dxp = rbfinterp([xgrid(:)'; zgrid(:)'], opx);
dxp = reshape(dxp, size(xgrid));
opz=rbfcreate([x'; z'], dz','RBFFunction', 'thinplate','Stats','on','RBFSmooth',0.001); rbfcheck(opz);
dzp = rbfinterp([xgrid(:)'; zgrid(:)'], opz);
dzp = reshape(dzp, size(xgrid));

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
    zn(j)=z0-double(j-1)*dimpix(2);
end

[Xn,Zn] = meshgrid(xn,zn);

dxn=interp2(xgrid,zgrid,dxp,Xn,Zn,'spline');                    % Interpolation spline 2D des déformations selon x et y aux points de coordonnées de la coupe
dzn=interp2(xgrid,zgrid,dzp,Xn,Zn,'spline');

Xnd=Xn+dxn;                                                     % Obtention des coord3D fausses correspondantes dans l'image déformée
Znd=Zn+dzn;

Ima2=double(Ima1);
Ima3=interp2(xn,zn,Ima2,Xnd,Znd,'cubic');                       % Obtention de l'intensit� aux coord2D de la nouvelle image par interpolation sur image d�form�e

figure (13)
subplot(121)
imshow(Ima1,[],'InitialMagnification','fit');
subplot(122);
imshow(Ima3,[],'InitialMagnification','fit');
Ima4 = uint16(Ima3);                                            % Ecriture de l'image corrigée dans son format initial