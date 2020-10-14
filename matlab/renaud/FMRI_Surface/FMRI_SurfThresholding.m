function [resClust,AA,numClass] = FMRI_SurfThresholding(sesspath,resClust,thresP,Mask)

% usage : [resClust,AA,numClass] = FMRI_SurfThresholding(sesspath,resClust,opt)
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
% Renaud Lopes @ CHRU Lille, Mar 2012

if nargin ~= 4
    error('invalid usage');
end

P            = resClust.P;
opt          = resClust.optClust;  
opt.thresP   = thresP;
resClust     = setfield(resClust,'optClust',opt);

if isfield(resClust,'tMaps')
    tMaps_pos = resClust.tMaps;
else
    disp(['Warning -- No tMaps'])
    return
end
numClass = size(tMaps_pos,2);
for pp = 1:numClass
    I             = find(P==pp);
    sizeClust(pp) = length(I);
end

% % Method SurfStat:
% for pp = 1:numClass
%     slm.t  = tMaps_pos(:,pp)';
%     slm.k  = 1;
%     slm.df = sizeClust(pp);
%     save(fullfile(sesspath,['slm_' num2str(pp) '.mat']),'slm');
%     qval   = SurfStatQ_me( slm );
%     ind    = find(qval.Q>thresP);
%     ind    = ind(:);
%     tMaps_pos_v(:,pp)   = tMaps_pos(:,pp);
%     tMaps_pos_v(ind,pp) = 0;
% end
% AA = tMaps_pos_v;

% Method 2 (FDR)
for pp = 1:numClass
    
    slm.t  = tMaps_pos(:,pp)';
    slm.k  = 1;
    slm.df = sizeClust(pp);
    save(fullfile(sesspath,['slm_' num2str(pp) '.mat']),'slm');
    qvalP = SurfStatQ( slm, Mask );
%     slm.t = -slm.t;
%     qvalN = SurfStatQ( slm, Mask );
%     ind   = find(qvalP.Q>thresP);
%     qvalP.Q(ind) = 1;
%     qvalP.Q = 1-qvalP.Q;
%     ind = find(qvalN.Q>thresP);
%     qvalN.Q(ind) = 1;
%     qvalN.Q = 1-qvalN.Q;
%     qvalN.Q = -qvalN.Q;
%     tmp = (qvalP.Q) + (qvalN.Q);
%     qvalue(:,pp) = tmp(:);
    
    qvalue(:,pp) = 1-qvalP.Q(:);
    
end
AA = qvalue;

% % Method 3 (RFT)
% for pp = 1:numClass
%     
%     slm.t  = tMaps_pos(:,pp)';
%     slm.k  = 1;
%     slm.df = sizeClust(pp);
%     save(fullfile(sesspath,['slm_' num2str(pp) '.mat']),'slm');
%     
%     [pvalP, peakP, clusP] = SurfStatP(slm);
%     slm.t = -slm.t;
%     [pvalN, peakN, clusN] = SurfStatP(slm);
%     ind   = find(pvalP.P>0.05);
%     pvalP.P(ind) = 1;
%     pvalP.P = 1-pvalP.P;
%     ind = find(pvalN.P>0.05);
%     pvalN.P(ind) = 1;
%     pvalN.P = 1-pvalN.P;
%     pvalN.P = -pvalN.P;
%     tmp = (pvalP.P) + (pvalN.P);
%     pvalue(:,pp) = tmp(:);
%     
% end
% AA = pvalue;
