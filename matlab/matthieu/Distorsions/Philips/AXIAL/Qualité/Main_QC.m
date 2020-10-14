clear all;
close all;

%% Initialisation des paramètres

cp=60;
rzp=90;
rzc=15;
AngleStep=pi/20;
DiamTh=200;
name3='.dcm';
    
if (cp < 10)
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-000';
    name1b='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_601/IM-0006-000';
elseif (cp >= 10) & (cp < 100)
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-00';
    name1b='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_601/IM-0006-00';
else
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-0';
    name1b='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_601/IM-0006-0'
end
name=strcat(name1,int2str(cp),name3);
nameb=strcat(name1b,int2str(cp),name3);

%% Test sur existence de l'image

if exist(name)~=0
    
    %% Calcul de l'uniformité de l'image
    [Uniz0 Uniz1 Uniz2 Uniz3 Uniz4 Uniz5 UniP1 UniP2] = Uniformity(name,rzp,rzc);
    
    %% Calcul de la déformation géométrique
    [MeanDia MaxErrDia DiaDist GFd] = GeometricDeformation(name,AngleStep,DiamTh);
    
    %% Calcul des paramètres de bruit
    [SN0 SN1 SN2 SN3 SN4 SN5] = SignalNoise(name,nameb,rzp,rzc);
        
end