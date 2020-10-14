function FMRI_Mod_Analysis(g1,g2,g3)
%% CONFIG

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog';
outConn   = 'Network'; 
groupList = 'TCog';
thresPars = 0.05;
gamma     = 1;


%% RECUP MATRICES

% subjects
subjs = {};
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_subjs.txt']),'%s \n');
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g3 '_subjs.txt']),'%s \n');


% covariates
%cov = [];
%cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
%cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];

Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end

Group  = [];
thresh = 0.1; % WARNING UNIQUE SPARSITY THRESHOLD
co_all = [];
clear k
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
            
                % CoClassification for communitie sof each subject
                for j=1:length(thresh)
                    A = gretna_R2b(Connectome.Cmat,'s',thresh(j));
                    co_all(z,:)= Topo_CoClassification(A,1000,1.03);
                end
                
                
            z=z+1;
            Group(end+1) = k;
           end
        else
            disp(['no connectome for subject: ' subj]);
        end
    end
end

% %% LOAD GROUP COMMUNITIES
% 
% co1 = load('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/Communities_SS_Ck31.mat','M');
% co2 = load('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/Communities_nocog_Ck31.mat','M');
% co3 = load('/NAS/tupac/protocoles/Strokdem/FMRI/Hubs/Communities_cog_Ck31.mat','M');
% 
% G1 = length(Group(Group == 1));
% G2 = length(Group(Group == 2));
% G3 = length(Group(Group == 3));
% co_all =  [repmat(co1.M,[G1,1]);repmat(co2.M,[G2,1]);repmat(co3.M,[G3,1])];

%% NMI
[x,y,z] = size(Conn_mat);


for i=1:z
    for j=i:z
        NMI_mat(i,j)=FMRI_Mod_NMI(Conn_mat(:,:,i),Conn_mat(:,:,j),co_all(i,:),co_all(j,:));
    end
end
[X,Y,~] = size(NMI_mat);
di=1:X+1:X*X;

NMI_mat(di) = 0;


disp('coucou')