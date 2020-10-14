function [numClass,resClust] = FMRI_VolDoClasses(datalist,subjlist,prefix,resClust,outdir,opt,maskFile)

% usage : resClust = FMRI_VolDoClasses(fspath,sesspath,sessname,resClust,opt,maskFile)
%
% Inputs :
%    datalist      : data list
%    subjlist      : subjects list
%    prefix        : ica maps prefix
%    resClust      : structure of clustering results
%    outdir        : output folder
%    opt           : options (structure: nbclasses - thresHierType: 'auto'
%    or 'manual')
%    maskFile      : mask file
%
% Output :
%    numClass      : number of classes
%    resClust      : structure of clustering results
%
% Renaud Lopes @ CHRU Lille, Feb 2013

if nargin ~= 7
    error('invalid usage');
end

compsName   = resClust.compsName;
hier        = resClust.hier;
contrib     = resClust.contrib;
nbCompSica  = resClust.nbCompSica;
timeCourses = resClust.timeCourses;

nbclasses     = opt.nbclasses; 
typeThresHier = opt.thresHierType;

hdrmask = spm_vol(maskFile);
mask    = spm_read_vols(hdrmask);
indmask = find(mask(:)>0);

s   = strfind(compsName{1},'/');
ind = strfind(compsName{1},subjlist{1});
pos = find(s==ind-1);
compsName{1} = compsName{1}(s(pos)+1:end);
for k = 2:length(compsName)
    s = strfind(compsName{k},'/');
    compsName{k} = compsName{k}(s(pos)+1:end);
end

if length(subjlist) == 1
    
    disp('single run - use individual absolute sica components')
    disp('single run - force number of classes equal to the number of sica components')
    nbclasses     = nbCompSica;
    opt.nbclasses = nbclasses;
    disp(['number of classes : ',num2str(nbclasses)])
    
    load(fullfile(datalist{1},'sica.mat'),'sica');
    tMaps = zeros(size(sica.S,1),nbCompSica);
    
    for j = 1:nbCompSica
        hdrtmp     = spm_vol(fullfile(datalist{1},[prefix num2str(j) '.nii']));
        tmp        = spm_read_vols(hdrtmp);
        dim        = size(tmp);
        tmp        = tmp(:);
        tmp        = tmp(indmask);
        tMaps(:,j) = tmp;
        clear tmp;
    end
    
    P = FMRI_Hier2Partition(hier,nbclasses,1);
    
else
    
    if strcmp(typeThresHier,'auto')
        
        disp(['classes determination type : ',typeThresHier])
        P             = FMRI_VolSelectionHierClass(hier,compsName,subjlist);
        nbclasses     = max(P);
        opt.nbclasses = nbclasses;
        disp(['number of classes : ',num2str(nbclasses)])
        
    elseif strcmp(typeThresHier,'manual')
        
        disp(['classes determination type : ',typeThresHier])
        disp(['number of classes : ',num2str(nbclasses)])
        P = FMRI_Hier2Partition(hier,nbclasses,1);
        
    end
    
    load(fullfile(outdir,'resClustData.mat'),'dataHier');

    % Prise en compte du signe
    meanMaps = zeros(size(dataHier,1),1);
    varMaps  = zeros(size(dataHier,1),1);
    tMaps    = zeros(size(dataHier,1),max(P));
    signComp = [];
    for pp = 1:max(P)
        
        disp(num2str(pp))
        
        if length(find(P==pp)) < 500
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
    AA = char(compsName{find(P == uu)});
    [represent(uu),unicity(uu)] = FMRI_ComputeScores(AA,subjlist);
end

numClass = size(tMaps,2);
tMaps(isnan(tMaps)) = 0;

resClust.clusName    = compsName;
resClust.hier        = hier;
resClust.contrib     = contrib;
resClust.timeCourses = timeCourses;
resClust.nbCompSica  = nbCompSica;
resClust.P           = P;
resClust.tMaps       = tMaps;
resClust.meanMaps    = meanMaps;
resClust.varMaps     = varMaps;
resClust.df          = df;
resClust.represent   = represent;
resClust.unicity     = unicity;
resClust.optClust    = opt;
