function write_vol_t1_spm12(anatpath)

[gm wm csf it]=get_vol_t1_spm12(anatpath)


%sauvegarde des valeurs brutes
vols=[gm wm csf it];
fid = fopen(fullfile(anatpath,'raw_vol.txt'),'w')
fprintf(fid,'%f\t',vols);
fclose(fid)

fid = fopen(fullfile(anatpath,'raw_vol_gm.txt'),'w')
fprintf(fid,'%f\t',gm);
fclose(fid)

fid = fopen(fullfile(anatpath,'raw_vol_wm.txt'),'w')
fprintf(fid,'%f\t',wm);
fclose(fid)

fid = fopen(fullfile(anatpath,'raw_vol_csf.txt'),'w')
fprintf(fid,'%f\t',csf);
fclose(fid)


fid = fopen(fullfile(anatpath,'raw_vol_it.txt'),'w')
fprintf(fid,'%f\t',it);
fclose(fid)

vol_name={'GM','WM','CSF','IT'}
save(fullfile(anatpath,'raw_vol.mat'),'vols','vol_name')



