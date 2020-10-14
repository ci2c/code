indir='/home/notorious/NAS/matthieu/fMRI_Emotions/Visages';
subjs=textread(fullfile(indir,'subjlist.txt'),'%s\n');

filepath='';
for i=1:3
	for j=1:length(subjs)
		filepath=[filepath [' -dset ' num2str(i) ' ' num2str(j) ' ' fullfile(indir,subj{j},'spm',['con_000' num2str(i) '.nii'])]];
	end
end

cmd = sprintf('3dANOVA2 -type 3 -alevels 3 -blevels 20 %s -amean 1 J -amean 2 N -amean 3 C -acontr 1 1 -2 JNvsC -acontr 1 -2 1 JCvsN -acontr -2 1 1 NCvsJ -acontr 1 1 1 JCN -fa F_jcn -bucket anova_result',filepath);

unix(cmd)
