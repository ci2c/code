function [resClust,dataHier] = FMRI_SurfClustering(sesspath,sessname)

% usage : hier = FMRI_HierarchicalClustering(X,[type,p])
%
% Inputs :
%    sesspath      : path to data
%    sessname      : list of subjects
%
% Output :
%    resClust      : structure of clustering results
%    dataHier      : clustering data
%
% Renaud Lopes @ CHRU Lille, Mar 2012

nbsess      = length(sessname);
contrib     = [];
timeCourses = [];
numcomp     = 0;

disp('Components loading...')

for k = 1:nbsess
    
    fprintf('loading session %d\n',k)
    
    load([fullfile(sesspath,sessname{k}) '/bold/001/ica/sica.mat'],'sica');
       
    [ntt,nbcmps] = size(sica.A);
    
    if(k==1)
        load(fullfile(sesspath,'sizeDataHier.mat'),'sizeDataHier');
        dataHier = zeros(size(sica.S,1),sizeDataHier);
        [tmp, fnum] = read_curv([fullfile(sesspath,sessname{k}) '/bold/001/ica/lh.ica_map_1']);
        nbleft = length(tmp);
        clear tmp;
    end
    
    d = zeros(size(sica.S,1),nbcmps);
    for j = 1:nbcmps
        contrib(numcomp+j)       = sica.contrib(j);
        timeCourses(:,numcomp+j) = sica.A(1:ntt,j);
        [tmp, fnum]              = read_curv([fullfile(sesspath,sessname{k}) '/bold/001/ica/lh.ica_map_' num2str(j)]);
        d(1:nbleft,j)            = tmp(:);
        [tmp, fnum]              = read_curv([fullfile(sesspath,sessname{k}) '/bold/001/ica/rh.ica_map_' num2str(j)]);
        d(nbleft+1:end,j)        = tmp(:);
        compsName_lh{numcomp+j}  = [fullfile(sesspath,sessname{k}) '/bold/001/ica/lh.ica_map_' num2str(j)];
        compsName_rh{numcomp+j}  = [fullfile(sesspath,sessname{k}) '/bold/001/ica/rh.ica_map_' num2str(j)];
        clear tmp;
    end
    numcomp     = nbcmps+numcomp;
    d(isnan(d)) = 0;
    dataHier(:,numcomp-nbcmps+1:numcomp) = st_normalise(d);
    clear d sica;
    
end

disp('hierarchy computing...')
hier = FMRI_HierarchicalClustering(dataHier,'corr');

resClust.compsName_lh = compsName_lh;
resClust.compsName_rh = compsName_rh;
resClust.hier         = hier;
resClust.contrib      = contrib;
resClust.timeCourses  = timeCourses;
resClust.nbCompSica   = size(dataHier,2)/nbsess;
