function [grpRes indRes] = discover(dat,noClus,noReps,meanFlag,dim,epsilon)

% [grpRes indRes] = discover(dat,noClus,noReps,meanFlag,dim,epsilon)
%
% Performs the analysis on the data (variable dat) with number of clusters
% indicated by variable noClus. The analysis is repeated noReps number of
% times with random initializations.
%
% Format of variable dat: 
%
% The variable has a cell structure. For subject i, dat{i} is an N X D 
% dimensional matrix representing the fMRI response of the N voxels within 
% the mask for subject i, to D different stimuli or time points.
%
% grpRes: clustering results for the concatenated group data
%
% indRes: clustering results for individual subject data. indRes has a cell
%         structure where indRes{i} presents the result for subject i (see the
%         structure of variable dat below).
%
% meanFlag: A flag that says whether or not to subtract the mean from the entire vectors (cluster
%			based on correlation coefficient rather than correlation). Default is 0.
%
% dim:    the actual dimensionality of data. Any linear constraint that we
%         add to the data reduces dim from the value D. For instance, if remove the mean to make
%         the vectors are all zero mean, then dim = D-1. 
%
%
% discover also has a number of other default values introduced running the
% clustering code (direcClus.m). For more information look at the help for
% direcClus.


d = size(dat{1},2);

if ~exist('dim')
    dim = d;
end

if ~exist('meanFlag')
    meanFlag = 0;
end


if ~exist('epsilon')
	epsilon = 1e-4;
end

yG = [];
for s = 1:length(dat)	
	if meanFlag == 0 
		yG = [yG; dat{s}];
	else
		yG = [yG; datanor(dat{s},'rmmn',2)];
    end
end

best = 1e-20;

for s = 1:length(dat)	
      
    if meanFlag == 0
		indRes{s} = direcClus(dat{s},noClus,dim,noReps);
	else
		indRes{s} = direcClus(datanor(dat{s},'rmmn',2),noClus,dim,noReps);
    end
	
    paramInits.lambda = indRes{s}.lambda;
    paramInits.m = indRes{s}.m;
    paramInits.p = indRes{s}.p;
    
	ctemp = direcClus(yG,noClus,dim,1,[],paramInits);
    if ctemp.likelihood(end) > best
       grpRes = ctemp;
	   bestsubj = s;
       best = ctemp.likelihood(end);
    end

end



