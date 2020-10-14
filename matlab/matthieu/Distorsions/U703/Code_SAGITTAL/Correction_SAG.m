function [dyn,dzn,Yn,Zn,Ima4,Ima1info,x0]= Correction_SAG(method,nbpts,name,Pf,Xf)

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

    %% Calcul de la déformation radiale et suivant y et z

z=Pf(:,3);
y=Pf(:,2);
dz=Xf(:,3)-z;
dy=Xf(:,2)-y;      
dr=sqrt(dz.^2+dy.^2);

    %% Visualisation des points 3D de déformation suivant chacun des axes

figure(8)
plot3(y,z,dy,'*');
xlabel('Axe des y');
ylabel('Axe des z');
zlabel('Déformation dy');
grid on;

figure (9)
plot3(y,z,dz,'*');
xlabel('Axe des y');
ylabel('Axe des z');
zlabel('Déformation dz');
grid on;

    %% Visualisation surfacique de la déformation et pré-interpolation : obtention d'une grille régulière de déformation

zg=linspace(z0-double(taillel-1)*dimpix(2)-dimpix(2)/2,z0+dimpix(2)/2,nbpts);    
yg=linspace(y0-dimpix(1)/2,y0+double(taillec-1)*dimpix(1)+dimpix(1)/2,nbpts);

switch lower(method)
    
    case 'gridfit'
        
    % Utilisation de gridfit
        
[dzp,ygrid,zgrid]=gridfit(y,z,dz,yg,zg);
dyp=gridfit(y,z,dy,yg,zg);
drp=gridfit(y,z,dr,yg,zg);

figure (10)
hold on
surf(ygrid,zgrid,drp);
plot3(y,z,dr,'*g');
xlabel('Axe des y');
ylabel('Axe des z');
zlabel('dr');
grid on
hold off;

figure (11)
hold on
surf(ygrid,zgrid,dyp);
plot3(y,z,dy,'*b');
xlabel('Axe des y');
ylabel('Axe des z');
zlabel('dy');
grid on
hold off

figure (12)
hold on
surf(ygrid,zgrid,dzp);
plot3(y,z,dz,'*r');
xlabel('Axe des y');
ylabel('Axe des z');
zlabel('dz');
grid on
hold off

    case 'RBF'

        % Utilisation de l'interpolation RBF

[ygrid,zgrid]=meshgrid(yg,zg);
opy=rbfcreate([y'; z'], dy','RBFFunction', 'thinplate','Stats','on','RBFSmooth',0.001); rbfcheck(opy);
dyp = rbfinterp([ygrid(:)'; zgrid(:)'], opy);
dyp = reshape(dyp, size(ygrid));
opz=rbfcreate([y'; z'], dz','RBFFunction', 'thinplate','Stats','on','RBFSmooth',0.001); rbfcheck(opz);
dzp = rbfinterp([ygrid(:)'; zgrid(:)'], opz);
dzp = reshape(dzp, size(ygrid));

end

    %% Interpolation de la d�formation et correction 2D

% for j=1:taillel
%     for i=1:taillec
% zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);         % Cr�ation coord3D fausses en y et z des pixels de la coupe axiale d�form�e et corrig�e
% yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);
%     end
% end
% 
% dzn=interp2(ygrid,zgrid,gz,yn,zn,'spline');                     % Interpolation spline 2D des d�formations selon y et z aux points de coordonn�es de la coupe
% dyn=interp2(ygrid,zgrid,gy,yn,zn,'spline');
% 
% znd=zn+dzn;                                                     % Obtention de l'intensit� aux coord3D de la nouvelle image par interpolation bicubique des intensit�s sur l'image d�form�e
% ynd=yn+dyn;

for i=1:taillec
    yn(i)=y0+double(i-1)*dimpix(1);     
end
for j=1:taillel
    zn(j)=z0-double(j-1)*dimpix(2);
end

[Yn,Zn] = meshgrid(yn,zn);

dyn=interp2(ygrid,zgrid,dyp,Yn,Zn,'spline');                    % Interpolation spline 2D des déformations selon x et y aux points de coordonnées de la coupe
dzn=interp2(ygrid,zgrid,dzp,Yn,Zn,'spline');

Ynd=Yn+dyn;                                                     % Obtention des coord3D fausses correspondantes dans l'image déformée
Znd=Zn+dzn;

Ima2=double(Ima1);
Ima3=interp2(yn,zn,Ima2,Ynd,Znd,'cubic');                       % Obtention de l'intensit� aux coord2D de la nouvelle image par interpolation sur image d�form�e

figure (13)
subplot(121)
imshow(Ima1,[],'InitialMagnification','fit');
subplot(122);
imshow(Ima3,[],'InitialMagnification','fit');
Ima4 = uint16(Ima3);                                            % Ecriture de l'image corrig�e dans son format initial