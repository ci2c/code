function NbFibres = getInterConnectFib(pConnectFib1, pConnectFib2, fibers_path, outdir, outpref)
% usage : NbFibres = getInterConnectFib(pConnectFib1, pConnectFib2, fibers_path, outdir, outpref)
%
% INPUT :
% -------
%    pConnectFib1       : path to sparse matrix of connected fibers of ROI1
%
%    pConnectFib2       : path to sparse matrix of connected fibers of ROI2
%
%    fibers_path       : Path to fibers
%
%    outdir            : Path to the output directory to store the fiber
%                        file passing through ROI1 and ROI2
%                            
%    outpref           : Prefix of the output files
%
% OUTPUT :
% --------
%    NbFibres        : Number of fibers passing through ROI1 and ROI2
%
% Matthieu Vanhoutte @ CHRU Lille, May 2014

if nargin ~= 5
    error('invalid usage');
end

% Load fibers and sparse matrix
% if logical(exist(fullfile(outdir,'fibers.mat')))
%     fibers = load(fullfile(outdir,'fibers.mat'));
%     fibers = fibers.fibers;
% else
    % Load fibers
    disp('mrtrix fibers');
    fibers = f_readFiber_tck(fibers_path);
%     save(fullfile(outdir,'fibers.mat'),'fibers');
% end

ConnectFib1 = load(pConnectFib1);
ConnectFib1 = ConnectFib1.ConnectFib;
ConnectFib2 = load(pConnectFib2);
ConnectFib2 = ConnectFib2.ConnectFib;

% Back up the extracted ROI fibers passing through ROI1 and ROI2 I
fibers.fiber = fibers.fiber((ConnectFib1&ConnectFib2));

if isempty(fibers.fiber)
    NbFibres = 0;
else
    fibers.nFiberNr = length(fibers.fiber);
    NbFibres = fibers.nFiberNr;

    % Color fibers
    fibersColor = color_tracts(fibers);
    save_tract_tck(fibersColor,fullfile(outdir, [outpref '_Color.tck']));
end