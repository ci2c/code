clear all;
close all;

%% Nom de la série DICOM traitée %%

cp=84;
name3='.dcm';
    
if (cp < 10)
    name1='/NAS/dumbo/matthieu/Distorsions/Phantom_Qc_X/IM-0001-000';
elseif (cp >= 10) & (cp < 100)
    name1='/NAS/dumbo/matthieu/Distorsions/Phantom_Qc_X/IM-0001-00';
else
%     name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-0';
end
name=strcat(name1,int2str(cp),name3);
    
if exist(name)~=0
    
    %% Détection des centres de gravités des points d'intérêt du fantôme
    [Cg,Ima] = Detection_AXIAL(name,cp);   % détection des centres de gravité automatique 
    
    %% Tri des centres de gravités selon y puis x croissants
    Cgt = Tri_AXIAL(Ima,Cg);      
       
    %% Calcul coord3D centres de gravité + construction mire théorique + recalage mire théorique sur mire détectée
    [R,q,dep,Pf,error,CG,Cth] = Recalage_AXIAL(name,Cgt);
         
    %% Caractérisation 2D des distorsions
    [dX,dY,dR,Xv,Yv,Ima1info,z0]= Caracterisation_AXIAL(name,Pf,CG,Cgt);

end