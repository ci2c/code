function [trend,mask] = FMRI_NoiseDetrending(epifiles,meanfile,parcfile,opt_detrend)

hdr        = spm_vol(epifiles);
epi        = spm_read_vols(hdr);
clear hdr;

P          = spm_vol(meanfile);
rot_func   = P.mat(1:3,1:3);
trans_func = P.mat(1:3,4);

V          = spm_vol(parcfile);
parc       = spm_read_vols(V);
[nx ny nz] = size(parc);
rot        = V.mat(1:3,1:3);
trans      = V.mat(1:3,4);

mask  = zeros(P.dim);
trend = [];

%% Mask of ventricules

if opt_detrend.vent == 1
    
    class = [4 43];

    for i=1:length(class)
        ind=find(parc(:)==class(i));
        [x{i},y{i},z{i}]=ind2sub([nx,ny,nz],ind);
    end

    tmp = [];
    
    for i = 1:length(x)

        if(length(x{i}>0))
            for j = 1:length(x{i})
                coord{i}(j,:) = (rot * [x{i}(j) y{i}(j) z{i}(j)]' + trans)' ;
            end
            nb_vox = size(coord{i},1);

            for num_vox = 1:nb_vox
                vox(:,num_vox) = round(inv(rot_func)*(coord{i}(num_vox,:)' - trans_func));
                if(vox(3,num_vox)<1)
                    vox(3,num_vox) = 1;
                elseif(vox(3,num_vox)>P.dim(3))
                    vox(3,num_vox) = P.dim(3);
                end
                mask(vox(1,num_vox),vox(2,num_vox),vox(3,num_vox)) = 1;
                tmp = [tmp squeeze(epi(vox(1,num_vox),vox(2,num_vox),vox(3,num_vox),:))];
            end
        end

    end   

    trend = [trend mean(tmp,2)];
    
    clear x y z coord class tmp;
    
end

%% Mask of brainstem

if opt_detrend.stem == 1
    
    class = [16];

    for i=1:length(class)
        ind=find(parc(:)==class(i));
        [x{i},y{i},z{i}]=ind2sub([nx,ny,nz],ind);
    end
    
    tmp = [];

    for i = 1:length(x)

        if(length(x{i}>0))
            for j = 1:length(x{i})
                coord{i}(j,:) = (rot * [x{i}(j) y{i}(j) z{i}(j)]' + trans)' ;
            end
            nb_peak = size(coord{i},1);

            for num_vox = 1:nb_vox
                vox(:,num_vox) = round(inv(rot_func)*(coord{i}(num_vox,:)' - trans_func));
                if(vox(3,num_vox)<1)
                    vox(3,num_vox) = 1;
                elseif(vox(3,num_vox)>P.dim(3))
                    vox(3,num_vox) = P.dim(3);
                end
                mask(vox(1,num_vox),vox(2,num_vox),vox(3,num_vox)) = 2;
                tmp = [tmp squeeze(epi(vox(1,num_vox),vox(2,num_vox),vox(3,num_vox),:))];
            end
        end

    end 
    
    trend = [trend mean(tmp,2)];

    clear x y z coord class tmp;

end

