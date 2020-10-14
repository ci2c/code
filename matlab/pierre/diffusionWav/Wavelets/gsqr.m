function [Idxs,DIdxs,Q,R] = gsqr(A, Options)

% function [Idxs DIdxs Q R] = gsqr(A, [Options])
%
% GSQR computes a partial QR decomposition of the matrix A via modified
% Gram-Schmidt orthogonalization.  A rank revealing QR decomposition is a
% factorization
%
%      A*P = | Q11 Q12 | * | R11 R12 |
%                          |  0  R22 |
%
% where P is a permutation, Q = [Q11 Q12] is orthogonal, and R22 is a matrix
% with small L^2 norm.  Under these assumptions, the contribution to the
% matrix product from the term Q12*R22 can be safely ignored (introducing
% a controllable error).
%
% GSQR computes the matrices Q11 and R11 in the RRQR decomposition, which
% yields the approximate factorization
%
%      [A(:,Idxs) A(:,DIdxs)] = [Q11*R11 Q11*R12]
%
% where R12 = Q11'*A(:,DIdxs).
%
% This is a matlab reference implementation of GSQR; its behavior is (almost)
% identical to the C MEX version but it isn't required to be efficient, only
% easy to understand and maintain.
%
% In:
%   A        = Input matrix
%   Options  = A structure specifying algorithm settings.
%
%   (1) Stopping conditions
%
%     StopPrecision   : stop when the l^2 norm of all remaining columns falls
%                       below this value
%     StopN           : specifies the maximum number of iterations
%     StopDensity     : stop when the density of all remaining columns becomes
%                       larger than this. Exception: no column could be picked, in which case returns one column.
%
%   (2) Thresholding
%
%     IPThreshold     : threshold for an inner product to be considered nonzero
%     Threshold       : threshold for the matrix Q
%
%   (3) Other Options
%
%     Reorthogonalize : perform two projections instead of one
%     Quiet           : when true, all output other than error messages is
%                       suppresed
%
%   The default options are as follows:
%
%     Options.StopPrecision      = eps;
%     Options.StopN              = Inf;
%     Options.StopDensity        = 1.0;
%     Options.IPThreshold        = 0.0;
%     Options.Threshold          = 0.0;
%     Options.Reorthogonalize    = true;
%     Options.Quiet              = false;
%     Options.Symmetric          = false;
%
% Out:
%   Idxs     = List of chosen columns, in the order in which they were chosen
%   DIdxs    = List of discarded columns, in arbitrary order
%   Q        = The matrix Q11 in the RRQR decomposition
%   R        = The matrix R11 in the RRQR decomposition
%
% Dependences:
%   none
%
% Version History:
%   jcb        2/2006         cell array version completed; elimanted RI
%                             computation (for now)
%   mm         4/2007         added parameters, fixed a few minor bugs
%

if isempty(A),
    Idxs = [];
    DIdxs = [];
    Q = 0;
    R = 0;
    return;
end

T = cputime;

if ~exist('Options')
    Options = [];
end

if ~isfield(Options, 'StopN')
    Options.StopN = Inf;
end
if ~isfield(Options, 'StopPrecision')
    Options.StopPrecision = eps;
end
if ~isfield(Options, 'StopDensity')
    Options.StopDensity = 1.0;
end
if ~isfield(Options, 'Reorthogonalize')
    Options.Reorthogonalize = true;
end
if ~isfield(Options, 'IPThreshold')
    Options.IPThreshold = 0.0;
end
if ~isfield(Options, 'Threshold')
    Options.Threshold = 0.0;
end
if ~isfield(Options, 'ComputeR')
    Options.ComputeR = true;
end
if ~isfield(Options, 'Quiet')
    Options.Quiet = false;
end

% shortcut variables for options
StopN              = Options.StopN;
StopPrecision      = Options.StopPrecision;
StopDensity        = Options.StopDensity;
Reorthogonalize    = Options.Reorthogonalize;
IPThreshold        = Options.IPThreshold;
Threshold          = Options.Threshold;
Quiet              = Options.Quiet;

ComputeR = nargout > 3;

% setup some basic options
[M N] = size(A);

% initialize the cell arrays for Q, R, and RI
Q = cell(1,N);

if ComputeR
    R = cell(1,N);
else
    R = [];
end

Chosen = zeros(1,N);
Norms = zeros(1,N);
Idxs = zeros(1,N);
NumChosen = 0;

if Reorthogonalize
    NumProjections = 2;
else
    NumProjections = 1;
end

if isfield(Options, 'NumProjections')
    NumProjections = Options.NumProjections;
end

% compute norms
for j=1:N
    Norms(j) = norm(A(:,j));
end

% prepare display
if ~Quiet

    if ~isfield(Options, 'dwtree')
        fprintf('gsqr.m: ');
    end

    fprintf('00000');
end

ips = zeros(N,1);

for j=1:min(StopN, N);
    % from among the remaining columns, choose the one with maximum l^2 norm
    [HeapNorm ChosenColumn] = max(Norms);

    % move the chosen column into the cell array Q and set its norm to -1 to
    % make sure its not chosen again
    Q{j} = sparse(A(:,ChosenColumn));
    Qt{j} = Q{j}';
    Norm(ChosenColumn) = -1;  % make sure we never pick this column again
    ComputedNorm = norm(Q{j});
    localIPThreshold = IPThreshold*ComputedNorm;
    
    % project the chosen column into the orthogonal complement of the column space
    % of Q
    for i=1:NumProjections
        % compute and threshold inner products
        idxs = [];
        count = 0;
        ips = zeros(1,j-1);
        for r=1:(j-1)
%            ip = sum(Q{r}.*Q{j});            
            ip = Qt{r}*Q{j};
%            if abs(ip) > localIPThreshold
                ips(r) = ip;
                Q{j} = Q{j} - ip*Q{r};
                % threshold Q
                Q{j} = Q{j} .* (abs(Q{j}) > Threshold);% Super dangerous
                idxs = [idxs; r];
                count = count+1;
%            end
        end

        if ComputeR
            if isempty(R{j})
                R{j} = sparse(idxs, ones(count, 1), ips(idxs), N, 1, count+1);
            else
                R{j} = R{j} - sparse(idxs, ones(count, 1), ips(idxs), N, 1, count);
            end
        end
    end

    % normalize Q
    ChosenNorm = norm(Q{j});
    if(ChosenNorm < StopPrecision) & (NumChosen>0),
        break;
    end
    Q{j} = Q{j}/ChosenNorm;

    % threshold Q
    %Q{j} = Q{j} .* (abs(Q{j}) > Threshold);    
    
    if issparse(Q{j}) & nnz(Q{j}) > .25*M
        Q{j} = full(Q{j});
    end
    Qt{j} = Q{j}';
    if ComputeR
        R{j}(j) = ChosenNorm;
    end
    if(nnz(Q{j})/M > StopDensity) & (NumChosen>0),
        break;
    end

    % mark column as chosen
    Chosen(ChosenColumn) = true;
    Norms(ChosenColumn) = -1.0;
    NumChosen = NumChosen+1;
    Idxs(NumChosen) = ChosenColumn;

    % update the norms of the overlapping columns

    valididxs = find(Norms > 0.0);

    if length(valididxs > 0)
        ips = A(:,valididxs)'*Q{j};

        for i=find(abs(ips'./Norms(valididxs))> IPThreshold)
            reali = valididxs(i);
            Norms(reali) = sqrt(abs(Norms(reali)^2 - ips(i)^2));
        end
    end
    % display
    if ~Quiet && rand(1,1) < .25
        fprintf('\b\b\b\b\b%05d', j);
    end

end

% truncate list of indicies, find list of columns not chosen
Idxs = Idxs(1:NumChosen);
DIdxs = sort(find(~Chosen));

% convert Q to normal sparse matrix and truncate it
Q = sparse([Q{1:NumChosen}]);

% convert R to normal sparse matrix and reorder it
if ComputeR
    R = sparse([R{1:NumChosen}]);
    R = R(1:NumChosen, :);
end

if ~Quiet
    if isfield(Options, 'dwtree')   % special dwtree mode
        fprintf('\b\b\b\b\b');
    else
        fprintf('\b\b\b\b\bdone (%d fcns chosen, %g secs)\n', NumChosen, cputime-T);
    end
end

if isempty(Q)
    Q = 0;
end

if isempty(R)
    R = 0;
end

return;