function results = DTIparams_perDistanceBin(allTracts_Fname,selectFname,dist_bin_Fname,tensorFname,FAthreshold)
% function results = DTIparams_perDistanceBin...
%                    (allTracts_Fname,...
%                     selectFname,...
%                     dist_bin_Fname,...
%                     tensorFname,..
%                     FAthreshold)
% 
% Compute the DTI parameters based on the distance mapping obtained by using DistanceMap.DTI.pipeline.sh
% 
% allTracts_Fname   : Path to the subject_fibers.fib file (MedINRIA)
% selectFname       : Path to the subject_tract.fib file (MedINRIA)
% dist_bin_Fname    : Path to the distance map (Dist_final.mnc.gz)
% tensorFname       : Path to the subject_tensors.inr.gz file (MedINRIA)
% FAthreshold       : Ignore voxels with low FA in the calculation. If not specified, all voxels are analyzed.
% 
% results           : A structure with the fields:
%                     wholeMean     : The mean DTI parameters over all voxels
%                     distances     : The distances specified in the distance mapping
%                     meanPerBin    : The means per distance bin of each DTI parameter
%                     ThresholdUsed : FA threshold used in the calculation. NaN if not used.
%                     
% Luis Concha. Noel lab. BIC, MNI. September, 2008.

if nargin < 5
    disp('Will NOT perform thresholding for calculation');
    doThreshold = false; 
else
    fprintf(1,'Voxels with an FA < %f will not be included for calculation of mean parameters\n\n',FAthreshold);
    doThreshold = true;
end



% Read the fibers
[allFibers,thisTract] = f_readFiber_vtk_bin_selection(allTracts_Fname,selectFname);
thisTract = thisTract.tracts;

% Read the tensors and calculate DTI pams
[tensor,lambdas] = lambdas_from_MedInria(tensorFname);
lambdas          = permute(lambdas,[2 1 3 4]);
[adc,fa,perp]    = calcFA(lambdas);
e1               = lambdas(:,:,:,1);

% Read the distance map
info = mnc_info(dist_bin_Fname);
dist = readmnc(dist_bin_Fname);
dist = round(dist);
distances        = [1:1:max(dist(:))];

% Put things into the same voxel space
thisTract = putTractInRightPlace_fromMedInria(thisTract,info);


% Prepare variables
meanFA           = zeros(size(distances));
meanADC          = zeros(size(distances));
meanE1           = zeros(size(distances));
meanPerp         = zeros(size(distances));

if doThreshold
    % Mask the distance maps based on FA threshold
    indexmask = find(fa< FAthreshold);
    fa(indexmask) = NaN;
    adc(indexmask) = NaN;
    e1(indexmask) = NaN;
    perp(indexmask) = NaN;
end

% obtain the mean of the whole tract
wholemean.FA   = nanmean(fa(dist>0));
wholemean.ADC  = nanmean(adc(dist>0));
wholemean.E1   = nanmean(e1(dist>0));
wholemean.PERP = nanmean(perp(dist>0));

% Now get the values per distance!
for thisDist = 1 : max(dist(:))
   index              = find(dist==distances(thisDist));
   meanFA(thisDist)   = nanmean(fa(index));
   meanADC(thisDist)  = nanmean(adc(index));
   meanE1(thisDist)   = nanmean(e1(index));
   meanPerp(thisDist) = nanmean(perp(index));
end

% Organize the results into a neat package.
results.wholeMean       = wholemean;
results.distances       = distances;
results.meanPerBin.FA   = meanFA;
results.meanPerBin.ADC  = meanADC;
results.meanPerBin.E1   = meanE1;
results.meanPerBin.PERP = meanPerp;
if doThreshold
    results.ThresholdUsed   = FAthreshold;
else
    results.FA_threshold_used   = NaN;
end
    