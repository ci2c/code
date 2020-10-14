function resClust = FMRI_Thresholding(datapath,resClust,opt)

disp('*****************************************')
disp('T-MAPS THRESHOLDING...')

numvox   = opt.numvox;    
thresT   = opt.thresT;
typeCorr = opt.typeCorr;
clear opt

nsess        = round(length(resClust.compsName)/resClust.nbCompSica);
maskB        = resClust.maskB;
header       = resClust.header;
P            = resClust.P;
opt          = resClust.optClust;
opt.numvox   = numvox;    
opt.thresT   = thresT;
opt.typeCorr = typeCorr;
resClust     = setfield(resClust,'optClust',opt);

[nx,ny,nz] = size(maskB);
maskB_v    = maskB(:);
if isfield(resClust,'tMaps')
    tMaps_pos = resClust.tMaps;
else
    disp(['Warning -- No tMaps'])
    return
end

numClass = size(tMaps_pos,4);
for pp = 1:numClass
    I  = find(P==pp);
    sizeClust(pp) = length(I);
end

if nsess == 1
    
    disp('single run - use individual z-score maps - z-score > 2 and extension > 5 voxels')
    for pp = 1:numClass
        mask_pos(:,:,:,pp) = tMaps_pos(:,:,:,pp) > 2;

        opt_conn.type_neig = 26;
        opt_conn.thre_size = 5;
        [mask_pos2(:,:,:,pp),taille_pos{pp}] = Find_connex_roi(mask_pos(:,:,:,pp),opt_conn);

        tMaps_pos_v(:,pp)  = reshape(tMaps_pos(:,:,:,pp),[nx*ny*nz 1]);
        mask_pos2_v(:,pp)  = reshape(mask_pos2(:,:,:,pp),[nx*ny*nz 1]);
        tMaps_pos_v(squeeze(mask_pos2_v(:,pp))==0,pp) = 0;
    end
    AA = reshape(tMaps_pos_v,[nx ny nz numClass]);
    
else
    
    for pp=1:numClass
        
        if strcmp(typeCorr,'BONF')
            nu                 = sum(sum(sum(maskB>0)));
            thresTcorr         = thresT/nu;
            p_pos(:,:,:,pp)    = (1-spm_Tcdf(tMaps_pos(:,:,:,pp),sizeClust(pp)));
            mask_pos(:,:,:,pp) = p_pos(:,:,:,pp) < thresTcorr;
            
        elseif strcmp(typeCorr,'FDR')
            if pp<10
                V = spm_vol(fullfile(epipath,'Classes',['tMapsClass000',num2str(pp),'.nii']));
                d = spm_read_vols(V);
            else
                V = spm_vol(fullfile(epipath,'Classes',['tMapsClass00',num2str(pp),'.nii']));
                d = spm_read_vols(V);
            end
            thresTcorr         = spm_uc_FDR(thresT,[1 sizeClust(pp)],'T',1,V);
            mask_pos(:,:,:,pp) = tMaps_pos(:,:,:,pp) > thresTcorr;
            
        elseif strcmp(typeCorr,'UNC')
            p_pos(:,:,:,pp)    = (1-spm_Tcdf(tMaps_pos(:,:,:,pp),sizeClust(pp)));
            mask_pos(:,:,:,pp) = p_pos(:,:,:,pp) < thresT;
        end
        
        if length(unique(mask_pos(:,:,:,pp)))>1

            opt_conn.type_neig = 26;
            opt_conn.thre_size = numvox;
            [mask_pos2(:,:,:,pp),taille_pos{pp}] = Find_connex_roi(mask_pos(:,:,:,pp),opt_conn);

            tMaps_pos_v(:,pp) = reshape(tMaps_pos(:,:,:,pp),[nx*ny*nz 1]);
            mask_pos2_v(:,pp) = reshape(mask_pos2(:,:,:,pp),[nx*ny*nz 1]);
            tMaps_pos_v(squeeze(mask_pos2_v(:,pp))==0,pp) = 0;

        else
            mask_pos2(:,:,:,pp) = double(mask_pos(:,:,:,pp));
            taille_pos{pp}      = [];
            tMaps_pos_v(:,pp)   = reshape(tMaps_pos(:,:,:,pp),[nx*ny*nz 1]);
            mask_pos2_v(:,pp)   = reshape(mask_pos2(:,:,:,pp),[nx*ny*nz 1]);
            tMaps_pos_v(squeeze(mask_pos2_v(:,pp))==0,pp) = 0;
        end

    end
    AA = reshape(tMaps_pos_v,[nx ny nz numClass]);
    
end

delete([datapath filesep 'Classes' filesep 'Thres_tMapsClass*.nii']);

st_write_nifti(AA,header,[datapath filesep 'Classes' filesep 'Thres_tMapsClass']);

if isfield(resClust,'COI')

    selCOI   = resClust.COI.num;
    labelCOI = resClust.COI.label;
    clear resClust

    [a,b] = mkdir([datapath filesep 'Classes'],'COI');
    delete([datapath filesep 'Classes' filesep 'COI' filesep '*.*'])

    for pp = 1:length(selCOI)
        if(isunix)
            if selCOI(pp)<10
                unix(['cp ', fullfile(datapath,'Classes',['tMapsClass000',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['tMaps_',labelCOI{pp},'.nii'])]);
                unix(['cp ', fullfile(datapath,'Classes',['Thres_tMapsClass000',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['Thres_tMaps_',labelCOI{pp},'.nii'])]);
            else
                unix(['cp ', fullfile(datapath,'Classes',['tMapsClass00',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['tMaps_',labelCOI{pp},'.nii'])]);
                unix(['cp ', fullfile(datapath,'Classes',['Thres_tMapsClass00',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['Thres_tMaps_',labelCOI{pp},'.nii'])]);
            end
        elseif(ispc)
            if selCOI(pp)<10
                copyfile(fullfile(datapath,'Classes',['tMapsClass000',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['tMaps_',labelCOI{pp},'.nii']));
                copyfile(fullfile(datapath,'Classes',['Thres_tMapsClass000',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['Thres_tMaps_',labelCOI{pp},'.nii']));
            else
                copyfile(fullfile(datapath,'Classes',['tMapsClass00',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['tMaps_',labelCOI{pp},'.nii']));
                copyfile(fullfile(datapath,'Classes',['Thres_tMapsClass00',num2str(selCOI(pp)),'.nii ']), fullfile(datapath,'Classes','COI',['Thres_tMaps_',labelCOI{pp},'.nii']));
            end

        end
    end
end
