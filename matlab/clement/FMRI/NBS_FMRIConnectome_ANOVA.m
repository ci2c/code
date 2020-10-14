function NBS_FMRIConnectome_ANOVA(g1,g2,g3)

%% CONFIG

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog';
outConn   = 'Network'; 
groupList = 'TCog';
alpha     = 0.05;
statCorr  = 'NBS'; % NBS or FDR
statSize  = 'Extent'; % Intensity or Extent
thresVal  = 2:0.1:4;
dozscore  = 0;
outDir    = fullfile(fMRIdir,outConn,['g' g1 'Vsg' g2 'Vsg' g3 'AN_C_OVA']);


%% BUILD GLM

if ~exist(outDir,'dir')
    cmd = sprintf('mkdir %s',outDir);
    unix(cmd);
end

% subjects
subjs = {};
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g3 '_subjs.txt']),'%s \n');
% covariates
cov = [];
% cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
% cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];
% cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g3 '_cov.txt']))];

cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
covg2 = load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']));
cov = [cov; covg2(:,1:2)];
covg3 = load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']));
cov = [cov; covg3(:,1:2)];


Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end

clear k

% Build design matrix and load connectivity matrices
X      = [];
nnodes = 313;
nedges = nnodes*(nnodes-1)/2;
cp     = 0;
Y      = [];
temp   = 0;
Cov=[];
z=1;
for k = 1:Ng
    
    disp(k)
     
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        connFile = fullfile(fsdir,subj,'rsfmri','Craddock_Parc','NB31','Connectome_Ck31.mat');
        if exist(connFile,'file')
            load(connFile);
            vtmp = niak_mat2vec(Connectome.Cmat)';
            if dozscore
                vtmp = niak_fisher(vtmp);
            end
            if length(vtmp)==nedges
                Y(end+1,:) = vtmp;
                X(end+1,k) = 1;
                Cov(end+1,:) = cov(z,:);
            else
                disp(['error with subject: ' subj]);
            end
            
        else
            
            disp(['no connectome for subject: ' subj]);
            
        end
        
    end
    temp = temp + length(subjs{k});
    z=z+1;
end

% final design matrix
x=X;

% %% ANOVA
% 
% contrast = [1 1 1];
% 
% 
% % GLM
% glmFile = fullfile(outDir,['nbs_glm_g' g1 '_g' g2 '_g' g3 '_' num2str(dozscore) 'ANOVA.mat']);
% if ~exist(glmFile,'file')
%     GLM.y           = Y;
%     GLM.X           = x;
%     GLM.contrast    = contrast;
%     GLM.test        = 'ttest';
%     GLM.perms       = 10000;
%     STATS.test_stat = NBSglm(GLM);
%     save(glmFile,'GLM','STATS','-v7.3');
%     clear GLM STATS;
% end
% 
% % STATS
% 
% [labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
% coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');
% load(glmFile,'GLM','STATS');
% 
% STATS.alpha = alpha;
% STATS.size  = 'Extent'; %'Intensity or Extent';
% STATS.N     = length(names);
% 
%     for k = 1:length(thresVal)
% 
%         STATS.thresh = thresVal(k);        
% 
%         clear NBS;
% 
%         NBS.node_coor  = coord_parc;
%         NBS.node_label = names;
%         [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
%         %NBSview(NBS);
% 
%         save(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '.mat']),'NBS','GLM','STATS');
% 
%         for netw = 1:NBS.n
% 
%             C = full(NBS.con_mat{netw});
%             C = C+C';
%             C = C>0;
%             deg = degrees_und(C);
% 
%             % % BrainNet
%             % nodes
%             nodes.coords = coord_parc;
%             nodes.colors = ones(1,size(coord_parc,1));
%             nodes.sizes  = deg';
%             nodes.labels = names;
% 
%             fid = fopen(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '_ANOVA' '.node']),'w');
% 
%             for cj = 1:size(nodes.coords,1)
%                 % Coordinates
%                 fprintf(fid,'%f ',nodes.coords(cj,1));
%                 fprintf(fid,'%f ',nodes.coords(cj,2));
%                 fprintf(fid,'%f ',nodes.coords(cj,3));
% 
%                 % Colors
%                 fprintf(fid,'%f ',nodes.colors(cj));
% 
%                 % Sizes
%                 fprintf(fid,'%f ',nodes.sizes(cj));
% 
%                 % Labels
%                 fprintf(fid,'%s ',nodes.labels{cj});
% 
%                 fprintf(fid,'\n');
%             end
%             fclose(fid);
% 
%             % edges
%             FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '_ANOVA' '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));
% 
%         end
% 
%     end
%     

%% ANCOVA

X = [X Cov];

contrast = [0 1 1 zeros(1,size(cov,2))];
[labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');

% GLM
glmFile = fullfile(outDir,['nbs_glm_g' g1 '_g' g2 '_g' g3 '_' num2str(dozscore) 'ANCOVA.mat']);
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

% STATS


load(glmFile,'GLM','STATS');

STATS.alpha = alpha;
STATS.size  = 'Extent'; %'Intensity or Extent';
STATS.N     = length(names);

    for k = 1:length(thresVal)

        STATS.thresh = thresVal(k);        

        clear NBS;

        NBS.node_coor  = coord_parc;
        NBS.node_label = names;
        [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
        %NBSview(NBS);

        save(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '.mat']),'NBS','GLM','STATS');

        for netw = 1:NBS.n

            C = full(NBS.con_mat{netw});
            C = C+C';
            C = C>0;
            deg = degrees_und(C);

            % % BrainNet
            % nodes
            nodes.coords = coord_parc;
            nodes.colors = ones(1,size(coord_parc,1));
            nodes.sizes  = deg';
            nodes.labels = names;

            fid = fopen(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '_ANCOVA' '.node']),'w');

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
            FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '_ANCOVA'  '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));

        end

    end
