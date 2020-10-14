function [resClust,AA,numClass] = FMRI_SurfThresholdingAfterVolAna(sesspath,resClust,thresP,Mask)

% usage : [resClust,AA,numClass] = FMRI_SurfThresholdingAfterVolAna(sesspath,resClust,opt)
%
% Inputs :
%    sesspath      : path to data
%    resClust      : structure of clustering results
%    thresP        : threshold value for pvalue (FDR correction)
%
% Output :
%    resClust      : structure of clustering results
%    AA            : thresholded maps
%    numClass      : number of classes
%
% Renaud Lopes @ CHRU Lille, Feb 2013

if nargin ~= 4
    error('invalid usage');
end

P            = resClust.P; 
resClust.optClust.SthresP  = thresP;

if isfield(resClust,'StMaps')
    tMaps_pos = resClust.StMaps;
else
    disp(['Warning -- No tMaps'])
    return
end
numClass = size(tMaps_pos,2);
for pp = 1:numClass
    I             = find(P==pp);
    sizeClust(pp) = length(I);
end

% Method 1 (FDR)
for pp = 1:numClass
    
    slm.t  = tMaps_pos(:,pp)';
    slm.k  = 1;
    slm.df = sizeClust(pp);
    save(fullfile(sesspath,['slm_' num2str(pp) '.mat']),'slm');
    qvalP = SurfStatQ( slm, Mask );
    
    qvalue(:,pp) = 1-qvalP.Q(:);
    
end
AA = qvalue;