function NRJ_WindowICAOnConcatRuns(datapath,maskfile,TR,ncomp,prefix,nsess,nwind,overlap)

list_files       = struct();
list_files.sess1 = [];

V    = spm_vol(maskfile);
mask = spm_read_vols(V); 
mask = mask>0;

suppress_vol = 0;
ord_detr     = 2;
slice_c      = 1;
cut_hpfilter = 0;
cut_lpfilter = 0;
type_norm    = 2;

optsica.algo          = 'Infomax';
optsica.param_nb_comp = ncomp;
optsica.type_nb_comp  = 0;

for k = 1:nsess
    
    if k < 10
        DirImg = dir(fullfile(datapath,['sess0' num2str(k)],[prefix '*.nii']));
    else
        DirImg = dir(fullfile(datapath,['sess' num2str(k)],[prefix '*.nii']));
    end
    
    FileList = [];
    if k < 10
        for j = 1:length(DirImg)
            FileList = [FileList;fullfile(datapath,['sess0' num2str(k)],[DirImg(j).name])];
        end
    else
        for j = 1:length(DirImg)
            FileList = [FileList;fullfile(datapath,['sess' num2str(k)],[DirImg(j).name])];
        end
    end
    
    list_files.sess1{k} = FileList;
    
end

for num_r = 1:length(list_files.sess1)
        
    fprintf('Reading data %s ... - ',list_files.sess1{num_r}(1,:))
    V           = spm_vol(list_files.sess1{num_r});
    data{num_r} = spm_read_vols(V);
    clear V;

    [nx,ny,nz,nt] = size(data{num_r});
    data{num_r}   = reshape(data{num_r},nx*ny*nz,nt);

    fprintf('Suppressing the first %i volumes !\n',suppress_vol);
    data{num_r} = data{num_r}(mask(:)>0,suppress_vol+1:end);
    
    data{num_r} = data{num_r}';
    Me(:,num_r) = (mean(data{num_r},1))';

    if ord_detr ~= -1
        fprintf('Correction of %ith order polynomial trends \n',ord_detr)
        data{num_r} = Detrend_array(data{num_r},ord_detr);
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

    [data{num_r},M,Varr] = st_normalise(data{num_r},type_norm);

    Va(:,num_r) = sqrt(Varr);
        
end

% Concatenation of all runs
data_all = [];
for num_r = 1:length(list_files.sess1)
    data_all    = [data_all ; data{num_r}];
    data{num_r} = [];
end
clear data

nbframes = size(data_all,1);
timeline = [0:TR:(nbframes-1)*TR];
d        = [];
windows  = FMRI_GetWindows(timeline,nwind,overlap,d);
nw       = size(windows,1);
mw       = mean(windows,2);

save(fullfile(datapath,'window','param.mat'),'TR','nwind','ncomp','overlap','timeline','windows');

% sica computation
for k = 1:size(windows,1)

    res_ica = st_do_sica(data_all(windows(k,:)',:),optsica);
    
    sica.S        = res_ica.composantes;
    res_ica       = rmfield(res_ica,'composantes');
    sica.A        = res_ica.poids;
    res_ica       = rmfield(res_ica,'poids');
    sica.nbcomp   = res_ica.nbcomp;
    sica.meanData = Me;
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
    
    sica.algo             = optsica.algo;
    %sica.labels = cellstr(repmat('N/A',sica.nbcomp,1));
    sica.detrend          = ord_detr;
    sica.filter.high      = cut_hpfilter;
    sica.filter.low       = cut_lpfilter;
    sica.slice_correction = slice_c;
    sica.suppress_vol     = suppress_vol;
    sica.type_norm        = type_norm;
    
    if k < 10
        save(fullfile(datapath,'window',['sica_00' num2str(k) '.mat']),'sica');
    elseif k<100
        save(fullfile(datapath,'window',['sica_0' num2str(k) '.mat']),'sica');
    else
        save(fullfile(datapath,'window',['sica_' num2str(k) '.mat']),'sica');
    end
    
end
