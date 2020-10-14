function meanTserie = FMRI_ExtractMeanROIs(datapath,maskROIs,prefix,mask,opt)

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
if opt.ord_detr ~= -1
    fprintf('Correction of %ith order polynomial trends \n',opt.ord_detr)
    data = Detrend_array(data,opt.ord_detr);
end
if opt.slice_c == 1
    fprintf('Correction of inter-slices mean variability \n')
    data = st_normalise(data,2);
    data = st_correct_slice_intensity(data,mask);
end
if opt.hp > 0
    fprintf('Temporal high-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',opt.tr,opt.hp)
    data = st_filter_data(data,mask,opt.tr,opt.hp,'hp');
end
if opt.lp > 0
    fprintf('Temporal low-pass filtering of data (TR = %1.2f s, cut-off freq = %1.2fHz) \n',opt.tr,opt.lp)
    data = st_filter_data(data,mask,opt.tr,opt.lp,'lp');
end

[data,M,Varr] = st_normalise(data,2);

data       = data';
nbroi      = max(unique(maskROIs));
meanTserie = zeros(nbroi,size(data,2));

for k = 1:nbroi
    ind = find(maskROIs==k);
    meanTserie(k,:) = mean(data(ind,:),1);
end