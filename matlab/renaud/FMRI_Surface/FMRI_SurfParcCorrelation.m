function FMRI_SurfParcCorrelation(fsdir,subjlist,prefix,annot,labelfile,TR,savename)

[labels_vol,names_vol] = textread(labelfile,'%d %s');
labels_vol = labels_vol(17:end);
names_vol  = names_vol(17:end);
nROI       = length(labels_vol);

for s = 1:length(subjlist)

    motionfile    = fullfile(fsdir,subjlist{s},'surffmri','spm','rp_aepi_0000.txt');
    opt.filtering = 0;
    opt.detrend   = 1;
    
    % SUBCORTICAL REGIONS
    meanTimes_ss = FMRI_ExtractMeanTSeriesOfSubCortROI(fsdir,subjlist{s},labelfile,annot,TR,motionfile,opt);
    
    
    % READ FMRI DATA

    List_lh = SurfStatListDir(fullfile(fsdir,subjlist{s},'surffmri',['lh.' prefix '*']));
    List_rh = SurfStatListDir(fullfile(fsdir,subjlist{s},'surffmri',['rh.' prefix '*']));
    Data    = SurfStatReadData([List_lh]);
    data_lh = Data.Data.Data;
    Data    = SurfStatReadData([List_rh]);
    data_rh = Data.Data.Data;
    nbleft  = size(data_lh,1);
    data    = [data_lh;data_rh];
    clear List_rh List_lh Data data_lh data_rh;


    % PREPROCESSING    
    tseries = data';
    clear data;
    tseries = FMRI_ConnPreprocessing(tseries,TR,motionfile,opt);

    data_lh = tseries(:,1:nbleft)';
    data_rh = tseries(:,nbleft+1:end)';


    % EXTRACT MEAN TIME COURSES PER ROI

    [vertices_lh, label_lh, colortable_lh] = read_annotation([fsdir, '/', subjlist{s}, '/label/lh.', annot, '.annot']);
    [vertices_rh, label_rh, colortable_rh] = read_annotation([fsdir, '/', subjlist{s}, '/label/rh.', annot, '.annot']);

    % reorder
    if(s==1)
        Label = [label_lh; label_rh];
        Label = unique(Label);
        
        for i = 1 : nROI
            if ~isempty(findstr(names_vol{i}, 'lh'))
                for j = 1 : length(colortable_lh.struct_names)
                    if ~isempty(strfind(names_vol{i}, char(colortable_lh.struct_names(j))))
                        surface_label(i) = colortable_lh.table(j, end);
                        break;
                    end
                end
            else
                if ~isempty(findstr(names_vol{i}, 'rh'))
                    for j = 1 : length(colortable_rh.struct_names)
                        if ~isempty(strfind(names_vol{i}, char(colortable_rh.struct_names(j))))
                            surface_label(i) = colortable_rh.table(j, end);
                            break;
                        end
                    end
                else
                    surface_label(i) = NaN;
                end
            end
        end
    end
    
    nframes = size(data_lh,2);
    
    for k = 1:nROI
        if ~isempty(findstr(names_vol{k}, 'lh'))
            vert = find(label_lh==surface_label(k));
            meanTimes_co(k,:) = mean(data_lh(vert,:),1);
        else
            vert = find(label_rh==surface_label(k));
            meanTimes_co(k,:) = mean(data_rh(vert,:),1);
        end
        ConnectomeFMRI.region(k).vertex    = vert;
        ConnectomeFMRI.region(k).surflabel = surface_label(k);
        ConnectomeFMRI.region(k).namelabel = names_vol{k};
    end

    % CONNECTIVITY MATRIX

    meanTimes{s} = [meanTimes_ss;meanTimes_co]';

    % Covariance
    nb_t = size(meanTimes{s},1);
    S    = (nb_t-1)*cov(meanTimes{s});

    % Correlation
    D    = diag(1./sqrt(diag(squeeze(S))));
    Corr = D*squeeze(S)*D;
    
    ConnectomeFMRI.Conn = Corr; 
    
    save(fullfile(fsdir,subjlist{s},'surffmri',savename),'ConnectomeFMRI');
    
    clear meanTimes_co data_lh data_rh meanTimes_ss Corr S;
    
end

% 
% 
% %%
% 
% % % Partial Correlation
% % D1       = size(S,1);
% % U        = inv(squeeze(S));
% % DiagMat  = diag(1./sqrt(diag(U)));
% % PartCorr = 2*eye(D1)-DiagMat*U*DiagMat;
% %         
% % % nb_tir     = 100;
% % % tS         = donnees_vers_covariance_hierarchique(donnees,nb_tir);
% % % tR         = covariance_vers_correlation(tS);
% % 
% % % %% HIERARCHICAL CLUSTERING
% % % 
% % % % X    = [meanTimes_lh;meanTimes_rh]';
% % % % type = 'corr';
% % % % hier = FMRI_HierarchicalClustering(X,type);
% % % % save(fullfile(fsdir,subjlist{s},'surffmri','HierClustering.mat'),'hier');
% % % % 
% % % % nbclasses = 40;
% % % % P = FMRI_Hier2Partition(hier,nbclasses,1);
% % % % save(fullfile(fsdir,subjlist{s},'surffmri','HierClustering.mat'),'hier','P','nbclasses');
% % % 
% % % 
% % % %% BUILD MAPS
% % % 
% % % load(fullfile(fsdir,subjlist{s},'surffmri','HierClustering.mat'),'hier','P','nbclasses');
% % % 
% % % % left hemisphere
% % % P_lh   = P(1:nroileft);
% % % map_lh = zeros(size(label_lh));
% % % 
% % % for clus = 1:nbclasses
% % %     
% % %     ind = find(P_lh==clus);
% % %     if(length(ind)>0)
% % %         list_roi = unique(labellist_lh(ind));
% % %         for k = 1:length(list_roi)
% % %             vert = find(label_lh==list_roi(k));
% % %             map_lh(vert) = clus;
% % %         end
% % %     end
% % %     
% % % end
% % % 
% % % % right hemisphere
% % % P_rh   = P(nroileft+1:end);
% % % map_rh = zeros(size(label_rh));
% % % 
% % % for clus = 1:nbclasses
% % %     
% % %     ind = find(P_rh==clus);
% % %     if(length(ind)>0)
% % %         list_roi = unique(labellist_rh(ind));
% % %         for k = 1:length(list_roi)
% % %             vert = find(label_rh==list_roi(k));
% % %             map_rh(vert) = clus;
% % %         end
% % %     end
% % %     
% % % end
% % % 
% % % surf      = SurfStatReadSurf([fullfile(fsdir,subjlist{s},'surf','lh.white')]);
% % % fnumleft  = size(surf.tri,1);
% % % surf      = SurfStatReadSurf([fullfile(fsdir,subjlist{s},'surf','rh.white')]);
% % % fnumright = size(surf.tri,1);
% % % 
% % % %write_annotation(fullfile(fsdir,subjlist{s},'surffmri','lh.HierClustering.annot'), (0:length(subj_surf_left.coord)-1)', Subj_label_left', left_colortable);
% % % 
% % % write_curv(fullfile(fsdir,subjlist{s},'surffmri','lh.HierClustering'),map_lh,fnumleft);
% % % write_curv(fullfile(fsdir,subjlist{s},'surffmri','rh.HierClustering'),map_rh,fnumright);
