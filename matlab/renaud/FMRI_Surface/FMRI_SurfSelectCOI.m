function resClust = FMRI_SurfSelectCOI(resClust,listCOI)

% usage : resClust = FMRI_SurfInterestClasses(resClust,nbleft,templatepath,type,listCOI)
%
% Inputs :
%    resClust      : structure of clustering results
%    listCOI       : list of COI (for manual selection) 
%
% Output :
%    resClust      : structure of clustering results
%
% Renaud Lopes @ CHRU Lille, July 2012

resClust.COI      = [];
resClust.COI.type = 'manual';
resClust.COI.num  = listCOI;
