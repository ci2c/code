%function FMRIConnectome_Score_Correlation

% This function compute correlation between connexions highlighted from NBS
% with a cognitive score, or any vector of value.
%
% Usage : Corr_Vec=FMRIConnectome_Score_Correlation(Net_mat,SubjsFile,ScoreFile)
%
% Inputs   : Net_mat   = sparse binary connexion matrix obtained from NBS.
%            SubjsFile = txt file with the subject IDs.
%            CovFile   = txt file with the subject covariates
%            ScoreFile = xls file with the values to be correlated with.
%                        First row = name of variates. 
%
% Outputs : .mat for matrix (same size as input) with edges that passed the test. Also .node and .edge files in output directory, readable with
% BraiNet.
%
% Clément Bournonville - Ci2C - CHU Lille - 02/2016

% For Strokdem :
% Net_mat : /NAS/tupac/protocoles/Strokdem/FMRI/TCog/Network/gnocog-CraVsgcog-Cra_AGE-SEXE-ED/NBS_gnocog-Cra_gcog-Cra_perm_p0.05_3_0.mat
% SubjsFile : /NAS/tupac/protocoles/Strokdem/FMRI/TCog/Nocog_Cog_subjs.txt
% CovFile : /NAS/tupac/protocoles/Strokdem/Clinical_Data/age-sexe-et.txt
% ScoreFile : /NAS/tupac/protocoles/Strokdem/Clinical_Data/Corr_Neuropsy.xls

%% CONFIG

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/Anxiete';
outConn   = 'Network'; 
groupList = 'Anxiete';
alpha     = 0.05;
statCorr  = 'FDR';
statSize  = 'Extent';
outDir    = fullfile(fMRIdir,outConn,['InteractionAxDep-CORRELATION']);
%% Loading

% [a,b,c] = xlsread('/NAS/tupac/protocoles/Strokdem/Corresp_ID.xls');
% Inc_ID = b(:,1);
% MRI_ID = b(:,2);
% 
% subjs{1,1} = MRI_ID;


% subjects
subj = {}; subj{end+1} = textread('/NAS/tupac/protocoles/Strokdem/Stk_All.txt','%s \n');

%load('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/Network/gnocog-CraVsgcog-Cra_AGE-SEXE-ED/NBS_gnocog-Cra_gcog-Cra_perm_p0.05_3_0.mat','NBS');
%load('/NAS/tupac/protocoles/Strokdem/FMRI/Anxiete/Network/gTDVsgNTD-Age-Sexe-INTERACTION_AnxDep/NBS_gNTD_gTD_perm_p0.05_2.7_0.mat');
%NBSmat=full(cell2mat(NBS.con_mat)) + triu(full(cell2mat(NBS.con_mat)))';
%NBSmat=full(NBS.con_mat{1}) + triu(full(NBS.con_mat{1}))';



[score,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_zscoreV2M36.xls');
score = score(:,1);
ScoreName = 'TEST-Mem_CorrelationMem';

%%
load('/NAS/tupac/protocoles/Strokdem/Prediction/Score_Munich/Score_MunichZscore_Munich_MEMOIRE_M36.mat');
NBSmat = msbproj;
%load('/NAS/tupac/protocoles/Strokdem/Prediction/Score_Munich/Multitask_123.mat')
%NBSmat(NBS1 == 0) = 0;
outDir = '/NAS/tupac/protocoles/Strokdem/Prediction/Score_Munich';

%% BUILD GLM
S= [];
vtmp = [];
for i = 1:length(subj{1})

    clear Y X Cov Score GLM STATS
    z=1;
    
    connFile = fullfile(fsdir,[ subj{1}{i} '_M6'],'rsfmri','Craddock_Parc','NB31','Connectome_Ck31.mat');
    
    if exist(connFile,'file')
    load(connFile);
        if isfield(Connectome,'Cmat') 
            if length(Connectome.Cmat(:)) == 313^2

                Net_Co=Connectome.Cmat.*NBSmat; 
                vtmp(end+1,:) = niak_mat2vec(Net_Co)'; 
                S(end+1,1) = i;
            else
                vtmp(end+1,:) = NaN;
            end
        else
            vtmp(end+1,:) = NaN;
        end
    else
        vtmp(end+1,:) = NaN;
    end
end

id = find(vtmp(1,:) ~= 0);
M1 = mean(vtmp(:,id),2); 

[C,~,~] = intersect(S,find(~isnan(score)));

vtmp = vtmp(C,:);
score = score(C);

% Final design matrix 

% contrast
contrast = [0 1];
X = [ones(length(score),1) score];

% Extract ~= 0 columns of Y
ID = find(sum(vtmp,1) ~= 0);
Y = vtmp(:,ID);



%% GLM
    glmFile = fullfile(outDir,['FDR_glm_g' 'correlation_' ScoreName '.mat']);
    cmd = sprintf('rm -rf  %s',glmFile);
    unix(cmd);
    if ~exist(glmFile,'file')
        GLM.y           = Y;
        GLM.X           = X;
        GLM.contrast    = contrast;
        GLM.test        = 'ttest';
        GLM.perms       = 10000;
        STATS.test_stat = NBSglm(GLM);
        save(glmFile,'GLM','STATS','-v7.3');
        clear GLM STATS;
    end

%% STATS

Yy = 48828;

%[labidx,names] = textread('/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_rename.txt','%d %s');
%coord_parc     = load('/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_coord.txt');
[labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');

    load(glmFile,'GLM','STATS');

    STATS.alpha = alpha;
    STATS.size  = 'Extent'; %'Intensity or Extent';
    STATS.N     = length(names);


    
    clear NBS;
    
    NBS.node_coor  = coord_parc;
    NBS.node_label = names;
    %[NBS.n,NBS.con_mat,NBS.pval,NBS.FDRe] = NBSfdr(STATS,1.0167,GLM);
    [~,~,~,FDRe] = NBSfdr(STATS,1.0167,GLM);
    
    
    if ~isempty(FDRe)
        
        vec=zeros(1,Yy);
    
    % Recompose original networks with only edges that were accepted for
    % FDR (because empty edges were removed originally for GLM)
        vec(ID(FDRe))=1;
        test_statf=zeros(GLM.perms+1,Yy);
        test_statf(:,ID(FDRe))=STATS.test_stat(:,FDRe);
        STATS.test_stat=test_statf;
        NBS.con_mat=niak_vec2mat(vec,0);
        
    % Find coordinates of edges for gephi use
    
        id=find(NBS.con_mat ~= 0);
        for f=1:length(id)
            [x,y,~]=coord1Dto3D(id(f),313,313,1);
            Coord(f,:)=[x-1,y-1]; %Gephi nodes start at 0
        end
        
        save(fullfile(outDir,[statCorr '_perm_p' num2str(alpha) '_' 'CORRELATION' ScoreName '.mat']),'NBS','GLM','STATS','Coord','-v7.3');
    
        C = full(NBS.con_mat);
        C = C+C';
        C = C>0;
        deg = degrees_und(C);

        % % BrainNet
        % nodes
        nodes.coords = coord_parc;
        nodes.colors = ones(1,size(coord_parc,1));
        nodes.sizes  = deg';
        nodes.labels = names;

        fid = fopen(fullfile(outDir,[statCorr '_perm_p' num2str(alpha) '_' 'CORRELATION' ScoreName '.node']),'w');
        
        for cj = 1:size(nodes.coords,1)
            % Coordinates
            fprintf(fid,'%f ',nodes.coords(cj,1));
            fprintf(fid,'%f ',nodes.coords(cj,2));
            fprintf(fid,'%f ',nodes.coords(cj,3));

            % Colors
            fprintf(fid,'%f ',nodes.colors(cj));

            % Sizes
            fprintf(fid,'%f ',nodes.sizes(cj));

            % Labels
            fprintf(fid,'%s ',nodes.labels{cj});

            fprintf(fid,'\n');
        end
        fclose(fid);

        % edges
        FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_perm_p' num2str(alpha) '_' 'CORRELATION' ScoreName '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0)); 
    end  
%end

