function [idxs, dists] = nnsearch(pointset, query_pts, NN, metric,opts)

%
% function [idxs, dists] = nnsearch(pointset, query_pts, NN, metric,opts)
%
% NNSEARCH is a wrapper for performing approximate nearest neighbor
% searches using either brute force or the ANN package of Mount, et al.
%
% In:
%    pointset  : MxN matrix of N points in R^M comprising the data set
%    query_pts : MxL matrix of L query points in R^M
%    NN        : number of nearest neighbors to find
%    metric    : (optional) distance function
%    [opts]    : structure containing the following fields:
%                   [DistRestrict]     : N array of cells, the k-th cell contains the indices of the points among which
%                                        the nearest neighbors of point k are searched for.
%                                        If it is only one cell, then it is assumed to contain the *relative* (w.r.t. current point)
%                                        indices of the points among which the nearest neighbors of point k are searched for. Indices out of range
%                                        are automatically clipped.
%                   [Tolerance]        : tolerance in range search
%                   [ReturnDistSquared]: return the distance squared (for Euclidean) distances. Default: 0.
%                   [ReturnAsArrays]   : returns <idxs> and <dists> as arrays rather than as cell arrays. Default: 0.
%
% Out:
%    idxs      : L cell array (or L times NN array if opts.ReturnAsArrays==1) of neighbor indices
%    dists     : L cell array (or L times NN array if opts.ReturnAsArrays==1) of distances of the neighbors
%

% SC:
%   MM:     1/21/2008 : modified, added extra options
%   MM:     3/10/2008 : added options
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
    opts.Tolerance = TOLERANCE;
end;
if ~isfield(opts,'ReturnDistSquared'),
    opts.ReturnDistSquared = 0;
end;
if ~isfield(opts,'ReturnAsArrays'),
    opts.ReturnAsArrays = 0;
end;

lUseBruteForceNN = false;

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

    if ~opts.ReturnAsArrays,
        idxs  = cell(1, L);
        if nargout>1,
            dists = cell(1, L);
        end;
    else
        idxs = zeros(L,NN,'uint32');
        if nargout>1,
            dists = zeros(L,NN,'double');
        end;
    end;

    alldists = zeros(N, 1);

    % for each query point
    for j=1:L
        for i=1:N
            alldists(i) = metric(query_pts(:,j), pointset(:,i));
        end

        [alldists ordering] = sort(alldists, 'ascend');

        if ~opts.ReturnAsArrays,
            idxs{j} = ordering(1:NN, 1);
            if nargout>1,
                dists{j} = alldists(1:NN, 1);
            end;
        else
            idxs(j,:) = ordering(1:NN, 1);
            if nargout>1,
                dists(j,:) = alldists(1:NN,1);
            end;
        end;
    end
else
    if isempty(opts.DistRestrict),
        % Call ANNsearch
        if isempty(query_pts),
            query_pts = pointset;
        end;
        if nargout>1,
            [idxs, dists] = ANNsearch(pointset, query_pts, NN, opts.Tolerance);
            dists = dists';
            if ~opts.ReturnDistSquared,
                % Compute the sqrt of the distances
                dists = sqrt(dists);
            end;
        else
            [idxs] = ANNsearch(pointset, query_pts, NN, opts.Tolerance);
        end;
        idxs  = idxs';
        if ~opts.ReturnAsArrays,
            idxs  = mat2cell(idxs,ones(size(idxs,1),1),size(idxs,2));
            if nargout>1,
                dists = mat2cell(dists,ones(size(dists,1),1),size(dists,2));
            end
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
            if nargout>1,
                [idxs_tmp,dists_tmp] = ANNsearch( pointset(:,lCurIdxs), pointset(:,k), NN, opts.Tolerance );
                if ~opts.ReturnDistSquared,
                    % Compute the sqrt of the distances
                    dists_tmp = sqrt(dists_tmp);
                else
                    dists_tmp = dists_tmp;
                end;
            else
                [idxs_tmp] = ANNsearch( pointset(:,lCurIdxs), pointset(:,k), NN, opts.Tolerance );
            end;
            if ~opts.ReturnAsArrays,
                idxs{k} = lCurIdxs(idxs_tmp);
                dists{k} = dists_tmp;
            else
                idxs(k,:) = lCurIdxs(idxs_tmp);
                if argout>2,
                    dists(k,:) = dists_tmp;
                end;
            end;
        end;
    end;
end

return;