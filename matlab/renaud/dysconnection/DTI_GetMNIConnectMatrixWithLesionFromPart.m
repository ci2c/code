function [ConnectomeLesion,Connectome] = DTI_GetMNIConnectMatrixWithLesionFromPart(lesion_vol, label_vol, fibers_path, resLabel, LOI, thresh)

% usage : CONNECTOME = DTI_GetMNIConnectMatrixWithLesionFromPart(lesion_vol, label_vol, fibers_path, resLabel, [LOI, thresh])
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
labels(isnan(labels))=0;
labels = round(labels);
clear XYZ;

% List of fibers
if strfind(fibers_path, '.mat')
    disp('matlab fibers');
    [p,n,e] = fileparts(fibers_path);
    fiblist = dir(fullfile(p,[n '_part*' e]));
else
    error('unrecognized fibers type');
end

if ~exist(LOI,'file')
    LOI = unique(labels);
    Ts = length(LOI);
    Names = cellstr([repmat('LOI', Ts, 1), num2str((1:Ts)', '%.4d')]);
    clear Ts;
else
    [LOI,Names] = textread(LOI,'%d %s');
%     fid = fopen(LOI, 'r');
%     T = textscan(fid, '%d %s');
%     LOI = T{1};
%     Names = char(T{2});
%     Names = Names(:,2:end);
%     fclose(fid);
%     clear T;
end

nROI = length(LOI);

% Preallocate memory
Connectome.region(nROI).name = NaN;
Connectome.region(nROI).label = NaN;
Connectome.region(nROI).selected = NaN;
ConnectomeLesion.region(nROI).name = NaN;
ConnectomeLesion.region(nROI).label = NaN;
ConnectomeLesion.region(nROI).selected = NaN;
nFibers_all = 0;
Selected_all = [];
SelectedLesion_all = [];
chaco = zeros(nROI,1);
chacon = zeros(nROI,1);

% Loop on fiber files
tic
for k = 1:length(fiblist)

    disp(k);
    
    % Load fibers
    load(fullfile(p,fiblist(k).name));
    
    % threshold
    keep = ones(length(fibmni.fiber),1);
%     for i = 1:length(fibmni.fiber)
%         if fibmni.fiber(i).length>thresh
%             keep=[keep i];
%         end
%     end
     for i = 1:length(fibmni.fiber)
         if fibmni.fiber(i).length<thresh
             keep(i) = 0;
         end
     end

    %fibmni.fiberT = fibmni.fiber(keep);
    %fibmni.nFiberNrT = length(keep);
    fibmni.fiberT = fibmni.fiber;
    fibmni.nFiberNrT = length(keep);   
    
%     fibmni.thresh = thresh;

    nFibers = fibmni.nFiberNrT;
    nFibers_all = nFibers_all+nFibers;

    FibersCoord = cat(1, fibmni.fiberT.xyzFiberCoord)';
    FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
    FibersCoord = spm_pinv(V.mat) * FibersCoord;  % Transform mm to voxels
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

    for i = 1 : nROI

        %disp(['Processing step ', num2str(i, '%.3d'), ' out of ', num2str(length(LOI)), ' | Time : ', num2str(toc)]);
%         Connectome.region(i).name = Names(i, :);
%         Connectome.region(i).label = LOI(i);
% 
%         ConnectomeLesion.region(i).name = Names(i, :);
%         ConnectomeLesion.region(i).label = LOI(i);

        % fibers passe through the ROI
        fibid = FibersID(T == LOI(i));
        % fibers from this ROI passe through lesion mask 
        [I,IA,IB] = intersect(fibid,fibid1,'rows','stable');
        [C,IA,IB] = intersect(I,find(keep == 1),'rows','stable');
        % take the minimum of each fiber
        n=0; m=zeros(length(C),1);
        for j = 1:length(C)
            id = find(fibid1==C(j));
            n = n + length(id); % number of fiber points inside the lesion mask
            m(j) = min(T1(id)); % ChaCo measure
        end

        chaco(i) = chaco(i)+sum(m);
%         ConnectomeLesion.region(i).chaco = sum(m);
        UU = unique(fibid);
        if ~isempty(UU)
%             ConnectomeLesion.region(i).chacon = ConnectomeLesion.region(i).chaco/length(UU);
            chacon(i) = chacon(i)+length(UU);
        end
        Cors = sparse(double(UU), 1, ones(size(UU)), double(nFibers), 1);
        Cors(keep == 0) = 0; % apply threshold
        
        CoLrs = sparse(double(fibid(IA)), 1, m, double(nFibers), 1);
        CoLrs(keep == 0) = 0;% apply threshold
        Connectome.region(i).selected = Cors;
        ConnectomeLesion.region(i).selected = CoLrs;

    end
    
    % Merge
    Selected       = Connectome.region(1).selected;
    
    %%%%%% WARNING : INDUCE NEGATIVE VALUES %%%%%%
    SelectedLesion = Connectome.region(1).selected-ConnectomeLesion.region(1).selected;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SelectedLesion(SelectedLesion < 0) = 0;
    for i = 2:nROI    
        Selected       = cat(2, Selected, Connectome.region(i).selected);
        
        covfefe        = Connectome.region(i).selected-ConnectomeLesion.region(i).selected;
        covfefe(covfefe < 0) = 0;
        
        SelectedLesion = cat(2, SelectedLesion, covfefe); 
    end
    Selected_all       = cat(1, Selected_all, Selected);
    SelectedLesion_all = cat(1, SelectedLesion_all, SelectedLesion);
    
end
timeformatrix = toc


%% Connectome structures

% Volume of ROIs & connectome structure
for i = 1 : nROI 
    Connectome.region(i).name     = Names{i};
    Connectome.region(i).label    = LOI(i);
    Connectome.region(i).selected = Selected_all(:,i);
    ConnectomeLesion.region(i).name     = Names{i};
    ConnectomeLesion.region(i).label    = LOI(i);
    ConnectomeLesion.region(i).selected = SelectedLesion_all(:,i);
    
    % volumes
    A(i,1) = length(find(labels(:)==Connectome.region(i).label))*resLabel(1)*resLabel(2)*resLabel(3);    
end

chacon(chacon==0)=1;
ConnectomeLesion.chaco  = chaco;
ConnectomeLesion.chacon = chaco./chacon;
clear labels chaco chacon;


%% Compute connectivity matrices without lesion

disp('Compute connectivity matrix');
Mat = Selected_all' * Selected_all;
clear Selected_all;

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

disp('Compute connectivity matrix');
Mat = SelectedLesion_all' * SelectedLesion_all;
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

