function Connectome = DTI_GetMNIConnectMatrix(label_vol, fibers_path, resLabel, LOI, thresh)
% usage : CONNECTOME = DTI_GetMNIConnectMatrix(label_vol, fibers_path, resLabel, [LOI, thresh])
%
% INPUT :
% -------
%    LABEL_vol         : Path to segmented volume (in MNI RAS nii format)
%
%    FIBERS            : Path to fibers
%
%    resLabel          : resolution of label voxels (ex: [1 1 1])
%
%    LOI               : Path to text file containing ID and names of the labels of interest (option)
%
%    THRESHOLD         : Minimum fiber length required (default : 0) (works
%    only with mrtrix fibers)
%
% OUTPUT :
% --------
%    CONNECTOME        : Connectome structure
%
% Renaud Lopes @ CHRU Lille, Aug. 2016

if nargin ~= 3 && nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

if nargin < 4
    LOI = [];
end

if nargin < 5
    thresh = 0;
end

Connectome.threshold = thresh;

% Load data
V = spm_vol(label_vol);
[labels, XYZ] = spm_read_vols(V);
labels     = round(labels);

% Load fibers
if strfind(fibers_path, '.mat')
    disp('matlab fibers');
    load(fibers_path);
    % threshold
    keep=[];
    for k =1:length(fibmni.fiber)
        if fibmni.fiber(k).length>thresh
            keep=[keep k];
        end
    end
    fibmni.fiberT = fibmni.fiber(keep);
    fibmni.nFiberNrT = length(keep);
    fibmni.thresh = thresh;
else
    error('unrecognized fibers type');
end


if ~exist(LOI,'file')
    LOI = unique(labels);
    Ts = length(LOI);
    Names = [repmat('LOI', Ts, 1), num2str((1:Ts)', '%.4d')];
    clear Ts;
else
    fid = fopen(LOI, 'r');
    T = textscan(fid, '%d %s');
    LOI = T{1};
    Names = char(T{2});
    Names = Names(:,2:end);
    fclose(fid);
    clear T;
end

nFibers = fibmni.nFiberNrT;
nROI    = length(LOI);

clear XYZ;

FibersCoord = cat(1, fibmni.fiberT.xyzFiberCoord)';
FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
FibersCoord = spm_pinv(V.mat) * FibersCoord;
FibersID    = cat(1, fibmni.fiberT.id);

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


%% Compute connectivity matrices

Selected = Connectome.region(1).selected;
for k = 2:nROI    
    Selected = cat(2, Selected, Connectome.region(k).selected);    
end

% Volume of ROIs
for i = 1 : nROI    
    A(i,1) = length(find(labels(:)==Connectome.region(i).label))*resLabel(1)*resLabel(2)*resLabel(3);    
end
clear labels;

disp('Compute connectivity matrix');
Mat = Selected' * Selected;
clear Selected;

disp('Mask upper matrix');
Mask = logical(Mat);
Mask = triu(Mask, 1);
Mat = Mask .* Mat;
clear Mask;
Md = Mat;
disp('Get sqrt');
Mat = sqrt(Mat);
disp('Get indices');
[index_i, index_j, index_k] = find(Mat);
clear Mat;
disp('Correct for areas');
disp('Step 1.');
Ai = A(index_i);
disp('Step 2.');
Ai = Ai + A(index_j);
disp('Step 3.');
index_k = 2 .* index_k ./ Ai;
clear Ai;
disp('Remove NaN areas...');
index_k(~isfinite(index_k)) = 0;
disp('Setting Mat...');
Mat = sparse(index_i, index_j, index_k, nROI, nROI);
clear index_i index_j index_k;

Connectome.Mdensity  = Mat;
Connectome.Mstrength = Md;

