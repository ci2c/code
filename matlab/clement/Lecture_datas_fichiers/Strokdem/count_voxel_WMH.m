format('shortG')

%% NTC 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 
voxNTC=[];
voxNTC_WMH=[];

ageNTC =[]; 
sexeNTC =[];
ICVNTC =[];


s1='/home/fatmike/Protocoles_3T/Strokdem/WMH_LST/M6/';
s2='_M6_bin.nii';


for i=1:length(b)
    
    file=char(strcat(s1,b(i),'_M6','/',b(i),s2));
%%%%   
    S1='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpg/NTC/NTC_';
    S2='M6_hpg.nii';
    
    file_hpg=char(strcat(S1,b(i),S2));
%%%%    
    if exist(file_hpg) ~= 0 && exist(file) ~= 0
%WMH      
      nii=load_untouch_nii(file);
      count=sum(nii.img(:)~=0);
      voxNTC_WMH=[voxNTC_WMH;count];

%Hippocampe      
      nii=load_nii(file_hpg);
      count=sum(nii.img(:)~=0);
      voxNTC=[voxNTC;count];
      
      ageNTC=[ageNTC;a(i,1)];
      sexeNTC=[sexeNTC;a(i,2)];
      ICVNTC=[ICVNTC;a(i,3)];   
    end

end
    
   

%% TC


[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
voxTC=[];
voxTC_WMH=[];

ageTC =[]; 
sexeTC =[];
ICVTC =[];


s1='/home/fatmike/Protocoles_3T/Strokdem/WMH_LST/M6/';
s2='_M6_bin.nii';


for i=1:length(b)
    
    file=char(strcat(s1,b(i),'_M6','/',b(i),s2));
%%%%   

    S1='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpg/TC/TC_';
    S2='M6_hpg.nii';

    file_hpg=char(strcat(S1,b(i),S2));
%%%%    
    if exist(file_hpg) ~= 0 && exist(file) ~= 0
        
% WMH      
      nii=load_untouch_nii(file);
      count=sum(nii.img(:)~=0);
      voxTC_WMH=[voxTC_WMH;count];
      
%Hippocampe

      nii=load_nii(file_hpg);
      count=sum(nii.img(:)~=0);
      voxTC=[voxTC;count];
      
      ageTC=[ageTC;a(i,1)];
      sexeTC=[sexeTC;a(i,2)];
      ICVTC=[ICVTC;a(i,3)];   
    end

end






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
    
%M = 1 + Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);
disp(pval)