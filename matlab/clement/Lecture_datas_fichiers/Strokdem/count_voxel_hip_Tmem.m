%% TCNTM
liste=dir('/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TMem_TCNTM/hpg/TCNTM/');
voxNTC=[];

for i=1:length(liste)
    
    if liste(i).isdir == 0  % les fichiers cachés ont un isdir de 1
        %Création du chemin
        s=liste(i).name;
        s1=('/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TMem_TCNTM/hpg/TCNTM/');
        file=strcat(s1,s);
    
        %Récupération du nii et comptage
        nii=load_nii(file);
        count=sum(nii.img(:)~=0);
    
        voxNTC=[voxNTC;count];
    end
end

clear s s1
%%TMem 

liste=dir('/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TMem_TCNTM/hpg/TM/');
voxTC=[];

for i=1:length(liste)
    
    if liste(i).isdir == 0
        %Création du chemin
        s=liste(i).name;
        s1=('/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TMem_TCNTM/hpg/TM/');
        file=strcat(s1,s);
    
        %Récupération du nii et comptage
        nii=load_nii(file);
        count=sum(nii.img(:)~=0);
    
        voxTC=[voxTC;count];

    end
   
end

%% Récupération covar

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_NonTM.xls'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem

ageNTC =a(:,1); 
sexeNTC =a(:,2);
ICVNTC =a(:,3);


[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/TMemoire.xls'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem

ageTC =a(:,1); 
sexeTC =a(:,2);
ICVTC =a(:,3);

%% GLM

Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

Y = [voxNTC(:,1);voxTC(:,1)];

age = [ageNTC;ageTC];
sexe = [sexeNTC;sexeTC];
icv= [ICVNTC;ICVTC];

Age = term(age);
Sexe = term(sexe);
ICV = term(icv);
group={};
for k = 1:Nntc
    group{end+1} = 'NTC';
end
for k = 1:Ntc
    group{end+1} = 'TC';
end

Group = term(group);
    
M = 1+ Group + Age + Sexe + ICV;
%M = 1 + Group + Age + Sexe;
%M = 1 + Group + Sexe;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);
disp(pval)

