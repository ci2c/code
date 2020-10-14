function Y=FMRIConnectome_topo_Extract(g1)
%% CONFIG

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog';
outConn   = 'Network'; 
groupList = 'TCog';
thresPars = 0.01:0.02:0.4;


%% BUILD GLM

% subjects
subjs = {};
subjs{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_subjs.txt']),'%s \n');


Ng = length(subjs);
Ns = 0;
for k = 1:Ng
    Ns = Ns + length(subjs{k});
end

clear k

% Build matrix design

X      = zeros(Ns,Ng);
nnodes = 313;
nedges = nnodes*(nnodes-1)/2;
cp     = 0;
Y      = zeros(Ns,nedges);
temp   = 0;

%Weighted
MeasW        = [];


%Binary
MeasB        = [];
MeasD = [];
MeasP = [];

%load connectivity matrices and apply sparsity 
%loop for group
for k = 1:Ng  
    disp(k)
    %loop for subject
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        X(temp+s,k) = 1;
        disp(s)
        
        %loop for sparsity 
        connFile = fullfile(fsdir,subj,'rsfmri','Craddock_Parc','Connectome_ck.mat');
        if exist(connFile,'file')
           load(connFile);
       
            Conn_mat=Connectome.Cmat;
                for j = 1:length(thresPars)
                    %Sparsity
                    bin=gretna_R2b(Conn_mat,'s',thresPars(j));
                    Conn_matS=bin.*abs(Conn_mat);
                    %Conn_matN=weight_conversion(Conn_matS,'lengths');
                    
                    [M]=clustering_coef_bu(bin);
                    
                    temp_MeasD(j,:) = sum(reshape(M,1,313))/313;
                end
        end
        
        clear Conn_mat
      % Compute AUC for the different measurments
      
      MeasD_AUC=trapz(thresPars,temp_MeasD);
      MeasD=[MeasD;MeasD_AUC];     
    end
end

Y=MeasD;