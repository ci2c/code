function [R,q,dep,Pf,error,CG,Cth] = Recalage_AXIAL(name,PC)

    %% Récupération info image concernée et coordonnées pixel des PI %%

Ima1info=dicominfo(name);
Ima1= dicomread(Ima1info);
x0=Ima1info.ImagePositionPatient(1);
y0=Ima1info.ImagePositionPatient(2);
z0=Ima1info.ImagePositionPatient(3);
op=Ima1info.ImageOrientationPatient;
dimpix=Ima1info.PixelSpacing;

    %% Calcul des coordonnées 3D des centres de gravité %%
    
CG=zeros(size(PC,1),3);    
    for i=1:size(PC,1)
    
        CG(i,1)=x0+(PC(i,1)-1)*dimpix(1)*op(1)+(PC(i,2)-1)*dimpix(2)*op(4);
        CG(i,2)=y0+(PC(i,1)-1)*dimpix(1)*op(2)+(PC(i,2)-1)*dimpix(2)*op(5);
        CG(i,3)=z0+(PC(i,1)-1)*dimpix(1)*op(3)+(PC(i,2)-1)*dimpix(2)*op(6);
        
    end

    %% Construction mire théorique %% 

Cth=[];
M1=zeros(1,3);

    % Ordre de construction similaire à celui de l'obtention des points détectés : 
    % croissant sur les lignes puis sur les colonnes, appariement déjà
    % réalisé
    
for i=1:7           
    for k=1:7
        M1 = [25*(k-1) 25*(i-1) z0];
        Cth = [Cth ; M1];
    end
end

IndexVides = [1;7;43;49];
Cth(IndexVides,:) = [];

figure(7)
hold on 
plot3(Cth(:,1),Cth(:,2),Cth(:,3),'.');
plot3(CG(:,1),CG(:,2),CG(:,3),'.g');
xlabel('x');
ylabel('y');
zlabel('z');
hold off
 
    %% Recalage des points : ICP -> matching référence sur expérimentaux %%

[R,q,dep,Pf,error]=Transformation(Cth,CG);
figure(8)
hold on
plot3(Pf(:,1),Pf(:,2),Pf(:,3),'.');
plot3(CG(:,1),CG(:,2),CG(:,3),'.g');
xlabel('x');
ylabel('y');
zlabel('z');
hold off