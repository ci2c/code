function Tree = DWPTree (T, Levels, Precision, Options)

%
% function Tree = DWPTree (T, Levels, Precision, Options)
%
% DWPTREE generates a "diffusion wavelet packet tree" for a given diffusion
% operator.  A diffusion wavelet packet tree stores the bases and operators
% associated with the diffusion wavelet packet transform.
%
% DWPTree returns a cell array represented a tree of subspaces.  Each node
% in the cell array represents a single subspace.
%
% IN:
%    Diffusion = diffusion operator represented in the delta basis
%    Levels    = maximum number of levels for the tree
%    Precision = precision for the calculations
%    Options   = a structure for passing algorithm options; the following
%                fields are recognized:
%
%      StopFcns:    don't split spaces with fewer functions than this
%      Wavelets:    when true, compute the wavelets. Default is true.
%      WaveletPackets: when true, compute wavelets and wavelet packets. Default is false.
%      ExtendBases: when true, DWPTree compute representations of each basis
%                   with respect to the delta basis
%      GS:          string with the name of the grahm-schmidt routine to use;
%                   the gs function must have the same syntax as gsqr.m
%      GSOptions:   structure containing options to pass to gsqr
%      SplitFcn:    handle to a user specified function for deciding where to
%                   split the wavelet packet spaces
%      OpThreshold: Threshold for the entries of Op at each level
%      Symm       : Whether T is symmetric or not. Default: no.
%      ScalePower : Power of the operator to be taken at every scale. Can be only 1 or 2 (for now). Default: 2.
%
% OUT:
%    Tree      = a cell array representing a diffusion wavelet packet tree
%
% Dependences:
%    gsqr.m, ljout.m
%
% Version History:
%   jcb        2/2006         DiffusionWaveletTree.m renamed and modified to use
%                             gsqr.m; split into DWTree.m and DWPTree.m; output
%                             format modified
%   mm         4/2007         Added a few options, bug fixes, nonsymmetric case...
%   mm         5/2007         Added a few more options
%
%
% (c) Copyright Yale University, 2006, James C Bremer Jr.
% (c) Copyright Duke University, 2007, Mauro Maggioni
%
% EXAMPLES:
%   T=MakeCircleDiffusion(256);
%   Tree = DWPTree (T, 12, 1e-4, struct('Wavelets',false,'OpThreshold',1e-3,'GSOptions',struct('StopDensity',0.5,'Threshold',1e-3)));
%   figure;plot(Tree{4,1}.ExtBasis(:,10))
%   figure;plot(Tree{4,1}.ExtBasis(:,10));hold on;Tp=T^15;plot(Tp(:,Tree{4,1}.ExtIdxs(10)),'r');
%

if (nargin<4) | (~exist('Options'))
    Options = [];
end

if ~isfield(Options, 'ExtendBases')
    Options.ExtendBases = true;
end

if ~isfield(Options, 'StopFcns')
    Options.StopFcns = 3;
end

if ~isfield(Options, 'GS')
    %Options.GS       = 'gsqr';
    Options.GS       = @gsqr;
end

if ~isfield(Options, 'GSOptions')
    Options.GSOptions  = [];
end
if ~isfield(Options, 'Wavelets')
    Options.Wavelets = true;
end
if ~isfield(Options, 'WaveletPackets')
    Options.WaveletPackets = false;
end
if ~isfield(Options, 'SplitFcn')
    Options.SplitFcn = @DefaultSplitFcn;
end
if ~isfield(Options, 'OpThreshold')
    Options.OpThreshold = Precision;
end;
if ~isfield(Options, 'Symm')
    Options.Symm = false;
end
if ~isfield(Options, 'ScalePower')
    Options.ScalePower = 2;
end



ExtendBases = Options.ExtendBases;
StopFcns    = Options.StopFcns;
GS          = Options.GS;
SplitFcn    = Options.SplitFcn;
GSOptions   = Options.GSOptions;

% process input
N = size(T,1);

%{
% initialize the tree structure
%}

MaxIndex = 2^floor(Levels/2);    % the maximum possible index of any node in the tree
Tree = cell(Levels, MaxIndex);

%{
% Perform the necessary computations, one level at a time
%}
for j=1:Levels

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Split the node V_{j-1} into V_{j} and W_{j}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if size(T,2) <= StopFcns   % well, only if its worth it
        break;
    end;

    % intialize the tree node corresponding to V_{j}
    Tree{j,1} = struct('Level', j, 'Index',1, 'Basis', [], 'Op', [], ...
        'T', [], 'ExtBasis', [], ...
        'Freq', [(Precision^(2^(-j+1))) 1.0]);

    % print out the name of the node and its index in the tree structure in
    % nice format
    ljout(sprintf('%s', DWNodeName(j,1)), 15);

    %{
   % Perform grahm-schmidt on the columns of the "current" T operator
    %}
    fprintf('gsqr: '); TIME = cputime;

    % QROptions specifies parameters for the grahm-schmidt process
    QROptions               = GSOptions;
    QROptions.StopPrecision = Precision;
    QROptions.dwtree        = 1;  % special formatting for gsqr.m output

    % call gs routine
    [Idxs DIdxs Tree{j,1}.Basis R11] = feval(GS, T, QROptions);
    Tree{j,1}.Idxs = Idxs;
    if j>1,
        Tree{j,1}.ExtIdxs = Tree{j-1,1}.ExtIdxs(Idxs);
    else
        Tree{j,1}.ExtIdxs = Idxs;
    end;
    Tree{j,1}.Op = [R11 Tree{j,1}.Basis'*T(:,DIdxs)];
    [zTemp,zIdxs] = sort([Idxs,DIdxs]);                                     %MM: Compute the inverse permutation
    lPI=sparse(zIdxs,1:length(zIdxs),1,length(zIdxs),length(zIdxs));        %MM: bug fixed.
    Tree{j,1}.Op = Tree{j,1}.Op*lPI;                                        %MM: for debug may want: Tree{j,1}.Idxs = Idxs;Tree{j,1}.DIdxs = DIdxs;Tree{j,1}.PIi = lPIi;
    if Options.OpThreshold>Precision
        Tree{j,1}.Op = Tree{j,1}.Op.*(abs(Tree{j,1}.Op)>Options.OpThreshold);
    end;
    clear('R11');

    N = size(T,2);             % number of functions at previous level
    K = size(Tree{j,1}.Basis,2); % number of functions at this level
    ljout(sprintf('%4d fcns, %4.2f secs', K, cputime-TIME), 25);

    % compute representations of the dyadic powers T, T^2, T^4 in our new basis
    % this is necessary for a wavelet packet transform because we will need those
    % T's further down the tree
    fprintf('T reps: '); TIME = cputime;
    Tree{j,1}.T    = cell(j,1);
    Tree{j,1}.T{1} = Tree{j,1}.Basis'*T*Tree{j,1}.Basis;     % representation of T w.r.t. Sigma_1
    if false, %MM
        for r=1:j-1
            Tree{j,1}.T{r+1} = Tree{j,1}.Basis'*Tree{j-1,1}.T{r}*Tree{j,1}.Basis;     % representation of T w.r.t. Sigma_1
        end
        ljout(sprintf('%4.2f secs', cputime-TIME), 14);
    end;

    %{
   % square the operator T for the next level
    %}
    fprintf('T^2: '); TIME=cputime;
    if Options.ScalePower == 2,
        if Options.Symm,
            T = Tree{j,1}.Op*Tree{j,1}.Op';            % Compute and store T^2 w.r.t. the latest bass
        else
            try
            T = (Tree{j,1}.Op*Tree{j,1}.Basis)^2;      % Compute and store T^2 on the new basis, general (non-symmetric) case, but less precise in the symmetric case
            catch
                fprintf('Ops!');
            end;
        end;
    else            % TODO: is there a better way of computing the following in the symmetric case?
        T = (Tree{j,1}.Op*Tree{j,1}.Basis);      % Compute and store T on the new basis, general (non-symmetric) case, but less precise in the symmetric case
    end;
    ljout(sprintf('%4.2f secs', cputime-TIME), 14);

    fprintf('freq: [%g %g]', Tree{j,1}.Freq);
    fprintf('\n');

    % compute "extended bases" --- representations of the bases at this level
    % in terms of the delta basis
    if ExtendBases
        if j==1
            Tree{j,1}.ExtBasis = Tree{j,1}.Basis;
            
        else
            Tree{j,1}.ExtBasis = Tree{j-1,1}.ExtBasis*Tree{j,1}.Basis;
        end
    end

    % initialize the node for the wavelet space W_j
    % intialize the tree node corresponding to V_{j}
    Tree{j,2} = struct('Level', j, 'Index', 2, 'Basis', [], 'Op', [], ...
        'T', [], 'ExtBasis', [], ...
        'Freq', []);

    if j==1
        Tree{j,2}.Freq   = [0 Tree{j,1}.Freq(1)];
    else
        Tree{j,2}.Freq   = [Tree{j-1,2}.Freq(2) Tree{j,1}.Freq(1)];
    end

    % Compute the wavelets
    if (Options.Wavelets) | (Options.WaveletPackets),
        % print out node name and position in tree
        ljout(sprintf('%s', DWNodeName(j,2)), 15);

        % QR options specifies the options for gsqr.m
        QROptions        = GSOptions;
        QROptions.StopN  = N-K; % choose the "right" number of columns
        QROptions.dwtree = 1;   % forces special formatting for gsqr.m output

        % Gram-Schmidt on the columns of I-Q*Q' in order to choose basis for the wavelet space
        fprintf('gsqr: '); TIME = cputime;
        W = speye(N) - Tree{j,1}.Basis*Tree{j,1}.Basis';
        [Idxs DIdxs Tree{j,2}.Basis] = feval(GS, W, QROptions);
        Tree{j,2}.Idxs = Idxs;
        if j>1,
            Tree{j,2}.ExtIdxs = Tree{j-1,1}.ExtIdxs(Idxs);
        end;

        ljout(sprintf('%4d fcns, %4.2f secs', N-K, cputime-TIME), 25);

        % compute T representations for the wavelet space as well
        if false, %MM
            fprintf('T reps: '); TIME = cputime;
            for r=1:j-1
                Tree{j,2}.T{r} = Tree{j,2}.Basis'*Tree{j-1,1}.T{r}*Tree{j,2}.Basis;     % representation of T w.r.t. Sigma_1
            end
            ljout(sprintf('%4.2f secs', cputime-TIME), 19);
        end;

        % we don't have to square T ... just output blank space
        ljout('', 14);

        fprintf('freq: [%g %g]', Tree{j,2}.Freq);
        fprintf('\n');
        % compute "extended bases" --- representations of the bases at this level
        % in terms of the delta basis
        if ExtendBases
            if j==1
                Tree{j,2}.ExtBasis = Tree{j,2}.Basis;
            else
                Tree{j,2}.ExtBasis = Tree{j-1,1}.ExtBasis*Tree{j,2}.Basis;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % split any wavelet nodes at the preceeding level
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Options.WaveletPackets,
        for node = 2: 2^ceil((j-2)/2)

            if ~isempty(Tree{j-1,node}) && length(Tree{j-1,node}.T) > 0
                N = size(Tree{j-1,node}.T{1}, 2);

                % check to see if the node is worth splitting
                if N > StopFcns

                    % node is the index of the parent node at the preceeding level
                    % LeftNode is the index of its left child
                    % RightNode is the index of its right child
                    LeftNode = 2*node-1;
                    RightNode = 2*node;

                    % determine what precision we should use for splitting the function
                    %SplitFreq = SplitFcn(Tree{j-1,node}, Precision);
                    SplitFreq = feval(SplitFcn, Tree{j-1,node}, Precision);

                    Tree{j,LeftNode} = struct('Level', j, 'Index', LeftNode, 'Basis', [], 'Op', [], ...
                        'T', [], 'ExtBasis', [], 'Freq', []);

                    Tree{j,RightNode} = struct('Level', j, 'Index', RightNode, 'Basis', [], 'Op', [], ...
                        'T', [], 'ExtBasis', [], 'Freq', []);


                    Tree{j, RightNode}.Freq = [Tree{j-1, node}.Freq(1) SplitFreq];
                    Tree{j, LeftNode}.Freq = [SplitFreq Tree{j-1, node}.Freq(2)];

                    % QROptions = parameters for gsqr.m
                    QROptions = GSOptions;
                    % TWPower adjusts for the fact that we are processing T^(2^TPower)
                    TPower = (2)^(length(Tree{j-1,node}.T)-1);
                    QROptions.StopPrecision    = SplitFreq^(TPower);
                    QROptions.dwtree           = 1;

                    % perform grahm-schmidt on the columns of the proper operator T
                    ljout(sprintf('%s', DWNodeName(j,LeftNode)), 15);

                    fprintf('gsqr: ');TIME = cputime;
                    %[Idxs DIdxs Tree{j, LeftNode}.Basis Tree{j,LeftNode}.Op] = gsqr(Tree{j-1,node}.T{1}, QROptions);
                    [Idxs DIdxs Tree{j, LeftNode}.Basis] = feval(GS,Tree{j-1,node}.T{1}, QROptions);
                    Tree{j,LeftNode}.Idxs = Idxs;
                    if j>1,
                        Tree{j,LeftNode}.ExtIdxs = Tree{j-1,1}.ExtIdxs(Idxs);
                    end;

                    K = size(Tree{j,LeftNode}.Basis,2);
                    ljout(sprintf('%4d fcns, %4.2f secs', K, cputime-TIME), 25);

                    % compute T reps
                    fprintf('T reps: '); TIME = cputime;
                    Tree{j,LeftNode}.T = cell(length(Tree{j-1,node}.T)-1,1);

                    for r=1:length(Tree{j-1,node}.T)-1
                        Tree{j,LeftNode}.T{r} = Tree{j,LeftNode}.Basis'*Tree{j-1,node}.T{r+1}*Tree{j,LeftNode}.Basis;
                    end

                    ljout(sprintf('%4.2f secs', cputime-TIME), 19);

                    % we don't have to square T ... just output blank space
                    ljout('', 14);
                    fprintf('freq: [%g %g]', Tree{j,LeftNode}.Freq);
                    fprintf('\n');

                    QROptions = GSOptions;
                    QROptions.StopN            = N-K;
                    QROptions.dwtree           = 1;

                    ljout(sprintf('%s', DWNodeName(j,RightNode)),15);
                    fprintf('gsqr: ');TIME = cputime;
                    W = speye(N) - Tree{j, LeftNode}.Basis*Tree{j, LeftNode}.Basis';
                    QROptions2.StopN = N-K;

                    [Idxs DIdxs Tree{j, RightNode}.Basis] = feval(GS, W, QROptions);
                    Tree{j,RightNode}.Idxs = Idxs;
                    if j>1,
                        Tree{j,RightNode}.ExtIdxs = Tree{j-1,1}.ExtIdxs(Idxs);
                    end;

                    ljout(sprintf('%4d fcns, %4.2f secs', K, cputime-TIME), 25);

                    % compute T reps
                    fprintf('T reps: '); TIME = cputime;


                    if ~isempty(Tree{j,RightNode}.Basis)
                        Tree{j,RightNode}.T = cell(length(Tree{j-1,node}.T)-1,1);
                        for r=1:length(Tree{j-1,node}.T)-1
                            Tree{j,RightNode}.T{r} = Tree{j,RightNode}.Basis'*Tree{j-1,node}.T{r+1}*Tree{j,RightNode}.Basis;
                        end
                    else
                        Tree{j,RightNode}.T = {};
                    end

                    ljout(sprintf('%4.2f secs', cputime-TIME), 19);
                    ljout('', 14);
                    fprintf('freq: [%g %g]', Tree{j,LeftNode}.Freq);


                    if ExtendBases
                        Tree{j,LeftNode}.ExtBasis = Tree{j-1,node}.ExtBasis*Tree{j,LeftNode}.Basis;
                        Tree{j,RightNode}.ExtBasis = Tree{j-1,node}.ExtBasis*Tree{j,RightNode}.Basis;
                    end

                    fprintf('\n');

                end
            end
        end;
    end;
end

Tree = Tree(1:(j-1),:);                 %MM

return;


function SplitFreq = DefaultSplitFcn(Node, Precision)
% function [SplitFreq NFcns] = DefaultSplitFcn(Node, Precision)
%
% Averages the endpoints of the approximate frequency range of the node
% Node.
%
% In:
%    Node       = Node to split
%    Precision  = Precision of the process
% Out:
%    SplitFreq  = Frequency value to split at.
%

SplitFreq = sqrt(Node.Freq(1)*Node.Freq(2));


return;
