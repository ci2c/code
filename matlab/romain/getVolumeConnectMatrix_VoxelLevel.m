function [fibers_out Connectome] = getVolumeConnectMatrix_VoxelLevel(label_vol, fibers_path, LOI, thresh)
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
% Romain VIARD @ CHRU Lille, Sep. 2015

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
mask_pixels_value=reshape(1:size(labels(:)),V.dim(1),V.dim(2),V.dim(3));
%test=mask_pixels_value.*ismember(labels,LOI);
%test(find(~test))=nan;
%mask_pixels_value=mask_pixels_value-min(min(min(mask_pixels_value)));
%limit_inf=min(min(min(test)))
%limit_sup=max(max(max(test)))

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
            disp(fibers_path);
            fibers = f_readFiber_tck(fibers_path, thresh);
        else
            error('unrecognized fibers type');
        end
    end
end


if isempty(LOI)
    LOI = 1;%unique(labels);
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

T1 = round(spm_sample_vol(mask_pixels_value, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));
T2 = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));

indexTmp=ismember(T2, LOI);
T1=T1(indexTmp);
T2=T2(indexTmp);
FibersID=FibersID(indexTmp);
FibersCoord(:,indexTmp == 0) = [];

Connectome = sparse(double(FibersID),double(T1),ones(size(T1,1),1),double(nFibers),V.dim(1)*V.dim(2)*V.dim(3));
fibers_out.fiber = fibers.fiber(unique(FibersID));
fibers_out.nFiberNr = size(unique(FibersID));