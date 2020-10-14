clear all;
close all;

%% Création de variables %%

tabledm=[];     % Variable de stockage des valeurs statistiques de déformation obtenues à partir des centres de gravités détectés automatiquement
% tabledf=[];     % Variable de stockage des valeurs statistiques de déformation obtenues à partir des centres de gravités obtenus par fit polynomial
defintm=[];     % Variable de stockage des matrices de déformation obtenues à partir des centres de gravités détectés automatiquement
% defintf=[];     % Variable de stockage des matrices de déformation obtenues à partir des centres de gravit�s obtenus par fit polynomial
CGTm=[];        % Variable de stockage des centres de gravités des coupes transverses obtenus automatiquement
% CGTf=[];        % Variable de stockage des centres de gravités des coupes transverses obtenus par fit polynomial

%% Nom de la série DICOM traitée %%

cp=5;
name3='.dcm';
    
%% Boucle des opérations sur l'ensemble des images présélectionnées %%

% for cp=1:50
         
    if (cp < 10)
        name1='/home/matthieu/NAS/matthieu/Distorsions/Code - AXIAL/IM-0003-000';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_401/IM-0004-000';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_501/IM-0005-000';
    else
        name1='/home/matthieu/NAS/matthieu/Distorsions/Code - AXIAL/IM-0003-00';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_401/IM-0004-00';
%         name1='/home/matthieu/NAS/matthieu/Distorsions/T2_HR_3_MM_501/IM-0005-00';
    end
    name=strcat(name1,int2str(cp),name3);
    
    if exist(name)~=0
        
        [Cg,Ima] = Detection_AXIAL(name,cp);   % détection des centres de gravité automatique 
        Cgt = Tri_AXIAL(Ima,Cg);          % Tri des centres de gravité selon y puis x croissants + fit polynomial

        
    % Correction à partir des points détectés automatiquement %%
        
%       Calcul coord3D centres de gravité + construction mire théorique + recalage mire théorique sur mire détectée
        [R,q,dep,Pf,error,CG,Cth] = Recalage_AXIAL(name,Cgt);

%       Stockage centres de gravité des coupes transverses
        CGTm = [CGTm;CG];  
        
%       Calcul valeurs statistiques de déformations
        table = Deformations_AXIAL(Pf,CG,cp); 
        
%       Stockage tables statistiques
        tabledm = [tabledm;table];
           
        clear Cg Cgl Cgt Cth Ima R dep q table;
        
%       Correction 2D des distorsions
        [dxn,dyn,Xn,Yn,Imac,Imacinfo,z0]= Correction_AXIAL('gridfit',100,name,Pf,CG);  
     
%       Stockage matrices de déformation calculées : création Atlas 2D
        temp = struct('CoupeAxial',{cp},'Position_z',{z0},'Axe_deformation_1',{'x'},'Grille_reguliere_1',{Xn},'Valeurs_deformation_1',{dxn},...
        'Axe_deformation_2',{'y'},'Grille_reguliere_2',{Yn},'Valeurs_deformation_2',{dyn});     
        defintm=[defintm;temp]; 
      
%       Ecriture de l'image corrigée en format DICOM
        dicomwrite(Imac,strcat('Corrected_AXIAL.',int2str(cp),'.dcm'),Imacinfo);   
%         
%         pause;  
%         clear R q dep Pf error CG Cth dxn dyn xn yn Imac Imacinfo z0 table temp;
%         close all;   
    end

% end
% save('CGT.mat','CGTm');
% save('defintm.mat','defintm');
% save('tabledm.mat','tabledm');
% 
% clear cp name1 name3 name;
% close all;
