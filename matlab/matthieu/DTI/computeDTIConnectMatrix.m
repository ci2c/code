function Connectome = computeDTIConnectMatrix(fibers_path, label_vol, fa_path, MD_path, Connectome, voxel_size, thresh)
% usage : Connectome = computeDTIConnectMatrix(fibers_path, label_vol, fa_path, MD_path, Connectome, voxel_size, [thresh]);
%
% INPUT :
% -------
%    fibers_path       : Path to fibers directory
%
%    label_vol         : Path to segmented volume (in RAS nii format)
%
%    fa_path           : Path to FA volume (i.e. '/my/volume/fa.nii')
%
%    MD_path           : Path to MD volume (i.e. '/my/volume/MD.nii')
%
%    Connectome        : Input connectome structure
% 
%    voxel_size        : Size of the isotropic voxel
%
% Option :
%    thresh         : Minimum required fiber length (default : Connectome.threshold or 0)
%
% OUTPUT :
% --------
%    Connectome        : Output connectome structure
%
% Matthieu Vanhoutte @ CHRU Lille, Dec 2014

if nargin ~= 6 & nargin ~= 7
    error('invalid usage');
end

if nargin == 6
    try 
        thresh = Connectome.threshold;
    catch
        thresh = 0;
    end
end

% Load data
V = spm_vol(label_vol);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);

nROI = length(Connectome.region);

FibersDensity = zeros(nROI);
Mfa = zeros(nROI);
MMD = zeros(nROI);

% Find split fibers files
F0 = rdir(fullfile(fibers_path,'whole_brain_6_2500000_part*.tck'));

l = 0;

for k=1:length(F0)   
    % Load fibers
    disp('mrtrix fibers');
    disp(k);
    Tract = f_readFiber_tck(F0(k).name, thresh);

    disp('FA projection');
    Tract = sampleFibers(Tract, fa_path, 'FA');

    disp('MD projection');
    Tract = sampleFibers(Tract, MD_path, 'MD');

    FA = cat(1, Tract.fiber.FA_mean);
    MD = cat(1, Tract.fiber.MD_mean);

    nFibers = Tract.nFiberNr;
    
    % Preallocate memory
    Sfa{nROI,nROI} = [];
    SMD{nROI,nROI} = [];

    for i = 2 : nROI
        Si = Connectome.region(i).selected((l+1):(l+nFibers));
        for j = 1 : (i - 1)
            S = Si .* Connectome.region(j).selected((l+1):(l+nFibers));
            Sfa{i,j} = [ Sfa{i,j} ; FA(S~=0) ];
            SMD{i,j} = [ SMD{i,j} ; MD(S~=0) ];
        end
    end
    l = l+nFibers;
end

for i = 2 : nROI
    Si = Connectome.region(i).selected;
    Li = Connectome.region(i).label;
    Vi = length(find(labels == Li))*(voxel_size^3);
    for j = 1 : (i - 1)
        Lj = Connectome.region(j).label;
        Vj = length(find(labels == Lj))*(voxel_size^3);
        Vmean = (Vi+Vj)/2;
        S = Si .* Connectome.region(j).selected;
        FibersDensity(i,j) = length(find(S~=0))/Vmean;
        Mfa(i,j) = mean(Sfa{i,j});
        MMD(i,j) = mean(SMD{i,j});
    end
end
    
FibersDensity = FibersDensity + FibersDensity';
Mfa = Mfa + Mfa';
MMD = MMD + MMD';

Connectome.FibersDensity = FibersDensity;
Connectome.Mfa = Mfa;
Connectome.MMD = MMD;
