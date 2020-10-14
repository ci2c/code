function [resClust,dataHier] = FMRI_SurfHierClustering(subjlist,prefix)

% usage : hier = FMRI_SurfHierClustering(subjdir,subjlist)
%
% Inputs :
%    subjlist     : list of subjects
%    prefix       : prefix of ica maps
%
% Output :
%    resClust      : structure of clustering results
%    dataHier      : clustering data
%
% Renaud Lopes @ CHRU Lille, Mar 2012

nsubj       = length(subjlist);
contrib     = [];
timeCourses = {};
numcomp     = 0;

disp('Components loading...')

for k = 1:nsubj
    
    fprintf('loading subject %d\n',k)
    
    load(fullfile(subjlist{k},'sica.mat'),'sica');
       
    [ntt,nbcmps] = size(sica.A);
    
    if(k==1)
        %[tmp, fnum] = read_curv(fullfile(subjlist{k},['lh.' prefix num2str(1) '.mgh']));
        tmp      = load_mgh(fullfile(subjlist{k},['lh.' prefix num2str(1) '.mgh']));
        nbleft   = length(tmp);
        tmp      = load_mgh(fullfile(subjlist{k},['rh.' prefix num2str(1) '.mgh']));
        nbright  = length(tmp);
        dataHier = zeros(nbleft+nbright,nsubj*nbcmps);
        clear tmp;
    end
    
    d = zeros(nbleft+nbright,nbcmps);
    for j = 1:nbcmps
        contrib(numcomp+j)       = sica.contrib(j);
        timeCourses{end+1}       = sica.A(1:ntt,j);
        %[tmp, fnum]              = read_curv(fullfile(subjlist{k},['lh.' prefix num2str(j) '.mgh']));
        tmp                      = load_mgh(fullfile(subjlist{k},['lh.' prefix num2str(j) '.mgh']));
        d(1:nbleft,j)            = tmp(:);
        %[tmp, fnum]              = read_curv(fullfile(subjlist{k},['rh.' prefix num2str(j) '.mgh']));
        tmp                      = load_mgh(fullfile(subjlist{k},['rh.' prefix num2str(j) '.mgh']));
        d(nbleft+1:end,j)        = tmp(:);
        compsName_lh{numcomp+j}  = fullfile(subjlist{k},['lh.' prefix num2str(j) '.mgh']);
        compsName_rh{numcomp+j}  = fullfile(subjlist{k},['rh.' prefix num2str(j) '.mgh']);
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
resClust.nbCompSica   = size(dataHier,2)/nsubj;
