function NbFibres = getVolConnectMatrix(label_vol, fibers_path, outdir, outpref)
% usage : NbFibres = getVolConnectMatrix(LABEL_vol, FIBERS, outdir, outpref)
%
% INPUT :
% -------
%    LABEL_vol         : Path to segmented volume (in LAS nii format)
%
%    FIBERS            : Path to fibers
%
%    outdir            : Path to the output directory to store the fiber
%                        file passing through the LABEL_vol
%                            
%    outpref           : Prefix of the output files
%
% OUTPUT :
% --------
%    NbFibres        : Number of fibers passing through LABEL_vol
%
% Matthieu Vanhoutte @ CHRU Lille, May 2014

if nargin ~= 4
    error('invalid usage');
end

% Load data
V = spm_vol(label_vol);

% if logical(exist(fullfile(outdir,'fibers.mat'))
%     fibers = load(fullfile(outdir,'fibers.mat'));
%     fibers = fibers.fibers;
% else
    % Load fibers
    disp('mrtrix fibers');
    fibers = f_readFiber_tck(fibers_path);
%     save(fullfile(outdir,'fibers.mat'),'fibers');
% end

LOI = [1];

nFibers = fibers.nFiberNr;

FibersCoord = cat(1, fibers.fiber.xyzFiberCoord)';
FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
FibersCoord = spm_pinv(V.mat) * FibersCoord;
FibersID = cat(1, fibers.fiber.id);

T = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
T(ismember(T, LOI) == 0) = 0;
FibersID(T==0) = [];
T(T==0) = [];

clear FibersCoord;

UU = unique(FibersID(T == LOI(1)));
ConnectFib = sparse(double(UU), 1, ones(size(UU)), double(nFibers), 1);
save(fullfile(outdir, [outpref '_ConnectFib.mat']),'ConnectFib');


% Back up the extracted ROI fibers passing through the LABEL_vol (.tck,.vtk) I
fibers.fiber = fibers.fiber(logical(ConnectFib));

if isempty(fibers.fiber)
    NbFibres = 0;
else
    fibers.nFiberNr = length(fibers.fiber);
    NbFibres = fibers.nFiberNr;

    % Color fibers
    fibersColor = color_tracts(fibers);
    save_tract_tck(fibersColor,fullfile(outdir, [outpref '_Color.tck']));
    % save_tract_vtk(fibersColor,fullfile(outdir, [outpref '_Color.vtk']));
end