function [resClust,dataHier] = NRJ_HierClustering(list_res,ncomp)

numcomp     = 0;
dataHier    = [];
contrib     = [];
timeCourses = [];
compsName   = [];

for k = 1:length(list_res)
    
    load(list_res{k});
    
    if k==1 
        ntt    = length(sica.A(:,1));
        %header = sica.header;
    end
    
    pathr = fileparts(list_res{k});
    
    complist = SurfStatListDir( fullfile(pathr,'ica_map_*') );
    
    for qq=1:ncomp
        s        = findstr(complist{qq},filesep);
        compname = complist{qq}(s(end-2)+1:end);
        compsName{numcomp+qq} = compname;
        J = strfind(compname,'map_');
        K = strfind(compname,'.nii');
        comp = str2num(compname(J(end)+4:K(end)-1));
        contrib(numcomp+qq) = sica.contrib(comp);

        timeCourses(:,numcomp+qq) = sica.A(1:ntt,comp);
    end
    
    d           = sica.S;
    d(isnan(d)) = 0;
    numcomp     = ncomp+numcomp;
    dataHier(:,numcomp-ncomp+1:numcomp) = st_normalise(d);
    
    clear sica;
    
end
    
disp('hierarchy computing...')
hier = ned_hier_clustering(dataHier,'corr'); 

resClust.compsName   = compsName;
resClust.hier        = hier;
resClust.contrib     = contrib;
resClust.timeCourses = timeCourses;
%resClust.header_sica = header;
resClust.nbCompSica  = size(dataHier,2)/length(list_res);

