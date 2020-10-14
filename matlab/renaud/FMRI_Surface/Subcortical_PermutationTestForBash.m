function Subcortical_PermutationTestForBash(mapfiles,outdir,maskfile,ind)

load(mapfiles);

T = randi(length(mapfiles),length(mapfiles),1);
tmpfiles = {};
for j = 1:length(T)
    tmpfiles{j} = mapfiles{T(j)};
end

% compute paramtric test
tmap = RandomParametricTest(tmpfiles,outdir,ind,maskfile);
save(fullfile(outdir,['tmap_' num2str(ind) '.mat']),'tmap');
