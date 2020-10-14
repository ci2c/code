function NBS_FMRIConnectome_Ttest_covariates(g1,g2)
%% CONFIG

fsdir     = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask';
fMRIdir   = '/home/fatmike/Protocoles_3T/Strokdem/FMRI/Fatigue';
outConn   = 'Network'; 
groupList = 'Fatigue';
thresPars = 10:2.5:35;
binary    = 1; % 0 or 1 for also binary matrix test
outDir    = fullfile(fMRIdir,outConn,['g' g1 'Vsg' g2 '_cov']);


%% BUILD GLM

if ~exist(outDir,'dir')
    cmd = sprintf('mkdir %s',outDir);
    unix(cmd);
end

% subjects
subjs = {};
subjs{end+1} = textread(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FMRI/',groupList,['Clu' g1 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FMRI/',groupList,['Clu' g2 '_subjs.txt']),'%s \n');

% covariates
cov = [];
cov = [cov; load(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
cov = [cov; load(fullfile('/home/fatmike/Protocoles_3T/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];

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

%% Load measurments 
Meas = {};
Meas{end+1} = textread('/home/fatmike/Protocoles_3T/Strokdem/FMRI/Fatigue/Network/network_list.txt','%s');

%loop for group
for k = 1:Ng  
    disp(k)
    
    %loop for subject
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        X(temp+s,k) = 1;
        
            connFile = fullfile(fsdir,subj,'rsfmri','Connectome.mat');
            if exist(connFile,'file') == 0
               disp(['no connectome for subject: ' subj]);
            end
            
        % Struct for temporary results    
        tmp_Res.ND=zeros(length(thresPars),nnodes);
        tmp_Res.NDb=zeros(length(thresPars),nnodes);
        tmp_Res.Str=zeros(length(thresPars),nnodes);
        %tmp_Res.TopOv=[];
        %tmp_Res.Ov=[];
        tmp_Res.Dst=zeros(length(thresPars),1);
        %tmp_Res.RtS-E=
        %tmp_Res.RtS-N=
        tmp_Res.ClCf=zeros(length(thresPars),nnodes);
        tmp_Res.ClCfb=zeros(length(thresPars),nnodes);
        tmp_Res.Trsv=zeros(length(thresPars),1);
        tmp_Res.Trsvb=zeros(length(thresPars),1);
        tmp_Res.LcEf-Eg=zeros(length(thresPars),1);
        tmp_Res.LcEf-El=zeros(length(thresPars),nnodes);
        tmp_Res.LcEfb-Eg=zeros(length(thresPars),1);
        tmp_Res.LcEfb-El=zeros(length(thresPars),nnodes);
        tmp_Res.CnCp=
        tmp_Res.ComLv=
        tmp_Res.Ag=
        tmp_Res.Agb=
        tmp_Res.Cns=
        tmp_Res.Ast=
        tmp_Res.Astb=
        tmp_Res.Rcl=
        tmp_Res.Rclb=
        tmp_Res.Kc=
        tmp_Res.Sc=
        tmp_Res.Pth=
        tmp_Res.Wlk=
        tmp_Res.Dst=
        tmp_Res.Dstb=
        tmp_Res.RDst=
        tmp_Res.BrthD=
        tmp_Res.Eff=zeros(length(thresPars),1);
        tmp_Res.Effb=zeros(length(thresPars),1);
        tmp_Res.ChPth=
        tmp_Res.CPrb=
        tmp_Res.Bt=
        tmp_Res.Btb=
        tmp_Res.EBt=
        tmp_Res.EBtb=
        tmp_Res.Mod=
        tmp_Res.Prt=
        tmp_Res.Eig=
        tmp_Res.SbG=
        tmp_Res.Kc=
        tmp_Res.FlC=
        tmp_Res.Shrt=
       
        
        %loop for sparsity 
        for j = 1:length(thresPars)
                
            load(connFile);
            Conn_mat=Connectome.Cmat;
            mat_sort=sort(niak_mat2vec(Connectome.Cmat));
                
            % Define the maximum of negative values and minimum of
            % positive values 
                
            id_neg=max(find(mat_sort<0));
            id_pos=min(find(mat_sort>0));
                
            % Extract the negative in mat_sneg and positive un mat_spos
            mat_sneg=(mat_sort(1:id_neg));
            mat_spos=(mat_sort(id_pos:end));
        
            prct_neg=prctile(mat_sneg,thresPars(j));
            prct_pos=prctile(mat_spos,thresPars(j));
            
            % Define 0 for values comprises between prct_neg and 0,
            % idem for prct_pos
            Conn_mat(Conn_mat > prct_neg & Conn_mat < 0)=0;
            Conn_mat(Conn_mat < prct_pos & Conn_mat > 0)=0;
            

            for l=1:length(Meas)
    
                func=Meas{1}{l};
                
                switch(Meas)
        
    % Degree_and_Similarity
        case 'Node_Degree'
     
        case 'Node_Degree_bin'
            
        case 'Strength'

        case 'Topological_overlap'
            
        case 'Neighborhood_overlap'
            
    % Density and Rentian Scaling (undirected)  
        case 'Density'
            
        case 'Rentian_Scaling'
            
    % Clustering and Community structure (undirected)
        case 'Clustering_coefficient'
            
        case 'Clustering_coefficient_bin'
            
        case 'Transitivity'
            
        case 'Transitivity_bin'
            
        case 'Local_efficiency'
            
        case 'Local_efficiency_bin'
            
        case 'Connected_components'
            
        case 'Community_louvain'
            
        case 'Agreement'
            
        case 'Agreement_bin'
            
        case 'Consensus'
            
     % Assortativity and Core Structure (undirected)
        case 'Assortavity'
            
        case 'Assortavity_bin'
            
        case 'Rich_club'
            
        case 'Rich_club_bin'
            
        case 'K_core'
            
        case 'S_core'
 
     % Paths and Distance (undirected)
        case 'Paths'
            
        case 'Walks'
            
        case 'Distance'
            
        case 'Distance_bin'
            
        case 'Reach_dist'
            
        case 'Breadthdist'

        case 'Efficiency'
            
        case 'Efficiency_bin'
            
        case 'Charpath'
            
        case 'Cyc_prob'
            
    % Centrality (undirected)
        case 'Betweeness'
            
        case 'Betweeness_bin'
            
        case 'Edge_betweeness'
            
        case 'Edge_betweeness_bin'
            
        case 'Module_deg_zscore'
            
        case 'Participation_coef'
            
        case 'Eigenvector_centrality'

        case 'Subgraph_centrality'
            
        case 'Kcoreness_centrality'
            
        case 'Flow_coef'
            
        case 'Shortcuts'


