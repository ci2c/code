function [sica,list_res] = NRJ_Sica(list_files,maskfile,opt)

% sica = st_script_sica(list_files,opt)
%
% INPUTS
% list_files: (cell of char array) list_files{j}(i,:) is the full path name of a 3D volume.
%             list_files{j} is the list of volumes of one functional run.
%               All runs of list_files are supposed to come from a single
%               condition, and will be analyzed jointly.
%              OR a structure with fields 'sess1','sess2', etc..., each
%              field being a cell of char array as described previously.
%
% maskfile: mask file (.nii or .img)
%
% opt:  (structure) opt.TR: the repetition time (TR) of the acquisition, in
%                           seconds
%                   opt.filter.high: (optional, default 0) cut-off frequency of a high-pass filtering
%                               A 0 value will result in no filtering
%                               (requires the signal processing toolbox).
%                               Typical value is 0.01.
%                   opt.filter.low: (optional, default 0) cut-off frequency of a low-pass filtering
%                               A 0 value will result in no filtering
%                               (requires the signal processing toolbox).
%                               Typical value is 0.1.
%                   opt.slice_correction: (optional, default 0) apply (1)
%                               or not (0) a correction for slice mean intensity.
%                               Use this correction if some mean slice intensities are not
%                               stable across time ("spiked" artefacts involving 1
%                               slice).
%                   opt.suppress_vol: (optional, default 0) number of
%                               volumes to suppress at the begining of a
%                               run.
%                   opt.detrend: (optional, default 2) order of the
%                                polynomial for polynomial drifts correction
%                   opt.norm: (optional, default 2) 2: corrects for differences in mean between runs,
%                               0,1: corrects for differences in variances
%                               (0 is faster, but requires more memory)
%                   opt.algo: (optional, default 'Infomax') the type of algorithm to be used
%                               for the sica decomposition: 'Infomax', 'Fastica-Def'
%                               or 'Fastica-Sym'.
%                   opt.type_nb_comp:  (optional, default 1)
%                                      0, to choose directly the number of component to compute
%                                      1, to choose the ratio of the variance to keep
%                   opt.param_nb_comp: if type_nb_comp = 0, number of components to
%                                      compute
%                                      if type_nb_comp = 1, ratio of the variance to keep
%                                       (default, 90 %)
%                   opt.prior  (structure used if opt.algo = 'Infomax-Prior')
%                       opt.prior.prior:  2D matrix whose columns are the
%                                           temporal priors or spatial
%                                           masks with 1's in the first ROI
%                                          , 2's in the second...
%                       opt.prior.type:  'temporal' or 'spatial'
%                       opt.prior.coeff:  constrain factor between 0 and 1
%                       opt.prior.nbclass:  number of classes used for
%                                           kmeans clustering in case of spatial priors
%
% OUTPUTS
% sica: a sica structure (see 'spec_sica_toolbox.sxw').
% list_res: (cell array of strings) filenames of saved sica structure in
% case of multiseesion computation. list_res = {} if sica is computed on
% only 1 session.
%

if iscell(list_files)
    list_files_tmp = list_files;
    clear list_files
    list_files.sess1 = list_files_tmp;
end

%%% Default parameters %%%
if isfield(opt,'type_nb_comp')
    type_nb_comp = opt.type_nb_comp;
else
    type_nb_comp  = 1;
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

nb_sess        = length(fieldnames(list_files));
list_files_tmp = {};
list_res       = {};

V    = spm_vol(maskfile);
mask = spm_read_vols(V); 
mask = mask>0;

for numSess=1:nb_sess
    
    fprintf('Working on session %d ... \n ',numSess)
    field_name = sprintf('sess%d',numSess);
    list_files_tmp = getfield(list_files,field_name);
    
    %%% Reading all runs
    hdr = spm_vol(list_files_tmp{1}(1,:));

    if isfield(hdr,'private') && isempty(TR)
        if isfield(hdr.private,'timing')
            TR = hdr.private.timing.tspace;
        end
    end
    
    if isempty(TR)
        fprintf('The TR of the acquisition is required in the ''opt'' structure \n');
        return
    end

    for num_r = 1:length(list_files_tmp)
        
        fprintf('Reading data %s ... - ',list_files_tmp{num_r}(1,:))
        V           = spm_vol(list_files_tmp{num_r});
        data{num_r} = spm_read_vols(V);
        clear V;
        
        [nx,ny,nz,nt] = size(data{num_r});
        data{num_r}   = reshape(data{num_r},nx*ny*nz,nt);
        
        fprintf('Suppressing the first %i volumes !\n',suppress_vol);
        data{num_r} = data{num_r}(mask(:)>0,suppress_vol+1:end);
        
    end
    
    % We only retain the voxels of mask_all
    % Pre-processing of each run
    for num_r = 1:length(list_files_tmp)
        
        data{num_r} = data{num_r}';
        Me(:,num_r) = (mean(data{num_r},1))';
        
        if ord_detr ~= -1
            fprintf('Correction of %ith order polynomial trends \n',ord_detr)
            data{num_r} = st_detrend_array(data{num_r},ord_detr);
        end
        if slice_c == 1
            fprintf('Correction of inter-slices mean variability \n')
            data{num_r} = st_normalise(data{num_r},2);
            data{num_r} = st_correct_slice_intensity(data{num_r},mask);
        end
        if cut_hpfilter > 0
            fprintf('Temporal high-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',TR,cut_hpfilter)
            data{num_r} = st_filter_data(data{num_r},mask,TR,cut_hpfilter,'hp');
        end
        if cut_lpfilter > 0
            fprintf('Temporal low-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',TR,cut_lpfilter)
            data{num_r} = st_filter_data(data{num_r},mask,TR,cut_lpfilter,'lp');
        end
        if type_norm == 2
            fprintf('Correction of mean temporal intensity \n')
        else
            fprintf('Correction to zero mean and unit temporal variance \n');
        end
        
        [data{num_r},M,Varr] = st_normalise(data{num_r},type_norm);
        
        Va(:,num_r) = sqrt(Varr);
        
    end

    % Concatenation of all runs
    data_all = [];
    for num_r = 1:length(list_files_tmp)
        data_all    = [data_all ; data{num_r}];
        data{num_r} = [];
    end
    clear data

    % Priors building if necessary
    if strcmp(type_algo,'Infomax-Prior')
        P = [];
        if strcmp(opt.prior.type,'spatial')
            nb_regions = length(unique(opt.prior.prior))-1;
            mask1 = opt.prior.prior(:);
            mask1 = mask1(mask);

            for j=1:nb_regions
                X=data_all(:,mask1==j);

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
    optsica.algo          = type_algo;
    optsica.param_nb_comp = param_nb_comp;
    optsica.type_nb_comp  = type_nb_comp;

    res_ica = st_do_sica(data_all,optsica);

    sica.S        = res_ica.composantes;
    res_ica       = rmfield(res_ica,'composantes');
    sica.A        = res_ica.poids;
    res_ica       = rmfield(res_ica,'poids');
    sica.nbcomp   = res_ica.nbcomp;
    sica.meanData = Me;
    %sica.varData = Va;
    %sica.varatio = res_ica.varatio;
    sica.contrib  = res_ica.contrib;
    if isfield(res_ica,'residus')
    sica.residus = res_ica.residus;
    end
    if isfield(res_ica,'prior')
        sica.prior = res_ica.prior;
    end
    clear res_ica
    sica.TR   = TR;
    sica.mask = mask;
    
    sica.data_name        = list_files_tmp;
    hdr(1).fname          = '.';
    sica.header           = hdr;
    sica.algo             = type_algo;
    %sica.labels = cellstr(repmat('N/A',sica.nbcomp,1));
    sica.detrend          = ord_detr;
    sica.filter.high      = cut_hpfilter;
    sica.filter.low       = cut_lpfilter;
    sica.slice_correction = slice_c;
    sica.suppress_vol     = suppress_vol;
    sica.type_norm        = type_norm;
    
    sica.className(1).name   = 'N/A';
    sica.className(1).color  = [0.7 0.7 0.7];
    sica.className(2).name   = 'FAR';
    sica.className(2).color  = [1 0 0];
    sica.className(3).name   = 'FAR(t)';
    sica.className(3).color  = [1 0 0];
    sica.className(4).name   = 'FAR(o)';
    sica.className(4).color  = [1 0 0];
    sica.className(5).name   = 'PNR';
    sica.className(5).color  = [0 1 0];
    sica.className(6).name   = 'PNR(c)';
    sica.className(6).color  = [0 1 0];
    sica.className(7).name   = 'PNR(r)';
    sica.className(7).color  = [0 1 0];
    sica.className(8).name   = 'PNR(m)';
    sica.className(8).color  = [0 1 0];
    sica.className(9).name   = 'SAR';
    sica.className(9).color  = [1 1 0];
    sica.className(10).name  = 'SAR(a)';
    sica.className(10).color = [1 1 0];
    sica.className(11).name  = 'SAR(d)';
    sica.className(11).color = [1 1 0];
    sica.labels              = ones(1,sica.nbcomp);
    
    if isfield(sica,'header')
        if ~isfield(sica.header,'vox')
            sica.header.vox = sqrt(sum(sica.header.mat(1:3,1:3).^2));
        end
    end
    
    if nb_sess > 1
        pathr = [];
        s     = [];
        for num_r = 1:length(list_files_tmp)
            pathr{num_r} = fileparts(list_files_tmp{num_r}(1,:));
            s{num_r}     = findstr(pathr{num_r},filesep);
            if num_r>1
                for pp = 1:min(length(s{num_r})-1,length(sInt)-1)
                    match(pp) = strcmp(pathr{num_r}(sInt(1):sInt(pp+1)),pathInt(sInt(1):sInt(pp+1)));
                    match(min(length(s{num_r}),length(sInt))) = strcmp(pathr{num_r}(sInt(1):end),pathInt(sInt(1):end));                    
                end
                index = match;
                I     = find(match == 0);
                if ~isempty(I)
                    index(I(1))=1;
                end
                si      = sInt(index);
                pathInt = pathr{num_r}(1:si(end));
                if min(length(s{num_r}),length(sInt)) == length(sInt)
                    sInt = sInt;
                else
                    sInt = s{num_r};
                end
            else
                pathInt = pathr{num_r};
                sInt    = s{num_r};
            end
        end
        [success] = mkdir(pathInt,strcat('res_',field_name));
        save(fullfile(pathInt,strcat('res_',field_name),'sica.mat'),'sica');
        fprintf(strcat('Saving sica in ', fullfile(pathInt,strcat('res_',field_name),'sica.mat'),' \n'))
        list_res{numSess} = fullfile(pathInt,strcat('res_',field_name),'sica.mat');
    end
    
    list_files_tmp = {};

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