function [clus,peak,clusid] = FMRI_SurfCluster(surf_file,curv_file,tmap_file,thresh_map,thresh_clus,clus_file,stmap_file)

% usage : V = FMRI_SurfCluster(surf_file, curv_file, [thresh_map, thresh_clus, clus_file])
%
% Inputs :
%    surf_file        : path to a surface
%    curv_file        : path to a map
%
% Options :
%    thresh_map       : threshold value applied to the map before the
%                       cluster analysis. Default : 2
%    thresh_clus      : threshold value applied to the number of vertices
%                       in one cluster. Default : 50
%    clus_file        : path to clusters map. Default : []
%
% Output :
%    clus             : structure of clusters
%    peak             : structure of maxima peak
%    clusid           : map of clusters
%
% Renaud Lopes @ CHRU Lille, Mar 2012

if nargin ~= 4 && nargin ~= 5 && nargin ~= 6 && nargin ~= 7
    error('invalid usage');
end

default_threshmap  = 2;
default_threshclus = 50;

% check args
if nargin < 4
    thresh_map = default_threshmap;
end

if nargin < 5
    thresh_clus = default_threshclus;
end

% read surface
surf = SurfStatReadSurf(surf_file);

% read map file
curv = SurfStatReadData(curv_file);
tmap = SurfStatReadData(tmap_file);

% Finds edges of a triangular mesh
data.tri = surf.tri;
data.t   = curv(:)';
edg      = SurfStatEdg(data);
[l,v]    = size(data.t);

% Thresholding the map
excurset = (data.t(1,:)>=thresh_map);
n        = sum(excurset);
if n<1
    peak   = [];
    clus   = [];
    clusid = [];
   
    write_curv(clus_file,zeros(size(curv)),size(surf.tri,1));
    if nargin == 7
        write_curv(stmap_file,zeros(size(curv)),size(surf.tri,1));
    end
    return
end

voxid = cumsum(excurset);
edg   = voxid(edg(all(excurset(edg),2),:));

% Find cluster id's in nf:
nf = 1:n;
for el = 1:size(edg,1)
    j = edg(el,1);
    k = edg(el,2);
    while nf(j)~=j j=nf(j); end
    while nf(k)~=k k=nf(k); end
    if j~=k nf(j)=k; end
end
for j=1:n
    while nf(j)~=nf(nf(j)) nf(j)=nf(nf(j)); end
end

% find the unique cluster id's corresponding to the local maxima:
t1    = data.t(1,edg(:,1));
t2    = data.t(1,edg(:,2));
islm  = ones(1,v);
islm(edg(t1<t2,1)) = 0;
islm(edg(t2<t1,2)) = 0;
lmvox = find(islm);
vox   = find(excurset);
ivox  = find(ismember(vox,lmvox));
clmid = nf(ivox);
[uclmid,iclmid,jclmid]=unique(clmid);
 
% find their volumes:
ucid  = unique(nf);
nclus = length(ucid);
ucvol = histc(nf,ucid);

% find their ranks (in ascending order):
reselsvox = ones(size(vox));
nf1       = interp1([0 ucid],0:nclus,nf,'nearest');
ucrsl     = accumarray(nf1',reselsvox)';
[sortucrsl,iucrsl] = sort(ucrsl);
rankrsl            = zeros(1,nclus);
rankrsl(iucrsl)    = nclus:-1:1;

% add these to lm as extra columns:
lmid = lmvox(ismember(lmvox,vox));
lm   = flipud(sortrows([data.t(1,lmid)' lmid' rankrsl(jclmid)'],1));
cl   = sortrows([rankrsl' ucvol' ucrsl'],1);

% results
clusid      = zeros(1,v);
clusid(vox) = interp1([0 ucid],[0 rankrsl],nf,'nearest');
index       = find(cl(:,2)<thresh_clus);
for k=1:length(index)
    ind = find(clusid==index(k));
    clusid(ind) = 0;
end

index       = find(cl(:,2)>=thresh_clus);
nclus       = length(index);
peak.max    = zeros(1,nclus);
peak.vertid = zeros(1,nclus);
peak.clusid = zeros(1,nclus);
clus.clusid = zeros(1,nclus);
clus.vert   = {};
clus.nvert  = zeros(1,nclus);

for k=1:length(index)
    ind            = find(clusid==index(k));
    tmp            = tmap(ind);
    [y,imax]       = max(tmp);
    peak.max(k)    = y;
    peak.clusid(k) = index(k);
    peak.vertid(k) = ind(imax);
    clus.clusid(k) = index(k);
    clus.vert{k}   = ind;
    clus.nvert(k)  = length(ind);
end

if nargin>=6
    %SurfStatWriteData(clus_file,clusid');
    write_curv(clus_file,clusid,size(surf.tri,1));
    if nargin == 7
        curv = curv(:);
        ind  = find(clusid(:)==0);
        curv(ind) = 0;
        %SurfStatWriteData(stmap_file,curv);
        write_curv(stmap_file,curv,size(surf.tri,1));
    end
end
