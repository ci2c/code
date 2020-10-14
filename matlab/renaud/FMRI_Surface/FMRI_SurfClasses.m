function [numClass,resClust] = FMRI_SurfClasses(fspath,sesspath,sessname,resClust,opt)

% usage : resClust = FMRI_SurfClasses(fspath,sesspath,sessname,resClust,opt)
%
% Inputs :
%    fspath        : path to freesurfer folder
%    sesspath      : path to data
%    sessname      : list of subjects
%    resClust      : structure of clustering results
%    opt           : options (structure: nbclasses - thresHierType: 'auto'
%    or 'manual')
%
% Output :
%    numClass      : number of classes
%    resClust      : structure of clustering results
%
% Renaud Lopes @ CHRU Lille, Mar 2012

if nargin ~= 5
    error('invalid usage');
end

compsName_lh  = resClust.compsName_lh;
compsName_rh  = resClust.compsName_rh;
hier          = resClust.hier;
contrib       = resClust.contrib;
nbCompSica    = resClust.nbCompSica;
timeCourses   = resClust.timeCourses;

nbclasses     = opt.nbclasses; 
typeThresHier = opt.thresHierType;

if length(sessname) == 1
    
    disp('single run - use individual absolute sica components')
    disp('single run - force number of classes equal to the number of sica components')
    nbclasses     = nbCompSica;
    opt.nbclasses = nbclasses;
    disp(['number of classes : ',num2str(nbclasses)])
    
    load([fullfile(sesspath,sessname{1}) '/bold/001/ica/sica.mat'],'sica');
    tMaps       = zeros(size(sica.S,1),nbCompSica);
    [tmp, fnum] = read_curv([fullfile(sesspath,sessname{1}) '/bold/001/ica/lh.ica_map_1']);
    nbleft      = length(tmp);
    
    for j = 1:nbCompSica
        [tmp, fnum]           = read_curv([fullfile(sesspath,sessname{1}) '/bold/001/ica/lh.ica_map_' num2str(j)]);
        tMaps(1:nbleft,j)     = tmp(:);
        [tmp, fnum]           = read_curv([fullfile(sesspath,sessname{1}) '/bold/001/ica/rh.ica_map_' num2str(j)]);
        tMaps(nbleft+1:end,j) = tmp(:);
        clear tmp;
    end
    
    P = FMRI_Hier2Partition(hier,nbclasses,1);
    
else
    
    if strcmp(typeThresHier,'auto')
        
        disp(['classes determination type : ',typeThresHier])
        P             = FMRI_SelectionHierClass(hier,compsName_lh,compsName_rh,sessname);
        nbclasses     = max(P);
        opt.nbclasses = nbclasses;
        disp(['number of classes : ',num2str(nbclasses)])
        
    elseif strcmp(typeThresHier,'manual')
        
        disp(['classes determination type : ',typeThresHier])
        disp(['number of classes : ',num2str(nbclasses)])
        P = FMRI_Hier2Partition(hier,nbclasses,1);
        
    end
    
    load(fullfile(sesspath,'resClustData.mat'),'dataHier');

    % Prise en compte du signe
    meanMaps = zeros(size(dataHier,1),1);
    varMaps  = zeros(size(dataHier,1),1);
    tMaps    = zeros(size(dataHier,1),max(P));
    signComp = [];
    for pp = 1:max(P)
        
        disp(num2str(pp))
        
        if length(find(P==pp))<500
            data = dataHier(:,find(P==pp));
            C    = zeros(size(data,2),size(data,2));
            for ppp=1:size(data,2)
                for qqq=1:size(data,2)
                    C(ppp,qqq) = data(:,ppp)'*data(:,qqq);
                end
            end
            S                  = (1/(size(data,1)-1)).*C;
            R                  = S./sqrt(diag(S)*diag(S)');
            R(eye(size(R))==1) = 0;
            [M,I]              = max(abs(R));
            clear C R S
            [MM,J]             = max(M);
            signR              = sign((1/(size(data,1)-1))*data(:,J)'*data);
            signComp           = [signComp signR];
            gI                 = mean(data.*repmat(signR,size(data,1),1),2);
            varI               = var(data.*repmat(signR,size(data,1),1),[],2);
            clear data
            meanMaps(:,1)      = gI';
            clear gI
            varMaps(:,1)       = varI';
            clear varI
            tMaps(:,pp)        = meanMaps(:,1)./sqrt(varMaps(:,1)).*sqrt(length(I)-1);
            df(pp)             = length(I)-1;
        else
            tMaps(:,pp)        = 1;
        end
        
    end
    
    clear dataHier
    
end

disp(['stats processing...'])
represent = [];
unicity   = [];
for uu=1:nbclasses
    AA = char(compsName_lh{find(P == uu)});
    [represent(uu),unicity(uu)] = FMRI_ComputeScores(AA,sessname);
end

numClass = size(tMaps,2);
tMaps(isnan(tMaps)) = 0;

resClust.compsName_lh = compsName_lh;
resClust.compsName_rh = compsName_rh;
resClust.hier         = hier;
resClust.contrib      = contrib;
resClust.timeCourses  = timeCourses;
resClust.nbCompSica   = nbCompSica;
resClust.P            = P;
resClust.tMaps        = tMaps;
resClust.meanMaps     = meanMaps;
resClust.varMaps      = varMaps;
resClust.df           = df;
resClust.represent    = represent;
resClust.unicity      = unicity;
resClust.optClust     = opt;

