function varargout = FMRI_BuildConnectivityMatrix(epiFile,roiFile,motionFile,varargin)

% usage : resClust = FMRI_SurfDoClasses(fspath,sesspath,sessname,resClust,opt)
%
% Inputs :
%    epiFile       : functional EPI file (.nii)
%    roiFile       : mask of ROIs (.nii)
%    motionFile    : motion parameters (.txt)
%
% Options
%    TR            : TR value (Default: 2)
%    detrending    : do detrending (Default: True)
%    filtering     : do filtering (Default: True)
%    hp            : high-pass filter value (Default: 0.01)
%    lp            : low-pass filter value (Default: 0.08)
%    smoothing     : do temporal smoothing (Default: false)
%    normalize     : do normalization (Default: true)
%    keeprois      : ROIs of the mask (Default: 1:nrois)
%    nameRoi       : name of ROIs (Default: AAL template)
%    tempFile      : template file (Default: AAL template)
%    method        : type of correlation ("correlation" - "" - "") (Default: 'correlation') 
%    path_to_gen   : add path to matlab (Default: true)
%
% Output :
%    Z             : fisher to Z data
%    C             : correlation vector
%    Cmat          : correlation matrix
%    coord         : ROIs coordinate
%    nameRoi       : name of ROIs
%    tseries       : mean time course for each ROI
%    data          : preprocessing data
%
% Renaud Lopes @ CHRU Lille, Sept 2013

Vroi = spm_vol(roiFile);
roi  = spm_read_vols(Vroi);
roi  = round(roi);
rois_to_keep = unique(roi(:));
rois_to_keep = rois_to_keep(2:end);

%----------default arguments-----------
Args = struct('TR',2,... 
            'detrending',true, ...
            'filtering',true, ...
            'hp',0.01, ...
            'lp',0.08, ...
            'smoothing',false, ...
            'normalize',true, ...
            'keeprois',rois_to_keep, ...
            'tempFile','/home/renaud/NAS/nicolas/M2/fmri_results/volume/ClusAll/raal.img', ...
            'method','correlation', ...
            'path_to_gen',true);

Args = parseArguments(varargin,Args,{'BlackandWhite'});

if Args.path_to_gen
    addpath('/home/notorious/NAS/renaud/scripts');
    addpath(genpath('/home/renaud/NAS/renaud/scripts/francois/captain'));
    addpath(genpath('/home/renaud/NAS/renaud/scripts/francois/Graphical_Lasso'));
    addpath(genpath('/home/renaud/NAS/renaud/scripts/wtc-r16'));
end

Vepi = spm_vol(epiFile);
epi  = spm_read_vols(Vepi);


%% ROIs

[numRoi,aalRoi,nums] = textread('/home/renaud/matlab/nbw_0.1/nbw_main_0.1/aal/aal.txt','%d%s%d');
Vaal = spm_vol(Args.tempFile);
aal = spm_read_vols(Vaal);

nameRoi = {};
rot   = Vroi.mat(1:3,1:3);
trans = Vroi.mat(1:3,4);

for k = 1:length(Args.keeprois)
    idx=find(roi(:)==Args.keeprois(k));
    [x,y,z] = ind2sub(size(roi),idx);
    G = mean([x y z],1)';
    coord(k,:) = (rot*G+trans)';
    ind = find(numRoi==aal(round(G(1)),round(G(2)),round(G(3))));
    if length(ind)>0
        nameRoi{k} = aalRoi{ind};
    else
        nameRoi{k} = ['roi_' num2str(Args.keeprois(k))];
    end
end

dim  = size(epi);
epi  = reshape(epi,dim(1)*dim(2)*dim(3),dim(4));

idx  = find(roi(:)>0);
data = epi(idx,:)';
roi  = roi(:);
roi  = roi(idx);


%% PREPROCESSING

% DETRENDING
if Args.detrending
    
    mot = load(motionFile);
    
    n_temporal = 3;
    n = size(data,1);
    keep = 1:n;
    
    % Create temporal trends:
    n_spline=round(n_temporal*Args.TR*n/360)
    if n_spline>=0 
       trend=((2*keep-(max(keep)+min(keep)))./(max(keep)-min(keep)))';
       if n_spline<=3
          temporal_trend=(trend*ones(1,n_spline+1)).^(ones(n,1)*(0:n_spline));
       else
          temporal_trend=(trend*ones(1,4)).^(ones(n,1)*(0:3));
          knot=(1:(n_spline-3))/(n_spline-2)*(max(keep)-min(keep))+min(keep);
          for k=1:length(knot)
             cut=keep'-knot(k);
             temporal_trend=[temporal_trend (cut>0).*(cut./max(cut)).^3];
          end
       end
    else
       temporal_trend=[];
    end 
    
    % Global signal - PCA
    mask_file   = epiFile;
    mask_thresh = fmri_mask_thresh(mask_file);
    %figure;
    [V, D] = pca_image(epiFile, [], 4, mask_file, mask_thresh);
    colormap(spectral);
    
    X = [mot temporal_trend V(:,1)];
    
    % - calcul des betas
    %X    = X';
    beta = data'*X*pinv(X'*X);
    % - calcul des residus
    data = data' - beta*X';
    data = data';
end

% FILTERING
if Args.filtering
    opt_filter.tr = Args.TR;
    opt_filter.hp = Args.hp;  % 0.01
    opt_filter.lp = Args.lp;  % Inf
    data = niak_filter_tseries(data,opt_filter);
end

% TEMPORAL SMOOTHING
if Args.smoothing
    for k = 1:size(data,2)
        data(:,k) = smooth(data(:,k),3,'moving');
    end
end

% NORMALIZATION
if Args.normalize
    
    optnorm.type = 'mean_var';
    data = niak_normalize_tseries(data,optnorm);
    
end


%% MEAN TIME COURSES

for k = 1:length(Args.keeprois)
    
    tseries(:,k) = mean(data(:,find(roi(:)==Args.keeprois(k))),2);
    
end


%% CONNECTIVITY MATRIX

if strcmpi(Args.method,'correlation')
    
    Cmat = corr(tseries);
       
end

nr = size(Cmat,1);
ind_upper = find(triu(ones(nr,nr),1));
C = Cmat(ind_upper);
Z = 0.5*log((1+C)./(1-C));


%% OUTPUTS

varargout={Z,C,Cmat,coord,nameRoi,tseries,data};
varargout=varargout(1:nargout);
