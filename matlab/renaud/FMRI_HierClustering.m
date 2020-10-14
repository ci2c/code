function [resClust,dataHier] = FMRI_HierClustering(subjlist,prefix,maskFile)

% usage : hier = FMRI_SurfHierClustering(subjdir,subjlist)
%
% Inputs :
%    subjlist     : list of subjects
%    prefix       : prefix of ica maps
%    maskFile     : mask file
%
% Output :
%    resClust      : structure of clustering results
%    dataHier      : clustering data
%
% Renaud Lopes @ CHRU Lille, Mar 2012

nsubj       = length(subjlist);
contrib     = [];
timeCourses = [];
numcomp     = 0;

hdrmask = spm_vol(maskFile);
mask    = spm_read_vols(hdrmask);
ind     = find(mask(:)>0);

disp('Components loading...')

for k = 1:nsubj
    
    fprintf('loading subject %d\n',k)
    
    load(fullfile(subjlist{k},'sica.mat'),'sica');
       
    [ntt,nbcmps] = size(sica.A);
    
    if(k==1)
        hdr = spm_vol(fullfile(subjlist{k},[prefix num2str(1) '.nii']));
        tmp = spm_read_vols(hdr);
        dim = size(tmp);
        tmp = tmp(:);
        tmp = tmp(ind);
        dataHier = zeros(length(tmp),nsubj*nbcmps);
        clear tmp;
    end
    
    d = zeros(size(dataHier,1),nbcmps);
    for j = 1:nbcmps
        contrib(numcomp+j)       = sica.contrib(j);
        timeCourses(:,numcomp+j) = sica.A(1:ntt,j);
        hdr                      = spm_vol(fullfile(subjlist{k},[prefix num2str(j) '.nii']));
        tmp                      = spm_read_vols(hdr);
        tmp                      = tmp(:);
        tmp                      = tmp(ind);
        d(:,j)                   = tmp;
        compsName{numcomp+j}     = fullfile(subjlist{k},[prefix num2str(j) '.nii']);
        clear tmp;
    end
    numcomp     = nbcmps+numcomp;
    d(isnan(d)) = 0;
    dataHier(:,numcomp-nbcmps+1:numcomp) = st_normalise(d);
    clear d sica;
    
end

disp('hierarchy computing...')
hier = FMRI_HierarchicalClustering(dataHier,'corr');

resClust.compsName   = compsName;
resClust.hier        = hier;
resClust.contrib     = contrib;
resClust.timeCourses = timeCourses;
resClust.nbCompSica  = size(dataHier,2)/nsubj;
