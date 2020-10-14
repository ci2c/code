function [Cg,Ima1] = Detection_COR(name,cp)

%     clear all;
%     close all;
% 
%     %% Nom de la série DICOM traitée
% 
%     name1='/home/matthieu/NAS/matthieu/Distorsions/20130712_Cq_X/T1W_3D_1mm_SAG_201/IM-0001-00';
%     cp=26;
%     name3='.dcm';    
% 
%     name=strcat(name1,int2str(cp),name3);

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

%     level = graythresh(Ima2);
%     Ima3 = im2bw(Ima2,level);
    Ima3 = (Ima2 >= (mean(Ima2(:))+220));
    figure (3)
    imshow(Ima3,'InitialMagnification','fit');
    
    %% Ouverture d'élément structurant disque %%

%     sef=strel('disk',3,0);
%     Ima4 = imclose(Ima3,sef);
%     figure (4)
%     imshow(Ima4,'InitialMagnification','fit');

    %% Détection des billes : bwlabel et regionprops %%

    [L,num]=bwlabel(Ima3);
    reg=regionprops(L,'Centroid','EquivDiameter','Area','MajorAxisLength','MinorAxisLength');
    Cg=zeros(length(reg),2);
    Aire=zeros(length(reg),1);
    for i=1:length(reg)           
        Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
        Aire(i)=reg(i).Area;
    end

    %% Critère de sélection sur les centres de gravité %%

        % Critère de surface et compacité
    
    res=[];
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
    res=[res;sc];
    if isempty(res)==0
        Cg(res,:)=[];
    end

    figure (5)
    imshow(Ima1,[],'InitialMagnification','fit');hold on;
    plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
    hold off
