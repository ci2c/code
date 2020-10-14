% function [Ivessel,Ima1] = Detection_AXIAL(name,cp)

    clear all;
    close all;

    %% Nom de la série DICOM traitée %%

    name1='/home/matthieu/NAS/matthieu/Distorsions/SCAN/AXIAL/IM-0001-00';
    cp=84;
    name3='.dcm';    

    name=strcat(name1,int2str(cp),name3);

    %% Récupération des informations de l'image DICOM traitée %%
   
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info); 
    figure (8)
    imhist(Ima1);
    figure (1)
    imshow(Ima1,[],'InitialMagnification','fit');
    
    Ima2= (Ima1>=1050) & (Ima1<=1250);
    figure (2)
    imshow(Ima2,[],'InitialMagnification','fit');
      
%     %% Fitrage adaptatif du bruit blanc %%
%     
%     Ima2 = wiener2(Ima1,[5 5]);
%     figure (2)
%     imshow(Ima2,[],'InitialMagnification','fit');

%     %% Définition de l'élément structurant et opération bottom hat
% 
%     se = strel('disk',10,0);  %ES forme disque de rayon lissé
%     Ima3 = imbothat(Ima1,se);
%     figure (3)
%     imshow(Ima3,[],'InitialMagnification','fit');
%     
% % %     %% Hessian filter %%
% %     Ima4=double(Ima3);
% %     Ima5=FrangiFilter2D(Ima4);
% %     figure (4)
% %     subplot(1,2,1), imshow(Ima1,[]);
% %     subplot(1,2,2), imshow(Ima5,[0 0.25]);
% 
%     %% Binarisation %%
% 
%     level = graythresh(Ima3);
%     Ima6 = im2bw(Ima3,level);
% % % %     Ima3 = (Ima2 >= mean(Ima2(:)));
%     figure (5)
%     imshow(Ima6,'InitialMagnification','fit');
%     
%     %% Ouverture d'élément structurant disque %%
% 
%     seo=strel('disk',2,0);
%     Ima7 = imclose(Ima6,seo);
%     figure (6)
%     imshow(Ima7,'InitialMagnification','fit');
% 
%     %% Détection des billes : bwlabel et regionprops %%
% 
%     [L,num]=bwlabel(Ima4);
%     reg=regionprops(L,'Centroid','EquivDiameter','Area','MajorAxisLength','MinorAxisLength');
%     Cg=zeros(length(reg),2);
%     Aire=zeros(length(reg),1);
%     for i=1:length(reg)           
%         Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
%         Aire(i)=reg(i).Area;
%     end
% 
%     %% Critère de sélection sur les centres de gravité %%
% 
% %     moy=mean(Aire);
% %     et=std(Aire);
% %     Index = [];
% %     for i=1:size(Cg,1)
% %         if Aire(i) < 50
% %             Index = [Index;i];
% %         end
% %     end
% %     Cg(Index,:) = [];
% %     Aire(Index)=[];
% 
%     figure (5)
%     imshow(Ima1,[],'InitialMagnification','fit');hold on;
%     plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
%     hold off