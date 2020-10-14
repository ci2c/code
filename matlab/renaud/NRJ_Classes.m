function [nbclasses,resClust] = NRJ_Classes(epipath,resClust,maskfile,opt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('*****************************************')
disp('CLASSES T-MAPS COMPUTING...')

nsess = round(length(resClust.compsName)/resClust.nbCompSica);

% Recherche des donnees selectionnees
nbclasses     = opt.nbclasses; 
typeThresHier = opt.thresHierType;

compsName     = resClust.compsName;
V             = spm_vol(maskfile);
maskB_sica    = spm_read_vols(V);
maskB_sica    = maskB_sica > 0;
hier          = resClust.hier;
contrib       = resClust.contrib;
header_sica   = resClust.header_sica;
nbCompSica    = resClust.nbCompSica;
timeCourses   = resClust.timeCourses;
[nx,ny,nz]    = size(maskB_sica);
maskB_sica_v  = maskB_sica(:);

if nsess == 1
    
    disp('single run - use individual absolute sica components')
    disp('single run - force number of classes equal to the number of sica components')
    nbclasses     = nbCompSica;
    opt.nbclasses = nbclasses;
    disp(['number of classes : ',num2str(nbclasses)])
    s             = findstr(compsName{1},filesep);
    subjectName   = compsName{1}(1:s(1)-1);
    rundir        = [res_dir filesep subjectName filesep condName filesep runName filesep];
    [LFNcomps,V]  = st_read_analyze('sica_comp*.img',fullfile(epipath,subjectName,'spatialComp'),0);
    tMaps         = LFNcomps;
    P             = ned_hier2P(hier,nbclasses,1);
    
else
    
    if strcmp(typeThresHier,'auto')
        disp(['classes determination type : ',typeThresHier])
        P             = NRJ_SelHierClass(hier,compsName);
        nbclasses     = max(P);
        opt.nbclasses = nbclasses;
        disp(['number of classes : ',num2str(nbclasses)])
    elseif strcmp(typeThresHier,'manual')
        disp(['classes determination type : ',typeThresHier])
        disp(['number of classes : ',num2str(nbclasses)])
        P = ned_hier2P(hier,nbclasses,1);
    end
    
    load(fullfile(epipath,'resClustData.mat'))
    
    % Prise en compte du signe
    meanMaps = zeros(nx*ny*nz,1);
    varMaps  = zeros(nx*ny*nz,1);
    tMaps    = zeros(nx*ny*nz,max(P));
    signComp = [];
    
    for pp =1:max(P)
        disp(num2str(pp))
        if length(find(P==pp))<500
            data = dataHier(:,find(P==pp));
            C    = zeros(size(data,2),size(data,2));
            for ppp=1:size(data,2)
                for qqq=1:size(data,2)
                    C(ppp,qqq) = data(:,ppp)'*data(:,qqq);
                end
            end
            S        = (1/(size(data,1)-1)).*C;
            R        = S./sqrt(diag(S)*diag(S)');
            R(eye(size(R))==1) = 0;
            [M,I]    = max(abs(R));
            clear C R S
            [MM,J]   = max(M);
            signR    = sign((1/(size(data,1)-1))*data(:,J)'*data);
            signComp = [signComp signR];
            gI       = mean(data.*repmat(signR,size(data,1),1),2);
            varI     = var(data.*repmat(signR,size(data,1),1),[],2);
            clear data
            meanMaps(maskB_sica_v,1) = gI';
            clear gI
            varMaps(maskB_sica_v,1)  = varI';
            clear varI
            tMaps(maskB_sica_v,pp) = meanMaps(maskB_sica_v,1)./sqrt(varMaps(maskB_sica_v,1)).*sqrt(length(I)-1);
        else
            tMaps(maskB_sica_v,pp) = 1;
        end
    end
    
    clear meanMaps varMaps dataHier
    tMaps = reshape(tMaps,[nx ny nz max(P)]);
    
end

header_sica.fname = '';

disp(['stats processing...'])
represent = [];
unicity   = [];
for uu=1:nbclasses
    AA = char(compsName{find(P == uu)});
    [represent(uu),unicity(uu)] = NRJ_ComputeScores(AA,nsess);
end
 
numClass  = size(tMaps,4);
tMaps_pos = tMaps;

[success] = mkdir(epipath,'Classes');
delete([epipath filesep 'Classes' filesep 'tMapsClass*.nii']);

st_write_nifti(tMaps_pos,header_sica,[epipath filesep 'Classes' filesep 'tMapsClass']);

resClust.compsName   = compsName;
resClust.maskB       = maskB_sica;
resClust.hier        = hier;
resClust.contrib     = contrib;
resClust.timeCourses = timeCourses;
resClust.header_sica = header_sica;
resClust.header      = header_sica;
resClust.nbCompSica  = nbCompSica;
resClust.P           = P;
resClust.tMaps       = tMaps;
resClust.represent   = represent;
resClust.unicity     = unicity;
resClust.optClust    = opt;

    