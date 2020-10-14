clear all;
close all;

%% Création de variables %%

tabledm=[];     % Variable de stockage des valeurs statistiques de déformation obtenues à partir des centres de gravités détectés automatiquement
% tabledf=[];     % Variable de stockage des valeurs statistiques de déformation obtenues à partir des centres de gravités obtenus par fit polynomial
defintm=[];     % Variable de stockage des matrices de déformation obtenues à partir des centres de gravités détectés automatiquement
% defintf=[];     % Variable de stockage des matrices de déformation obtenues à partir des centres de gravit�s obtenus par fit polynomial
CGCm=[];        % Variable de stockage des centres de gravités des coupes transverses obtenus automatiquement
% CGTf=[];        % Variable de stockage des centres de gravités des coupes transverses obtenus par fit polynomial

%% Nom de la série DICOM traitée %%

% cp=12;
name3='.dcm';
    
%% Boucle des opérations sur l'ensemble des images présélectionnées %%

for cp=1:60
         
    if (cp < 10)
        name1='/home/matthieu/NAS/matthieu/Distorsions/Code - CORONAL/IM-0004-000';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_401/IM-0004-000';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_501/IM-0005-000';
    else
        name1='/home/matthieu/NAS/matthieu/Distorsions/Code - CORONAL/IM-0004-00';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_401/IM-0004-00';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_501/IM-0005-00';
    end
    name=strcat(name1,int2str(cp),name3);
    
    if exist(name)~=0
        
        [Cg,Ima] = Detection_COR(name,cp);   % détection des centres de gravité automatique 
        Cgt = Tri_COR(Ima,Cg);          % Tri des centres de gravité selon y puis x croissants + fit polynomial
        
    % Correction à partir des points détectés automatiquement %%
        
%       Calcul coord3D centres de gravité + construction mire théorique + recalage mire théorique sur mire détectée
        [R,q,dep,Pf,error,CG,Cth] = Recalage_COR(name,Cgt);

%       Stockage centres de gravité des coupes transverses
        CGCm = [CGCm;CG];  
        
%       Correction 2D des distorsions
        [dxn,dzn,Xn,Zn,Imac,Imacinfo,y0]= Correction_COR('gridfit',100,name,Pf,CG);  
     
%       Stockage matrices de déformation calculées : création Atlas 2D
        temp = struct('CoupeCoronal',{cp},'Position_y',{y0},'Axe_deformation_1',{'x'},'Grille_reguliere_1',{Xn},'Valeurs_deformation_1',{dxn},...
        'Axe_deformation_2',{'z'},'Grille_reguliere_2',{Zn},'Valeurs_deformation_2',{dzn});     
        defintm=[defintm;temp]; 
        
        close all;
    end
end
save('CGC.mat','CGCm');
save('defint.mat','defintm');
% save('tabledm.mat','tabledm');
% 
% clear cp name1 name3 name;
% close all;
