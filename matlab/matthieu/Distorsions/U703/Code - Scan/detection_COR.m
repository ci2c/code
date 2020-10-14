function [CG,Cg,Ima1] = detection_COR(name,cp)

%% Récupération des informations de l'image DICOM traitée
   
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info);
    x0=Ima1info.ImagePositionPatient(1);
    y0=Ima1info.ImagePositionPatient(2);
    z0=Ima1info.ImagePositionPatient(3);
    op=Ima1info.ImageOrientationPatient;
    dimpix=Ima1info.PixelSpacing;
    figure (1)
    subplot(121)
    imshow(Ima1,[],'notruesize');

%% Définition de l'élément structurant et opération bottom hat

se = strel('disk',10,0);  %ES forme disque de rayon lissé
Ima2 = imbothat(Ima1,se);
subplot(122)
imshow(Ima2,[],'notruesize');
Ima3=uint16(Ima2);

%% Binarisation : graythresh  

level = graythresh(Ima3);
Ima4 = im2bw(Ima3,level);
figure (2)
subplot(221)
imshow(Ima4,'notruesize');

%% Ouverture d'élément structurant disque

seo=strel('disk',3,0);
Ima5=imopen(Ima4,seo);
subplot(222)
imshow(Ima5,'notruesize');

%% Suppression des pixels de 8-connexité sur les bords de l'image

Ima6=imclearborder(Ima5);
subplot(223)
imshow(Ima6,'notruesize');

%% Détection des billes : bwlabel et regionprops

[L,num]=bwlabel(Ima6);
reg=regionprops(L,'Centroid','EquivDiameter','Area','MajorAxisLength','MinorAxisLength');
Cg=zeros(length(reg),2);
Aire=zeros(length(reg),1);
for i=1:length(reg)           
    Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
    Aire(i)=reg(i).Area;
end

%% Critère de sélection sur les centres de gravité

        % Critère ligne/colonne
    
        tournevis=6;
        cp=zeros(size(Cg,1),2);
        for i=1:size(Cg,1)
            PX=abs(Cg(:,1)-Cg(i,1));
            PY=abs(Cg(:,2)-Cg(i,2));   
            indX=PX<tournevis;
            indY=PY<tournevis;
            if sum(indX)>1
                cp(i,1)=0;
            else
                cp(i,1)=1;
            end
   
            if sum(indY)>1
                cp(i,2)=0;
            else
                cp(i,2)=1;
            end           
        end

        % Critère de distance

        cdis=zeros(size(Cg,1),1);
        for i=1:size(Cg,1)
            D=[Cg(:,1)-Cg(i,1) Cg(:,2)-Cg(i,2)];
            D(i,:)=[];
            Dn=zeros(size(D,1),1);
            for j=1:size(D,1)
                Dn(j)=norm(D(j,:));
            end  
            if isempty(find(Dn<14))==0
                cdis(i)=1;
            end
        end

        total=[cp(:,1)+cdis cp(:,2)+cdis];
        dis=find(total==max(total(:)));
        if length(dis)~=2*size(Cg,1)
            for i=1:length(dis)
                if dis(i)>size(Cg,1)
                    dis(i)=dis(i)-size(Cg,1);
                end
            end
        else
            dis=[];
        end
     

        % Critère de surface et compacité
    
        moy=mean(Aire);
        et=std(Aire);
        cs=zeros(size(Cg,1),1);
        cc=zeros(size(Cg,1),1);
        for i=1:size(Cg,1)
            if (Aire(i)>moy+2*et) || (Aire(i)<moy-2*et)
                cs(i)=1;
            else
                cs(i)=0;
            end
            if reg(i).MajorAxisLength/reg(i).MinorAxisLength>2
                cc(i)=1;
            else
                cc(i)=0;
            end
        end

        csc=cs+cc;
        sc=find(csc>1);

        res=[dis;sc];
        res=unique(res);
        if isempty(res)==0
            Cg(res,:)=[];
        end
        
%% Affichage des centres de gravités détectés sur l'image originale

but=1;
n=0;
xy=[];
figure (3)                      
imshow(Ima1,[],'notruesize');hold on;
plot(Cg(:,1),Cg(:,2),'.');
    while but == 1
        [xi,yi,but] = ginput(1);
        if but==1
        plot(xi,yi,'.r')
        n = n+1;
        xy(n,:) = [xi yi];
        end
    end
hold off
Cg=[Cg;xy];

%% Calcul des coordonnées 3D des points de contrôle

    
    for i=1:size(Cg,1)
    
        CG(i,1)=x0+(Cg(i,1)-1)*dimpix(1)*op(1)+(Cg(i,2)-1)*dimpix(2)*op(4);
        CG(i,2)=y0+(Cg(i,1)-1)*dimpix(1)*op(2)+(Cg(i,2)-1)*dimpix(2)*op(5);
        CG(i,3)=z0+(Cg(i,1)-1)*dimpix(1)*op(3)+(Cg(i,2)-1)*dimpix(2)*op(6);
    
    end    

figure (4)
plot3(CGf(:,1),CGf(:,2),CGf(:,3),'.');
xlabel('Axe des x');
ylabel('Axe des y');
zlabel('Axe des z');