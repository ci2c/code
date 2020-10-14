function [scores indperms] = performPermutation(indRes,dat,B,noClus,dim,epsilon,matchingFlag,meanFlag)
% [scores indperms] = performPermutation(indRes,y,B,noClus,dim,epsilon)
%
% This code performs a group permutation test. 
%
% indRes:   individual results from discover()
% dat:      cell structure containing data from different subjects
% B: 		number of repetitions.
% noClus:   number of clusters
% dim:      dimensionality of the data
% epsilon:  breaking condition threshold for stopping model updates (default: 1e-4)
% meanFlag: flag that says whether or not to subtract the mean from the entire vectors (cluster
%			based on correlation coefficient rather than correlation).
%			Default is 0.
% 
% matchingFlag specifies what kind of matching should be performed. The
% default is 0 which means matching based on the vectors of selectivity
% profiles. If it is 1, the matching is based on clustering assignments.
%
% Function outputs:
%
% scores:   K X B consistency scores of the profiles in each sample from the null distribution
% indperms: 

if ~exist('epsilon')
	epsilon = 1e-4;
end

breakCond.type = 'clusmean';
breakCond.epsilon = epsilon;

if ~exist('matchingFlag')
	matchingFlag = 0;
end

if ~exist('meanFlag')
    meanFlag = 0;
end

noSubjs = length(indRes);
d = size(dat{1},2);

rand('seed',sum(100*clock));

for j=1:B
    
    yG = [];

	% Permute the data labels
    %
    for i = 1:noSubjs
        indperms(:,i,j) = randperm(d)';
		if meanFlag == 0
		   yG = [yG; dat{i}(:,indperms(:,i,j))];
		else
		   yG = [yG; datanor(dat{i}(:,indperms(:,i,j)),'rmmn',2)];
		end
    end
    
    
	% Rerun the permuted group data with different initializations
	
	
	% Option 1: initialization using the permuted results of individual subjects
	%
	best = -1e20;
    for i = 1:noSubjs
	
	    paramInits.lambda = indRes{i}.lambda;
	    paramInits.m = indRes{i}.m(:,indperms(:,i,j));
	    paramInits.p = indRes{i}.p;
	
		ctemp = direcClus(yG,noClus,dim,1,breakCond,paramInits);
		
        if ctemp.likelihood(end) > best
            grpResPerm = ctemp;
            best = ctemp.likelihood(end);
        end
    end
    %}


	% Option 2: random initializaitons
	%{
	noInits = 10;	
	grpResPerm = direcClus(yG,noClus,dim,noInits);
	%}
	
	% Mathing
    %
    for i = 1:noSubjs
        indRes_temp{i}.m = indRes{i}.m(:,indperms(:,i,j));
        indRes_temp{i}.clusters = indRes{i}.clusters;
    end    
        
    scores(:,j) = performMatching(grpResPerm,indRes_temp,matchingFlag);

    end

end

