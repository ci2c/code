function FMRI_HubDefinition
%% %%%%%%%%%%%%%%%%%%%%%%%%%% CONFIG %%%%%%%%%%%%%%%%%%%%%%%%%%

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog';
outConn   = 'Network'; 
groupList = 'TCog';



%% %%%%%%%%%%%%%%%%%%%%%%%%%% LOADING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%
[a,b,c] = xlsread('/NAS/tupac/protocoles/Strokdem/Corresp_ID.xls');
Inc_ID = b(:,1);
MRI_ID = b(:,2);

subjs{1,1} = MRI_ID;





Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end

% Build matrix design

nnodes   = 313;
nedges   = nnodes*(nnodes-1)/2;
Conn_mat = [];

%Build spatial Distance Matrix
coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');
SpDist = dist(coord_parc');

bSpDist = gretna_R2b(SpDist,'r',20);

clear k
z=1;
for k = 1:Ng  
% Loop for subject
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        connFile = fullfile(fsdir,[ subj '_M6' ],'rsfmri','Craddock_Parc','NB31','Connectome_Ck31.mat');
        %connFile = fullfile('/NAS/tupac/protocoles/Strokdem/volunteers_1000connectome',subj,'rsfmri/Craddock_Parc/NB31/Connectome_Ck31.mat');
        if exist(connFile,'file')
           load(connFile);
           if isfield(Connectome,'Cmat')
               if length(Connectome.Cmat) == 313
                Conn_mat(:,:,z)=Connectome.Cmat.*bSpDist; % 3D matrix with all of the matrices
                z=z+1;
               end
           end
        else
            disp(['no connectome for subject: ' subj]);
        end
    end
end
sNB=z-1;
[x,y,z]=size(Conn_mat);

di=1:x+1:x*x;

V=[];
Pr=[];
Co=[];
PartCoeff = [];
Zscore = [];
Bet = [];
thresh = 0.02:0.01:0.1;

%% Perso
% for i=1:sNB
%     disp(i)
%     for j=1:length(thresh)
%         
%      A =gretna_R2b(Conn_mat(:,:,i),'s',thresh(j));
%      %M = community_louvain(A,1.03);
%      [M,D]  = Topo_CoClassification(A,1000,1.03);
%      
%      P = [participation_coef(A,M)]';
%      Z = [module_degree_zscore(A,M,0)]';
%      
%      IDp = find(P <= 0.3 & Z >= 1.5);
%      IDc = find(P > 0.3 & P <= 0.75 & Z > 1.5);
%       
%      %Prov = zeros(1,x);
%      %Prov(IDp) = P(IDp); 
%      
%      Conn = zeros(1,x);
%      Conn(IDc) = P(IDc);
% 
%      PartCoeff(end+1,:) = Conn;
%     end
% 
% end

%% Group
gD=[];
Prov_nodes=zeros(1,x);
Conn_nodes=[];
for j=1:length(thresh)
    disp(j)
    % Generate community structure at group scale
    for i=1:sNB  
        A =gretna_R2b(Conn_mat(:,:,i),'s',thresh(j));
   
        [~,D]  = Topo_CoClassification(A,1000,1.2);
        gDtmp(:,:,i) = D;
    end  
    
    gD = sum(gDtmp,3);
    M = community_louvain(gD,1.1);
    
%     
    for i=1:sNB
        % Connector Hubs:  Compute Partcoeff 1on each subject using group modules
        A = gretna_R2b(Conn_mat(:,:,i),'s',thresh(j));
        P = [participation_coef(A,M)]';
        Z = [module_degree_zscore(A,M,0)]';
     
        IDc = find(P > 0.3 & P <= 0.75 & Z > 1.5);

        Conn = zeros(1,x);
        Conn(IDc) = 1;

        Conn_nodes(end+1,:) = Conn;
        
        % Provincial Hubs: 
        co = unique(M); % group communities
        
        for k=1:length(co)
            ID  = find(M == co(k));
            tmp = A([ID],[ID]);    % temp matrix with only nodes of the community 
            %Deg = degrees_und(tmp);
            Deg = betweenness_bin(tmp);
            
            prov_id  = find(Deg == max(Deg));
            Prov_nodes(ID(prov_id)) = Prov_nodes(ID(prov_id)) + 1;
        end
    end
end

save('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/Communities_nocog_Ck31.mat','M');
deg = sum(Conn_nodes);
[labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
nodes.coords = coord_parc;
nodes.colors = M';
nodes.sizes  = M';
nodes.labels = names;
fid = fopen('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/Communities_Group_nocog_Ck31.node','w');
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










% Ag=mean(Conn_mat,3);
%       
% STD= 0.5;
% S = exp( -(Ag.*Ag) / ( 2*(STD^2) ) );
% S(di) = 0;
%       
% A = gretna_R2b(S,'s',0.02);
% M  = community_louvain(A,1.03);
% P = [participation_coef(A,M)]';
% Z = [module_degree_zscore(A,M,0)]';
% B = betweenness_bin(A);      
% IDp = find(P <= 0.3 & Z >= 1.5);
% IDc = find(P > 0.3 & P <= 0.75 & Z >= 1.5);
% 
% 
% idp = find(sum(Pr) > 0);
% idc = find(sum(Co) > 0);
%      
% Pr=Pr(:,idp);
% Co=Co(:,idc);
% 
% %load('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/test_clust.mat','V');
% 
% PrC = sum(Pr ~= 0);
% CoC = sum(Co ~= 0);
% 
% for i = 1:length(Co)
%    Co(:,i) = Co(:,i)*CoC(i);    
% end
% 
% [X,Y,Z] = size(Co);
% clear i j
% Dis=zeros(Y,Y,1);
% 
% % Provincial
% 
% for i = 1:Y
%     for j = 1:Y
%     Dis(i,j) = sum(Co(:,i)-Co(:,j));
%     end
% end
% 
% di=1:Y+1:Y*Y;
% 
% Dis= 1./ abs(Dis);
% Dis(di) = 0;
% Dis=gretna_R2b(Dis,'s',0.02);
% D = zeros(size(Dis));
% D (di) = sum(Dis);
% 
% L = D - Dis;
% [v,d] = eig(L);
% d = diag(d);


% Ag=gretna_R2b(mean(A,4),'s',0.7);
% 
% 
% % Similarity matrix of D
% STD= 0.5;
% S = exp( -(Ag.*Ag) / ( 2*(STD^2) ) );
% S(di) = 0;
% 
% % Degree matrix of D
% D = zeros(size(Ag));
% D (di) = sum(Ag);
%  
% % Normalized Laplacian matrix of A
% L = eye(size(D)) - (  D^(-1/2) * S * D^(-1/2)  );
% L = D - Ag;
% % Eigenvalues and eigenvectors of L
% 
% [v,d] = eig(L);
% d = diag(d);



%% OLD
% Dis = 1 ./ dist(V);
% Dis(di) = 0;
% bin=gretna_R2b(Dis,'s',0.2);
% 
% D = zeros(x,y,1);
% D(di) = sum(bin);
% 
% L = D - bin;
% clear v d
% [v,d] = eig(L);
% d = diag(d);
% 
% 
% % Clustering
% X = v(:,end-3:end);
% IDX = kmeans(Y,3);


