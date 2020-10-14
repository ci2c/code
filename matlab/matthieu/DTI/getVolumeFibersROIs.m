function Connectome = getVolumeFibersROIs(label_vol, fibers_path, LOI, thresh)
% usage : Connectome = getVolumeFibersROIs(label_vol, fibers_path, [LOI, thresh])
%
% INPUT :
% -------
%    label_vol         : Path to segmented volume (in RAS nii format)
%
%    fibers_path       : Path to fibers directory
%
%    LOI               : Path to text file containing ID and names of the labels of interest (option)
%
%    thresh            : Minimum fiber length required (default : 0) (works
%                       only with mrtrix fibers)
%
% OUTPUT :
% --------
%    Connectome        : Connectome structure
%
% Pierre Besson @ CHRU Lille, Nov. 2011
% Matthieu Vanhoutte @ CHRU Lille, Dec. 2014

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

% Load labels data
V = spm_vol(label_vol);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);

if isempty(LOI)
    LOI = unique(labels);
    Ts = length(LOI);
    Names = [repmat('LOI', Ts, 1), num2str((1:Ts)', '%.4d')];
    clear Ts;
else
    fid = fopen(LOI, 'r');
    T = textscan(fid, '%d %s');
    LOI = T{1};
    Names = T{2};
    fclose(fid);
    clear T;
end

nROI = length(LOI);

clear labels XYZ;

% Preallocate memory
Connectome.region(length(LOI)).name = NaN;
Connectome.region(length(LOI)).label = NaN;
Connectome.region(length(LOI)).selected = NaN;

% Find split fibers files
F0 = rdir(fullfile(fibers_path,'whole_brain_2_1500000_part*.tck'));

% Compute loop on split fibers files

TT{nROI} = [];

for k=1:length(F0)
    % Load fibers
    disp('mrtrix fibers');
    disp(k);
    fibers = f_readFiber_tck(F0(k).name, thresh);
    nFibers= fibers.nFiberNr;

    FibersCoord = cat(1, fibers.fiber.xyzFiberCoord)';
    FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
    FibersCoord = spm_pinv(V.mat) * FibersCoord;
    FibersID = cat(1, fibers.fiber.id);

    T = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
    T(ismember(T, LOI) == 0) = 0;
    FibersID(T==0) = [];
    T(T==0) = [];

    clear FibersCoord;

    for i = 1 : nROI
       UU{i} = unique(FibersID(T == LOI(i)));
       TT{i} = [ TT{i} ; sparse(double(UU{i}), 1, ones(size(UU{i})), double(nFibers), 1) ];
    end
end

for i = 1 : nROI
    Connectome.region(i).name = Names{i};
    Connectome.region(i).label = LOI(i);
    Connectome.region(i).selected = TT{i};
end