function STK_prediction_PrepareData

%% CONFIG
fsdir  = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
lesdir = '/NAS/tupac/protocoles/Strokdem/Lesions/72H/';

subj = {};
subj{end+1} = textread('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/Nocog_Cog_subjs.txt','%s \n');

subjSS = {};
subjSS{end+1} = textread('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/CluSS-Cra_subjs.txt','%s \n');

fMRI   = 0;
ChacoN = 1;
Demog  = 0;
Struc  = 0;
Deff   = 0;

Evo_M12 = 0;

% ---------------------------
L = 1;
P = 2;
E = 3;
A = 4;
M = 5;
G = 6;
V = 7;

MMSE = 8;
MoCA = 9;

dom = [G];



%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                              LOADING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%% Resting-State fMRI %%%%%%%%%%%%%%%%%%%%%%%

% CONFIG
MMSE = 0;
PSCI = 1;

% load PSCI network to slect only the connexion of this network

if PSCI
    disp('PSCI Network used')
    load('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/Network/gnocog-CraVsgcog-Cra_AGE-SEXE-ED/NBS_gnocog-Cra_gcog-Cra_perm_p0.05_3_0.mat','NBS');
    Net_mat = full(cell2mat(NBS.con_mat(1)));
elseif MMSE
    disp('MMSE connections on PSCI Network used')
    load('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/Network/NTC-TC_CORRELATION/FDR_perm_p0.05_CORRELATIONMMSE.mat','NBS')
    Net_mat = full(NBS.con_mat);
end

X_fMRI = [];
S = [];
ID_mat = [];

%%%% A AUTOMATISER %%%%
nnodes = 313; 
nedges = nnodes*(nnodes-1)/2;
%%%%%%%%%%%%%%%%%%%%%%%
if fMRI
    for s = 1:length(subj{1})
            Subj = subj{1}{s};


        % fMRI
        connFile = fullfile(fsdir,Subj,'rsfmri','Craddock_Parc','NB31','Connectome_Ck31.mat');
        if exist(connFile,'file')
            load(connFile);
            if isfield(Connectome,'Cmat') 
                if length(Connectome.Cmat(:)) == nnodes^2

                    if PSCI == 0
                        vtmp = niak_mat2vec(Connectome.Cmat)';
                    else
                        Net_Co=Connectome.Cmat.*Net_mat; 
                        sNet_Co = Net_Co + triu(Net_Co)';
                        vtmp = niak_mat2vec(sNet_Co)'; 
                        
                        ID_mat = find(vtmp ~=0);
                        vtmp = vtmp(ID_mat);
                    end
                    %%% ---------- absolute values ---------
                    X_fMRI(end+1,:) = abs(vtmp);
                    %%% ------------------------------------
                    S(end+1,1) = s;
                else
                    X_fMRI(end+1,:) = 0;
                end
            else
                X_fMRI(end+1,:) = 0;
            end
        else
            X_fMRI(end+1,:) = 0;
        end
    end

[~,nFC,~] = size(X_fMRI);

INPUT.fMRI.X = X_fMRI;
INPUT.fMRI.S = S;
INPUT.fMRI.doNorm = 0;
INPUT.fMRI.PSCI = PSCI;
INPUT.fMRI.id = ID_mat;
INPUT.fMRI.nFC = nFC;

if PSCI 
    INPUT.fMRI.doPCA = 0;
else
    INPUT.fMRI.doPCA = 1;
end

end
%%%%%%%%%%%%%%%%%%%%%%% ChacoN Score %%%%%%%%%%%%%%%%%%%%%%%

if ChacoN
    load('/NAS/tupac/protocoles/Strokdem/DTI/Disconnection/ChacoNs_NTCTC','ChacoNs','SUBJ_ID');

    Xchaco = zeros(length(subj{1}),nnodes);
    Xchaco(SUBJ_ID,:) = ChacoNs';

    INPUT.ChacoN.X = Xchaco;
    INPUT.ChacoN.S = SUBJ_ID;
    INPUT.ChacoN.doPCA = 1;
    INPUT.ChacoN.doNorm = 1;

end

%%%%%%%%%%%%%%%%%%%%%%% Demographic Data %%%%%%%%%%%%%%%%%%%%%%%

if Demog
    
    [a,b,c] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/Demographic_features.xls');
    
    f = [1];
    
    INPUT.Demog.X = a(:,f);
    INPUT.Demog.S = find(~isnan(sum(a,2)));
    INPUT.Demog.doPCA = 0;
    INPUT.Demog.doNorm = 1;

end

%%%%%%%%%%%%%%%%%%%%%%% Structural features %%%%%%%%%%%%%%%%%%%%%%%

if Struc
    [a,b,c] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/Predictive_features.xls');

    f = [6 7 9 10];
    
    X_str = a(:,f);
    ID = find(~isnan(X_str));

    INPUT.Struc.X = X_str;
    INPUT.Struc.S = ID;
    INPUT.Struc.doPCA = 0;
    INPUT.Struc.doNorm = 1;
end

%%%%%%%%%%%%%%%%%%%%%%% Hippocampal deformation %%%%%%%%%%%%%%%%%%%%%%%

% Will load only significant vertex for NTC/TC comparison
if Deff
    
 
    load('/NAS/tupac/protocoles/Strokdem/Prediction/Shape_Hipp_M6','Mat_DispNorm','SUBJ_OK','ID_Deffp','ID_DeffRawp');
    
    INPUT.DeffM6.X = Mat_DispNorm(:,ID_DeffRawp);
    INPUT.DeffM6.S = SUBJ_OK;
    INPUT.DeffM6.doPCA = 0;
    INPUT.DeffM6.doNorm = 1;
    
    

end
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                              PCA reduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sf = {};

INPUT_fields=fieldnames(INPUT);

for i=1:length(INPUT_fields)
    Sf{end+1} = INPUT.(cell2mat(INPUT_fields(i))).S;
end

% Multiple intersection 
n = numel(Sf); 
if n == 2 
    [C,~,~] = intersect(Sf{1}, Sf{2}); 
elseif (n > 2 && rem(n,2) == 0) 
    for i = 1:(n/2) 
        intersections{1, i} = intersect(Sf{i}, Sf{n-i+1}); 
    end 
elseif (n > 2 && rem(n,2) == 1) 
    for i = 1:((n-1)/2) 
        intersections{1, i} = intersect(Sf{i}, Sf{n-i+1}); 
    end 
        intersections{1, i+1} = Sf{(n+1)/2}; 
elseif n == 1 
    C = Sf{1}; 
end
if n > 2 
    C = intersect2(intersections); 
end
% 

disp('PCA reduction...')

for j=1:length(INPUT_fields)
        
    if INPUT.(cell2mat(INPUT_fields(j))).doPCA == 1
       
        %%% PCA %%%
        Xtmp = INPUT.(cell2mat(INPUT_fields(j))).X;
        Xtmp = Xtmp(C,:);
        [coeff, SCORE, LATENT,~,~] = pca( Xtmp ); %pca center data

        var_expl = cumsum(LATENT) / sum(LATENT);  
        ID = find(var_expl < 0.96); % Get components that explained 95% of variance
        reducedDimension = coeff(:,ID);
        Zf = Xtmp * reducedDimension;

        INPUT.(cell2mat(INPUT_fields(j))).coeff = reducedDimension;
        
        %%%%%%%%%%
        [Xx,~,~] = size(Zf);
        Xy = length(ID);
        Xf = zeros(Xx,Xy);

        % Normalisation to [-1 1]
        if INPUT.(cell2mat(INPUT_fields(j))).doNorm == 1 % Check if normalisation [-1 1] is needed (not for connectivity e.g)
            clear i
            for i = 1 :Xy
                Zf(:,i) = normVec(Zf(:,i),1);
            end
        end
        
        Xf(C,:) = Zf;
        INPUT.(cell2mat(INPUT_fields(j))).X = Xf;
        
    else
        
        Xf  = INPUT.(cell2mat(INPUT_fields(j))).X;
        % Normalisation to [-1 1]
        if INPUT.(cell2mat(INPUT_fields(j))).doNorm == 1 % Check if normalisation [-1 1] is needed (not for connectivity e.g)
            [Xx,Xy,~] = size(Xf);
            clear i
            for i = 1 :Xy
                Xf(:,i) = normVec(Xf(:,i),1);
            end
        end
        INPUT.(cell2mat(INPUT_fields(j))).X = Xf;
        
    end
    
end
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                           Prediction Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[Cog,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_binary.xls'); 
TC = Cog(:,end-1);

[Score,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_zscore.xls');
Y6 = Score(:,dom);

[Scorei,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_score.xls');
Yi6 = Scorei(:,dom);


%--------------------------------------------------------------------------------------
[Score,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_zscoreM12.xls');
Y12 = Score(:,dom);
Y12(end+1,:) = NaN;

[Scorei,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_scoreM12.xls');
Yi12 = Scorei(:,dom);
Yi12(end+1,:) = NaN;

if Evo_M12
    Y = Yi12 - Yi6;
    Yi = Yi12 - Yi6;
else
    Y = Y6;
    Yi = Yi6;
end


[~,Yy,~] = size(Y);


if Yy > 1 
    INPUT.Composite = 1;
else
    INPUT.Composite = 0;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    Input Recomposition && saving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X = [];
ID_X = {};
coeff = [];
for j=1:length(INPUT_fields)
    [~,Xy,~] = size(INPUT.(cell2mat(INPUT_fields(j))).X);
    X = cat(2,X,INPUT.(cell2mat(INPUT_fields(j))).X);
    for i = 1:Xy
        ID_X{end+1} = cell2mat(INPUT_fields(j));
    end
    clear i
end

clear x y

S = C;

INPUT.ID_X = ID_X;
INPUT.X    = X;
INPUT.Y    = Y;
INPUT.Yi   = Yi;
INPUT.S    = S;
INPUT.dom  = dom;


%% OUTPUT WRITING
disp('Writing output file...')

save('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','INPUT');




