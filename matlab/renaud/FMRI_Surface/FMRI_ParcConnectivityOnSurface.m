function varargout = FMRI_ParcConnectivityOnSurface(epiFiles,annotFiles,outFile)

% % SUBCORTICAL REGIONS
% meanTimes_ss = FMRI_ExtractMeanTSeriesOfSubCortROI(fsdir,subjlist{s},labelfile,annot,TR,motionfile,opt);
    
    
% READ FMRI DATA

tseries     = [];
std_tseries = [];
labels      = {};

optn1.type = 'mean_var';
optn2.type = 'mean_var';

% Subcortical regions
sub_lab = {'Thalamus_L','Thalamus_R','VentralDC_L','VentralDC_R','Caudate_L','Caudate_R','Putamen_L','Putamen_R','Pallidum_L','Pallidum_R','Accumbens_L','Accumbens_R','Hippocampus_L','Hippocampus_R','Amygdala_L','Amygdala_R'};
sub_ind = [10 49 28 60 11 50 12 51 13 52 26 58 17 53 18 54];

[hvol,vol]   = niak_read_vol(epiFiles{3});
[hparc,parc] = niak_read_vol(annotFiles{3});

[nx,ny,nz,nt] = size(vol);
vol           = reshape(vol,nx*ny*nz,nt)';
vol           = niak_normalize_tseries(vol,optn1);
parc          = parc(:);

% remove voxels with nan value
idd  = find(~isnan(mean(vol,1)));
vol  = vol(:,idd);
parc = parc(idd);

for k = 1:length(sub_ind)
    idx_vox = find(parc==sub_ind(k));
    if length(idx_vox)>0
        tseries       = [tseries mean(vol(:,idx_vox),2)];
        std_tseries   = [std_tseries std(vol(:,idx_vox),0,2)];
    else
        disp([sub_lab{k} ' no voxel'])
        tseries       = [tseries zeros(size(vol,1),1)];
        std_tseries   = [std_tseries zeros(size(vol,1),1)];
    end
    labels{end+1} = sub_lab{k};
end

for k = 1:length(epiFiles)-1
    
    hdr{k}    = load_nifti(epiFiles{k});
    data{k}   = squeeze(hdr{k}.vol)';
    nbvert(k) = size(data{k},1);
    
    data{k} = niak_normalize_tseries(data{k},optn1);

    % EXTRACT MEAN TIME COURSES PER ROI

    [vert_tmp, label_tmp, table_tmp] = read_annotation(annotFiles{k}); 

    % hemisphere
    for j = 1:length(table_tmp.struct_names)

        if ~strcmp(table_tmp.struct_names{j},'Unknown') && ~strcmp(table_tmp.struct_names{j},'Medial_wall')
            
            idx = find(label_tmp==table_tmp.table(j,5));
            if length(idx)>0
                idx_vert      = vert_tmp(idx)+1;
                tseries       = [tseries mean(data{k}(:,idx_vert),2)];
                std_tseries   = [std_tseries std(data{k}(:,idx_vert),0,2)];
            else
                disp([table_tmp.struct_names{j} ' no vertex'])
                tseries       = [tseries zeros(size(data{k},1),1)];
                std_tseries   = [std_tseries zeros(size(data{k},1),1)];
            end
            labels{end+1} = table_tmp.struct_names{j};
            
        end

    end
    
end

% normalization
%tseries = niak_normalize_tseries(tseries,optn2);

% BUILD CONNECTOME
optConn.typeConn='R';
switch optConn.typeConn
    case 'S'
        Cmat = niak_build_srup(tseries,true);
    case 'R' 
        [tmp,Cmat] = niak_build_srup(tseries,true);
    case 'Z' 
        [tmp,Cmat] = niak_build_srup(tseries,true);
        Cmat = niak_fisher(Cmat);
    case 'U'
        [tmp,tmp2,Cmat] = niak_build_srup(tseries,true);
    case 'P' 
        [tmp,tmp2,tmp3,Cmat] = niak_build_srup(tseries,true);
    otherwise
        error('%s is an unknown type of connectome',optConn.typeConn)
end
Cmat(isnan(Cmat)) = 0;

Cmat = niak_vec2mat(Cmat,0);

varargout = {Cmat,labels,tseries,std_tseries};
varargout = varargout(1:nargout);

    

%     % CONNECTIVITY MATRIX
% 
%     meanTimes{s} = [meanTimes_ss;meanTimes_co]';
% 
%     % Covariance
%     nb_t = size(meanTimes{s},1);
%     S    = (nb_t-1)*cov(meanTimes{s});
% 
%     % Correlation
%     D    = diag(1./sqrt(diag(squeeze(S))));
%     Corr = D*squeeze(S)*D;
%     
%     ConnectomeFMRI.Conn = Corr; 
%     
%     save(fullfile(fsdir,subjlist{s},'surffmri',savename),'ConnectomeFMRI');
%     
%     clear meanTimes_co data_lh data_rh meanTimes_ss Corr S;
    