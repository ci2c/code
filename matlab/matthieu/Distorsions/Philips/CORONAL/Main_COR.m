clear all;
close all;

%% Nom de la série DICOM traitée %%

cp=26;
name3='.dcm';
    
if (cp < 10)
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_SAG_201/IM-0001-000';
elseif (cp >= 10) & (cp < 100)
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_SAG_201/IM-0001-00';
else
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_SAG_201/IM-0001-0';
end
name=strcat(name1,int2str(cp),name3);
    
if exist(name)~=0
    
    %% Détection des centres de gravités des points d'intérêt du fantôme
    [Cg,Ima] = Detection_COR(name,cp);   % détection des centres de gravité automatique 
    
    %% Tri des centres de gravités selon y puis x croissants
    Cgt = Tri_COR(Ima,Cg);      
       
    %% Calcul coord3D centres de gravité + construction mire théorique + recalage mire théorique sur mire détectée
    [R,q,dep,Pf,error,CG,Cth] = Recalage_COR(name,Cgt);
         
    %% Caractérisation 2D des distorsions
    [dX,dZ,dR,Xv,Zv,Ima1info,y0]= Caracterisation_COR(name,Pf,CG,Cgt);

end