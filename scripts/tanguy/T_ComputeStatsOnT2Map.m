function stats = T_ComputeStatsOnT2Map(filepath,roidir,roilist)

t2mapfile = filepath
[hdr,t2map] = niak_read_vol(t2mapfile);
t2map = t2map(:);

for k = 1:length(roilist)
    roifile = fullfile(roidir,roilist{k});
    [hdr,roi] = niak_read_nifti(roifile);
    ind = find(roi(:)>0);
    stats(k).name = roilist{k};
    stats(k).volume = length(ind);
    stats(k).min = min(t2map(ind));
    stats(k).max = max(t2map(ind));
    stats(k).moy = mean(t2map(ind));
    stats(k).std = std(t2map(ind));
end