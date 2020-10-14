function [Cg,Ima1] = Detection_SAG(name,cp)

   %% Récupération des informations de l'image DICOM traitée %%
   
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info);       
    figure (1)
    imshow(Ima1,[],'InitialMagnification','fit');
    
    %% Fitrage adaptatif du bruit blanc %%
    
    Ima2 = wiener2(Ima1,[5 5]);
    figure (2)
    imshow(Ima2,[],'InitialMagnification','fit');

    %% Binarisation %%

    Ima3 = (Ima2 >= mean(Ima2(:)));
    figure (3)
    imshow(Ima3,'InitialMagnification','fit');
    
    %% Ouverture d'élément structurant disque %%

    seo=strel('disk',3,0);
    Ima4 = imopen(Ima3,seo);
    figure (4)
    imshow(Ima4,'InitialMagnification','fit');

    %% Détection des billes : bwlabel et regionprops %%

    [L,num]=bwlabel(Ima4);
    reg=regionprops(L,'Centroid','EquivDiameter','Area','MajorAxisLength','MinorAxisLength');
    Cg=zeros(length(reg),2);
    Aire=zeros(length(reg),1);
    for i=1:length(reg)           
        Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
        Aire(i)=reg(i).Area;
    end

    %% Critère de sélection sur les centres de gravité %%

%     moy=mean(Aire);
%     et=std(Aire);
%     Index = [];
%     for i=1:size(Cg,1)
%         if Aire(i) < 50
%             Index = [Index;i];
%         end
%     end
%     Cg(Index,:) = [];
%     Aire(Index)=[];

    %% Affichage des centres de gravités détectés sur l'image originale +
    %% ajout manuel des centres de gravités manquants

but=1;
n=0;
xy=[];
    figure (5) 
    clf
    imshow(Ima1,[],'InitialMagnification','fit');hold on;
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