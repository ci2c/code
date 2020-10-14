function CBF = ASL_CBFMap(Mz,deltaM0,outname,t1File)

% %
% % help : CBF=aslmap1(Mz,diff)
% % Mz : image control
% % diff : image de différence
% 

V1=spm_vol(Mz);
V2=spm_vol(deltaM0);

data1=spm_read_vols(V1);
data2=spm_read_vols(V2);

data2(~isfinite(data2(:))) = 0;
Z=(1:size(data2,3))';
B=repmat(Z, [1 size(data2,1) size(data2,2)]);
C=permute(B,[3 2 1]);

CBFtemp=6000.*data2.*exp(1.525./1.68)./(2.*0.85.*0.76.*1.68.*data1);

V1.fname=outname;
spm_write_vol(V1,CBFtemp);

% reslice
spm('Defaults','fMRI');
spm_jobman('initcfg'); % SPM8 only
clear matlabbatch
matlabbatch={};

matlabbatch{end+1}.spatial{1}.coreg{1}.write.ref           = cellstr(t1File);
matlabbatch{end}.spatial{1}.coreg{1}.write.source          = cellstr(outname);
matlabbatch{end}.spatial{1}.coreg{1}.write.roptions.interp = 1;
matlabbatch{end}.spatial{1}.coreg{1}.write.roptions.wrap   = [0 0 0];
matlabbatch{end}.spatial{1}.coreg{1}.write.roptions.mask   = 0;
matlabbatch{end}.spatial{1}.coreg{1}.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);
