%% Lecture de tous les volumes de lésion

liste=dir('/NAS/tupac/protocoles/Strokdem/Lesions/72H/');
vox=struct('vol',{},'subjid',{},'wm',{});
subjid_no={};
j=1;
k=1;

for i=1:length(liste)
    
    if liste(i).isdir == 1  
        
        %Création du chemin
        s=liste(i).name;
        s2 = s(1:end-4);
        s3 = '_lesions_refT1.nii';
        s1=('/NAS/tupac/protocoles/Strokdem/Lesions/72H/ws');
        
        file=fullfile('/NAS/tupac/protocoles/Strokdem/Lesions/72H',s,['ws' s2 s3]);
        %Test existence fichier nifti
        
        if exist(file,'file')
            %Récupération du nii et comptage
            nii=load_nii(file);
            count=sum(nii.img(:)~=0);
            vol(k)=count;
            subjid_ok(k)={s2};
       
            k=k+1;
          
        else 
            subjid_no(j)={s2};
            j=j+1;
            
            
        end
    end
end

%% Récupération des valeurs des groupes

%Tcog
[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls');
valTC=[];





for i=1:length(b)
   
   index=find(ismember(subjid_ok,b(i))); 
    
   if index ~= 0
    valTC = [valTC;vol(index)];
   end
    
    
end

%NTCog


[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls');
valNTC=[];

for i=1:length(b)
   
   index=find(ismember(subjid_ok,b(i))); 
    
   if index ~= 0
    valNTC = [valNTC;vol(index)];
   end
    
    
end






