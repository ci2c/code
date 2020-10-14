[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 

volTC=[];
dir='/home/fatmike/Protocoles_3T/Strokdem/Lesions/72H/';
for i=1:length(b)
    
    file=strcat(dir,b(i),'_72H/',b(i),'_lesions.nii');
    if exist(char(file))
    nii=load_untouch_nii(char(file));
    count=sum(nii.img(:)~=0);
    
    volTC=[volTC;((count./a(i,3))*100)];
    end
end
     

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 

volNTC=[];
dir='/home/fatmike/Protocoles_3T/Strokdem/Lesions/72H/';
for i=1:length(b)
    
    file=strcat(dir,b(i),'_72H/',b(i),'_lesions.nii');
    if exist(char(file))
    nii=load_untouch_nii(char(file));
    count=sum(nii.img(:)~=0);
    
    volNTC=[volNTC;((count./a(i,3))*100)];
    end
end
     
