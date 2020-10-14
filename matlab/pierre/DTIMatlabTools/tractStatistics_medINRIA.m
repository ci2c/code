function wholemean = tractStatistics_medINRIA(tensorFname,tractBinFname,FAthreshold)
%
% function wholemean = tractStatistics_medINRIA(tensorFname,tractBinFname)
% 
% Obtain the mean diffusion parameters of a tract drawn in MedINRIA. It
% requires that the tract be saved as a mask with the extension .nii.gz
% 
% tensorFname    = The .inr.gz tensors computed in MedINRIA. If the .dts
% file has been saved, then this file can be found in the same directory,
% with the same file prefix.
%
% tractBinFname  = The tract mask saved in MedINRIA in .nii.gz format.
%
% FAthreshold    = If defined, voxels having an FA value lower than this
% parameter will not be included in the calculation. Recommended value is
% the same as used for fiber tracking. If not specified, results can be a
% bit lower, as the voxel where tracking stopped is included in the
% analysis.
%
%
% wholemean      : The resulting structure with the average diffusion
% parameters of all the voxels contained within the tract.
%
%
% Example: wholemean = tractStatistics_medINRIA...
%                      ('new_bernasconi_neda_tensors.inr.gz',...
%                       'new_bernasconi_neda_right.nii.gz')
%
% Luis Concha. Noel Lab. BIC, MNI. September, 2008.


if nargin < 3
    disp('Will NOT perform thresholding for calculation');
    doThreshold = false; 
else
    fprintf(1,'Voxels with an FA < %f will not be included for calculation of mean parameters\n\n',FAthreshold);
    doThreshold = true;
end

                         
[tensor,lambdas] = lambdas_from_MedInria(tensorFname);
[adc,fa,perp]    = calcFA(lambdas);
e1               = lambdas(:,:,:,1);

tractMask    = load_niigz(tractBinFname);
tractBinMask = zeros(size(tractMask.img));
tractBinMask(tractMask.img>0) = 1;
tractBinMask = flipdim(tractBinMask,2);

if doThreshold
    indexmask       = find(fa < FAthreshold);
    fa(indexmask)   = NaN;
    adc(indexmask)  = NaN;
    e1(indexmask)   = NaN;
    perp(indexmask) = NaN;
end

wholemean.FA = nanmean(fa(tractBinMask>0));
wholemean.ADC = nanmean(adc(tractBinMask>0));
wholemean.E1 = nanmean(e1(tractBinMask>0));
wholemean.PERP = nanmean(perp(tractBinMask>0));
