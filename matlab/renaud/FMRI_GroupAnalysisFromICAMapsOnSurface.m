function [numClass,resClust,SdataHier] = FMRI_GroupAnalysisFromICAMapsOnSurface(resClust,pref_ica)

compsName_lh = {};
compsName_rh = {};
for k = 1 : length(resClust.compsName)
    
    disp(['Loading subject: ' num2str(k)])
    
    [p,n,e] = fileparts(resClust.compsName{k});
    if(~isempty(str2num(n(end-2:end))))
        ind = str2num(n(end-2:end));
    elseif(~isempty(str2num(n(end-1:end))))
        ind = str2num(n(end-1:end));
    else
        ind = str2num(n(end));
    end
    compsName_lh{k} = fullfile(p,['lh.' pref_ica num2str(ind) '.mgh']);
    compsName_rh{k} = fullfile(p,['rh.' pref_ica num2str(ind) '.mgh']);
    
    if(k==1)
        tmp       = load_mgh(compsName_lh{k});
        nbleft    = length(tmp);
        tmp       = load_mgh(compsName_rh{k});
        nbright   = length(tmp);
        SdataHier = zeros(nbleft+nbright,length(resClust.compsName));
        clear tmp;
    end
    
    d                 = zeros(nbleft+nbright,1);
    tmp               = load_mgh(compsName_lh{k});
    d(1:nbleft,1)     = tmp(:);
    tmp               = load_mgh(compsName_rh{k});
    d(nbleft+1:end,1) = tmp(:);
    d(isnan(d))       = 0;
    SdataHier(:,k)    = st_normalise(d);
    clear d;
   
end

P = resClust.P;
numClass = max(P);

% Prise en compte du signe
SmeanMaps = zeros(size(SdataHier,1),1);
SvarMaps  = zeros(size(SdataHier,1),1);
StMaps    = zeros(size(SdataHier,1),numClass);
signComp  = [];

for pp = 1:numClass

    disp(num2str(pp))

    ind = find(P==pp);
    if length(find(P==pp))<500
        data = SdataHier(:,find(P==pp));
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
        SmeanMaps(:,1)     = gI';
        clear gI
        SvarMaps(:,1)      = varI';
        clear varI
        StMaps(:,pp)       = SmeanMaps(:,1)./sqrt(SvarMaps(:,1)).*sqrt(length(I)-1);
        df(pp)             = length(I)-1;
    else
        StMaps(:,pp)       = 1;
    end

end

resClust.compsName_lh = compsName_lh;
resClust.compsName_rh = compsName_rh;
resClust.StMaps       = StMaps;
resClust.SmeanMaps    = SmeanMaps;
resClust.SvarMaps     = SvarMaps;
