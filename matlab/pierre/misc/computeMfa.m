function Connectome = computeMfa(fibers_path, fa_path, Connectome, thresh)
% usage : CONNECTOME = computeMfa(FIBERS_PATH, FA_PATH, Connectome, [THRESHOLD)];
%
% INPUT :
% -------
%    FIBERS_PATH       : Path to fibers (i.e. '/my/great/fibers.tck')
%
%    FA_PATH           : Path to FA volume (i.e. '/my/volume/fa.nii')
%
%    Connectome        : Input connectome structure
%
% Option :
%    THRESHOLD         : Minimum required fiber length (default : Connectome.threshold or 0)
%
% OUTPUT :
% --------
%    CONNECTOME        : Output connectome structure
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 3 & nargin ~= 4
    error('invalid usage');
end

if nargin == 3
    try 
        thresh = Connectome.threshold;
    catch
        thresh = 0;
    end
end

Tract = f_readFiber_tck(fibers_path, thresh);

Tract = sampleFibers(Tract, fa_path, 'FA');

FA = cat(1, Tract.fiber.FA_mean);

nFiberNr = Tract.nFiberNr;

% clear Tract;

nROI = length(Connectome.region);

nFibers = length(Connectome.region(1).selected);

if nFibers ~= nFiberNr
    warning('The number of fibers in selected vector does not match the numer of fibers in the tracts structure');
end

Mfa = zeros(nROI);

for i = 2 : nROI
    Si = Connectome.region(i).selected;
    for j = 1 : (i - 1)
        S = Si .* Connectome.region(j).selected;
        Mfa(i,j) = mean(FA(S~=0));
    end
end

Mfa = Mfa + Mfa';

Connectome.Mfa = Mfa;

Mfa_cuts = zeros(nROI);

try
    length(Connectome.cuts);
    for i = 2 : nROI
        for j = 1 : i-1
            fib_info = Connectome.cuts{j,i}.fib;
            for k = 1 : size(fib_info, 1)
                Mfa_cuts(i,j) = Mfa_cuts(i,j) + mean(Tract.fiber(fib_info(k,1)).FA(fib_info(k,2):fib_info(k,3)));
            end
        end
    end
    
    Temp = cat(2, Connectome.region.selected);
    Temp = Temp'*Temp;
    Temp(eye(size(Temp))~=0) = 0;
    Mfa_cuts = Mfa_cuts ./ Temp;
    Mfa_cuts(~isfinite(Mfa_cuts)) = 0;
    Mfa_cuts = Mfa_cuts + Mfa_cuts';
    Connectome.Mfa_cuts = Mfa_cuts;
    
catch
    disp('No Connectome.cuts found');
end