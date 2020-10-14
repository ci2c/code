function getHypothConnectMatrix(label_vol, ConnectFibHypoth, fibers_path, HypothalamicLOI, outdir, SeqDti, LOI, thresh)
% usage : getHypothConnectMatrix(label_vol, ConnectFibHypoth, fibers_path, HypothalamicLOI, outdir, SeqDti, [LOI, thresh])
%
% INPUT :
% -------
%    LABEL_vol         : Path to segmented volume (in LAS nii format)
%
%    ConnectFibHypoth  :  sparse matrix of connected fibers of Hypothalmic
%    ROIs (4) -> output of getVolumeConnectMatrix.m
%
%    FIBERS            : Path to fibers
%
%    HypothalamicLOI   : Path to text file containing ID and names of the hypothalamic labels of interest
%
%    outdir            : Path to the output directory to store the fiber
%                        file passing through the LABEL_vol and
%                        Hypothalamic ROIs
%
%    SeqDti            : Number of dti
%
%    LOI               : Path to text file containing ID and names of the labels of interest (option)
%
%    THRESHOLD         : Minimum fiber length required (default : 0) (works
%    only with mrtrix fibers)
%
% Matthieu Vanhoutte @ CHRU Lille, Sep. 2016

if nargin ~= 2 && nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin < 3
    LOI = [];
end

if nargin < 4
    thresh = 0;
end

Connectome.threshold = thresh;

% Load data
V = spm_vol(label_vol);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);

% Load fibers
if strfind(fibers_path, '.fib')
    disp('MedINRIA fibers');
    fibers = f_readFiber_vtk_bin(fibers_path);
    fibers = tracts_flip_x(tracts_flip_y(fibers));
else
    if strfind(fibers_path, 'FTR.mat')
        disp('dti tool fibers');
        fibers = FTRtoTracts(fibers_path);
    else
        if strfind(fibers_path, '.tck')
            disp('mrtrix fibers');
            fibers = f_readFiber_tck(fibers_path, thresh);
        else
            error('unrecognized fibers type');
        end
    end
end

% Load LOI and hypothalamic ROIs
if isempty(LOI)
    LOI = unique(labels);
    Ts = length(LOI);
    Names = [repmat('LOI', Ts, 1), num2str((1:Ts)', '%.4d')];
    clear Ts;
else
    fid = fopen(LOI, 'r');
    T = textscan(fid, '%d %s');
    LOI = T{1};
    Names = char(T{2});
    fclose(fid);
    clear T;
end

fid = fopen(HypothalamicLOIs, 'r');
T = textscan(fid, '%d %s');
NamesHypoth = char(T{2});
fclose(fid);
clear T;

% Compute number of fibers and size of LOIs
nFibers = fibers.nFiberNr;
nROI = length(LOI);
nROIhypoth = length(HypothalamicLOI);

clear labels XYZ;

FibersCoord = cat(1, fibers.fiber.xyzFiberCoord)';
FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
FibersCoord = spm_pinv(V.mat) * FibersCoord;
FibersID = cat(1, fibers.fiber.id);

T = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
T(ismember(T, LOI) == 0) = 0;
FibersID(T==0) = [];
T(T==0) = [];

clear FibersCoord;

% Preallocate memory
Connectome.region(length(LOI)).name = NaN;
Connectome.region(length(LOI)).label = NaN;
Connectome.region(length(LOI)).selected = NaN;

tic;
for i = 1 : nROI
    disp(['Processing step ', num2str(i, '%.3d'), ' out of ', num2str(length(LOI)), ' | Time : ', num2str(toc)]);
    Connectome.region(i).name = Names(i, :);
    Connectome.region(i).label = LOI(i);
    
    UU = unique(FibersID(T == LOI(i)));
    Connectome.region(i).selected = sparse(double(UU), 1, ones(size(UU)), double(nFibers), 1);
end

% Determine number of fibers passing through combination of 2 ROIs (hypothalamic-FS Segmentation) and save tracks
for i = 1 : nROIhypoth
    tic;
    for j = 1 : nROI
        InterConnectome = (ConnectFibHypoth.region(i).selected&Connectome.region(j).selected);
        Tmp.fiber = fibers.fiber(InterConnectome);

        if isempty(Tmp.fiber)
            NbFibres = 0;
        else
            Tmp.nFiberNr = length(Tmp.fiber);
            NbFibres = Tmp.nFiberNr;
            % Color fibers
            fibersColor = color_tracts(Tmp);
            save_tract_tck(Tmp,fullfile(outdir, [NamesHypoth{i} '_2_' Names{j} '.tck']));
            % save_tract_vtk(Tmp,fullfile(outdir, [outpref '_Color.vtk']));
        end   
        fid = fopen(fullfile(outdir, [ 'NbFibres_' SeqDti '.txt']), 'a');
        fprintf(fid, '%s_2_%s %d\n', NamesHypoth{i}, Names{j}, NbFibres);
        fclose(fid);  
    end
    disp(['2 - Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROIhypoth), ' | Time : ', num2str(toc)]);
end
