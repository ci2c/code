function [sica,list_res] = script_sica(list_files,opt)


%%% Default parameters %%%
if isfield(opt,'type_nb_comp')
    type_nb_comp = opt.type_nb_comp;
else
    type_nb_comp = 1;
    param_nb_comp = 0.9;
end

if isfield(opt,'param_nb_comp')
    param_nb_comp = opt.param_nb_comp;
end

if isfield(opt,'detrend')
    ord_detr = opt.detrend;
else
    ord_detr = 2;
end

if isfield(opt,'filter')
    cut_hpfilter = opt.filter.high;
    cut_lpfilter = opt.filter.low;
else
    cut_hpfilter = 0;
    cut_lpfilter = 0;
end

if isfield(opt,'slice_correction')
    slice_c = opt.slice_correction;
else
    slice_c = 0;
end

if isfield(opt,'norm')
    type_norm = opt.norm;
else
    type_norm = 2;
end

if isfield(opt,'suppress_vol')
    suppress_vol = opt.suppress_vol;
else
    suppress_vol = 0;
end

if isfield(opt,'algo')
    type_algo = opt.algo;
else
    type_algo = 'Infomax';
end

if isfield(opt,'TR')
    TR = opt.TR;
else
    %fprintf('The TR of the acquisition is required in the ''opt'' structure \n');
    %return
    TR = [];
end

% PROCESSING        
%%% Reading all runs
%[tmp,hdr] = st_read_vol(list_files(1,:),[],0);
hdr = spm_vol(list_files(1,:));
% tmp = spm_read_vols(VV);
clear tmp
%[hdr,data] = niak_read_nifti(filename);
    
if isempty(TR)
    fprintf('The TR of the acquisition is required in the ''opt'' structure \n');
    return
end

fprintf('Reading data %s ... - ',list_files(1,:))
%data = st_read_vol(list_files,[],0);
V = spm_vol(list_files);
data=spm_read_vols(V);
fprintf('Brain segmentation - ')
mask = st_segment_brain(data(:,:,:,2:11))>0;
[nx,ny,nz,nt]=size(data);
data = reshape(data,nx*ny*nz,nt);
fprintf('Suppressing the first %i volumes !\n',suppress_vol);
data=data(mask(:)>0,suppress_vol+1:end);

% Computation of a mask of interest common to all runs
mask_all = ones(size(mask));
mask_all = mask_all & mask;
    
% We only retain the voxels of mask_all
% Pre-processing of each run
to_keep = mask_all(mask);
data    = data(to_keep,:)';
Me(:,1) = (mean(data,1))';
if ord_detr ~= -1
    fprintf('Correction of %ith order polynomial trends \n',ord_detr)
    data = st_detrend_array(data,ord_detr);
end
if slice_c == 1
    fprintf('Correction of inter-slices mean variability \n')
    data = st_normalise(data,2);
    data = st_correct_slice_intensity(data,mask_all);
end
if cut_hpfilter > 0
    fprintf('Temporal high-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',TR,cut_hpfilter)
    data = st_filter_data(data,mask_all,TR,cut_hpfilter,'hp');
end
if cut_lpfilter > 0
    fprintf('Temporal low-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',TR,cut_lpfilter)
    data = st_filter_data(data,mask_all,TR,cut_lpfilter,'lp');
end
if type_norm == 2
    fprintf('Correction of mean temporal intensity \n')
else
    fprintf('Correction to zero mean and unit temporal variance \n');
end
[data,M,Varr] = st_normalise(data,type_norm);
        
Va(:,1) = sqrt(Varr);
    
% Concatenation of all runs
data_all = data;
clear data

% Priors building if necessary
if strcmp(type_algo,'Infomax-Prior')
    P = [];
    if strcmp(opt.prior.type,'spatial')
        nb_regions = length(unique(opt.prior.prior))-1;
        mask = opt.prior.prior(:);
        mask = mask(mask_all);

        for j=1:nb_regions
            X=data_all(:,mask==j);

            [PP,Y] = st_kmeans(X,opt.prior.nbclass);


            siz_p = [];
            for num_p = 1:max(PP)
                siz_p(num_p) = sum(PP==num_p);
            end
            OK = siz_p > 3;

            if sum(OK) == 0
                [val_max,i_max] = max(siz_p);
                OK(i_max) = 1;
            end

            P = [P Y(OK,:)'];
        end
    elseif strcmp(opt.prior.type,'temporal')
        P = opt.prior.prior;
    end
    optsica.prior = P;
end

% sica computation
optsica.algo = type_algo;
optsica.param_nb_comp = param_nb_comp;
optsica.type_nb_comp = type_nb_comp;

res_ica = st_do_sica2(data_all,optsica);

sica.S = res_ica.composantes;
res_ica = rmfield(res_ica,'composantes');
sica.A = res_ica.poids;
res_ica = rmfield(res_ica,'poids');
sica.nbcomp = res_ica.nbcomp;
sica.meanData = Me;
%sica.varData = Va;
%sica.varatio = res_ica.varatio;
sica.contrib = res_ica.contrib;
if isfield(res_ica,'residus')
    sica.residus = res_ica.residus;
end
if isfield(res_ica,'prior')
    sica.prior = res_ica.prior;
end
clear res_ica
sica.TR = TR;
sica.mask = mask_all;
    
sica.data_name = list_files;
hdr(1).fname = '.';
sica.header = hdr;
sica.algo = type_algo;
%sica.labels = cellstr(repmat('N/A',sica.nbcomp,1));
sica.detrend = ord_detr;
sica.filter.high = cut_hpfilter;
sica.filter.low = cut_lpfilter;
sica.slice_correction = slice_c;
sica.suppress_vol = suppress_vol;
sica.type_norm = type_norm;
    
sica.className(1).name = 'N/A';
sica.className(1).color = [0.7 0.7 0.7];
sica.className(2).name = 'FAR';
sica.className(2).color = [1 0 0];
sica.className(3).name = 'FAR(t)';
sica.className(3).color = [1 0 0];
sica.className(4).name = 'FAR(o)';
sica.className(4).color = [1 0 0];
sica.className(5).name = 'PNR';
sica.className(5).color = [0 1 0];
sica.className(6).name = 'PNR(c)';
sica.className(6).color = [0 1 0];
sica.className(7).name = 'PNR(r)';
sica.className(7).color = [0 1 0];
sica.className(8).name = 'PNR(m)';
sica.className(8).color = [0 1 0];
sica.className(9).name = 'SAR';
sica.className(9).color = [1 1 0];
sica.className(10).name = 'SAR(a)';
sica.className(10).color = [1 1 0];
sica.className(11).name = 'SAR(d)';
sica.className(11).color = [1 1 0];
sica.labels = ones(1,sica.nbcomp);
    
if isfield(sica,'header')
    if ~isfield(sica.header,'vox')
        sica.header.vox = sqrt(sum(sica.header.mat(1:3,1:3).^2));
    end
end


function data_d = st_detrend_array(data,pow)

% On effectue la regression
nt = size(data,1);
for i = 0:pow
    X(:,i+1) = ((1:nt)').^i;
end
% - calcul des betas
beta = (pinv(X'*X)*X')*data;

% - calcul des residus
data_d = data - X*beta;