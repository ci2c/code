function NRJ_PreprocessingSPM12(anatFile,epiDir,prefepi,nruns,nslices,TR,acquisition,smoothValue)

%addpath('/home/global/matlab_toolbox/spm12b');

spm('defaults', 'FMRI');


%% REALIGNMENT

for k = 1:nruns
    
    if k<10
        f = spm_select('FPList', fullfile(epiDir,['run0' num2str(k)]), ['^' prefepi '.*\.nii$']);
    else
        f = spm_select('FPList', fullfile(epiDir,['run' num2str(k)]), ['^' prefepi '.*\.nii$']);
    end
    
    matlabbatch{1}.spm.spatial.realign.estwrite.data{k} = editfilenames(f,'prefix','');
    
end

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight  = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp  = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask    = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';


%% SLICE TIMING CORRECTION

for k = 1:nruns
    matlabbatch{2}.spm.temporal.st.scans{k}(1) = cfg_dep(['Realign: Estimate & Reslice: Resliced Images (Sess ' num2str(k) ')'], substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{k}, '.','rfiles'));
end
matlabbatch{2}.spm.temporal.st.nslices  = nslices;
matlabbatch{2}.spm.temporal.st.tr       = TR;
matlabbatch{2}.spm.temporal.st.ta       = TR-(TR/nslices);
if strcmp(acquisition,'ascending')
    sliceorder = 1:nslices;
elseif strcmp(acquisition,'descending')
    sliceorder = nslices:-1:1;
elseif strcmp(acquisition,'interleaved')
    sliceorder = [];
    space      = round(sqrt(nslices));
    for k=1:space
        tmp        = k:space:nslices;
        sliceorder = [sliceorder tmp];
    end
elseif strcmp(acquisition,'interleaved_F')  % Friederike's data
    sliceorder = [nslices:-2:1 nslices-1:-2:1];
end
matlabbatch{2}.spm.temporal.st.so       = sliceorder;
matlabbatch{2}.spm.temporal.st.refslice = 1;
matlabbatch{2}.spm.temporal.st.prefix   = 'a';



%% T1-EPI coregistration

matlabbatch{3}.spm.spatial.coreg.estimate.ref(1)            = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.spatial.coreg.estimate.source            = cellstr(anatFile);
matlabbatch{3}.spm.spatial.coreg.estimate.other             = {''};
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];



%% TEMPLATE NORMALIZATION

% Estimate
matlabbatch{4}.spm.spatial.normalise.est.subj.vol(1)       = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{4}.spm.spatial.normalise.est.eoptions.biasreg  = 0.0001;
matlabbatch{4}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{4}.spm.spatial.normalise.est.eoptions.tpm      = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
matlabbatch{4}.spm.spatial.normalise.est.eoptions.affreg   = 'mni';
matlabbatch{4}.spm.spatial.normalise.est.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
matlabbatch{4}.spm.spatial.normalise.est.eoptions.fwhm     = 0;
matlabbatch{4}.spm.spatial.normalise.est.eoptions.samp     = 3;

% Write

matlabbatch{5}.spm.spatial.normalise.write.subj(1).def(1)      = cfg_dep('Normalise: Estimate: Deformation (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{5}.spm.spatial.normalise.write.subj(1).resample(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));

for k = 1:nruns
    matlabbatch{5}.spm.spatial.normalise.write.subj(k+1).def(1)      = cfg_dep('Normalise: Estimate: Deformation (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
    matlabbatch{5}.spm.spatial.normalise.write.subj(k+1).resample(1) = cfg_dep(['Slice Timing: Slice Timing Corr. Images (Sess ' num2str(k) ')'], substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{k}, '.','files'));
end

matlabbatch{5}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70
                                                               78 76 85];
matlabbatch{5}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;



%% SMOOTHING

for k = 1:nruns
    matlabbatch{6}.spm.spatial.smooth.data(k) = cfg_dep(['Normalise: Write: Normalised Images (Subj ' num2str(k+1) ')'], substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{k+1}, '.','files'));
end
matlabbatch{6}.spm.spatial.smooth.fwhm   = [smoothValue smoothValue smoothValue];
matlabbatch{6}.spm.spatial.smooth.dtype  = 0;
matlabbatch{6}.spm.spatial.smooth.im     = 0;
matlabbatch{6}.spm.spatial.smooth.prefix = 's';

for k = 1:nruns
    matlabbatch{7}.spm.spatial.smooth.data(k) = cfg_dep(['Slice Timing: Slice Timing Corr. Images (Sess ' num2str(k) ')'], substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{k}, '.','files'));
end
matlabbatch{7}.spm.spatial.smooth.fwhm   = [smoothValue smoothValue smoothValue];
matlabbatch{7}.spm.spatial.smooth.dtype  = 0;
matlabbatch{7}.spm.spatial.smooth.im     = 0;
matlabbatch{7}.spm.spatial.smooth.prefix = 's';



%% OUTLIER IDENTIFICATION

for k = 1:nruns
    matlabbatch{8}.spm.tools.art.sess(k).motionfiletype.SPM.mvmtfile(1) = cfg_dep('Realign: Estimate & Reslice: Realignment Param File (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
    matlabbatch{8}.spm.tools.art.sess(k).nscan(1) = cfg_dep(['Normalise: Write: Normalised Images (Subj ' num2str(k+1) ')'], substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{k+1}, '.','files'));
    matlabbatch{8}.spm.tools.art.sess(k).threshold.globalsig.globaldiff.zthresh = 3;
    matlabbatch{8}.spm.tools.art.sess(k).threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
    matlabbatch{8}.spm.tools.art.sess(k).threshold.compflag = 1;
end
matlabbatch{8}.spm.tools.art.maskfile = {''};
matlabbatch{8}.spm.tools.art.savefiles.motionflag = 1;
matlabbatch{8}.spm.tools.art.savefiles.analysisflag = 1;
matlabbatch{8}.spm.tools.art.savefiles.voxvarflag = 1;
matlabbatch{8}.spm.tools.art.savefiles.SNRflag = 1;
matlabbatch{8}.spm.tools.art.closeflag = 1;
matlabbatch{8}.spm.tools.art.interp = 0;


%% LAUNCH

spm_jobman('run',matlabbatch);
