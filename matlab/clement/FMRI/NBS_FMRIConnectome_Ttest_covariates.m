function NBS_FMRIConnectome_Ttest_covariates(g1,g2)

%% CONFIG

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog'; %
outConn   = 'Network'; 
groupList = 'TCog'; %
alpha     = 0.05;
statCorr  = 'NBS'; % NBS or FDR
statSize  = 'Extent'; % Intensity or Extent
thresVal  = 2:0.1:4;
dozscore  = 0;
corr      = 0;
outDir    = fullfile(fMRIdir,outConn,['g' g1 'Vsg' g2 '-DEEPFAZEKAS']);


%% BUILD GLM

if ~exist(outDir,'dir')
    cmd = sprintf('mkdir %s',outDir);
    unix(cmd);
end

% subjects
subjs = {};
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_subjs.txt']),'%s \n');

% covariates
cov = [];
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];


Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end

clear k

% Build design matrix and load connectivity matrices
X      = [];
nnodes = 313; %
nedges = nnodes*(nnodes-1)/2;
cp     = 0;
Y      = [];
temp   = 0;
q=1;
subj_ok = [];
Con = [];
for k = 1:Ng
    
    disp(k)
     
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        
        connFile = fullfile(fsdir,[ subj '_M6'],'rsfmri','Craddock_Parc','NB31','Connectome_Ck31.mat');
        %connFile = fullfile(fsdir,subj,'rsfmri','Connectome_fs.mat'); %
        if exist(connFile,'file')
            load(connFile);
            if isfield(Connectome,'Cmat')
                vtmp = niak_mat2vec(Connectome.Cmat)';
                
            
                if dozscore
                    vtmp = niak_fisher(vtmp);
                end
                if length(vtmp)==nedges
                    X(end+1,k) = 1;
                    Y(end+1,:) = vtmp;
                    subj_ok(end+1,1)=q;
                    Con(:,:,end+1) = Connectome.Cmat;
                else
                    disp(['error with subject: ' subj]);
                    Y(end+1,:) = zeros(1,nedges);
                    X(end+1,k) = 0;
                end
            else 
                Y(end+1,:) = zeros(1,nedges);
                X(end+1,k) = 0;
            end
            
        else
            
            disp(['no connectome for subject: ' subj]);
            Y(end+1,:) = zeros(1,nedges);
            X(end+1,k) = 0;
            
        end  
        q=q+1;                
    end
    temp = temp + length(subjs{k});
    
end

% final design matrix


if corr
    X = [X(C,:) Score(C,:)];
    Y = Y(C,:);
elseif isempty(cov)
    X = X(subj_ok,:);
    Y = Y(subj_ok,:);
else
    X = [X(subj_ok,:) cov(subj_ok,:)];
    Y = Y(subj_ok,:);
end

%% G1 > G2

% contrast
contrast = [1 -1 0 0 0 0];

% GLM
glmFile = fullfile(outDir,['nbs_glm_g' g1 '_g' g2 '_' num2str(dozscore) '.mat']);
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

%[labidx,names] = textread('/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_rename.txt','%d %s');
%coord_parc     = load('/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_coord.txt');
[labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');
load(glmFile,'GLM','STATS');

STATS.alpha = alpha;
STATS.size  = 'Extent'; %'Intensity or Extent';
STATS.N     = length(names);

if strcmp(statCorr,'FDR')
    
    clear NBS;
    
    NBS.node_coor  = coord_parc;
    NBS.node_label = names;
    [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
    
    save(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(dozscore) '.mat']),'NBS','GLM','STATS','-v7.3');

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

        fid = fopen(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(dozscore) '_' num2str(netw) '.node']),'w');
        
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
        FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(dozscore) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));
        
    end
    
else
    
    for k = 1:length(thresVal)

        STATS.thresh = thresVal(k);        

        clear NBS;

        NBS.node_coor  = coord_parc;
        NBS.node_label = names;
        [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
        %NBSview(NBS);

        save(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '.mat']),'NBS','GLM','STATS','-v7.3');

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

            fid = fopen(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '.node']),'w');

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
            FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_g' g1 '_g' g2 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));

        end

    end
    
end


% % G1 < G2
% 
% clear NBS GLM STATS;
% 
% % contrast
% contrast = [-1 1 0 0 0];
% 
% % GLM
% glmFile = fullfile(outDir,['nbs_glm_g' g2 '_g' g1 '_' num2str(dozscore) '.mat']);
% if ~exist(glmFile,'file')
%     GLM.y           = Y;
%     GLM.X           = X;
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
% %[labidx,names] = textread('/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_rename.txt','%d %s');
% %coord_parc     = load('/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_coord.txt');
% [labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
% coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');
% 
% load(glmFile,'GLM','STATS');
% 
% STATS.alpha = alpha;
% STATS.size  = 'Extent'; %'Intensity';
% STATS.N     = length(names);
% 
% if strcmp(statCorr,'FDR')
%     
%     clear NBS;
%     
%     NBS.node_coor  = coord_parc;
%     NBS.node_label = names;
%     [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
%     
%     save(fullfile(outDir,[statCorr '_g' g2 '_g' g1 '_perm_p' num2str(alpha) '_' num2str(dozscore) '.mat']),'NBS','GLM','STATS','-v7.3');
% 
%     for netw = 1:NBS.n
% 
%         C = full(NBS.con_mat{netw});
%         C = C+C';
%         C = C>0;
%         deg = degrees_und(C);
% 
%         % % BrainNet
%         % nodes
%         nodes.coords = coord_parc;
%         nodes.colors = ones(1,size(coord_parc,1));
%         nodes.sizes  = deg';
%         nodes.labels = names;
% 
%         fid = fopen(fullfile(outDir,[statCorr '_g' g2 '_g' g1 '_perm_p' num2str(alpha) '_' num2str(dozscore) '_' num2str(netw) '.node']),'w');
%         
%         for cj = 1:size(nodes.coords,1)
%             % Coordinates
%             fprintf(fid,'%f ',nodes.coords(cj,1));
%             fprintf(fid,'%f ',nodes.coords(cj,2));
%             fprintf(fid,'%f ',nodes.coords(cj,3));
% 
%             % Colors
%             fprintf(fid,'%f ',nodes.colors(cj));
% 
%             % Sizes
%             fprintf(fid,'%f ',nodes.sizes(cj));
% 
%             % Labels
%             fprintf(fid,'%s ',nodes.labels{cj});
% 
%             fprintf(fid,'\n');
%         end
%         fclose(fid);
% 
%         % edges
%         FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_g' g2 '_g' g1 '_perm_p' num2str(alpha) '_' num2str(dozscore) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));
%         
%     end
%     
% else
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
%         save(fullfile(outDir,[statCorr '_g' g2 '_g' g1 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '.mat']),'NBS','GLM','STATS','-v7.3');
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
%             fid = fopen(fullfile(outDir,[statCorr '_g' g2 '_g' g1 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '.node']),'w');
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
%             FMRI_CreateEdgeFileBrainNet(fullfile(outDir,[statCorr '_g' g2 '_g' g1 '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(dozscore) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));
% 
%         end
% 
%     end
%     
% end
% 
% 
% 
% 
