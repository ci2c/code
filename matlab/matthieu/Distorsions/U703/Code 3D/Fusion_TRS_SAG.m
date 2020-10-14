clear all;
close all;

%% Affichage des points TRS et SAG

load CGT; load CGS;

figure (1)
plot3(CGSm(:,1),CGSm(:,2),CGSm(:,3),'.');hold on
plot3(CGTm(:,1),CGTm(:,2),CGTm(:,3),'.r');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');
hold off

%% Construction de la mire 3D théorique

Mire = [];
temp = zeros(1,3);
        
for i = 1:15
    for k = 1:14
        for j = 1:17
            if (((i==1) || (i==15)) && (3<=j) && (j<=15)) || (((i==2) || (i==14)) && (2<=j) && (j<=16)) || ((3<=i) && (i<=13))
                temp = [(i-1)*10 (j-1)*10 (k-1)*10];
                Mire = [Mire ; temp];
            end
        end
    end
end
figure(2)
plot3(Mire(:,1),Mire(:,2),Mire(:,3),'.r');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');


%% Tri des données SAG

CGSt = Tri3D(CGSm);

figure (3)
plot3(CGSt(:,1),CGSt(:,2),CGSt(:,3),'.');hold on
plot3(Mire(:,1),Mire(:,2),Mire(:,3),'.r');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');
hold off

%% Recalage Mire théorique sur Mire exp SAG

[R,q,dep,PS,error]=Transformation(Mire,CGSt);
figure (4)
plot3(CGSt(:,1),CGSt(:,2),CGSt(:,3),'.');hold on
plot3(PS(:,1),PS(:,2),PS(:,3),'.r');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');
hold off
           
%% Mesure de la d�formation suivant l'axe z dans les plans SAG

dzS = CGSt(:,3)-PS(:,3);

%% Tri des données TRS

CGTt = Tri3D(CGTm);

%% Ajout de la distorsion suivant l'axe z aux distorsions mesurées sur les
%% coupes axiales

CGTt(:,3) = CGTt(:,3)+dzS;      

%% Recalage Mire théorique sur exp TRS

[R2,q2,dep2,PT,error2]=Transformation(Mire,CGTt);
figure (5)
plot3(CGTt(:,1),CGTt(:,2),CGTt(:,3),'.');hold on
plot3(PT(:,1),PT(:,2),PT(:,3),'.r');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');
hold off

clear CGSm CGTm R q error;

%% Mesure de la déformation dans les coupes TRS

x = PT(:,1);
y = PT(:,2);
z = PT(:,3);
dzT = CGTt(:,3)-z;
dyT = CGTt(:,2)-y;
dxT = CGTt(:,1)-x;
drT=sqrt(dxT.^2+dyT.^2+dzT.^2);

clear R2 q2 error2;

figure (6)
quiver3(x,y,z,dxT,dyT,dzT);
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');

xg = min(x):2:max(x);
yg = min(y):2:max(y);
zg = min(z):2:max(z);

[X,Y,Z] = meshgrid(xg,yg,zg);
dzG = griddata3(x,y,z,dzT,X,Y,Z);

figure (7)
% scatter3( X(:), Y(:), Z(:), 3, data(:))
%xlabel('Tape your xlabel here')
%ylabel('Tape your ylabel here')
%zlabel('Tape your zlabel here')
%title('Tape your title here')
% scatter3(X(:), Y(:), Z(:), 3, drG(:));
plot3k({X(:) Y(:) Z(:)}, 'ColorData', dzG(:),'ColorRange',[0 5]);
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');

% %% Reconstruction 3D du volume axial de coupes  
% 
% name1='MR.1.2.392.200036.9123.100.12.11.14250.20070612134013.90.'; 
% name3='.dcm';
% coupeini = 13;
% name=strcat(name1,int2str(coupeini),name3);
% Imainfo=dicominfo(name);
% taillel=Imainfo.Rows;
% taillec=Imainfo.Columns;
% z0v=Imainfo.ImagePositionPatient(3);
% nbcoupes = 37;
% 
% volume = volume(name1,name3,coupeini,nbcoupes,taillel,taillec);
% clear name1 name3 name Imainfo taillel taillec coupeini;
% 
% %% Considération de la coupe que l'on souhaite corriger
% 
% name1='MR.1.2.392.200036.9123.100.12.11.14250.20070612134013.90.'; 
% name3='.dcm';
% name=strcat(name1,int2str(13),name3);
% Imainfo=dicominfo(name);
% x0=Imainfo.ImagePositionPatient(1);
% y0=Imainfo.ImagePositionPatient(2);
% z0=Imainfo.ImagePositionPatient(3);
% op=Imainfo.ImageOrientationPatient;
% dimpix=Imainfo.PixelSpacing;
% taillel=Imainfo.Rows;
% taillec=Imainfo.Columns;
% epaisseur=Imainfo.SliceThickness;
% 
% %% Utilisation de l'interpolation RBF : pré-interpolation et obtention d'une grille régulière 3D 
%     
%     xg = linspace(x0-dimpix(2)/2,x0+double(taillec-1)*dimpix(2)+dimpix(2)/2,30);
%     yg = linspace(y0-dimpix(1)/2,y0+double(taillel-1)*dimpix(1)+dimpix(1)/2,25);
%     zg = linspace(z0v-epaisseur/2,z0v+nbcoupes*epaisseur+epaisseur/2,25);
% 
%     [xng,yng,zng] = meshgrid(xg,yg,zg);
%     
%     clear xg yg zg;
% 
%     opx = rbfcreate([x'; y'; z'], dxT','RBFFunction', 'linear');
%     rbfcheck(opx);
%     dxg = rbfinterp([xng(:)'; yng(:)'; zng(:)'], opx);
%     dxg = reshape(dxg, size(xng));
% 
%     opy = rbfcreate([x'; y'; z'], dyT','RBFFunction', 'linear');
%     rbfcheck(opy);
%     dyg = rbfinterp([xng(:)'; yng(:)'; zng(:)'], opy);
%     dyg = reshape(dyg, size(xng));
% 
%     opz = rbfcreate([x'; y'; z'], dzT','RBFFunction', 'linear');
%     rbfcheck(opz);
%     dzg = rbfinterp([xng(:)'; yng(:)'; zng(:)'], opz);
%     dzg = reshape(dzg, size(xng));
% 
%     clear x y z dxT dyT dzT opx opy opz;
% 
% %% Interpolation 3D matlab de la déformation et correction 3D
% 
% tic;
% 
% xn = zeros(1,taillec);
% yn = zeros(1,taillel);
% for i=1:taillec
%     xn(i)=x0+(i-1)*dimpix(1)*op(1);        % Construction volume 3D d'interpolation : choix par la suite de correction   
% end
% 
% for i=1:taillel
%     yn(i)=y0+(i-1)*dimpix(2)*op(5);
% end
% 
% for i=1:nbcoupes
%     zn(i)=z0+epaisseur*(i-1);
% end
% 
% clear x0 y0 z0 op taillec taillel;
% 
% [xgrid,ygrid,zgrid] = meshgrid(xn,yn,zn);
% 
% clear xn yn zn;
% 
% dxn=interp3(xng,yng,zng,dxg,xgrid(:,64,2:36),ygrid(:,64,2:36),zgrid(:,64,2:36),'spline');
% dyn=interp3(xng,yng,zng,dyg,xgrid(:,64,2:36),ygrid(:,64,2:36),zgrid(:,64,2:36),'spline');
% dzn=interp3(xng,yng,zng,dzg,xgrid(:,64,2:36),ygrid(:,64,2:36),zgrid(:,64,2:36),'spline');
% 
% clear xng yng zng dxg dyg dzg;
% 
% xnd=xgrid(:,64,2:36)+dxn;                                % Obtention des coord3D correspondantes dans image d�form�e
% ynd=ygrid(:,64,2:36)+dyn;
% znd=zgrid(:,64,2:36)+dzn;
% 
% clear dxn dyn dzn;
% 
% Imac=interp3(xgrid,ygrid,zgrid,volume,xnd,ynd,znd,'cubic');  % Obtention de l'intensité aux coord3D de la nouvelle image par interpolation sur image déformée
% Ima = volume(:,64,2:36);
% Imar = extraction(Ima,'sag',epaisseur,dimpix(1));                                % Obtention de coupe sagittale à partir du format initial de coupes axiales
% Imacr = extraction(Imac,'sag',epaisseur,dimpix(1));
% 
% toc
% 
% figure (6)
% subplot(121)
% imshow(Imar,[],'InitialMagnification','fit');
% subplot(122)
% imshow(Imacr,[],'InitialMagnification','fit');