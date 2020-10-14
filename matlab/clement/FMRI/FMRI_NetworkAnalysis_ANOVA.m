function NBS_FMRIConnectome_Graph_ANCOVA(g1,g2,g3)
%% CONFIG

fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
fMRIdir   = '/NAS/tupac/protocoles/Strokdem/FMRI/TCog';
outConn   = 'Network'; 
groupList = 'TCog';
thresPars = 5:2.5:40;
binary    = 0; % 0 or 1 for also binary matrix test
outDir    = fullfile(fMRIdir,outConn,['g' g1 'Vsg' g2 'Vsg' g3 '_AN-C-OVA']);


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
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g1 '_cov.txt']))];
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g2 '_cov.txt']))];
cov = [cov; load(fullfile('/NAS/tupac/protocoles/Strokdem/FMRI/',groupList,['Clu' g3 '_cov.txt']))];

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

%Weighted
MeasW        = [];


%Binary
MeasB        = [];
temp_mod=[];

%load connectivity matrices and apply sparsity 

%loop for group
for k = 1:Ng  
    disp(k)
    %loop for subject
    for s = 1:length(subjs{k})
        subj = subjs{k}{s};
        X(temp+s,k) = 1;
        
        %Weighted
        %temp_MeasW=zeros(164,164,length(thresPars));
        temp_MeasW=zeros(length(thresPars),164);

        
        %Binary
        %temp_MeasB=zeros(164,164,length(thresPars));
        temp_MeasB=zeros(length(thresPars),164);
        
        %loop for sparsity 
        for j = 1:length(thresPars)
            
            connFile = fullfile(fsdir,subj,'rsfmri','Connectome_hp.mat');
            if exist(connFile,'file')
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
                %
                % Define 0 for values comprises between prct_neg and 0,
                % idem for prct_pos
                Conn_mat(Conn_mat > prct_neg & Conn_mat < 0)=0;
                Conn_mat(Conn_mat < prct_pos & Conn_mat > 0)=0;
                
                if size(Conn_mat,1)~=size(Conn_mat,2)
                    Conn_mat = niak_vec2mat(Conn_mat,1);
                end
                
                for i=size(Conn_mat,1)
                    Conn_mat(i,i)=0;
                end  
                
                Conn_mat = weight_conversion(Conn_mat,'normalize');    
                Conn_mat = abs(Conn_mat); % ATTENTION valeurs absolues

                if binary
                   Conn_matB = weight_conversion(Conn_mat,'binarize');
                end
                
            else
                disp(['no connectome for subject: ' subj]);
            
            end
        
                %Graph theory measurements weighted
                %opt.norm=[];
                %network = CONN_NetworkMeasures(Conn_mat,opt);
                M  =  eigenvector_centrality_und(Conn_mat);
                temp_MeasW(j,:)=reshape(M,1,164);
                
                if binary
                [B,~]  = get_components(Conn_matB);
                temp_MeasB(j,:)=B;
                end 
        end
      % Compute AUC for the different measurments

      MeasW_AUC=trapz(thresPars,temp_MeasW);
      MeasW=[MeasW;MeasW_AUC];
                 
      if binary
      MeasB_AUC=trapz(thresPars,temp_MeasB);
      %MeasB=cat(3,MeasB,MeasB_AUC);
      MeasB=[MeasB;MeasB_AUC];

      end
      
    end
    temp = temp + length(subjs{k});   
end

%% GLM for group comparison with FDR
disp('Statistical analysis');

X=X(:,1:2);
X=[ones(Ns,1),X];
X = [X cov];

contrast = [0 1 1 zeros(1,size(cov,2))];

%Weighted
Mes.MeasW=MeasW;



if binary
Mes.MeasB=MeasB;
end

field=fieldnames(Mes);
%G1 > G2
%contrast
contrast = [0 1 1 zeros(1,size(cov,2))];

clear j k
for j=1:length(fieldnames(Mes)) %Traite mesure par mesure

    %Y=MeasB;
    Y=Mes.(cell2mat(field(j))); %Accès au champs de la structure
    [nx,ny,nz,nt]=size(Y);
    
    
    Res_GLM=[];
    %for l=1:nx
       %pvalx=[]; 
    for k=1:ny
        
        %MAT=reshape(Y(l,k,:),88,1);
        %slm = SurfStatLinMod( MAT, term(X) );
        slm = SurfStatLinMod( Y(:,k), term(X) );
        slm = SurfStatT( slm, contrast );
        pval = SurfStatP(slm);
        Res_GLM=[Res_GLM,pval.P];
    end
    
    %Res_GLM=[Res_GLM;pvalx];
    %end
    [Res_GLM]=spm_P_FDR(Res_GLM); %FDR 
    ResANCOVA.(cell2mat(field(j)))=Res_GLM; %Stocke dans une variable résultat
end

disp('fini')



