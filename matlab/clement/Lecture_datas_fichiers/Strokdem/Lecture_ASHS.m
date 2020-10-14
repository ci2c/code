%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lecture volumes segmentation ASHS%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all

%%% 72H %%%
%% Sujets avec troubles cog

[cov,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 

voxTC72G=[];
voxTC72D=[];
subj=[];

ageTC72=[];
sexeTC72=[];
ICVTC72=[];


TCog72=struct('CA1',{},'CA2',{},'CA3',{},'DG',{},'subiculum',{},'ERC',{});

for i = 1: length(b)
   
    s1g='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpg/TC/TC_';
    s1d='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpd/TC/TC_';
    s2g='72H_hpg.nii';
    s2d='72H_hpd.nii';
    
    % Mesure voxels masque hippocampe gauche
    file=char(strcat(s1g,b(i),s2g));    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxTC72G=[count;voxTC72G];
      subj=[subj;b(i)];
    end
    
    % Mesure voxels masque hippocampe droit   
    file=char(strcat(s1d,b(i),s2d));
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxTC72D=[count;voxTC72D];
    end
    
    
    
end
    
for i = 1: length(subj)
    
    dir_l=strcat('/NAS/dumbo/clement/ashs/72H/Results/',subj(i),'/final/',subj(i),'_left_corr_usegray_volumes.txt');
    dir_r=strcat('/NAS/dumbo/clement/ashs/72H/Results/',subj(i),'/final/',subj(i),'_right_corr_usegray_volumes.txt');
    
        
        
      % Attribution des covariables  
      ageTC72=[ageTC72;cov(i,1)];
      sexeTC72=[sexeTC72;cov(i,2)];
      ICVTC72=[ICVTC72;cov(i,3)];
        
% Mesure voxels masque ASHS
      fid=fopen(char(dir_l),'rt');
      
% gauche        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
           
            switch (char(a(3)))
               
                case 'CA1'
                   CA1_g=str2num(a{5});
                case 'CA2'
                   CA2_g=str2num(a{5});
                case 'DG'
                   DG_g=str2num(a{5});
                case 'CA3'
                   CA3_g=str2num(a{5});
                case 'subiculum'
                   sub_g=str2num(a{5});
                case 'ERC'
                   ERC_g=str2num(a{5});
            end
           
           tline=fgetl(fid);
           end
           
           fclose(fid);
        end

% Droite

        fid=fopen(char(dir_r),'rt');
        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
          
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
            switch char(a(3));
               
                case 'CA1'
                   CA1_d=str2num(a{5});
                case 'CA2'
                   CA2_d=str2num(a{5});
                case 'DG'
                   DG_d=str2num(a{5});
                case 'CA3'
                   CA3_d=str2num(a{5});
                case 'subiculum'
                   sub_d=str2num(a{5});
                case 'ERC'
                   ERC_d=str2num(a{5});
            end
           tline=fgetl(fid);
           end
        fclose(fid);
        end
        
       TCog72(i).CA1=[((CA1_g/voxTC72G(i))*(mean(voxTC72G))),((CA1_d/voxTC72G(i))*(mean(voxTC72G)))];
       TCog72(i).CA2=[((CA2_g/voxTC72G(i))*(mean(voxTC72G))),((CA2_d/voxTC72G(i))*(mean(voxTC72G)))];
       TCog72(i).CA3=[((CA3_g/voxTC72G(i))*(mean(voxTC72G))),((CA3_d/voxTC72G(i))*(mean(voxTC72G)))];
       TCog72(i).DG=[((DG_g/voxTC72G(i))*(mean(voxTC72G))),((DG_d/voxTC72G(i))*(mean(voxTC72G)))];
       TCog72(i).subiculum=[((sub_g/voxTC72G(i))*(mean(voxTC72G))),((sub_d/voxTC72G(i))*(mean(voxTC72G)))];
       TCog72(i).ERC=[ERC_g,ERC_d];
end

z=length(voxTC72G);

TC72_CA1=zeros(z,2);
TC72_CA3=zeros(z,2);
TC72_DG=zeros(z,2);
TC72_subiculum=zeros(z,2);
TC72_ERC=zeros(z,2);

for i=1:z
    TC72_CA1(i,:)=TCog72(i).CA1;
    TC72_CA3(i,:)=TCog72(i).CA3;
    TC72_DG(i,:)=TCog72(i).DG;
    TC72_subiculum(i,:)=TCog72(i).subiculum;
    TC72_ERC(i,:)=TCog72(i).ERC;
end

clear CA1_d CA1_g CA2_d CA2_g CA3_d CA3_g DG_d DG_g sub_d sub_g ERC_g ERC_d

%% Sujets sans troubles cog 

[cov,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 

voxNTC72G=[];
voxNTC72D=[];
subj=[];


ageNTC72=[];
sexeNTC72=[];
ICVNTC72=[];

NTCog72=struct('CA1',{},'CA2',{},'CA3',{},'DG',{},'subiculum',{},'ERC',{});

for i = 1: length(b)
    
    s1g='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpg/NTC/NTC_';
    s1d='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpd/NTC/NTC_';
    s2g='72H_hpg.nii';
    s2d='72H_hpd.nii';
    
    % Mesure voxels masque hippocampe gauche
    file=char(strcat(s1g,b(i),s2g));    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxNTC72G=[count;voxNTC72G];
      subj=[subj,b(i)];
    end
    
    % Mesure voxels masque hippocampe droit   
    file=char(strcat(s1d,b(i),s2d));
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxNTC72D=[count;voxNTC72D];
    end

    
end

for i = 1: length(subj)
    
    
    dir_l=strcat('/NAS/dumbo/clement/ashs/72H/Results/',subj(i),'/final/',subj(i),'_left_corr_usegray_volumes.txt');
    dir_r=strcat('/NAS/dumbo/clement/ashs/72H/Results/',subj(i),'/final/',subj(i),'_right_corr_usegray_volumes.txt');

      % Attribution des covariables 
      ageNTC72=[ageNTC72;cov(i,1)];
      sexeNTC72=[sexeNTC72;cov(i,2)];
      ICVNTC72=[ICVNTC72;cov(i,3)];
    
        
        
% Mesure voxels masque ASHS
      fid=fopen(char(dir_l),'rt');
      
% gauche        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
           
            switch (char(a(3)))
               
                case 'CA1'
                   CA1_g=str2num(a{5});
                case 'CA2'
                   CA2_g=str2num(a{5});
                case 'DG'
                   DG_g=str2num(a{5});
                case 'CA3'
                   CA3_g=str2num(a{5});
                case 'subiculum'
                   sub_g=str2num(a{5});
                case 'ERC'
                   ERC_g=str2num(a{5});
            end
           
           tline=fgetl(fid);
           end
           
           fclose(fid);
        end

% Droite

        fid=fopen(char(dir_r),'rt');
        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
          
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
            switch char(a(3));
               
                case 'CA1'
                   CA1_d=str2num(a{5});
                case 'CA2'
                   CA2_d=str2num(a{5});
                case 'DG'
                   DG_d=str2num(a{5});
                case 'CA3'
                   CA3_d=str2num(a{5});
                case 'subiculum'
                   sub_d=str2num(a{5});
                case 'ERC'
                   ERC_d=str2num(a{5});
            end
           tline=fgetl(fid);
           end
        fclose(fid);
        end
        
       NTCog72(i).CA1=[((CA1_g/voxNTC72G(i))*(mean(voxNTC72G))),((CA1_d/voxNTC72G(i))*(mean(voxNTC72G)))];
       NTCog72(i).CA2=[((CA2_g/voxNTC72G(i))*(mean(voxNTC72G))),((CA2_d/voxNTC72G(i))*(mean(voxNTC72G)))];
       NTCog72(i).CA3=[((CA3_g/voxNTC72G(i))*(mean(voxNTC72G))),((CA3_d/voxNTC72G(i))*(mean(voxNTC72G)))];
       NTCog72(i).DG=[((DG_g/voxNTC72G(i))*(mean(voxNTC72G))),((DG_d/voxNTC72G(i))*(mean(voxNTC72G)))];
       NTCog72(i).subiculum=[((sub_g/voxNTC72G(i))*(mean(voxNTC72G))),((sub_d/voxNTC72G(i))*(mean(voxNTC72G)))];
       NTCog72(i).ERC=[ERC_g,ERC_d];
      

end

z=length(voxNTC72G);

NTC72_CA1=zeros(z,2);
NTC72_CA3=zeros(z,2);
NTC72_DG=zeros(z,2);
NTC72_subiculum=zeros(z,2);
NTC72_ERC=zeros(z,2);

for i=1:z
    NTC72_CA1(i,:)=NTCog72(i).CA1;
    NTC72_CA3(i,:)=NTCog72(i).CA3;
    NTC72_DG(i,:)=NTCog72(i).DG;
    NTC72_subiculum(i,:)=NTCog72(i).subiculum;
    NTC72_ERC(i,:)=NTCog72(i).ERC;
end

clear CA1_d CA1_g CA2_d CA2_g CA3_d CA3_g DG_d DG_g sub_d sub_g ERC_g ERC_d

%% GLM gauche 

Nntc = size(ageNTC72,1);
Ntc  = size(ageTC72,1);

Y1 = [NTC72_CA1(:,1);TC72_CA1(:,1)];
Y3 = [NTC72_CA3(:,1);TC72_CA3(:,1)];
YDG = [NTC72_DG(:,1);TC72_DG(:,1)];
Ysub = [NTC72_subiculum(:,1);TC72_subiculum(:,1)];
YERC = [NTC72_ERC(:,1);TC72_ERC(:,1)];

age = [ageNTC72;ageTC72];
sexe = [sexeNTC72;sexeTC72];
icv= [ICVNTC72;ICVTC72];

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
    
%M = 1+ Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y1, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA1 gauche 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Y3, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA3 gauche 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YDG, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('DG gauche 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Ysub, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('subiculum gauche 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YERC, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('ERC gauche 72H')
disp([pval])

%% GLM droite

Nntc = size(ageNTC72,1);
Ntc  = size(ageTC72,1);

Y1 = [NTC72_CA1(:,2);TC72_CA1(:,2)];
Y3 = [NTC72_CA3(:,2);TC72_CA3(:,2)];
YDG = [NTC72_DG(:,2);TC72_DG(:,2)];
Ysub = [NTC72_subiculum(:,2);TC72_subiculum(:,2)];
YERC = [NTC72_ERC(:,2);TC72_ERC(:,2)];

age = [ageNTC72;ageTC72];
sexe = [sexeNTC72;sexeTC72];
icv= [ICVNTC72;ICVTC72];

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
    
%M = 1+ Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y1, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA1 droit 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Y3, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA3 droit 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YDG, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('DG droit 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Ysub, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('subiculum droit 72H')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YERC, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('ERC droit 72H')
disp([pval])



%%% M6 %%% 

%% Sujets avec troubles cog

[cov,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 

voxTC6G=[];
voxTC6D=[];
subj=[];

ageTC6=[];
sexeTC6=[];
ICVTC6=[];


TCog6=struct('CA1',{},'CA2',{},'CA3',{},'DG',{},'subiculum',{},'ERC',{});

for i = 1: length(b)
    
    
    s1g='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpg/TC/TC_';
    s1d='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpd/TC/TC_';
    s2g='M6_hpg.nii';
    s2d='M6_hpd.nii';
    
    % Mesure voxels masque hippocampe gauche
    file=char(strcat(s1g,b(i),s2g));    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxTC6G=[count;voxTC6G];
      subj=[subj,b(i)];
    end
    
    % Mesure voxels masque hippocampe droit   
    file=char(strcat(s1d,b(i),s2d));
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxTC6D=[count;voxTC6D];
    end
    
    
end 
    
for i = 1: length(subj)

    
    dir_l=strcat('/NAS/dumbo/clement/ashs/M6/Results/',subj(i),'/final/',subj(i),'_left_corr_usegray_volumes.txt');
    dir_r=strcat('/NAS/dumbo/clement/ashs/M6/Results/',subj(i),'/final/',subj(i),'_right_corr_usegray_volumes.txt');
    

    if exist(file) ~= 0
        
        
              
% Attribution des covariables   
      ageTC6=[ageTC6;cov(i,1)];
      sexeTC6=[sexeTC6;cov(i,2)];
      ICVTC6=[ICVTC6;cov(i,3)];
    
        
% Mesure voxels masque ASHS
      fid=fopen(char(dir_l),'rt');
      
% gauche        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
           
            switch (char(a(3)))
               
                case 'CA1'
                   CA1_g=str2num(a{5});
                case 'CA2'
                   CA2_g=str2num(a{5});
                case 'DG'
                   DG_g=str2num(a{5});
                case 'CA3'
                   CA3_g=str2num(a{5});
                case 'subiculum'
                   sub_g=str2num(a{5});
                case 'ERC'
                   ERC_g=str2num(a{5});
            end
           
           tline=fgetl(fid);
           end
           
           fclose(fid);
        end

% Droite

        fid=fopen(char(dir_r),'rt');
        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
          
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
            switch char(a(3));
               
                case 'CA1'
                   CA1_d=str2num(a{5});
                case 'CA2'
                   CA2_d=str2num(a{5});
                case 'DG'
                   DG_d=str2num(a{5});
                case 'CA3'
                   CA3_d=str2num(a{5});
                case 'subiculum'
                   sub_d=str2num(a{5});
                case 'ERC'
                   ERC_d=str2num(a{5});
            end
           tline=fgetl(fid);
           end
        fclose(fid);
        end
        
       TCog6(i).CA1=[((CA1_g/voxTC6G(i))*(mean(voxTC6G))),((CA1_d/voxTC6G(i))*(mean(voxTC6G)))];
       TCog6(i).CA2=[((CA2_g/voxTC6G(i))*(mean(voxTC6G))),((CA2_d/voxTC6G(i))*(mean(voxTC6G)))];
       TCog6(i).CA3=[((CA3_g/voxTC6G(i))*(mean(voxTC6G))),((CA3_d/voxTC6G(i))*(mean(voxTC6G)))];
       TCog6(i).DG=[((DG_g/voxTC6G(i))*(mean(voxTC6G))),((DG_d/voxTC6G(i))*(mean(voxTC6G)))];
       TCog6(i).subiculum=[((sub_g/voxTC6G(i))*(mean(voxTC6G))),((sub_d/voxTC6G(i))*(mean(voxTC6G)))];
       TCog6(i).ERC=[ERC_g,ERC_d];
    end
end

z=length(voxTC6G);

TC6_CA1=zeros(z,2);
TC6_CA3=zeros(z,2);
TC6_DG=zeros(z,2);
TC6_subiculum=zeros(z,2);
TC6_ERC=zeros(z,2);

for i=1:z
    TC6_CA1(i,:)=TCog6(i).CA1;
    TC6_CA3(i,:)=TCog6(i).CA3;
    TC6_DG(i,:)=TCog6(i).DG;
    TC6_subiculum(i,:)=TCog6(i).subiculum;
    TC6_ERC(i,:)=TCog6(i).ERC;
end

clear CA1_d CA1_g CA2_d CA2_g CA3_d CA3_g DG_d DG_g sub_d sub_g ERC_g ERC_d

%% Sujets sans troubles cog 

[cov,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 

voxNTC6G=[];
voxNTC6D=[];
subj=[];

ageNTC6=[];
sexeNTC6=[];
ICVNTC6=[];

NTCog6=struct('CA1',{},'CA2',{},'CA3',{},'DG',{},'subiculum',{},'ERC',{});

for i = 1: length(b)
    
        
    s1g='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpg/NTC/NTC_';
    s1d='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpd/NTC/NTC_';
    s2g='M6_hpg.nii';
    s2d='M6_hpd.nii';
    
    % Mesure voxels masque hippocampe gauche
    file=char(strcat(s1g,b(i),s2g));    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxNTC6G=[count;voxNTC6G];
      subj=[subj,b(i)];
    end
    
    % Mesure voxels masque hippocampe droit   
    file=char(strcat(s1d,b(i),s2d));
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);
      voxNTC6D=[count;voxNTC6D];
    end
    
    
end 
   
for i = 1: length(subj)

    
    dir_l=strcat('/NAS/dumbo/clement/ashs/M6/Results/',subj(i),'/final/',subj(i),'_left_corr_usegray_volumes.txt');
    dir_r=strcat('/NAS/dumbo/clement/ashs/M6/Results/',subj(i),'/final/',subj(i),'_right_corr_usegray_volumes.txt');

   
    if exist(file) ~= 0
% Mesure voxels masque ASHS
      fid=fopen(char(dir_l),'rt');
      
      
% Attribution des covariables  
      ageNTC6=[ageNTC6;cov(i,1)];
      sexeNTC6=[sexeNTC6;cov(i,2)];
      ICVNTC6=[ICVNTC6;cov(i,3)];
      
      
      
% gauche        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
           
            switch (char(a(3)))
               
                case 'CA1'
                   CA1_g=str2num(a{5});
                case 'CA2'
                   CA2_g=str2num(a{5});
                case 'DG'
                   DG_g=str2num(a{5});
                case 'CA3'
                   CA3_g=str2num(a{5});
                case 'subiculum'
                   sub_g=str2num(a{5});
                case 'ERC'
                   ERC_g=str2num(a{5});
            end
           
           tline=fgetl(fid);
           end
           
           fclose(fid);
        end

% Droite

        fid=fopen(char(dir_r),'rt');
        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
          
           while tline~=-1
           a = strread(tline,'%s','delimiter',' ');
            switch char(a(3));
               
                case 'CA1'
                   CA1_d=str2num(a{5});
                case 'CA2'
                   CA2_d=str2num(a{5});
                case 'DG'
                   DG_d=str2num(a{5});
                case 'CA3'
                   CA3_d=str2num(a{5});
                case 'subiculum'
                   sub_d=str2num(a{5});
                case 'ERC'
                   ERC_d=str2num(a{5});
            end
           tline=fgetl(fid);
           end
        fclose(fid);
        end
        
       NTCog6(i).CA1=[((CA1_g/voxNTC6G(i))*(mean(voxNTC6G))),((CA1_d/voxNTC6G(i))*(mean(voxNTC6G)))];
       NTCog6(i).CA2=[((CA2_g/voxNTC6G(i))*(mean(voxNTC6G))),((CA2_d/voxNTC6G(i))*(mean(voxNTC6G)))];
       NTCog6(i).CA3=[((CA3_g/voxNTC6G(i))*(mean(voxNTC6G))),((CA3_d/voxNTC6G(i))*(mean(voxNTC6G)))];
       NTCog6(i).DG=[((DG_g/voxNTC6G(i))*(mean(voxNTC6G))),((DG_d/voxNTC6G(i))*(mean(voxNTC6G)))];
       NTCog6(i).subiculum=[((sub_g/voxNTC6G(i))*(mean(voxNTC6G))),((sub_d/voxNTC6G(i))*(mean(voxNTC6G)))];
       NTCog6(i).ERC=[ERC_g,ERC_d];

    end
end

z=length(voxNTC6G);

NTC6_CA1=zeros(z,2);
NTC6_CA3=zeros(z,2);
NTC6_DG=zeros(z,2);
NTC6_subiculum=zeros(z,2);
NTC6_ERC=zeros(z,2);

for i=1:z
    NTC6_CA1(i,:)=NTCog6(i).CA1;
    NTC6_CA3(i,:)=NTCog6(i).CA3;
    NTC6_DG(i,:)=NTCog6(i).DG;
    NTC6_subiculum(i,:)=NTCog6(i).subiculum;
    NTC6_ERC(i,:)=NTCog6(i).ERC;
end

clear CA1_d CA1_g CA2_d CA2_g CA3_d CA3_g DG_d DG_g sub_d sub_g ERC_g ERC_d

%% GLM gauche 

Nntc = size(ageNTC6,1);
Ntc  = size(ageTC6,1);

Y1 = [NTC6_CA1(:,1);TC6_CA1(:,1)];
Y3 = [NTC6_CA3(:,1);TC6_CA3(:,1)];
YDG = [NTC6_DG(:,1);TC6_DG(:,1)];
Ysub = [NTC6_subiculum(:,1);TC6_subiculum(:,1)];
YERC = [NTC6_ERC(:,1);TC6_ERC(:,1)];

age = [ageNTC6;ageTC6];
sexe = [sexeNTC6;sexeTC6];
icv= [ICVNTC6;ICVTC6];

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
    
%M = 1+ Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y1, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA1 gauche M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Y3, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA3 gauche M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YDG, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('DG gauche M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Ysub, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('subiculum gauche M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YERC, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('ERC gauche M6')
disp([pval])

%% GLM droite

Nntc = size(ageNTC6,1);
Ntc  = size(ageTC6,1);

Y1 = [NTC6_CA1(:,2);TC6_CA1(:,2)];
Y3 = [NTC6_CA3(:,2);TC6_CA3(:,2)];
YDG = [NTC6_DG(:,2);TC6_DG(:,2)];
Ysub = [NTC6_subiculum(:,2);TC6_subiculum(:,2)];
YERC = [NTC6_ERC(:,2);TC6_ERC(:,2)];

age = [ageNTC6;ageTC6];
sexe = [sexeNTC6;sexeTC6];
icv= [ICVNTC6;ICVTC6];

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
    
%M = 1+ Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y1, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA1 droit M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Y3, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('CA3 droit M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YDG, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('DG droit M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( Ysub, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('subiculum droit M6')
disp([pval])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slm = SurfStatLinMod( YERC, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('ERC droit M6')
disp([pval])


close all
