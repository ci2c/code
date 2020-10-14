function [seed] = NIAK_FunctionalConnectivityBySeed(dataroot,subj,maskFile,roiName,epiName,outdir,mniformat,tempfile)

%% Extract seed time-course

roifile   = fullfile(outdir,[roiName '_to_epi.mnc']);
trgfile   = fullfile(dataroot,'epi_mean_nativefunc.mnc');
transfile = fullfile(dataroot,'transf_nativefunc_to_stereolin.xfm');
epifile   = fullfile(dataroot,epiName);
    
if(mniformat==1)
    
    % Resample mask file to epi
    cmd = sprintf('mincresample -like %s %s %s -transformation %s -invert_transformation -clobber',trgfile,maskFile,roifile,transfile); 
    unix(cmd);
    
else
    
    roifile = maskFile;
    
end

segfile = fullfile(dataroot,'anat_classify_stereolin.mnc');
resfile = fullfile(dataroot,'anat_classify_nativefunc.mnc');
cmd = sprintf('mincresample -like %s %s %s -transformation %s -invert_transformation -clobber',trgfile,segfile,resfile,transfile); 
unix(cmd);

% Extract seed time-course
isplot = 0;
seed   = Extract_SeedTimeCourse(roifile,epifile,resfile,isplot);

% Save
save(fullfile(outdir,['seed_' subj '_' roiName '.mat']),'seed');


%% 1st Level (GLM)

[hdr,vol]   = niak_read_minc(epifile);
opt.tr      = hdr.info.tr;
opt.nframes = hdr.info.dimensions(4);
opt.nslices = hdr.info.dimensions(3);
clear hdr vol;
        
motionfile = fullfile(dataroot,'motion_Wrun_pi.mat'); 

[p,n,e] = fileparts(epifile);
niifile = fullfile(p,[n '.nii']);
cmd     = sprintf('mri_convert %s %s',epifile,niifile);
unix(cmd);

ApplyGLM2Seed(niifile,motionfile,seed,outdir,['tmap_' subj '_' roiName],opt);


%% Resample to MNI
        
cmd = sprintf('nii2mnc %s %s',fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_ef.nii']),fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_ef.mnc']));
unix(cmd);
cmd = sprintf('nii2mnc %s %s',fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_sd.nii']),fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_sd.mnc']));
unix(cmd);
        
cmd = sprintf('mincresample -like %s %s %s -transformation %s',...
                    tempfile, ...
                    fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_ef.mnc']), ...
                    fullfile(outdir,['rtmap_' subj '_' roiName '_001_mag_ef.mnc']), ...
                    transfile);

unix(cmd);

cmd = sprintf('mincresample -like %s %s %s -transformation %s',...
                    tempfile, ...
                    fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_sd.mnc']), ...
                    fullfile(outdir,['rtmap_' subj '_' roiName '_001_mag_sd.mnc']), ...
                    transfile);

unix(cmd);

cmd = sprintf('mri_convert %s %s',fullfile(outdir,['rtmap_' subj '_' roiName '_001_mag_ef.mnc']),fullfile(outdir,'temp_ef.nii'));
unix(cmd);
cmd = sprintf('mri_convert %s %s',fullfile(outdir,['rtmap_' subj '_' roiName '_001_mag_sd.mnc']),fullfile(outdir,'temp_sd.nii'));
unix(cmd);

d            = fmris_read_image(fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_ef.nii']));
d1           = fmris_read_nifti(fullfile(outdir,'temp_ef.nii'));
d2           = d1;
d2.df        = d.df;
d2.fwhm      = d.fwhm;
d2.file_name = fullfile(outdir,['rtmap_' subj '_' roiName '_001_mag_ef.nii']);
fmris_write_nifti(d2);
clear d d1 d2;

d            = fmris_read_image(fullfile(outdir,['tmap_' subj '_' roiName '_001_mag_sd.nii']));
d1           = fmris_read_nifti(fullfile(outdir,'temp_sd.nii'));
d2           = d1;
d2.df        = d.df;
d2.fwhm      = d.fwhm;
d2.file_name = fullfile(outdir,['rtmap_' subj '_' roiName '_001_mag_sd.nii']);
fmris_write_nifti(d2);
clear d d1 d2;

cmd = sprintf('rm -f %s',fullfile(outdir,'temp_ef.nii'));
unix(cmd);
cmd = sprintf('rm -f %s',fullfile(outdir,'temp_sd.nii'));
unix(cmd);
        
