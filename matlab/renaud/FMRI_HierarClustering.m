function [resClust,dataHier] = FMRI_HierarClustering(outfolder,subjectlist,Ncomp)

numcomp     = 0;
dataHier    = [];
contrib     = [];
timeCourses = [];
compsName   = [];

maskfile   = fullfile(outfolder,'nedica','maskB.nii');
V          = spm_vol(maskfile);
maskB_sica = spm_read_vols(V);
clear V;
maskB_sica = maskB_sica > 0;

[nx,ny,nz]   = size(maskB_sica);
maskB_sica_v = maskB_sica(:);
disp('Components loading...')
load(fullfile(outfolder,'nedica','sizeDataHier.mat'),'sizeDataHier');
dataHier = zeros(sum(maskB_sica_v>0),sizeDataHier);
ntt      = 10000;
    
for k = 1:length(subjectlist)
    
    subj = subjectlist{k};
       
    load(fullfile(outfolder,'nedica',subj,'sica.mat'));
    
    if k==1 
        ntt = length(sica.A(:,1));
    end
    
    DirImg = dir(fullfile(outfolder,'nedica',subj,'spatialComp','wsica_comp*'));
    FileList = [];
    for j = 1:length(DirImg)
        FileList = [FileList;fullfile(outfolder,'nedica',subj,'spatialComp',[DirImg(j).name])];
    end
    V         = spm_vol(FileList);
    header    = V(1);
    header.dt = [16 0];
    LFNcomps  = spm_read_vols(V);
    
    for qq=1:Ncomp
        s        = findstr(V(1).fname,filesep);
        compname = V(1).fname(s(end-2)+1:end);
        compsName{numcomp+qq} = compname;
        J    = strfind(compname,'comp');
        K    = strfind(compname,'.nii');
        comp = str2num(compname(J(end)+4:K(end)-1));
        contrib(numcomp+qq) = sica.contrib(comp);

        timeCourses(:,numcomp+qq) = sica.A(1:ntt,comp);
    end
    
    numcomp = Ncomp+numcomp;
    [nx,ny,nz,ncomp] = size(LFNcomps);
    d = reshape(LFNcomps,[nx*ny*nz,ncomp]);
    clear LFNcomps
    d = d(maskB_sica_v,:);
    d(isnan(d)) = 0;
    dataHier(:,numcomp-Ncomp+1:numcomp) = st_normalise(d);
    clear d V
    
    clear sica;
    
end

disp('hierarchy computing...')
hier = ned_hier_clustering(dataHier,'corr'); 

resClust.compsName   = compsName;
resClust.hier        = hier;
resClust.contrib     = contrib;
resClust.timeCourses = timeCourses;
resClust.header_sica = header;
resClust.nbCompSica  = size(dataHier,2)/length(subjectlist);

clear compsName hier contrib timeCourses header numcomp;