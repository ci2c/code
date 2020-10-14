function [BETA_COEF,XX,dof,sig2,E] = bpm_glm_surf_opt(data,confound,col_conf, brain_mask, type,no_subj,nr,BETA_COEF,E,sig2,dof,XX,flag,Rwfun)
%-----------------------------------------------------------------------%
%                         BPM GLM                                       %                         
%                                                                       %
%  It fits a GLM vertex-wise including imaging covariates               %
%  Non-imaging covariates  can be included in the analysis.             %
%                                                                       %
%-----------------------------------------------------------------------%

[n,ng] = size(data); % ng - number of groups
[n,nc] = size(confound); % nc - number of confounds
Tsubj  = sum(no_subj);

if strcmp(type,'ANCOVA')
    X = wfu_bpm_design_mat(no_subj); 
end

if strcmp(type,'REGRESSION')
    X = ones(no_subj,1);
end

%----- Append non-imaging confounds -----------%
if ~isempty(col_conf)      
    X = [X col_conf];
end

% ----------- The analysis is performed on voxel by voxel basis --------- %

I = find(brain_mask > 0);

if ~isempty(confound)
    for c = 1:nc
        x1{c} = arrayfun(@(x) confound{c}{x}(:,I), 1:ng, 'UniformOutput', false);
    end
    for c = 1:nc
        X1(:,:,c) = vertcat(x1{c}{:});
    end
    X2 = arrayfun(@(x) [X squeeze(X1(:,x,:))], 1:length(I), 'UniformOutput', false);
else
    X2 = arrayfun(@(x) X, 1:length(I), 'UniformOutput', false);
end

% ------- creating the data vector ---------- %

y1 = arrayfun(@(x) data{x}(:,I), 1:ng, 'UniformOutput', false);
y = vertcat(y1{:});
        
if flag == 0        
    beta = arrayfun(@(x) X2{x}\y(:,x), 1:length(I), 'UniformOutput', false);
    BETA_COEF(:,I) = horzcat(beta{:});
    e = arrayfun(@(x) y(:,x)-X2{x}*beta{x}, 1:length(I), 'UniformOutput', false);
    p = cellfun(@(x) rank(x), X2);
    sig = arrayfun(@(x) e{x}'*e{x}/(Tsubj-p(x)), 1:length(I));
    sig2(1,I) = sig;
    Xmat = arrayfun(@(x) X2{x}'*X2{x}, 1:length(I), 'UniformOutput', false);
else
    X3 = cellfun(@(x) x(:,2:end), X2, 'UniformOutput', false);   
    [beta, stats] = arrayfun(@(x) robustfit(X3{x},y(:,x),Rwfun), 1:length(I), 'UniformOutput', false);    
    BETA_COEF(:,I) = horzcat(beta{:});
    e = arrayfun(@(x) y(:,x)-X2{x}*beta{x}, 1:length(I), 'UniformOutput', false);
    sig = cellfun(@(x) x.robust_s^2, stats); % assume Tsubj is larger compared to p^2, use robust_s as estimated covariance
    sig2(1,I) = sig;  
    W = cellfun(@(x) x.w, stats, 'UniformOutput', false);
    wei = cellfun(@(x) diag(x), W, 'UniformOutput', false);
    Xmat = arrayfun(@(x) X2{x}'*wei{x}*X2{x}/(sum(W{x})/Tsubj), 1:length(I), 'UniformOutput', false);
end
    
p = cellfun(@(x) rank(x), X2); 
E(:,I) = horzcat(e{:});
Xmatv = cellfun(@(x) x(:), Xmat, 'UniformOutput', false);
XX(:,I) = horzcat(Xmatv{:});
dof(1,I) = arrayfun(@(x) Tsubj-x, p);        