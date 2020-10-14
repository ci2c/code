function [count, idxs, dists] = rsearch(pointset, query_pts, radius, metric, opts)

%
% function [idxs, dists] = rsearch(pointset, query_pts, radius, [metric], [opts])
%
% RSEARCH is a wrapper for performing approximate range searchs using either
% brute force or the ANN package of Mount, et al.
%
% In:
%    pointset  : MxN matrix of N points in R^M comprising the data set
%    query_pts : MxL matrix of L query points in R^M.
%    radius    : radius for range search
%    [metric]  : distance function
%    [opts]    : structure containing the following fields:
%                   [DistRestrict]     : N array of cells, the k-th cell contains the indices of the points among which
%                                        the nearest neighbors of point k are searched for.
%                                        If it is only one cell, then it is assumed to contain the *relative* (w.r.t. current point)
%                                        indices of the points among which the nearest neighbors of point k are searched for. Indices out of range
%                                        are automatically clipped.
%                   [Tolerance]        : tolerance in range search
%                   [kNN]              : restrict to at most kNN neighbors. Default: 0 (no limit on nn's). Inf is same as 0 (no limit).
%                   [ReturnDistSquared]: return the distance squared (for Euclidean) distances. Default: 0.
%
% Out:
%    count     : vector specifying the number of neighbors for each query point
%    idxs      : cell array giving the indices of each query points neighbors
%    dists     : cell array giving the distance to each neighbor of  each query point. Not sorted.
%
%
% Example:
%   X = linspace(0,1,100);
%   [count,idxs,dists] = rsearch(X,X,0.2,[],[]);
%   for k = 2:size(X,2)-1;opts.DistRestrict{k}=[k-1,k,k+1];end;opts.DistRestrict{1}=[1,2];opts.DistRestrict{size(X,2)}=[size(X,2)-1,size(X,2)];
%   [count2,idxs2,dists2] = rsearch(X,X,0.2,[],opts);

% SC:
%   JCB:    4/8/06
%   MM:     11/16/07
%   MM:     1/18/08
%
% James C Bremer,
% Mauro Maggioni
% (c) Duke University, 2006
%
%

TOLERANCE = 1e-7;

if nargin<5,
    opts = [];
end;

if ~isfield(opts,'DistRestrict'),
    opts.DistRestrict = {};
end;
if ~isfield(opts,'Tolerance'),
    opts.tolerance = TOLERANCE;
end;
if ~isfield(opts,'kNN'),
    opts.kNN = 0;
end;
if opts.kNN == Inf,
    opts.kNN = 0;
end;
if ~isfield(opts,'ReturnDistSquared'),
    opts.ReturnDistSquared = 0;
end;

if (exist('metric') & ~isempty(metric)) | exist('ANNsearch')~=3
    % ANNsearch either doesn't exist or can't be used
    if (~exist('metric')) | (isempty(metric)),
        metric = @(x,y) norm(x-y);
    end
    if isempty(query_pts),
        query_pts = pointset;
    end;

    [M, N] = size(pointset);
    L = size(query_pts,2);

    count = zeros(1, L);
    idxs  = cell(1, L);
    dists = cell(1, L);

    alldists = zeros(N, 1);

    % Go brute force
    for j=1:L
        for i=N:-1:1,
            alldists(i) = metric(query_pts(:,j), pointset(:,i));
        end;
        idxs{j}  = find(alldists < radius);
        dists{j} = alldists(idxs{j});
        count(j) = length(idxs{j});
        %[alldists ordering] = sort(alldists, 'ascend');
        %idxs(:,j) = ordering(1:NN, 1);
        %dists(:,j) = alldists(1:NN, 1);
    end;
else
    if isempty(opts.DistRestrict),
        % Use Annrsearch
        if isempty(query_pts),
            query_pts = pointset;
        end;
        % Call ANNsearch
        [count, idxs, dists] = ANNrsearch(pointset, query_pts, opts.kNN, radius.^2, opts.tolerance);
        if ~opts.ReturnDistSquared,
            % Compute the sqrt of the distances
            for j=1:length(dists)
                dists{j} = sqrt(dists{j});
            end;
        end;
    else
        N = size(pointset,2);
        count = zeros(N,1);
        for k = 1:N,       
            if (iscell(opts.DistRestrict)) & (length(opts.DistRestrict)==N),
                % A NN list is provided for each point
                lCurIdxs = opts.DistRestrict{k};
            else
                % Only one NN list, interpret as relative to the current point
                lCurIdxs = k+opts.DistRestrict;
                % Clip indices out of range
                lCurIdxs(find((lCurIdxs<1) | (lCurIdxs>N))) = [];
            end;
            % Find the neighbors
            [count(k),idxs_tmp,dists_tmp] = ANNrsearch( pointset(:,lCurIdxs), pointset(:,k), 0, radius.^2, opts.tolerance );            
            idxs{k} = lCurIdxs(idxs_tmp{1});            
            if ~opts.ReturnDistSquared,
                % Compute the sqrt of the distances
                dists{k} = sqrt(dists_tmp{1});
            else
                dists{k} = dists_tmp{1};
            end;
        end;
    end;
end;
