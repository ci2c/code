% clear all; close all;
% 
% FSDir = '/NAS/dumbo/protocoles/CogPhenoPark/FS5.3';
% inDir = '/NAS/dumbo/protocoles/CogPhenoPark/Connectome/Two_sample_Ttest';
% 
% nb_grp = 5;
% 
% for i = 1:nb_grp
%     fid(i) = fopen(fullfile(inDir,['Cluster' num2str(i) '.txt']),'r');
%     T(i) = textscan(fid(i), '%s');
%     nsubj(i) = length(T{i});
% end
% 
% fclose('all');
% 
% nnodes = 164;
% nedges = nnodes*(nnodes-1)/2;
% 
% alpha = 0.05;
% 
% % Construct each Two sample T-test among the 5 groups
% 
% FA{nb_grp,nb_grp} = NaN;
% MD{nb_grp,nb_grp} = NaN;
% FD{nb_grp,nb_grp} = NaN;
% 
% for g1 = 1:nb_grp
%     for g2 = 1:(g1-1)
%         % Load connectivity matrices
%         cp = 0;
%         FA{g1,g2} = zeros(nsubj(g1)+nsubj(g2),nedges);
%         MD{g1,g2} = zeros(nsubj(g1)+nsubj(g2),nedges);
%         FD{g1,g2} = zeros(nsubj(g1)+nsubj(g2),nedges);
%         for k = 1:nsubj(g1)
%             disp(k)
%             cp = cp+1;
%             load(fullfile(FSDir,T{g1}{k},'dti',['Connectome_' T{g1}{k} '.mat']));
%             FA{g1,g2}(cp,:) = niak_mat2vec(Connectome.Mfa)';
%             MD{g1,g2}(cp,:) = niak_mat2vec(Connectome.MMD)';
%             FD{g1,g2}(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
%         end
%         for k = 1:nsubj(g2)
%             disp(k)
%             cp = cp+1;
%             load(fullfile(FSDir,T{g2}{k},'dti',['Connectome_' T{g2}{k} '.mat']));
%             FA{g1,g2}(cp,:) = niak_mat2vec(Connectome.Mfa)';
%             MD{g1,g2}(cp,:) = niak_mat2vec(Connectome.MMD)';
%             FD{g1,g2}(cp,:) = niak_mat2vec(Connectome.FibersDensity)';
%         end    
%         
%         FA{g1,g2}(find(isnan(FA{g1,g2}))) = 0;
%         MD{g1,g2}(find(isnan(MD{g1,g2}))) = 0;    
%         FD{g1,g2}(find(isnan(FD{g1,g2}))) = 0;
%         
%         nsamp = size(FA{g1,g2},1);
%         X     = zeros(nsamp,2);
%         X(1:nsubj(g1),1) = ones(nsubj(g1),1);
%         X((nsubj(g1)+1):nsamp,2) = ones(nsubj(g2),1);
%         
%         % Contrast : g1 > g2
%         contrast = [1 -1];
%         
%             % Group effect on Mfa
% 
%             % GLM
%             GLM.y           = FA{g1,g2};
%             GLM.X           = X;
%             GLM.contrast    = contrast;
%             GLM.test        = 'ttest';
%             GLM.perms       = 10000;
%             STATS.test_stat = NBSglm(GLM);
%             save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_Mfa.mat']),'GLM','STATS');
%             clear GLM STATS;
% 
%             % Group effect on MMD
% 
%             % GLM
%             GLM.y           = MD{g1,g2};
%             GLM.X           = X;
%             GLM.contrast    = contrast;
%             GLM.test        = 'ttest';
%             GLM.perms       = 10000;
%             STATS.test_stat = NBSglm(GLM);
%             save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_MMD.mat']),'GLM','STATS');
%             clear GLM STATS;
% 
%             % Group effect on FibersDensity
% 
%             % GLM
%             GLM.y           = FD{g1,g2};
%             GLM.X           = X;
%             GLM.contrast    = contrast;
%             GLM.test        = 'ttest';
%             GLM.perms       = 10000;
%             STATS.test_stat = NBSglm(GLM);
%             save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_FD.mat']),'GLM','STATS');
%             clear GLM STATS;
% 
%         % Contrast : g2 > g1
%         contrast = [-1 1];
%         
%             % Group effect on Mfa
% 
%             % GLM
%             GLM.y           = FA{g1,g2};
%             GLM.X           = X;
%             GLM.contrast    = contrast;
%             GLM.test        = 'ttest';
%             GLM.perms       = 10000;
%             STATS.test_stat = NBSglm(GLM);
%             save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_Mfa.mat']),'GLM','STATS');
%             clear GLM STATS;
% 
%             % Group effect on MMD
% 
%             % GLM
%             GLM.y           = MD{g1,g2};
%             GLM.X           = X;
%             GLM.contrast    = contrast;
%             GLM.test        = 'ttest';
%             GLM.perms       = 10000;
%             STATS.test_stat = NBSglm(GLM);
%             save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_MMD.mat']),'GLM','STATS');
%             clear GLM STATS;
% 
%             % Group effect on FibersDensity
% 
%             % GLM
%             GLM.y           = FD{g1,g2};
%             GLM.X           = X;
%             GLM.contrast    = contrast;
%             GLM.test        = 'ttest';
%             GLM.perms       = 10000;
%             STATS.test_stat = NBSglm(GLM);
%             save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_FD.mat']),'GLM','STATS');
%             clear GLM STATS;
% 
%     end
% end
% 
%% STATS

load(fullfile(FSDir,T{1}{1},'dti',['Connectome_' T{1}{1} '.mat']));

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

for g1 = 1:nb_grp
    for g2 = 1:(g1-1)
        for j = 1:3

            % g1 > g2
            clear GLM STATS NBS;
            load(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '.mat']),'GLM','STATS');
            STATS.alpha = alpha;
            STATS.size  = 'Extent'; %'Intensity';
            STATS.N     = nnodes;

            for k = 1:length(thresVal)

                STATS.thresh = thresVal(k); % thresVal;        

                clear NBS;

                NBS.node_coor  = coord;
                NBS.node_label = roiNames;
                if strcmp(statCorr,'FDR')
                    [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
                else
                    [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
                end
            %     NBSview(NBS);

                save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '.mat']),'NBS');

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

                    fid = fopen(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(netw) '.node']),'w');
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
                    FMRI_CreateEdgeFileBrainNet(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:)));
                end
            end
            
            % g2 > g1
            clear GLM STATS NBS;
            load(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '.mat']),'GLM','STATS');
            STATS.alpha = alpha;
            STATS.size  = 'Extent'; %'Intensity';
            STATS.N     = nnodes;

            for k = 1:length(thresVal)

                STATS.thresh = thresVal(k); % thresVal;        

                clear NBS;

                NBS.node_coor  = coord;
                NBS.node_label = roiNames;
                if strcmp(statCorr,'FDR')
                    [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
                else
                    [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
                end
            %     NBSview(NBS);

                save(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '.mat']),'NBS');

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

                    fid = fopen(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(netw) '.node']),'w');
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
                    FMRI_CreateEdgeFileBrainNet(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(thresVal(k)) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:)));
                end
            end
        end
    end
end


% %% STATS : FDR
% 
% load(fullfile(FSDir,T{1}{1},'dti',['Connectome_' T{1}{1} '.mat']));
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
% for g1 = 1:nb_grp
%     for g2 = 1:(g1-1)
%        
%         for j = 1:3
%             
%             % g1 > g2
%             clear GLM STATS NBS;
%             load(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '.mat']),'GLM','STATS');
%             STATS.alpha = alpha;
%             STATS.size  = 'Extent'; %'Intensity';
%             STATS.N     = nnodes;
%             STATS.thresh = thresVal; % thresVal(k);        
%             clear NBS;
% 
%             NBS.node_coor  = coord;
%             NBS.node_label = roiNames;
%             if strcmp(statCorr,'FDR')
%                 [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
%             else
%                 [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
%             end
%         %     NBSview(NBS);
% 
%             save(fullfile(inDir,['fdr_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '_perm_p' num2str(alpha) '.mat']),'NBS','GLM','STATS');
% 
%             for netw = 1:NBS.n
% 
%                 C = full(NBS.con_mat{netw});
%                 C = C+C';
%                 C = C>0;
%                 deg = degrees_und(C);
% 
%                 % % BrainNet
%                 % nodes
%                 nodes.coords = coord;
%                 nodes.colors = ones(1,size(coord,1));
%                 nodes.sizes  = deg';
%                 nodes.labels = roiNames;
% 
%                 fid = fopen(fullfile(inDir,['fdr_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(netw) '.node']),'w');
%                 for cj = 1:size(nodes.coords,1)
%                     % Coordinates
%                     fprintf(fid,'%f ',nodes.coords(cj,1));
%                     fprintf(fid,'%f ',nodes.coords(cj,2));
%                     fprintf(fid,'%f ',nodes.coords(cj,3));
% 
%                     % Colors
%                     fprintf(fid,'%f ',nodes.colors(cj));
% 
%                     % Sizes
%                     fprintf(fid,'%f ',nodes.sizes(cj));
% 
%                     % Labels
%                     fprintf(fid,'%s ',nodes.labels{cj});
% 
%                     fprintf(fid,'\n');
%                 end
%                 fclose(fid);
% 
%                 %edges
%                 FMRI_CreateEdgeFileBrainNet(fullfile(inDir,['fdr_Two_sample_Ttest_G' num2str(g1) 'VsG' num2str(g2) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:)));
%             end
%             
%             % g2 > g1
%             clear GLM STATS NBS;
%             load(fullfile(inDir,['nbs_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '.mat']),'GLM','STATS');
%             STATS.alpha = alpha;
%             STATS.size  = 'Extent'; %'Intensity';
%             STATS.N     = nnodes;
%             STATS.thresh = thresVal; % thresVal(k);        
%             clear NBS;
% 
%             NBS.node_coor  = coord;
%             NBS.node_label = roiNames;
%             if strcmp(statCorr,'FDR')
%                 [NBS.n,NBS.con_mat,NBS.pval] = NBSfdr(STATS,1.0167,GLM);
%             else
%                 [NBS.n,NBS.con_mat,NBS.pval] = NBSstats(STATS,1.0167,GLM);
%             end
%         %     NBSview(NBS);
% 
%             save(fullfile(inDir,['fdr_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '_perm_p' num2str(alpha) '.mat']),'NBS','GLM','STATS');
% 
%             for netw = 1:NBS.n
% 
%                 C = full(NBS.con_mat{netw});
%                 C = C+C';
%                 C = C>0;
%                 deg = degrees_und(C);
% 
%                 % % BrainNet
%                 % nodes
%                 nodes.coords = coord;
%                 nodes.colors = ones(1,size(coord,1));
%                 nodes.sizes  = deg';
%                 nodes.labels = roiNames;
% 
%                 fid = fopen(fullfile(inDir,['fdr_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(netw) '.node']),'w');
%                 for cj = 1:size(nodes.coords,1)
%                     % Coordinates
%                     fprintf(fid,'%f ',nodes.coords(cj,1));
%                     fprintf(fid,'%f ',nodes.coords(cj,2));
%                     fprintf(fid,'%f ',nodes.coords(cj,3));
% 
%                     % Colors
%                     fprintf(fid,'%f ',nodes.colors(cj));
% 
%                     % Sizes
%                     fprintf(fid,'%f ',nodes.sizes(cj));
% 
%                     % Labels
%                     fprintf(fid,'%s ',nodes.labels{cj});
% 
%                     fprintf(fid,'\n');
%                 end
%                 fclose(fid);
% 
%                 %edges
%                 FMRI_CreateEdgeFileBrainNet(fullfile(inDir,['fdr_Two_sample_Ttest_G' num2str(g2) 'VsG' num2str(g1) '_' VCD{j} '_perm_p' num2str(alpha) '_' num2str(netw) '.edge']),double(C).*niak_vec2mat(STATS.test_stat(1,:)));
%             end
%           
%         end
%     end
% end