function clustered = direcClus(x,K,d,noInits,breakCond,paramInit)

% clustered = direcClus(x,k,d,noruns,lambda,p,mInit,epsilon,flagCorStop)
%
% This function implements a clustering based on a mixture of
% vonMises-Fisher distributions. It first projects the data to the unit
% hypersphere and then estimates the centers of different components, a concentration
% parameter shared among all components and the component assignments.
%
% x:                the V X D data matrix where n is the number of data
%                   points to be clustered
% K:                number of clusters
% d:                the actual dimensionality of the data. Any linear constraints in the data
%                   reduces the dimensionality by one. For instance, if you remove the mean
%                   of the data, the dimensionality will be D-1. If entered
%                   zero, it lets d=D.
% noInits:          number of repetitions with different random initializations.
% breakCond         structure specifying the breaking condition.
% breakCond.type    type of breaking condition. If 'clusmean', the
%                   algorithm controls the correlation betweeh current and previous
%                   cluster centers. If 'hardAssignment', if stops only
%                   when the hardAssignment do not change between two
%                   consecutive updates. Otherwise, it controls the
%                   likelihood value.
% breakCond.epsilon the stopping threshold for the difference between two
%                   consecutive cluster center correlations or likelihoods
% paramInit         if entered, used instead of random initializations
% paramInit.p       K X 1 vector of cluster weights
% paramInit.lambda  concentration parameter
% paramInit.m       K X D cluster centers (must be unit vectors)
%
%
% The function output is a structure with the following fields:
%
% clustered.lambda      concentration parameter lambda;
% clustered.likelihood  vector of likelihood values in updates of the best
%                       result
% clustered.r           V X K assignment probabilities for all data points
%                       and clusters
% clustered.clusters    hard assignments
% clustered.p           component (cluster) weights
% clustered.m           K X D cluster centers
% clustered.mInit       initializing cluster centers

%--------------------------------------------------------------------------
%    Initialization
%--------------------------------------------------------------------------

clustered.listlik = [];
clustered.listavcor = [];

% Find the parameters

n = size(x,1);
if d==0
    d = size(x,2);
end
clustered.d = d;
alpha = d/2 - 1;

% Project the data to the unit hypersphere
x = x ./ (sqrt(sum(x.^2,2))*ones(1,size(x,2)));

% Check the input variables
%--------------------------------------------------------------------------

if ~exist('breakCond') || length(breakCond)==0
    breakCond.type = 'clusmean';
    breakCond.epsilon = 1e-6;
end

pFlag = 0;
lambdaFlag = 0;
mInitFlag = 0;
if exist('paramInit')
    if isfield(paramInit,'p')
        pFlag = 1;
        p = paramInit.p;
    end

    if isfield(paramInit,'lambda')
        lambdaFlag = 1;
        lambda = paramInit.lambda;
    end

    if isfield(paramInit,'m')
        mInitFlag = 1;
        mInit = paramInit.m;
    end
end


%--------------------------------------------------------------------------
%    Loop of Repetitions
%--------------------------------------------------------------------------

best = -1e100;
itcount = 1;
conditionReps = 1;

while conditionReps

    fprintf('Iter. %g...',itcount);
    tic;

    %   initialize the parameters -----------------------------------------

    if pFlag == 0
        p = ones(1,K)/K;
    end

    if lambdaFlag == 0
        lambda = 500 ;
    end

    if mInitFlag == 0
        rand('seed',sum(100*clock));
        init = ceil(n*rand(K,1));
        mInit = x(init, :);
    end

    m = mInit';
    mtemp = m;

    % ---------------------------------------------------------------------
    %   Main Loop ---------------------------------------------------------

    condition = 0;
    likelihood = [];
    temp = ones(1,n);

    if breakCond.type == 'clusmean'
        mtcXitCor = [];
    end


    while condition == 0

        % Estimation step   ---------------------------------------------------------

        dis = -(x*m) * lambda  - Cdln(lambda,d) ;
        mindis = min(dis,[],2);
        r = repmat(p,n,1) .* exp(-(dis-repmat(mindis,1,K)));

        likelis = sum(r,2);
        r = r ./ repmat(likelis , 1,K);
        p = sum(r,1)/n;

        % Maximization step -------------------------------------------------

        % Mean
        m = x'*r;
        m = m ./ repmat(sqrt(sum(m.^2)),size(x,2),1);

        % Concentration parameter
        lambda = invAd(d,sum(sum(r.*(x*m)))/n);

        % Compute the likelihood
        likelihoodFinal = (1/n)*sum(log(likelis)-mindis);
        likelihood = [likelihood likelihoodFinal];

        % Checking the loop-break conditions ------------------------------

        if breakCond.type == 'clusmean'
            mtcXitCor = [mtcXitCor diag(m'*mtemp)];
            controlCondition = (sum(1-mtcXitCor(:,end) < breakCond.epsilon) < K);
            mtemp = m;
        elseif breakCond.type == 'hardAssignments'
            [temp1 hardAssignments] = max(r');
            controlCondition = norm( hardAssignments - temp);
            temp = hardAssignments;
        else
            controlCondition = abs(likelihoodFinal - temp) > breakCond.epsilon;
            temp = likelihoodFinal;

        end

        if controlCondition <1
            condition = 1;
        end

    end

    itcount = itcount + 1;

    if noInits > 0
        conditionReps = ~(itcount > noInits);
    elseif itcount > 2
        if  likelihoodFinal > best

            [temppp overlapp] = Hungarian(-clustered.r'*r);
            overlapp = -overlapp/n

            conditionReps = (overlapp<.98);

        end
    end

    % Checking if this repetition gives the best solution -----------------

    [temp1 hardAssignments] = max(r');
    avcor = mean(sum(x.*m(:,hardAssignments)',2));

    if likelihoodFinal > best

        best = likelihoodFinal;
        clustered.lambda = lambda;
        clustered.likelihood = likelihood;
        clustered.r = r;
        clustered.clusters = hardAssignments';
        clustered.p = p;
        clustered.m = m';
        clustered.mInit = mInit;
        clustered.avcor = avcor;

        if breakCond.type == 'clusmean'
            clustered.mtcXitCor = mtcXitCor;
        end

    end

    clustered.listlik = [clustered.listlik likelihoodFinal];
    clustered.listavcor = [clustered.listavcor avcor];
    timetemp = toc;
    fprintf('took %f second.\n',timetemp);

end

end

%-----------------------------------------------------------------------
function [out exitflag] = invAd(D,rbar)
% Computes the inverse of the Ad function

outu = (D-1)*rbar/(1-rbar^2) + D/(D-1)*rbar;

[i ierr] = besseli(D/2-1,outu);

if ierr ~= 0
    out = outu - D/(D-1)*rbar/2;
    exitflag = Inf;
else
    [outNew fval exitflag]  = fzero(@(argum) Ad(argum,D)-rbar,outu);
    if exitflag == 1
        out = outNew;
    else
        out = outu - D/(D-1)*rbar/2;
    end
end

end

%-----------------------------------------------------------------------
function out = Ad(in,D)
% out = Ad(in,D)
out = besseli(D/2,in) ./ besseli(D/2-1,in);
end
%-----------------------------------------------------------------------
function out = Cdln(k,d)

% Computes the logarithm of the partition function of vonMises-Fisher as
% a function of kappa

sizek = size(k);
k = k(:);

out = (d/2-1).*log(k)-logbz(besseli((d/2-1)*ones(size(k)),k));

k0 = 500;
fk0 = (d/2-1).*log(k0)-logbz(besseli(d/2-1,k0));
nGrids = 1000;

maskof = find(k>k0);
nkof = length(maskof);

% The kappa values higher than the overflow

if nkof > 0
    kof = k(maskof);

    ofintv = (kof - k0)/nGrids;
    tempcnt = (1:nGrids) - 0.5;
    ks = k0 + repmat(tempcnt,nkof,1).*repmat(ofintv,1,nGrids);
    adsum = sum( 1./((0.5*(d-1)./ks) + sqrt(1+(0.5*(d-1)./ks).^2)) ,2);
    out(maskof) =  fk0 - ofintv .* adsum;
end

out = reshape(out,sizek);

end