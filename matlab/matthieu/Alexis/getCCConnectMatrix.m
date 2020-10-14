function getCCConnectMatrix(label_vol, fibers_path, outdir, outpref, FA_map, LOI, thresh)
% usage : CONNECTOME = getCCConnectMatrix(LABEL_vol, FIBERS, outdir, outpref, FA_map, [LOI, THRESHOLD])
%
% INPUT :
% -------
%    LABEL_vol         : Path to segmented volume (in RAS nii format)
%
%    FIBERS            : Path to fibers
%
%    outdir            : Path to the output directory to store the fiber
%                        file passing through the Corps Callosum
%                            
%    outpref           : Prefix of the output files
%
%    FA_map            : Path to FA map (in nii format)
%
%    LOI               : Path to text file containing ID and names of the labels of interest (option)
%
%    THRESHOLD         : Minimum fiber length required (default : 0) (works
%                        only with mrtrix fibers)
%
% OUTPUT :
% --------
%    CONNECTOME        : Connectome structure
%
% Matthieu Vanhoutte @ CHRU Lille, March 2014

if nargin ~= 5 && nargin ~= 6 && nargin ~= 7
    error('invalid usage');
end

if nargin < 6
    LOI = [];
end

if nargin < 7
    thresh = 0;
end

Connectome.threshold = thresh;

% Load data
V = spm_vol(label_vol);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);
FD = zeros(size(labels));

P = spm_vol(FA_map);
FA = spm_read_vols(P);

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
%nbvox_CC = sum(labels(:)==1);

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
for i = 2 : nROI
    Connectome.region(i).name = Names(i, :);
    Connectome.region(i).label = LOI(i);
    
    UU = unique(FibersID(T == LOI(i)));
    Connectome.region(i).selected = sparse(double(UU), 1, ones(size(UU)), double(nFibers), 1);
    
    for j = 1 : nFibers
        FibersCoord = fibers.fiber(j).xyzFiberCoord';
        FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
        FibersCoord = spm_pinv(V.mat) * FibersCoord;
        T = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
        FibersCoord = round(FibersCoord(:,(T == LOI(i)))');
        UC = unique(FibersCoord,'rows');
        for k = 1 : size(UC,1)
            FD(UC(k,1),UC(k,2),UC(k,3)) = FD(UC(k,1),UC(k,2),UC(k,3)) + 1;
        end
    end
    disp(['Processing step ', num2str(i, '%.3d'), ' out of ', num2str(length(LOI)), ' | Time : ', num2str(toc)]);
end

clear FibersCoord UC;

% Calculate the number of extracted ROI fibers per voxel
W = V;
W.fname = fullfile(outdir, ['NFibers_' outpref '.nii']);
%spm_write_vol(W,FD);

clear W V;

% Back up the extracted ROI fibers passing through the CC (.tck,.vtk) I
fibers.fiber = fibers.fiber(logical(Connectome.region(2).selected));
fibers.nFiberNr = length(fibers.fiber);

% Color fibers
fibersColor = color_tracts(fibers);
save_tract_tck(fibersColor,fullfile(outdir, [outpref '_Color.tck']));
%save_tract_vtk(fibersColor,fullfile(outdir, [outpref '_Color.vtk']));
    
%Map FA on fibers
%fibersFA = sampleFibers(fibers, FA_map, 'FA');
%save_tract_tck(fibersFA,fullfile(outdir, [outpref '_FA.tck']));
%save_tract_vtk(fibersFA,fullfile(outdir, [outpref '_FA.vtk']),[],'FA');

% Calcultate the probability map of ROI fibers density passing through the CC

FD = FD/fibers.nFiberNr;
FD = FD.*FA;
W = P;
W.fname = fullfile(outdir, ['Prob_' outpref '_CC.nii']);
%spm_write_vol(W,FD);

clear FD W;