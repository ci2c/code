function STK_prediction_LOOCV

STK_prediction_PrepareData


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          CONFIG & LOADING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fsdir  = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
lesdir = '/NAS/tupac/protocoles/Strokdem/Lesions/72H/';

fileName = 'PSCI';

logistic = 0;
doPerm   = 0;
Projection = 1;

% load input and output data for ridge
load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','INPUT'); % id correspond to the connexions in the PSCI network


switch INPUT.dom
    
    case 1
        domain_name = 'Langage';
    case 2
        domain_name = 'Praxie';
    case 3
        domain_name = 'Executif_Stroop';
    case 4
        domain_name = 'Attention_Digit';
    case 5
        domain_name = 'Memoire_Sensib';
    case 6
        domain_name = 'Gnosie';
    case 7
        domain_name = 'VisuoSpatial';
    case 8
        domain_name = 'MMSE';
    case 9
        domain_name = 'MoCA';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          Data Extraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if INPUT.Composite
    sy=sum(INPUT.Y,2);
    [C,~,~] = intersect(INPUT.S,find(~isnan(sy)));
    Y = mean(INPUT.Y(C,:),2);
else
    [C,~,~] = intersect(INPUT.S,find(~isnan(INPUT.Y))); % Find subjects with input AND output valid data
    Y = INPUT.Y(C,:);
end

X = INPUT.X(C,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                           Ridge Regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if logistic == 0;
    disp('Lauching rigde_LOOCV...')
    [B,R,rmse,var_expl,pred,errs,P_perm,blambda] = ridge_LOOCV(X,-Y,doPerm); % 1 for permutation testing, 0 for not. Need matlab pool
    disp(['Variance explained :  ' num2str(var_expl)])
    disp(['Rmse :  ' num2str(rmse)])
    
    %%%% INTERCEPT ONLY MODEL %%%%%
%     Y_IM = Y;
%     Y_IM(Y~=0) = mean(Y);
%     [B_IM,~,~,~,~,~,~,~] = ridge_LOOCV(X,-Y_IM,doPerm);
%     
%     [H,~] = ttest2([mean(B)'],[mean(B_IM)']);
%     
%     if H == 1
%         disp('Significant model compared to intercept only !')
%     else 
%         disp('The model is NOT significant compared to intercept only model !')
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else
    [pred,B,Opt_lambda] = LOOCV_LogisticR( X, -Y, opts, Lambda);
end


%------------------
% Rescaling data
%------------------
pred = pred';
Yi = INPUT.Yi(C);

p1 = polyfit(pred,Y,1);
tmp1 = pred*p1(1) + p1(2);
p2 = polyfit(Y,Yi,1);
predr = tmp1*p2(1) + p2(2); % rescaled predicted data


figure; plot(Yi,predr,'o')

errs=(predr-Yi).^2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                Data Projection                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Projection

    % TECHNIQUE POUR NORMALISER LES POIDS, C'EST PLUS FACILE POUR PROJETER

    B_proj = mean(B,2);

    id_neg = find(B_proj < 0);
    b_neg = B_proj(id_neg);
    m_neg = max(abs(b_neg));

    B_proj(id_neg) = 10*b_neg/m_neg;

    id_pos = find(B_proj > 0);
    b_pos = B_proj(id_pos);
    m_pos = max(b_pos);

    B_proj(id_pos) = 10*b_pos/m_pos;
    B_proj = abs(B_proj); % Si on veut les prédicteurs peu importe le signe
    %

    clear i

    IDu_X = unique(INPUT.ID_X);
    for i = 1:length(IDu_X)

        switch char(IDu_X(i))

            case 'fMRI'
                ID_fMRI = find(ismember(INPUT.ID_X,'fMRI') == 1 );
                disp('Projection on connectome...')
                if INPUT.fMRI.PSCI ==  0 % If the entire whole connectome is entered as input 

                    coeff = INPUT.fMRI.coeff;
                    bproj = B(ID_fMRI,:)' * coeff';
                    sbproj = mean(bproj);

                    % TECHNIQUE POUR NORMALISER LES POIDS, C'EST PLUS FACILE POUR PROJETER
                    id_neg = find(sbproj < 0);
                    b_neg = sbproj(id_neg);
                    m_neg = max(abs(b_neg));

                    sbproj(id_neg) = 10*b_neg/m_neg;

                    id_pos = find(sbproj > 0);
                    b_pos = sbproj(id_pos);
                    m_pos = max(b_pos);

                    sbproj(id_pos) = 10*b_pos/m_pos;
                %%%%%%%%%%%%%%%%%%%% A VERIFIER %%%%%%%%%%%%%%%%%%%%%%%
                    proj_vec = sbproj(1:nFC); 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                    msbproj = niak_vec2mat(proj_vec);

                    deg=strengths_und(msbproj);

                else % Work on PSCI network

                    sbproj = mean(B(ID_fMRI,:),2);
                    id_neg = find(sbproj < 0);
                    b_neg = sbproj(id_neg);
                    m_neg = max(abs(b_neg));

                    sbproj(id_neg) = 10*b_neg/m_neg;

                    id_pos = find(sbproj > 0);
                    b_pos = sbproj(id_pos);
                    m_pos = max(b_pos);

                    sbproj(id_pos) = 10*b_pos/m_pos;
                %%%%%%%%%%%%%%%%%%%%%% A AUTOMATISER %%%%%%%%%%%%%%%%%%%%%%%%%
                    proj_vec = zeros(1,48828); 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    id = INPUT.fMRI.id;
                    proj_vec(id) = sbproj(1:INPUT.fMRI.nFC);

                %
                    %-----------ABS VALUE OF WEIGHTS-------
                    msbproj = niak_vec2mat(abs(proj_vec));
                    %--------------------------------------
                    [x,~,~] = size(msbproj);
                    di = 1:x+1:x*x;
                    msbproj(di) = 0;
                    clear x di
                end

                Stk_BrainNet_Display(fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/',domain_name),[domain_name fileName],msbproj)
                save(fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/',domain_name,[domain_name fileName '.mat']),'B','var_expl','pred','errs','P_perm','X','Y','msbproj');

            case 'ChacoN'

                B_proj = mean(B,2);
                ID_ChacoN = find(ismember(INPUT.ID_X,'ChacoN') == 1 );
                disp('Projection on Craddock Nodes...')

                coeff = INPUT.ChacoN.coeff;
                bproj = abs(B_proj(ID_ChacoN,:)' * coeff');

                V   = spm_vol('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/tcorr05_2level_all-FRAME31.nii');
                vol = spm_read_vols(V);

                V_B = V;
                V_B.fname = fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/',domain_name,[domain_name '_' fileName '_ChacoN.nii']);
                vol_B = vol;

                load('/NAS/tupac/protocoles/Strokdem/DTI/Disconnection/ChacoNs_meanSS.mat','lab');

                for i = 1:length(lab)
                    vol_B(vol == lab(i)) = bproj(i); % J'ai mis un - car on cherche la corrélation négative (+ c'est disconnecté et - le Y est élevé, et c'est mieux pour la visu sur freeview
                end

                spm_write_vol(V_B,vol_B);
                save(fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/',domain_name,[domain_name fileName '.mat']),'B','var_expl','pred','errs','P_perm','X','Y');

            otherwise
                disp(['No projection for these features : ' IDu_X(i)]);

        end
    end
    
    
end    
