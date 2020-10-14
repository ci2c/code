clear all 

format('shortG')

%% NTC 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 
WMNTC=[];

ageNTC=[]; 
sexeNTC=[];
ICVNTC=[];

s1='/home/fatmike/Protocoles_3T/Strokdem/Lesions/M6/';
s2='_M6/WM/WM-cer.nii';


for i=1:length(b)
    
    file=char(strcat(s1,b(i),s2));
    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      
      WMNTC=[WMNTC;count];
      
      ageNTC=[ageNTC;a(i,1)];
      sexeNTC=[sexeNTC;a(i,2)];
      ICVNTC=[ICVNTC;a(i,3)];
    else disp(b(i))
    end
end

%% TC 

format('shortG')

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
WMTC=[];

ageTC=[]; 
sexeTC=[];
ICVTC=[];

s1='/home/fatmike/Protocoles_3T/Strokdem/Lesions/M6/';
s2='_M6/WM/WM-cer.nii';


for i=1:length(b)
    
    file=char(strcat(s1,b(i),s2));
    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      
      WMTC=[WMTC;count];
      
      ageTC=[ageTC;a(i,1)];
      sexeTC=[sexeTC;a(i,2)];
      ICVTC=[ICVTC;a(i,3)];
        
    end
end
