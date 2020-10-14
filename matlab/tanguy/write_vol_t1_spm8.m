function write_vol_t1_spm8(anatpath)

[gm wm csf it]=get_vol_t1_spm8(anatpath)


%sauvegarde des valeurs brutes
vols=[gm wm csf it];
fid = fopen(fullfile(anatpath,'raw_vol.txt'),'w')
fprintf(fid,'%f\t',vols);
fclose(fid)

vol_name={'GM','WM','CSF','IT'}
save(fullfile(anatpath,'raw_vol.mat'),'vols','vol_name')



