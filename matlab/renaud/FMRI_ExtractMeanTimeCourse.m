function meanTserie = FMRI_ExtractMeanTimeCourse(datapath,maskROIs,prefix,mask)

% INIT
cut_lpfilter = 0;
cut_hpfilter = 0;
slice_c      = 1;
ord_detr     = 2;

DirImg = dir(fullfile(datapath,[prefix '*.nii']));

FileList = [];
for j = 1:length(DirImg)
    FileList = [FileList;fullfile(datapath,[DirImg(j).name])];
end

keep     = find(mask(:)>0);
maskROIs = maskROIs(:);
maskROIs = maskROIs(keep);
hdr      = spm_vol(FileList);
data     = spm_read_vols(hdr);
dim      = size(data);
data     = reshape(data,dim(1)*dim(2)*dim(3),dim(4));
data     = data(keep,:)';

% PREPROCESSING
if ord_detr ~= -1
    fprintf('Correction of %ith order polynomial trends \n',ord_detr)
    data = Detrend_array(data,ord_detr);
end
if slice_c == 1
    fprintf('Correction of inter-slices mean variability \n')
    data = st_normalise(data,2);
    data = st_correct_slice_intensity(data,mask);
end
if cut_hpfilter > 0
    fprintf('Temporal high-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',TR,cut_hpfilter)
    data = st_filter_data(data,mask,TR,cut_hpfilter,'hp');
end
if cut_lpfilter > 0
    fprintf('Temporal low-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',TR,cut_lpfilter)
    data = st_filter_data(data,mask,TR,cut_lpfilter,'lp');
end

[data,M,Varr] = st_normalise(data,2);

data       = data';
nbroi      = max(unique(maskROIs));
meanTserie = zeros(nbroi,size(data,2));

for k = 1:nbroi
    ind = find(maskROIs==k);
    meanTserie(k,:) = mean(data(ind,:),1);
end
    