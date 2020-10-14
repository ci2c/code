function Connectome = getVolumeConnectMatrix(label_vol, fibers_path, LOI, thresh)
% usage : CONNECTOME = getVolumeConnectMatrix(LABEL_vol, FIBERS, [LOI, THRESHOLD])
%
% INPUT :
% -------
%    LABEL_vol         : Path to segmented volume (in RAS nii format)
%
%    FIBERS            : Path to fibers
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
% Pierre Besson @ CHRU Lille, Sep. 2011

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

nFibers = fibers.nFiberNr;
nROI = length(LOI);

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


% for i = 2 : nROI
%     for j = 1 : i-1
%         Connectome.cuts{j,i}.N = 0;
%         Connectome.cuts{j,i}.mean_length = 0;
%         Connectome.cuts{j,i}.fib = [];
%     end
% end
% 
% clear j;
%
%
% disp('starts cuts');
% tic;
% for i = 1 : nFibers
%     if mod(i,5000) == 0
%         disp([num2str(100*i/nFibers)]);
%         toc
%     end
%     ROI_fiber = T(FibersID == i);
%     Distance = fibers.fiber(i).cumlength;
%     U = unique(ROI_fiber);
%     U(U==0) = [];
%     if length(U) > 1
%         nROI = length(U);
%         % Look for all possible combinations
%         Comb = combntns(1:nROI, 2);
%         for j = 1 : size(Comb, 1)
%             roiID1 = find(U(Comb(j,1)) == LOI);
%             roiID2 = find(U(Comb(j,2)) == LOI);
%             if roiID1 > roiID2
%                 disp('stop');
%             end
%             ROI_1 = ROI_fiber == U(Comb(j,1));
%             ROI_2 = ROI_fiber == U(Comb(j,2));
%             ROI_1_first = find(ROI_1, 1, 'first');
%             ROI_1_last = find(ROI_1, 1, 'last');
%             ROI_2_first = find(ROI_2, 1, 'first');
%             ROI_2_last = find(ROI_2, 1, 'last');
%             First_point = min(ROI_1_first, ROI_2_first);
%             Last_point = max(ROI_1_last, ROI_2_last);
%             N = Connectome.cuts{roiID1, roiID2}.N;
%             Connectome.cuts{roiID1, roiID2}.N = N + 1;
%             Mean_length = Connectome.cuts{roiID1, roiID2}.mean_length;
%             Dist = Distance(First_point:Last_point);
%             Mean_length = (N * Mean_length + Dist(end) - Dist(1)) ./ (N+1);
%             Connectome.cuts{roiID1, roiID2}.mean_length = Mean_length;
%             Connectome.cuts{roiID1, roiID2}.fib = cat(1, Connectome.cuts{roiID1, roiID2}.fib, [i, First_point, Last_point]);
%         end
%     end
% end
% toc