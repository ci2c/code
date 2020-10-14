clear all
close all

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
ConTC_g=[];
ConTC_d=[];

ageTC=[]; 
sexeTC=[];
j=1;
for i=1:length(b) 

    if exist(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',strcat(char(b(i)),'_M6'),'mri',strcat(char(b(i)),'_M6_hpg.nii'))) ~= 0 && exist(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',strcat(char(b(i)),'_M6'),'rsfmri/Connectome_hp.mat')) ~= 0
    load(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',strcat(char(b(i)),'_M6'),'rsfmri/Connectome_hp.mat'));    
    ConTC_g(j,:)=Connectome.Cmat(17,:);
    ConTC_d(j,:)=Connectome.Cmat(18,:);
    
    ageTC(j,:)=a(i,1);
    sexeTC(j,:)=a(i,2);
    
    j=j+1;
    end
end

clear a b c

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 

ConNTC_g=[];
ConNTC_d=[];

ageNTC=[]; 
sexeNTC=[];

j=1;
for i=1:length(b)

    if exist(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',strcat(char(b(i)),'_M6'),'mri',strcat(char(b(i)),'_M6_hpg.nii'))) ~= 0 && exist(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',strcat(char(b(i)),'_M6'),'rsfmri/Connectome_hp.mat')) ~= 0
    load(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',strcat(char(b(i)),'_M6'),'rsfmri/Connectome_hp.mat'));
    ConNTC_g(j,:)=Connectome.Cmat(17,:);
    ConNTC_d(j,:)=Connectome.Cmat(18,:);
    
    ageNTC(j,:)=a(i,1);
    sexeNTC(j,:)=a(i,2);
    
    
    j=j+1;
    end
end

ConTC_g=[ConTC_g(:,1:16),ConTC_g(:,18:end)];
ConTC_d=[ConTC_d(:,1:17),ConTC_d(:,19:end)];

ConNTC_g=[ConNTC_g(:,1:16),ConNTC_g(:,18:end)];
ConNTC_d=[ConNTC_d(:,1:17),ConNTC_d(:,19:end)];

%% GLM
    
Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

Y = [ConNTC_g;ConTC_g];
age = [ageNTC;ageTC];
sexe = [sexeNTC;sexeTC];

Age = term(age);
Sexe = term(sexe);

group={};
for k = 1:Nntc
    group{end+1} = 'NTC';
end
for k = 1:Ntc
    group{end+1} = 'TC';
end

Group = term(group);
    
M = 1+ Group + Age + Sexe;
%M = 1 + Group + Age + Sexe;
%M = 1 + Group;
contrast = Group.NTC - Group.TC;

%Gauche
Y = [ConNTC_g;ConTC_g];
[nx,ny,nz,nt]=size(Y);
Res_GLM_g=[];

for k=1:ny
slm = SurfStatLinMod( Y(:,k), M );
slm = SurfStatT( slm, contrast );
pval = SurfStatP(slm);
Res_GLM_g=[Res_GLM_g;pval.P];
end

Res_GLMFDR_g=spm_P_FDR(Res_GLM_g);

%Droite
Y = [ConNTC_d;ConTC_d];
[nx,ny,nz,nt]=size(Y);
Res_GLM_d=[];

for k=1:ny
slm = SurfStatLinMod( Y(:,k), M );
slm = SurfStatT( slm, contrast );
pval = SurfStatP(slm);
Res_GLM_d=[Res_GLM_d;pval.P];
end

Res_GLMFDR_d=spm_P_FDR(Res_GLM_d);
