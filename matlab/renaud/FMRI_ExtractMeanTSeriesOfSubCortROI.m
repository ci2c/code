function meanTimes_ss = FMRI_ExtractMeanTSeriesOfSubCortROI(fsdir,subj,labelfile,annot,TR,motionfile,opt)

[labels_ss,names_ss] = textread(labelfile,'%d %s',16);

meanfile   = fullfile(fsdir,subj,'surffmri','spm','meanaepi_0000.nii');
P          = spm_vol(meanfile);
rot_func   = P.mat(1:3,1:3);
trans_func = P.mat(1:3,4);

tmpfile    = fullfile(fsdir,subj,'mri',[annot '.mgz']);
parcfile   = fullfile(fsdir,subj,'mri',[annot '_las.nii']);
if (~exist(parcfile,'file'))
    cmd = sprintf('mri_convert %s %s --out_orientation LAS',tmpfile,parcfile);
    unix(cmd);
end
V          = spm_vol(parcfile);
parc       = spm_read_vols(V);
[nx ny nz] = size(parc);
rot        = V.mat(1:3,1:3);
trans      = V.mat(1:3,4);


for i=1:length(labels_ss)
    ind=find(parc(:)==labels_ss(i));
    [x{i},y{i},z{i}]=ind2sub([nx,ny,nz],ind);
end

mask = zeros(P.dim);

% spatial smoothing
DirImg = dir(fullfile(fsdir,subj,'surffmri','spm',['vs*.nii']));
if (length(DirImg)>0)
    fileslist = [];
    for j = 1:length(DirImg)
        fileslist = [fileslist; fullfile(fsdir,subj,'surffmri','spm',[DirImg(j).name])];
    end
else
    DirImg        = dir(fullfile(fsdir,subj,'surffmri','spm',['raepi*.nii']));
    filestosmooth = [];
    fileslist     = [];
    for j = 1:length(DirImg)
        filestosmooth = [filestosmooth;fullfile(fsdir,subj,'surffmri','spm',[DirImg(j).name])];
        fileslist     = [fileslist; fullfile(fsdir,subj,'surffmri','spm',['vs' DirImg(j).name])];
        spm_smooth(filestosmooth(j,:),fileslist(j,:),[6 6 6]);
    end
end
hdr = spm_vol(fileslist);
epi = spm_read_vols(hdr);

meanTimes_ss = zeros(size(epi,4),length(x));
vecepi       = reshape(epi,size(epi,1)*size(epi,2)*size(epi,3),size(epi,4));
for i = 1:length(x)
    
    if(length(x{i}>0))
        
        for j = 1:length(x{i})
            coord{i}(j,:) = (rot * [x{i}(j) y{i}(j) z{i}(j)]' + trans)' ;
        end
        nvox = size(coord{i},1);
        for j = 1:nvox
            vox(:,j) = round(inv(rot_func)*(coord{i}(j,:)' - trans_func));
            if(vox(3,j)<1)
                vox(3,j) = 1;
            elseif(vox(3,j)>P.dim(3))
                vox(3,j) = P.dim(3);
            end
            mask(vox(1,j),vox(2,j),vox(3,j)) = labels_ss(i);
        end
        
        ind     = find(mask(:)==labels_ss(i));
        courses = vecepi(ind,:)';
        
        courses = FMRI_ConnPreprocessing(courses,TR,motionfile,opt);
        meanTimes_ss(:,i) = mean(courses,2);
        clear courses;
            
    end
    
end
P.fname = fullfile(fsdir,subj,'surffmri','mask_ss.nii');
spm_write_vol(P,mask);

meanTimes_ss = meanTimes_ss';

