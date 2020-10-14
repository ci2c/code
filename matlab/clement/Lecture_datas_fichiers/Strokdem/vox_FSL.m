%% NTC 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls');

liste=dir('/NAS/dumbo/clement/FSL_T1');
voxNTC=[];

for i=1:length(b)
    
 % les fichiers cachés ont un isdir de 1
        %Création du chemin
        s1=('/NAS/dumbo/clement/FSL_T1/');
        file=strcat(s1,b(i),'/','subCort-L_Hipp_first.nii');
    
        %Récupération du nii et comptage
        nii=load_nii(char(file));
        count=sum(nii.img(:)==17);
    
        voxNTC=[voxNTC;count];

end

clear s s1
%%TC 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls');

liste=dir('/NAS/dumbo/clement/FSL_T1');
voxTC=[];

for i=1:length(b)
    
 % les fichiers cachés ont un isdir de 1
        %Création du chemin
        s1=('/NAS/dumbo/clement/FSL_T1/');
        file=strcat(s1,b(i),'/','subCort-L_Hipp_first.nii');
    
        %Récupération du nii et comptage
        nii=load_nii(char(file));
        count=sum(nii.img(:)==17);
    
        voxTC=[voxTC;count];

end

