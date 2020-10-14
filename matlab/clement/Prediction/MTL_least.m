%% MULTITASK LEARNING 

%% CONFIG
load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','X','coeff','Y','id','nFC');
wholeCo = 0;
fileName = 'NoFazekas_PSCINetwork_Optimized_AG';

sy=sum(Y,2);
[C,~,~] = intersect(S,find(~isnan(sy)));

A = X(C,:);
y = Y(C,:);

%% OPTIMIZATION



opts = [];

 opts.q = 2;
 opts.mFlag = 1;
 opts.nFlag = 0;

 %opts.init = DoE(D,2);
 opts.tFlag = 4;
 %opts.lFlag = DoE(D,4);
 opts.rFlag = 0;

 
 Spars = 2;

if opts.rFlag == 0
    Z = [0.001 : 0.1 : 10];
else opts.rFlag == 1
    Z = [0.001 : 0.01 : 1];
end 

[S,I] = sort(A(:),'descend');
A( A < S(round(length(S(:)) / Spars) +1)) = 0; % Introduce sparsity
[pred,B,Opt_lambda] = LOOCV_mcLeastR(A,-y, opts, Z);


figure; plot(y(:),pred(:),'+')
[R,~] = corrcoef(y,pred);
var_expl = R(1,2).^2;
disp(['Variance explained : ' num2str(var_expl)])


%% PROJECTION
if wholeCo % If the entire whole connectome is entered as input 
disp('Projection on whole connectome...')
bproj = B' * coeff';
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

else % Work onn PSCI network

sbproj = sum(B,2);
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

proj_vec(id) = sbproj(1:nFC);

%
msbproj = niak_vec2mat(proj_vec);

deg=strengths_und(msbproj);
end


% BrainNet
% nodes

[labidx,names] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_nodes.txt','%d %s');
coord_parc     = load('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/MASK/FRAME31/Ck31_coord.txt');

C = ones(length(coord_parc),length(coord_parc));

nodes.coords = coord_parc;
nodes.colors = deg';
nodes.sizes  = deg';
nodes.labels = names;

fid = fopen(fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/Multitask',[fileName '.node']),'w');

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

% edges
FMRI_CreateEdgeFileBrainNet(fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/Multitask',[fileName '.edge']),double(C).*msbproj);


%% Save

save(fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/Multitask',[fileName '.mat']),'B','var_expl','pred','A','y','msbproj');