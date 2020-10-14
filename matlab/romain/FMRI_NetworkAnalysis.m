function NBS_FMRIConnectome_Ttest_covariates()
%SCript de clement pour calcul de l'efficience

%% CONFIG

fsdir     = '/NAS/tupac/romain/testHRSFC/';
fMRIdir   = '//NAS/tupac/romain/testHRSFC/';
outConn   = 'Network'; 
groupList = 'TCog';
thresPars = 0.05:0.025:0.4;
binary    = 0; % 0 or 1 for also binary matrix test
outDir    = fullfile(fMRIdir,outConn);

if ~exist(outDir,'dir')
    cmd = sprintf('mkdir %s',outDir);
    unix(cmd);
end

% subjects
subjs = {};
subjs{end+1} = textread(fullfile('/NAS/dumbo/romain/','cohorte.txt'),'%s \n');
%subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_subjs.txt']),'%s \n');

% covariates
%cov = [];
%cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
%cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];

Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end
clear k
% Build matrix design
X      = zeros(Ns,Ng);
nnodes = 164;
nedges = nnodes*(nnodes-1)/2;
cp     = 0;
Y      = zeros(Ns,nedges);
temp   = 0;
MeasW        = []; %Weighted
MeasB        = []; %Binary

%load connectivity matrices and apply sparsity 
for k = 1:Ng  
    disp(k)
    %loop for subject
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        X(temp+s,k) = 1;                
        temp_MeasW=zeros(length(thresPars),164); %Weighted                
        temp_MeasB=zeros(length(thresPars),1); %Binary
        
        %loop for sparsity 
        for j = 1:length(thresPars)            
            connFile = fullfile(fsdir,subj,'connectome','Connectome.mat');
            if exist(connFile,'file')
                load(connFile);       
                Conn_mat=Connectome.Cmat;                                
                bin=gretna_R2b(Conn_mat,'s',thresPars(j)); %Sparsity
                Conn_mat=bin.*abs(Conn_mat);                
                Conn_mat = weight_conversion(Conn_mat,'normalize');  
                Conn_matL = weight_conversion(Conn_mat,'lengths');                 
                M =  efficiency_bin(bin);
                temp_MeasW(j,:)=reshape(M,164,1);  
            else
                disp(['no connectome for subject: ' subj]);            
            end             
        end
        MeasW_AUC=trapz(thresPars,temp_MeasW); % Compute AUC for the different measurments
        MeasW=[MeasW;MeasW_AUC];
                 
      	if binary
            MeasB_AUC=trapz(thresPars,temp_MeasB);
            MeasB=[MeasB;MeasB_AUC];
        end   
    end
   temp = temp + length(subjs{k});   
end
X = [X cov];

%% GLM for group comparison with FDR
disp('Statistical analysis');

%Weighted
Mes.MeasW=MeasW;


if binary
Mes.MeasB=MeasB;
end

field=fieldnames(Mes);

%Prepare GLM
Nntc = length(subjs{1});
Ntc  = length(subjs{2});

group={};
for k = 1:Nntc
    group{end+1} = 'NTC';
end
for k = 1:Ntc
    group{end+1} = 'TC';
end

COV=term(cov);
Group = term(group);
M = 1 + Group + COV;

%G1 > G2
%contrast
contrast = Group.NTC - Group.TC;
%contrast = [1 -1 zeros(1,size(cov,2))];

clear j k
for j=1:length(fieldnames(Mes)) %Traite mesure par mesure

    Y=Mes.(cell2mat(field(j))); %Accès au champs de la structure
    [nx,ny,nz,nt]=size(Y);
    
    Res_GLM=[];
    for k=1:ny
        slm = SurfStatLinMod( Y(:,k),M);
        slm = SurfStatT( slm, contrast );
        pval = SurfStatP(slm);%
        Res_GLM=[Res_GLM,pval.P];%
    end
    [Res_GLMFDR]=spm_P_FDR(Res_GLM); %FDR 
    ResG1G2.(cell2mat(field(j)))=Res_GLMFDR; %Stocke dans une variable résultat
end

%save(fullfile(outDir,['local_eff' '_g' g1 '_g' g2 '_' num2str(binary) '.mat']),'ResG1G2');


%G2 > G1

%Weighted 
Mes.MeasW=MeasW;

if binary
Mes.MeasB=MeasB;
end

field=fieldnames(Mes);

%contrast
contrast = Group.TC - Group.NTC;

%contrast = [-1 1 zeros(1,size(cov,2))];

clear j
for j=1:length(fieldnames(Mes)) %Traite mesure par mesure

    Y=Mes.(cell2mat(field(j))); %Accès au champs de la structure
    [nx,ny,nz,nt]=size(Y);
    
    Res_GLM=[];
    for k=1:ny
        slm = SurfStatLinMod( Y(:,k),M);
        slm = SurfStatT( slm, contrast );
        pval = SurfStatP(slm);%
        Res_GLM=[Res_GLM,pval.P];%
    end
    [Res_GLM]=spm_P_FDR(Res_GLM); %FDR 
    ResG2G1.(cell2mat(field(j)))=Res_GLM; %Stocke dans une variable résultat
end
disp('fini')
% save(fullfile(outDir,['Node-degree''_g' g2 '_g' g1 '_' num2str(binary) '.mat']),'Res');


