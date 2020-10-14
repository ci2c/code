function coord3Dc=Correction_3D(coord3Dd)

clear all;
close all;

%% Chargement des points TRS et SAG %%

load CGT; load CGSb;

%% Tri des données SAG %%

CGSt = Tri3D(CGSb);

% Construction de la mire 3D théorique

Mire = [];
for i=1:10
    for k=1:6
        for j=1:7
           temp = [(i-1)*30 (j-1)*30 (k-1)*30]; 
           Mire = [Mire ; temp];
        end
    end
end

% Recalage Mire théorique sur Mire exp SAG

[R,q,PS,error]=Transformation(Mire,CGSt);

% Mesure de la déformation suivant l'axe z dans les plans SAG

dzS = CGSt(:,3)-PS(:,3);

%% Tri des données TRS %%

CGTt = Tri3D(CGT);

%% Ajout de la déformation suivant z mesurée sur les coupes sagittales

CGTt(:,3) = CGTt(:,3)+dzS;      

%% Recalage mire théorique sur mire exp axial modifiée

[R2,q2,PT,error2]=Transformation(Mire,CGTt);

clear CGS CGT R q PS error CGSt CGSb R2 q2 error2;

%% Mesure de la déformation 3D %%

x = CGTt(:,1);
y = CGTt(:,2);
z = CGTt(:,3);
dz = PT(:,3)-z;
dy = PT(:,2)-y;
dx = PT(:,1)-x;

%% Vérification de l'appartenance de la coordonnées distordues dans
%% le volume du fantôme étudié

xmax=max(x); xmin=min(x);
ymax=max(y); ymin=min(y);
zmax=max(z); zmin=min(z);


test = false(size(coord3Dd,1));
for i=1:size(coord3Dd,1)
    if (xmin<=coord3Dd(i,1)<=xmax) & (ymin<=coord3Dd(i,2)<=ymax) & (zmin<=coord3Dd(i,3)<=zmax)
        test(i)=true;
    else
        disp('coordonnée n°',num2str(i),'hors du volume effectif du fantôme étudié');
    end
end

coord3Dd = coord3Dd(test,:);

%% rbf_interp

% opx = rbfcreate([x'; y'; z'], dx','RBFFunction', 'thinplate', 'Stats', 'on');
% rbfcheck(opx);
% dxg = rbfinterp([xng(:)'; yng(:)'; zng(:)'], opx);
% dxg = reshape(dxg, size(xng));
% 
% opy = rbfcreate([x'; y'; z'], dy','RBFFunction', 'thinplate', 'Stats', 'on');
% rbfcheck(opy);
% dyg = rbfinterp([xng(:)'; yng(:)'; zng(:)'], opy);
% dyg = reshape(dyg, size(xng));
% 
% opz = rbfcreate([x'; y'; z'], dz','RBFFunction', 'thinplate', 'Stats', 'on');
% rbfcheck(opz);
% dzg = rbfinterp([xng(:)'; yng(:)'; zng(:)'], opz);
% dzg = reshape(dzg, size(xng));
% 
% clear x y z dx dy dz opx opy opz;

%% Seconde interpolation : interp3

% xi=linspace(xmin,xmax,100);
% yi=linspace(ymin,ymax,70);
% zi=linspace(zmin,zmax,60);
% 
% [xgrid,ygrid,zgrid]=meshgrid(xi,yi,zi);
% clear xi yi zi;
% 
% dxi=interp3(xng,yng,zng,dxg,xgrid,ygrid,zgrid);
% dyi=interp3(xng,yng,zng,dyg,xgrid,ygrid,zgrid);
% dzi=interp3(xng,yng,zng,dzg,xgrid,ygrid,zgrid);
% 
% clear xng yng zng dxg dyg dzg;

%% Récupération de la coordonnée 3D corrigée %%

    % rbf_interp
    
opx = rbfcreate([x'; y'; z'], dx','RBFFunction', 'thinplate', 'Stats', 'on');
rbfcheck(opx);
dxn = rbfinterp([coord3Dd(:,1)'; coord3Dd(:,2)'; coord3Dd(:,3)'], opx);
dxn = reshape(dxn, size(coord3Dd(:,1)));

opy = rbfcreate([x'; y'; z'], dy','RBFFunction', 'thinplate', 'Stats', 'on');
rbfcheck(opy);
dyn = rbfinterp([coord3Dd(:,1)'; coord3Dd(:,2)'; coord3Dd(:,3)'], opy);
dyn = reshape(dyn, size(coord3Dd(:,1)));

opz = rbfcreate([x'; y'; z'], dz','RBFFunction', 'thinplate', 'Stats', 'on');
rbfcheck(opz);
dzn = rbfinterp([coord3Dd(:,1)'; coord3Dd(:,2)'; coord3Dd(:,3)'], opz);
dzn = reshape(dzn, size(coord3Dd(:,1)));

    % interp3
    
% dxn=interp3(xgrid,ygrid,zgrid,dxi,coord3Dd(:,1),coord3Dd(:,2),coord3Dd(:,3));         % Interpolation interp3
% dyn=interp3(xgrid,ygrid,zgrid,dyi,coord3Dd(:,1),coord3Dd(:,2),coord3Dd(:,3));
% dzn=interp3(xgrid,ygrid,zgrid,dzi,coord3Dd(:,1),coord3Dd(:,2),coord3Dd(:,3));


coord3Dc(:,1)=coord3Dd(:,1)+dxn;         % Obtention des coord2D correspondantes dans image déformée
coord3Dc(:,2)=coord3Dd(:,2)+dyn;
coord3Dc(:,3)=coord3Dd(:,3)+dzn;
