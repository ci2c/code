function [ConnectomeLesion,Connectome] = DTI_GetMNIConnectMatrixWithLesion(lesion_vol, label_vol, fibers_path, resLabel, LOI, thresh)

% usage : CONNECTOME = DTI_GetMNIConnectMatrixWithLesion(lesion_vol, label_vol, fibers_path, resLabel, [LOI, thresh])
%
% INPUT :
% -------
%    LESION_vol        : Path to lesion volume (in MNI RAS nii format)
% 
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
%    CONNECTOMELESION  : Connectome structure taking into account the
%                           lesion.
%    CONNECTOME        : Connectome structure
%
% Renaud Lopes @ CHRU Lille, Aug. 2016


if nargin ~= 4 && nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

if nargin < 5
    LOI = [];
end

if nargin < 6
    thresh = 0;
end

Connectome.threshold = thresh;
ConnectomeLesion.threshold = thresh;

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
% FibersID(T==0) = [];
% T(T==0) = [];

% lesion
FibersID1 = cat(1, fibmni.fiberT.id);
V1 = spm_vol(lesion_vol);
T1 = round(spm_sample_vol(V1, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
% T1(ismember(T1, 1) == 0) = 0;
% FibersID1(T1==0) = 0;
id1 = find(T1==1);
fibid1 = FibersID1(id1);
T1 = T1(id1);

clear FibersCoord;

% Preallocate memory
Connectome.region(nROI).name = NaN;
Connectome.region(nROI).label = NaN;
Connectome.region(nROI).selected = NaN;
ConnectomeLesion.region(nROI).name = NaN;
ConnectomeLesion.region(nROI).label = NaN;
ConnectomeLesion.region(nROI).selected = NaN;

tic;
for i = 1 : nROI
    
    disp(['Processing step ', num2str(i, '%.3d'), ' out of ', num2str(length(LOI)), ' | Time : ', num2str(toc)]);
    Connectome.region(i).name = Names(i, :);
    Connectome.region(i).label = LOI(i);
    
    ConnectomeLesion.region(i).name = Names(i, :);
    ConnectomeLesion.region(i).label = LOI(i);
    
    % fibers passe through the ROI
    fibid = FibersID(T == LOI(i));
    % fibers from this ROI passe through lesion mask 
    [C,IA,IB] = intersect(fibid,fibid1,'rows','stable');
    % take the minimum of each fiber
    n=0; m=zeros(length(C),1);
    for j = 1:length(C)
        id = find(fibid1==C(j));
        n = n + length(id); % number of fiber points inside the lesion mask
        m(j) = min(T1(id)); % ChaCo measure
    end
    
    ConnectomeLesion.region(i).chaco = sum(m);
    UU = unique(fibid);
    if length(UU)>0
        ConnectomeLesion.region(i).chacon = ConnectomeLesion.region(i).chaco/length(UU);
    else
        ConnectomeLesion.region(i).chacon = 0;
    end
    
    Connectome.region(i).selected = sparse(double(UU), 1, ones(size(UU)), double(nFibers), 1);
    ConnectomeLesion.region(i).selected = sparse(double(fibid(IA)), 1, m, double(nFibers), 1);
    
end
timeformatrix = toc


%% Compute connectivity matrices without lesion

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


%% Compute connectivity matrices with lesion

Selected = Connectome.region(1).selected-ConnectomeLesion.region(1).selected;
for k = 2:nROI    
    Selected = cat(2, Selected, Connectome.region(k).selected-ConnectomeLesion.region(k).selected);    
end

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

ConnectomeLesion.Mdensity  = Mat;
ConnectomeLesion.Mstrength = Md;

