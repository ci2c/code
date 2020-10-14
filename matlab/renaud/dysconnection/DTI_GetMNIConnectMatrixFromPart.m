function Connectome = DTI_GetMNIConnectMatrixFromPart(label_vol, fibers_path, resLabel, LOI, thresh)

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

% List of fibers
if strfind(fibers_path, '.mat')
    disp('matlab fibers');
    [p,n,e] = fileparts(fibers_path);
    fiblist = dir(fullfile(p,[n '_part*' e]));
else
    error('unrecognized fibers type');
end

% LOI names
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
    fclose(fid);
    clear T;
end

nROI = length(LOI);

% Preallocate memory
Connectome.region(nROI).name = NaN;
Connectome.region(nROI).label = NaN;
Connectome.region(nROI).selected = NaN;
Md = sparse(zeros(nROI,nROI));
Selected_all = [];
nFibers = 0;

% Loop on fiber files
tic
for k = 1:length(fiblist)
   
    disp(k);
    
    load(fullfile(p,fiblist(k).name));
    
    % threshold
    keep=[];
    for i =1:length(fibmni.fiber)
        if fibmni.fiber(i).length>thresh
            keep=[keep i];
        end
    end
    fibmni.fiberT = fibmni.fiber(keep);
    fibmni.nFiberNrT = length(keep);
    fibmni.thresh = thresh;
    
    N = fibmni.nFiberNrT;
    nFibers = nFibers + fibmni.nFiberNrT;
    
    FibersCoord = cat(1, fibmni.fiberT.xyzFiberCoord)';
    FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
    FibersCoord = spm_pinv(V.mat) * FibersCoord;
    %FibersVoxel = cat(1, fibmni.fiberT.voxels)';
    FibersID    = cat(1, fibmni.fiberT.id);
    
    T = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
    T(ismember(T, LOI) == 0) = 0;
    FibersID(T==0) = [];
    T(T==0) = [];
    
    clear FibersCoord;
    
    %tic;
    for i = 1 : nROI
        %disp(['Processing step ', num2str(i, '%.3d'), ' out of ', num2str(length(LOI)), ' | Time : ', num2str(toc)]);
        if k==1
            Connectome.region(i).name = Names(i, :);
            Connectome.region(i).label = LOI(i);
        end

        UU = unique(FibersID(T == LOI(i)));
        Connectome.region(i).selected = sparse(double(UU), 1, ones(size(UU)), double(N), 1);
    end
    
    % Compute connectivity matrices
    Selected = Connectome.region(1).selected;
    for i = 2:nROI    
        Selected = cat(2, Selected, Connectome.region(i).selected);    
    end
    Selected_all = cat(1, Selected_all, Selected);
    
%     disp('Compute connectivity matrix');
%     Mat = Selected' * Selected;
%     clear Selected;
% 
%     disp('Mask upper matrix');
%     if k==1
%         Mask = logical(Mat);
%         Mask = triu(Mask, 1);
%     end
%     Mat = Mask .* Mat;
%     %clear Mask;
%     Md = Md + Mat;
%     clear Mat;
    
end
timeformatrix = toc

clear XYZ;

disp('Compute connectivity matrix');
Mat = Selected_all' * Selected_all;
clear Selected_all;

disp('Mask upper matrix');
Mask = logical(Mat);
Mask = triu(Mask, 1);
Mat = Mask .* Mat;
clear Mask;
Md = Md + Mat;
% clear Mat;

% Volume of ROIs
for i = 1 : nROI    
    A(i,1) = length(find(labels(:)==Connectome.region(i).label))*resLabel(1)*resLabel(2)*resLabel(3);    
end
clear labels;

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

