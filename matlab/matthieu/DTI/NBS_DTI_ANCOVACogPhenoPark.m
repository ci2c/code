clear all; close all;

FSDir = '/NAS/dumbo/protocoles/CogPhenoPark/FS5.3';
inDir = '/NAS/dumbo/protocoles/CogPhenoPark/Connectome/ANCOVA';
% 
fid0 = fopen(fullfile(inDir,'Cluster1.txt'),'r');
% fid1 = fopen(fullfile(inDir,'Cluster2.txt'),'r');
% fid2 = fopen(fullfile(inDir,'Cluster3.txt'),'r');
% fid3 = fopen(fullfile(inDir,'Cluster4.txt'),'r');
% fid4 = fopen(fullfile(inDir,'Cluster5.txt'),'r');
% 
T0=textscan(fid0, '%s');
% T1=textscan(fid1, '%s');
% T2=textscan(fid2, '%s');
% T3=textscan(fid3, '%s');
% T4=textscan(fid4, '%s');
% 
fclose('all');
% 
% % Preallocate memory
D0(length(T0{1})).name = NaN;
% D1(length(T1{1})).name = NaN;
% D2(length(T2{1})).name = NaN;
% D3(length(T3{1})).name = NaN;
% D4(length(T4{1})).name = NaN;
% 
nsubj0  = length(D0);
% nsubj1  = length(D1);
% nsubj2  = length(D2);
% nsubj3  = length(D3);
% nsubj4  = length(D4);
% 
nnodes = 164;
nedges = nnodes*(nnodes-1)/2;
% 
alpha = 0.1;
% 
% % Load connectivity matrices
% cp = 0;
% Y0  = zeros(nsubj0+nsubj1+nsubj2+nsubj3+nsubj4,nedges);
% Y1  = zeros(nsubj0+nsubj1+nsubj2+nsubj3+nsubj4,nedges);
% Y2  = zeros(nsubj0+nsubj1+nsubj2+nsubj3+nsubj4,nedges);
% 
for k = 1:nsubj0
    
%     disp(k)
%     cp = cp+1;
    D0(k).name = fullfile(FSDir,T0{1}{k},'dti',['Connectome_' T0{1}{k} '.mat']);  
%     load(D0(k).name);
%     Y0(cp,:) = niak_mat2vec(Connectome.Mfa)';
%     Y1(cp,:) = niak_mat2vec(Connectome.MMD)';
%     Y2(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
    
end
% for k = 1:nsubj1
%     
%     disp(k)
%     cp = cp+1;
%     D1(k).name = fullfile(FSDir,T1{1}{k},'dti',['Connectome_' T1{1}{k} '.mat']);  
%     load(D1(k).name);
%     Y0(cp,:) = niak_mat2vec(Connectome.Mfa)';
%     Y1(cp,:) = niak_mat2vec(Connectome.MMD)';
%     Y2(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
%     
% end
% for k = 1:nsubj2
%     
%     disp(k)
%     cp = cp+1;
%     D2(k).name = fullfile(FSDir,T2{1}{k},'dti',['Connectome_' T2{1}{k} '.mat']);  
%     load(D2(k).name);
%     Y0(cp,:) = niak_mat2vec(Connectome.Mfa)';
%     Y1(cp,:) = niak_mat2vec(Connectome.MMD)';
%     Y2(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
%     
% end
% for k = 1:nsubj3
%     
%     disp(k)
%     cp = cp+1;
%     D3(k).name = fullfile(FSDir,T3{1}{k},'dti',['Connectome_' T3{1}{k} '.mat']);  
%     load(D3(k).name);
%     Y0(cp,:) = niak_mat2vec(Connectome.Mfa)';
%     Y1(cp,:) = niak_mat2vec(Connectome.MMD)';
%     Y2(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
%     
% end
% for k = 1:nsubj4
%     
%     disp(k)
%     cp = cp+1;
%     D4(k).name = fullfile(FSDir,T4{1}{k},'dti',['Connectome_' T4{1}{k} '.mat']);  
%     load(D4(k).name);
%     Y0(cp,:) = niak_mat2vec(Connectome.Mfa)';
%     Y1(cp,:) = niak_mat2vec(Connectome.MMD)';
%     Y2(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
%     
% end
% 
% Y0(find(isnan(Y0)))=0;
% Y1(find(isnan(Y1)))=0;
% Y2(find(isnan(Y2)))=0;
% 
% % Load covariates
% cov = load(fullfile(inDir,'Covariates.txt'));
% % cov(:,2) = cov(:,2)-mean(cov(:,2));
% 
% % Design matrix
% nsamp0 = size(Y0,1);
% X     = zeros(nsamp0,1+5+size(cov,2));
% X(:,1) = ones(nsamp0,1);
% X(:,2) = [ones(1,nsubj0) zeros(1,(nsamp0-nsubj0))]';
% X(:,3) = [zeros(1,nsubj0) ones(1,nsubj1) zeros(1,(nsamp0-nsubj0-nsubj1))]';
% X(:,4) = [zeros(1,nsubj0+nsubj1) ones(1,nsubj2) zeros(1,(nsamp0-nsubj0-nsubj1-nsubj2))]';
% X(:,5) = [zeros(1,nsubj0+nsubj1+nsubj2) ones(1,nsubj3) zeros(1,(nsamp0-nsubj0-nsubj1-nsubj2-nsubj3))]';
% X(:,6) = [zeros(1,nsubj0+nsubj1+nsubj2+nsubj3) ones(1,nsubj4) zeros(1,(nsamp0-nsubj0-nsubj1-nsubj2-nsubj3-nsubj4))]';
% X(:,7:end) = cov; 
% 
% % Contrast
% contrast = [0 ones(1,5) zeros(1,size(cov,2))];
% 
% % Group effect on Mfa
% 
% % GLM
% GLM.y           = Y0;
% GLM.X           = X;
% GLM.contrast    = contrast;
% GLM.test        = 'ftest';
% GLM.perms       = 10000;
% STATS.test_stat = NBSglm(GLM);
% save(fullfile(inDir,'nbs_ANCOVA_G1toG5_Mfa.mat'),'GLM','STATS');
% clear GLM STATS;
% 
% % Group effect on MMD
% 
% % GLM
% GLM.y           = Y1;
% GLM.X           = X;
% GLM.contrast    = contrast;
% GLM.test        = 'ftest';
% GLM.perms       = 10000;
% STATS.test_stat = NBSglm(GLM);
% save(fullfile(inDir,'nbs_ANCOVA_G1toG5_MMD.mat'),'GLM','STATS');
% clear GLM STATS;
% 
% % Group effect on FibersDensity
% 
% % GLM
% GLM.y           = Y2;
% GLM.X           = X;
% GLM.contrast    = contrast;
% GLM.test        = 'ftest';
% GLM.perms       = 10000;
% STATS.test_stat = NBSglm(GLM);
% save(fullfile(inDir,'nbs_ANCOVA_G1toG5_FD.mat'),'GLM','STATS');
% clear GLM STATS;

%% STATS : NBS

load(D0(1).name);

% name
for k = 1:length(Connectome.region)
    roiNames{k} = Connectome.region(k).name;
end

% coord
load('/home/renaud/SVN/scripts/renaud/aparc2009LOIConnNames.mat');
coord_parc = load('/home/renaud/SVN/scripts/renaud/aparc2009LOIConnCoord.txt');
for k = 1:length(Connectome.region)
    ind = 1;
    while isempty( findstr(Connectome.region(k).name,names{ind}) )
        ind = ind+1;
    end
    coord(k,:) = coord_parc(ind,:);
end

statCorr = 'NBS';
thresVal = 1.5:0.1:3.5;
VCD = {'Mfa' 'MMD' 'FD'};

for j = 1:3
    
    clear GLM STATS NBS;
    load(fullfile(inDir,['nbs_ANCOVA_G1toG5_' VCD{j} '.mat']),'GLM','STATS');
    STATS.alpha = alpha;
    STATS.size  = 'Extent'; %'Intensity';
    STATS.N     = nnodes;

    for k = 1:length(thresVal)

        STATS.thresh = thresVal(k);        

        clear NBS;

        NBS.node_coor  = coord;
        NBS.node_label = roiNames;
        if strcmp(statCorr,'FDR')
            [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
        else
            [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
        end
    %     NBSview(NBS);

        save(fullfile(inDir,['nbs_ANCOVA_G1toG5_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '.mat']),'NBS');

        for netw = 1:NBS.n

            C = full(NBS.con_mat{netw});
            C = C+C';
            C = C>0;
            deg = degrees_und(C);

            % % BrainNet
            % nodes
            nodes.coords = coord;
            nodes.colors = ones(1,size(coord,1));
            nodes.sizes  = deg';
            nodes.labels = roiNames;

            fid = fopen(fullfile(inDir,['nbs_ANCOVA_G1toG5_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(netw) '.node']),'w');
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

            %edges
            FMRI_CreateEdgeFileBrainNet(fullfile(inDir,['nbs_ANCOVA_G1toG5_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:),0));

        end

    end
end

% %% STATS : FDR
% 
% load(D0(1).name);
% 
% % name
% for k = 1:length(Connectome.region)
%     roiNames{k} = Connectome.region(k).name;
% end
% 
% % coord
% load('/home/renaud/SVN/scripts/renaud/aparc2009LOIConnNames.mat');
% coord_parc = load('/home/renaud/SVN/scripts/renaud/aparc2009LOIConnCoord.txt');
% for k = 1:length(Connectome.region)
%     ind = 1;
%     while isempty( findstr(Connectome.region(k).name,names{ind}) )
%         ind = ind+1;
%     end
%     coord(k,:) = coord_parc(ind,:);
% end
% 
% statCorr = 'FDR';
% thresVal = 3.1;
% VCD = {'Mfa' 'MMD' 'FD'};
% 
% for j = 1:3
%     
%     clear GLM STATS NBS;
%     load(fullfile(inDir,['nbs_ANCOVA_G1toG5_' VCD{j} '.mat']),'GLM','STATS');
%     STATS.alpha = alpha;
%     STATS.size  = 'Extent'; %'Intensity';
%     STATS.N     = nnodes;
%     STATS.thresh = thresVal; % thresVal(k);        
%     clear NBS;
%     
%     NBS.node_coor  = coord;
%     NBS.node_label = roiNames;
%     if strcmp(statCorr,'FDR')
%         [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
%     else
%         [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
%     end
% %     NBSview(NBS);
% 
%     save(fullfile(inDir,['fdr_ANCOVA_G1toG5_' VCD{j} '_perm_p' num2str(alpha) '.mat']),'NBS');
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
%         nodes.coords = coord;
%         nodes.colors = ones(1,size(coord,1));
%         nodes.sizes  = deg';
%         nodes.labels = roiNames;
% 
%         fid = fopen(fullfile(inDir,['fdr_ANCOVA_G1toG5_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(netw) '.node']),'w');
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
%         %edges
%         FMRI_CreateEdgeFileBrainNet(fullfile(inDir,['fdr_ANCOVA_G1toG5_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:)));
%     end
% end