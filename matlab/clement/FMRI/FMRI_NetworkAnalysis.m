function FMRI_NetworkAnalysis(g1,g2)
%% %%%%%%%%%%%%%%%%%%%%%%%%%% CONFIG %%%%%%%%%%%%%%%%%%%%%%%%%%

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog';
outConn   = 'Network'; 
groupList = 'TCog';
outDir    = fullfile(fMRIdir,outConn,['g' g1 'Vsg' g2 'GRAPH_cov']);


doCorrelation = 1;

%% %%%%%%%%%%%%%%%%%%%%%%%%%% LOADING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%


% Subjects
subjs = {};
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_subjs.txt']),'%s \n');

G1  = length(subjs{1});
G2  = length(subjs{2});



% Group assignment vector 
group={};
Group=[];
for k = 1:G1
    group{end+1} = 'G1';
end
for k = 1:G2
    group{end+1} = 'G2';
end
GROUP = term(group);

Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end

% Covariates loading
cov = [];
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];

cov =cov(:,1:end-1);
[cx,cy,~]=size(cov);

ind_nuisance = 1:1:cy;

% Build matrix design

X        = zeros(Ns,Ng);
nnodes   = 313;
nedges   = nnodes*(nnodes-1)/2;
Y        = zeros(Ns,nedges);
Conn_mat = [];

% Loop for group
z=1;
for k = 1:Ng  
    disp(k)
% Loop for subject
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        connFile = fullfile(fsdir,subj,'rsfmri','Craddock_Parc','NB31','Connectome_Ck31.mat');
        if exist(connFile,'file')
           load(connFile);
           if isfield(Connectome,'Cmat')
            Conn_mat(:,:,z)=Connectome.Cmat; % 3D matrix with all of the matrices
            vtmp(z,:)=niak_mat2vec(Connectome.Cmat); 
            Group(end+1) = k;
            Cov(z,:)=cov(s,:);
            z=z+1;
           end
        else
            disp(['no connectome for subject: ' subj]);
        end
    end
end
sNB=z-1;
[x,y,s]=size(Conn_mat);

%% %%%%%%%%%%%%%%%%%%%%%%%%%% REMOVE CLOSED EDGES %%%%%%%%%%%%%%%%%%%%%%%%%%
%Build spatial Distance Matrix
coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');
SpDist = dist(coord_parc');

bSpDist = gretna_R2b(SpDist,'r',20); % < 20 mm

%% %%%%%%%%%%%%%%%%%%%%%%%%%% MATRIX REGRESSION %%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:length(vtmp)
    b=pinv(Cov(:,ind_nuisance))*vtmp(:,j);
    rvtmp(:,j)=vtmp(:,j)-Cov(:,ind_nuisance)*b;
end
clear j
di=1:x+1:x*x;
for j = 1:s
    mtmp=niak_vec2mat(rvtmp(j,:));
    mtmp(di)=0; % Set diagonal to 0
    rConn_mat(:,:,j)=mtmp .* bSpDist;
end

CMat_G1=rConn_mat(:,:,Group == 1);
CMat_G2=rConn_mat(:,:,Group == 2);


%% %%%%%%%%%%%%%%%%%%%%%%%%%% BASIC CONNECTIVITY ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%
disp( ' - - - - - - - - - - BASIC CONNECTIVITY ANALYSIS - - - - - - - - - ')

                         %%%%% Correlation distribution %%%%% 
disp (' Correlation Distribution' )                            
% round for 2 decimales after "," 
roCMat_G1=roundn(CMat_G1,-1); 
roCMat_G2=roundn(CMat_G2,-1);

a=unique(roCMat_G1);
b=unique(roCMat_G2);

outG1=[a,histc(roCMat_G1(:),a)];
outG2=[b,histc(roCMat_G2(:),b)];

%%%PLOTTING%%%
figure
plot(outG1(:,1),outG1(:,2),'b')
xlabel('Correlation coefficient');
ylabel('Number of edges');
title('Correlation distribution')
hold on
plot(outG2(:,1),outG2(:,2),'r')
legend('G1','G2')

% %% %%%%%%%%%%%%%%%%%%%%%%%%%% BASIC NETWORK CHARACTERISTICS ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%
disp( ' - - - - - - - - - - BASIC NETWORK CHARACTERISTICS ANALYSIS - - - - - - - - - ')

                         %%%%% Degree distribution %%%%% 

thresPars = 0.1;
disp (' Degree Distribution' )  
clear i t
for i=1:sNB
    bin  = gretna_R2b(rConn_mat(:,:,i),'s',thresPars);
    Deg  = degrees_und(bin);
end

uDeg = unique(Deg);

for j=1:length(uDeg)
%Pdeg(j,:) = ( (factorial(nnodes - 1))/(factorial(uDeg(j))*factorial(nnodes-1-uDeg(j))) ) * ((sum(sum(bin)))/nedges)^(uDeg(j)) * ( 1 - ((sum(sum(bin)))/nedges))^(nnodes - 1 - uDeg(j));
Pdeg(j,:) = ( (nnodes  *  ((sum(sum(bin)))/nedges) )^(uDeg(j)) * exp(-nnodes * ((sum(sum(bin)))/nedges)) ) / factorial(uDeg(j)); 
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%% GRAPH CONNECTIVITY ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%

% Only binary for the moment. Warning : if further use weighted, have to normalize using
% weight_conversion 
 
thresPars = 0.02:0.01:0.4; 
thresCorr = 0.5:0.05:0.8;

% Gamma value for community detection
gamma=1.03;
% K value for core analysis
klevel=8;
                         


% disp( ' - - - - - - - - - - GLOBAL GRAPH ANALYSIS - - - - - - - - - ')
% 
% 
% disp( ' Average Degree - Global Efficiency - Average Clustering Coefficient ' )
% clear i t
% for i=1:sNB
%     for t = 1:length(thresPars) 
%         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
%         gEff(t,:) = efficiency_bin(bin);
%         mClc(t,:) = mean(clustering_coef_bu(bin));
%     end
%     Graph.Result.gEff_AUC(i,:) = trapz(thresPars,gEff);
%     Graph.Result.mClc_AUC(i,:) = trapz(thresPars,mClc);
% end
% 
% 
% 
% clear i t
% for i=1:sNB
%     for t=1:length(thresCorr)
%         bin=gretna_R2b(rConn_mat(:,:,i),'r',thresPars(t));
%         mDeg(t,:)  = mean(degrees_und(bin));
%     end
%     Graph.Result.mDeg_AUC(i,:) = trapz(thresCorr,mDeg);
% end
% 
% load('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/Hubs_Connector_PC_Deg.mat') % Nodes ID for Connector
% disp( ' - - - - - - - - - - LOCAL GRAPH ANALYSIS - - - - - - - - - ')
% 
% 
%                          %%%%% Degree & Similarity %%%%% 
%                          
% clear i t
% disp(' Node Degree / Strength Analysis ')
% for i=1:sNB
%     for t = 1:length(thresPars) 
%         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
%         Deg(t,:)  = degrees_und(bin);
%         Stg(t,:)  = strengths_und(bin);
%     end
%     Graph.Result.Deg_AUC(i,:)  = trapz(thresPars,Deg(:,Connector_Deg));
%     Graph.Result.Stg_AUC(i,:)  = trapz(thresPars,Stg);
% end
% 
% 
%                              %%%%% Density %%%%% 
% 
% % clear i t
% % disp(' Matrix Density Analysis ')
% % for i=1:sNB
% %     for t = 1:length(thresCorr)
% %         bin=gretna_R2b(rConn_mat(:,:,i),'r',thresCorr(t));
% %         Den(t,:) = density_und(bin);
% %     end
% %     Graph.Result.Den_AUC(i,:) = trapz(thresCorr,Den);
% % end
% 
%                         %%%% Rentian Scaling %%%%% 
% 
% 
% % [c1,c2,c3]=textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt','%d %d %d');
% % coord=[c1,c2,c3];
% % clear c1 c2 c3
% % 
% % clear i t
% % disp(' Rentian Scaling Analysis ')
% % for i=1:sNB
% %     for t = 1:length(thresPars)
% %         bin=gretna_R2b(rConn_mat(:,:,i),'r',thresPars(t));
% %         [N E]     = rentian_scaling(bin,coord,5000);
% %         N_prime   = N(find(N<x/2));
% %         E_prime   = E(find(N<x/2));
% %         [b,stats] = robustfit(log10(N_prime),log10(E_prime));
% %         p(t,:)=b(2,1);
% %     end
% %     Graph.Result.Rent_AUC(i,:) = trapz(thresPars,p);
% % end
% 
%                     %%%%% Clustering & Efficiency %%%%% 
% clear i t
% disp(' Clustering and Efficiency Analysis ')
% for i=1:sNB
%     for t = 1:length(thresPars)
%         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
%         Clc(t,:)  = clustering_coef_bu(bin);
%         lEff(t,:) = efficiency_bin(bin,1);
%     end
%     Graph.Result.Clc_AUC(i,:)  = trapz(thresPars,Clc(:,Connector_Deg));
%     Graph.Result.lEff_AUC(i,:) = trapz(thresPars,lEff(:,Connector_Deg));
% end
%                      
%                         %%%% Modularity %%%%% 
% 
% % clear i t
% % disp(' Modularity Analysis ')
% % for i=1:sNB
% %     for t = 1:length(thresCorr)
% %         bin=gretna_R2b(rConn_mat(:,:,i),'r',thresCorr(t));
% %         [M,Q]    = community_louvain(bin,gamma);
% %         Mod(t,:) = Q;
% %     end
% %     Graph.Result.Mod_AUC(i,:)  = trapz(thresCorr,Mod);
% %     Graph.Result.Mod(i,:)      = M;
% % end
%              
%                       %%%%% Assortativity %%%%%              
% % clear i t
% % disp(' Assortativity Analysis ')
% % for i=1:sNB
% %     for t = 1:length(thresPars)
% %         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
% %         As(t,:)   = assortativity(bin,0);
% %     end
% %     Graph.Result.As_AUC(i,:)   = trapz(thresPars,As);
% % end
% 
%                   %%%% Distance Analysis %%%%% 
% % clear i t
% % disp(' Paths Analysis ')
% % for i=1:sNB
% %     for t = 1:length(thresPars)
% %         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
% %         smat=bin.*Conn_mat(:,:,i);
% %         dsmat = weight_conversion(smat,'lengths');
% %         
% %         [lambda,efficiency,ecc,radius,diameter] = charpath(dsmat);
% %         
% %         La(t,:)  = lambda;
% %         Ec(t,:)  = ecc;
% %         Ra(t,:)  = radius;
% %         Di(t,:)  = diameter;
% %         
% %     end
% %     Graph.Result.La_AUC(i,:)  = trapz(thresPars,La);
% %     Graph.Result.Ec_AUC(i,:)  = trapz(thresPars,Ec);
% %     Graph.Result.Ra_AUC(i,:)  = trapz(thresPars,Ra);
% %     Graph.Result.Di_AUC(i,:)  = trapz(thresPars,Di);
% % end
%                   
% 
%                   %%%%% Centrality Analysis %%%%%
% clear i t
% disp(' Centrality  Analysis ')
% for i=1:sNB
%     for t = 1:length(thresPars)
%         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
%         bc      = betweenness_bin(bin);
%         Bc(t,:) = bc/((x-1)*(x-2)); % Normalize Betweeness centrality 
%     end
%     Graph.Result.Bc_AUC(i,:)   = trapz(thresPars,Bc(:,Connector_Deg));
% end 
% 
% clear i t
% 
% for i=1:sNB
%     for t = 1:length(thresPars)
%         bin=gretna_R2b(rConn_mat(:,:,i),'s',thresPars(t));
%         Egc(t,:)   = eigenvector_centrality_und(bin);
%     end
%     Graph.Result.Egc_AUC(i,:)   = trapz(thresPars,Egc(:,Connector_Deg));
% end
% 
% %% %%%%%%%%%%%%%%%%%%%%%%%%%% GRAPH CONNECTIVITY ANALYSIS : RESULTS && STATS %%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph_fields=fieldnames(Graph.Result);
% 
% clear j
% for j=1:length(Graph_fields)
%     
%     Graph_G1=Graph.Result.(cell2mat(Graph_fields(j)))(Group == 1,:);
%     Graph_G2=Graph.Result.(cell2mat(Graph_fields(j)))(Group == 2,:);
%     [Gx,Gy,~]=size(Graph_G1); 
%     
%         
%     [H,p]=ttest2(Graph_G1,Graph_G2);
%     
%     if length(p) > 1
%         upval=p';
%         cpval=mafdr(upval);
%     else 
%         upval=p;
%         cpval=p;
%     end
%     
%     Graph.pval.corrected.(cell2mat(Graph_fields(j)))=cpval;
%     
%     pID=find(cpval < 0.05);
%     
%     if ~isempty(pID)
%         disp(strcat('Significant results for :',char(Graph_fields(j))));
%         for z=1:length(pID)
%             disp(pID(z))
%         end
%     end
%     
% end

    
%% %%%%%%%%%%%%%%%%%%%%%%%%%% GRAPH CONNECTIVITY ANALYSIS : MODULARITY %%%%%%%%%%%%%%%%%%%%%%%%%%

disp( ' - - - - - - - - - - GRAPH ANALYSIS : MODULARITY - - - - - - - - - ')

%% G1
gD=[];
Prov_nodes=zeros(1,x);
Conn_nodes=[];
thresh = 0.5; % Threshold 5%

% Generate community structure at group scale
for i=1:sNB  
    A =gretna_R2b(rConn_mat(:,:,i),'s',thresh);
   
    [~,D]  = Topo_CoClassification(A,1000,1.03);
    gDtmp(:,:,i) = D;
end  
G1D = gDtmp(:,:,Group == 1);
G2D = gDtmp(:,:,Group == 2);


g1D = sum(G1D,3);
g2D = sum(G2D,3);

M1 = community_louvain(g1D,1.03);
M2 = community_louvain(g2D,1.03);   

%load('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/nocog-cog_CoClgroup.mat','M1','M2');

% %% %%%%%%%%%%%%%%%%%%%%%%%%%% HUB DISRUPTION INDEX %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
snb = 1:sNB;
G1 = snb(Group == 1);
G2 = snb(Group == 2);

P1 = [];
P2 = [];
Z1 = [];
Z2 = [];

disp( ' - - - - - - - - - - GRAPH ANALYSIS : HUB DISRUPTION INDEX WITH PART COEFF - - - - - - - - - ')

if exist('M1','var') && exist('M2','var')
    for i=G1  
        A = gretna_R2b(rConn_mat(:,:,i),'s',thresh); % Keep threshold 5%
        P1(end+1,:) = [participation_coef(A,M1)]';
        Z1(end+1,:) = [module_degree_zscore(A,M1,0)]';
    end 
    for i=G2  
        A = gretna_R2b(rConn_mat(:,:,i),'s',thresh); % Keep threshold 5%
        P2(end+1,:) = [participation_coef(A,M2)]';
        Z2(end+1,:) = [module_degree_zscore(A,M2,0)]';
    end 
end

HDI_G2p = []; % Hub Disruption index for group 2 compared to group 1 (control)
clear i
for i=1:length(G2)
    
    ID = find(P2(i,:) > 0.3);
    
    P1g = mean(P1(:,ID));
    Diff = P2(i,ID)-P1g;
    [R,~] = corrcoef(P1g,Diff);
    HDI_G2p(end+1,:) = R(1,2);
end

HDI_G1p = []; % Hub Disruption index for group 1 compared to group 1 (control)
clear i
for i=1:length(G1)
    ID = find(P1(i,:) > 0.3);
    
    P1g = mean(P1(:,ID));
    Diff = P1(i,ID)-P1g;
    [R,~] = corrcoef(P1g,Diff);
    HDI_G1p(end+1,:) = R(1,2);
end
%% 
disp( ' - - - - - - - - - - GRAPH ANALYSIS : HUB DISRUPTION INDEX WITH zScore - - - - - - - - - ')

HDI_G2z = []; % Hub Disruption index for group 2 compared to group 1 (control)
clear i
for i=1:length(G2)
 
    Z1g = mean(Z1);
    Diff = Z2(i,:)-Z1g;
    [R,~] = corrcoef(Z1g,Diff);
    HDI_G2z(end+1,:) = R(1,2);
end

HDI_G1z = []; % Hub Disruption index for group 1 compared to group 1 (control)
clear i
for i=1:length(G1)
    Z1g = mean(Z1);
    Diff = Z1(i,:)-Z1g;
    [R,~] = corrcoef(Z1g,Diff);
    HDI_G1z(end+1,:) = R(1,2);
end


disp( ' - - - - - - - - - - GRAPH ANALYSIS : HUB DISRUPTION INDEX WITH DEGREE - - - - - - - - - ')
                         
clear i t
for i=1:sNB
    for t = 1:length(thresh) 
        bin=gretna_R2b(rConn_mat(:,:,i),'s',thresh);
        Deg(t,:)  = degrees_und(bin);
    end
    Graph.Result.Deg_AUC(i,:)  = Deg;
end


HDI_G2d = []; % Hub Disruption index for group 2 compared to group 1 (control)
clear i
Deg_G1 = Graph.Result.Deg_AUC(G1,:);
Deg_G2 = Graph.Result.Deg_AUC(G2,:);
for i=1:length(G2)
    D1g = mean(Deg_G1);
    Diff = Deg_G2(i,:)-D1g;
    [R,~] = corrcoef(D1g,Diff);
    HDI_G2d(end+1,:) = R(1,2);
end

HDI_G1d = []; % Hub Disruption index for group 1 compared to group 1 (control)
for i=1:length(G1)
    D1g = mean(Deg_G1);
    Diff = Deg_G1(i,:)-D1g;
    [R,~] = corrcoef(D1g,Diff);
    HDI_G1d(end+1,:) = R(1,2);
end

disp('coucou')
