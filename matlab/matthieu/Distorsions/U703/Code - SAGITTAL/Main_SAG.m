clear all;
close all;

%% Création de variables %%

tabledm=[];         % Variable de stockage des valeurs statistiques de d�formation obtenues � partir des centres de gravit�s d�tect�s automatiquement + ajout manuel
% tabledf=[];         % Variable de stockage des valeurs statistiques de d�formation obtenues � partir des centres de gravit�s obtenus par fit polynomial
defintm=[];         % Variable de stockage des matrices de d�formation obtenues � partir des centres de gravit�s d�tect�s automatiquement + manuellement
% defintf=[];         % Variable de stockage des matrices de d�formation obtenues � partir des centres de gravit�s obtenus par fit polynomial
CGSm=[];            % Variable de stockage des centres de gravit�s des coupes transverses obtenus automatiquement + manuellement
% CGSf=[];            % Variable de stockage des centres de gravit�s des coupes transverses obtenus par fit polynomial

%% Nom de la série DICOM trait�e %%

cp=20;
name3='.dcm';

%% Boucle des opérations sur l'ensemble des images présélectionnées %%

% for cp=1:52
    if (cp < 10)
        name1='/home/matthieu/NAS/matthieu/Distorsions/Code - SAGITTAL/IM-0005-000';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_401/IM-0004-000';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_501/IM-0005-000';
    else
        name1='/home/matthieu/NAS/matthieu/Distorsions/Code - SAGITTAL/IM-0005-00';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_401/IM-0004-00';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_501/IM-0005-00';
    end
    name=strcat(name1,int2str(cp),name3);
    
    if exist(name)~=0
        
        Ima1info=dicominfo(name);
        [Cg,Ima] = Detection_SAG(name);          % détection des centres de gravité automatique + ajout manuel 
        Cgt = Tri_SAG(Ima,Cg);          % Tri des centres de gravité selon y puis x croissants + fit polynomial

        
    % Correction à partir des points détectés automatiquement %%
        
%       Calcul coord3D centres de gravité + construction mire théorique + recalage mire théorique sur mire détectée
        [R,q,dep,Pf,error,CG,Cth] = Recalage_SAG(name,Cgt);

%       Stockage centres de gravité des coupes transverses
        CGSm = [CGSm;CG];  
        
%       Correction 2D des distorsions
        [dyn,dzn,Yn,Zn,Imac,Imacinfo,x0]= Correction_SAG('gridfit',100,name,Pf,CG);  
     
%       Stockage matrices de déformation calculées : création Atlas 2D
        temp = struct('CoupeSagittal',{cp},'Position_x',{x0},'Axe_deformation_1',{'y'},'Grille_reguliere_1',{Yn},'Valeurs_deformation_1',{dyn},...
        'Axe_deformation_2',{'z'},'Grille_reguliere_2',{Zn},'Valeurs_deformation_2',{dzn});     
        defintm=[defintm;temp];  
    end
% end

% save('CGS.mat','CGSm');
% save('defint.mat','defintm');

% clear cp name1 name3 name;
% close all;
