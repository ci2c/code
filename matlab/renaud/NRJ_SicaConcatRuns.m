function [sica,list_res] = NRJ_SicaConcatRuns(epipath,maskfile,Ns,prefix,ncomp,TR)

opt_sica.detrend          = 2;
opt_sica.norm             = 0;
opt_sica.slice_correction = 1;
opt_sica.algo             = 'Infomax';
opt_sica.type_nb_comp     = 0;
opt_sica.param_nb_comp    = ncomp;
opt_sica.TR               = TR;

for k = 1:Ns
    
    if k<10
        ses = ['sess0' num2str(k)];
    else
        ses = ['sess' num2str(k)];
    end
    
    DirImg  = dir(fullfile(epipath,ses,[prefix '*.nii']));
    tmplist = [];
    for j = 1:length(DirImg)
        tmplist = [tmplist;fullfile(epipath,ses,[DirImg(j).name])];
    end
    
    filelist.sess1{k} = tmplist;
    
end

[sica,list_res] = NRJ_Sica(filelist,maskfile,opt_sica);

comps = 1:ncomp;

ses = 'concat';

[m1,m2] = mkdir(fullfile(epipath,ses),'spatialComp');
d = sica.header;
    
for i = 1:ncomp

    if i<10 
        d.fname = fullfile(epipath,ses,'spatialComp',['sica_comp000' num2str(comps(i)) '.nii']);
    elseif i<100
        d.fname = fullfile(epipath,ses,'spatialComp',['sica_comp00' num2str(comps(i)) '.nii']);
    else
        d.fname = fullfile(epipath,ses,'spatialComp',['sica_comp0' num2str(comps(i)) '.nii']);
    end	

    if length(size(sica.S))<3
        vol = st_1Dto3D(sica.S(:,comps(i)),sica.mask);
    else
        vol = squeeze(sica.S(:,:,:,comps(i)));
    end
    vol_c   = st_correct_vol(vol,sica.mask);
    st_write_analyze(vol_c,d,d.fname);

end
    
