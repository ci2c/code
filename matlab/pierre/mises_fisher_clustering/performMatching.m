function [cs matchInds scores matching mus sps] = performMatching(grpRes,indRes,matchingFlag)

% [cs matchInds scores matching mus sps] = performMatching(grpRes,indRes,matchingFlag)
%
% Performs the matching of the group and individual clusters based on
% solving the bipartite graph matching problem between each individual and
% the group. grpRes and indRes are the group and individual results as
% created by discover.m.
%
% matchingFlag specifies what kind of matching should be performed. The
% default is 0 which means matching based on the vectors of selectivity
% profiles. If it is 1, the matching is based on clustering assignments.
%
% Function outputs:
%
% cs:           consistency scores for clustesrs
% matchInds:    matching indices of individual data to group clusters
% scores:       matching scores for each individual data
% mus:          group system profiles
% sps:          individual system profiles
%

noSubjs = length(indRes);

if ~exist('matchingFlag')
	matchingFlag = 0;
end

if matchingFlag == 1
	ss = 0;
	for s = 1:length(indRes)
		pointer{s} = (ss+1:ss+length(indRes{s}.clusters))';
		ss = ss + length(indRes{s}.clusters);
	end
end

switch matchingFlag
	
	case 0
	
	mus = grpRes.m;
	
	% Matching based on selectivity profiles

	musnor = datanor(mus,'norm',2);
	
	for i = 1:noSubjs

    	spsunnor = indRes{i}.m;
    	spsnor = datanor(spsunnor,'norm',2);
		sps(:,:,i) = spsunnor;

    	cors = musnor*spsnor';
    	matching(:,:,i) = Hungarian(-cors);
		scores(:,i) = diag(cors*matching(:,:,i)');

    	[temp matchInds(:,i)] = max(matching(:,:,i),[],2);
    	

	end
	
	cs = mean(scores,2);

	% Matching based on clustering
	
	case 1
	
	mus = grpRes.m;

	for i = 1:noSubjs
		
		spsunnor = indRes{i}.m;

		spsnor = full(sparse(indRes{i}.clusters,(1:size(indRes{i}.clusters,1))', ... 
					ones(size(indRes{i}.clusters,1),1),size(mus,1),size(indRes{i}.clusters,1)));		
		musnor = full(sparse(grpRes.clusters(pointer{i}),(1:size(grpRes.clusters(pointer{i}),1))', ...
					ones(size(indRes{i}.clusters,1),1),size(mus,1),size(indRes{i}.clusters,1)));

		sps(:,:,i) = spsunnor; 
    	cors = musnor*spsnor';

    	matching(:,:,i) = Hungarian(-cors);

		scores(:,i) = diag((cors*matching(:,:,i)')./ ... 
					(sum(musnor,2)*ones(1,size(musnor,1))+~sum(musnor,2)*ones(1,size(musnor,1))));
    	[temp matchInds(:,i)] = max(matching(:,:,i),[],2); 	

	end

	cs = mean(scores,2);
	
end


