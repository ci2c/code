function FMRI_PreprocessingBySPM8(epiDir,pref_epi,anatFile,TR,nslices,refslice,surffwhm,volfwhm,coreg,acquisition)

%addpath('/home/global/matlab_toolbox/spm8');

%%  INIT
if strcmp(acquisition,'ascending')
    prefix{1}  = '';
    prefix{2}  = 'r';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    joblist    = [2 3];
    sliceorder = 1:1:nslices;
elseif strcmp(acquisition,'interleaved')
    prefix{1}  = 'a';
    prefix{2}  = '';
    prefix{3}  = 'ra';
    prefix{4}  = 'meana';
    sliceorder = [];
    space      = round(sqrt(nslices));
    for k=1:space
        tmp        = k:space:nslices;
        sliceorder = [sliceorder tmp];
    end
elseif strcmp(acquisition,'descending')
    prefix{1}  = 'a';
    prefix{2}  = '';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    sliceorder = [nslices:-2:1 nslices-1:-2:1];
else
    prefix{1} = '';
    prefix{2} = 'r';
    prefix{3} = 'r';
    prefix{4}  = 'mean';
    sliceorder = 1:1:nslices;
end


%%  LAUNCH SPM

spm('defaults', 'FMRI');

spm_jobman('initcfg'); % SPM8 and SPM12

matlabbatch = {};

f = spm_select('FPList', epiDir, ['^' pref_epi '.*\.nii$']);
a = anatFile;

if strcmp(acquisition,'ascending') || strcmp(acquisition,'descending')
    
    % REALIGNMENT
    matlabbatch{end+1}.spm.spatial.realign.estwrite.data{1}        = editfilenames(f,'prefix','');
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.weight  = '';
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.interp  = 4;
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.mask    = 1;
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';

    % SLICE TIMING CORRECTION
    matlabbatch{end+1}.spm.temporal.st.scans{1} = editfilenames(f,'prefix','r');
    matlabbatch{end}.spm.temporal.st.nslices    = nslices;
    matlabbatch{end}.spm.temporal.st.tr         = TR;
    matlabbatch{end}.spm.temporal.st.ta         = TR-TR/nslices;
    matlabbatch{end}.spm.temporal.st.so         = sliceorder;
    matlabbatch{end}.spm.temporal.st.refslice   = refslice;
    matlabbatch{end}.spm.temporal.st.prefix     = 'a';

elseif strcmp(acquisition,'interleaved')
    
    % SLICE TIMING CORRECTION
    matlabbatch{end+1}.spm.temporal.st.scans{1} = editfilenames(f,'prefix','');
    matlabbatch{end}.spm.temporal.st.nslices    = nslices;
    matlabbatch{end}.spm.temporal.st.tr         = TR;
    matlabbatch{end}.spm.temporal.st.ta         = TR-TR/nslices;
    matlabbatch{end}.spm.temporal.st.so         = sliceorder;
    matlabbatch{end}.spm.temporal.st.refslice   = refslice;
    matlabbatch{end}.spm.temporal.st.prefix     = 'a';
    
    % REALIGNMENT
    matlabbatch{end+1}.spm.spatial.realign.estwrite.data{1}        = editfilenames(f,'prefix','a');
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
    matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.weight  = '';
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.interp  = 4;
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.mask    = 1;
    matlabbatch{end}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';
    
end


% COREGISTRATION

if strcmp(coreg,'epi2anat')
    matlabbatch{end+1}.spm.spatial.coreg.estimate.ref  = cellstr(anatFile);
    matlabbatch{end}.spm.spatial.coreg.estimate.source = editfilenames(f(1,:),'prefix',prefix{4});
    matlabbatch{end}.spm.spatial.coreg.estimate.other  = editfilenames(f,'prefix',prefix{3});
elseif strcmp(coreg,'anat2epi')
    matlabbatch{end+1}.spm.spatial.coreg.estimate.ref  = editfilenames(f(1,:),'prefix',prefix{4});
    matlabbatch{end}.spm.spatial.coreg.estimate.source = cellstr(anatFile);
    matlabbatch{end}.spm.spatial.coreg.estimate.other  = {''};
end
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];


% NORMALIZATION

mepifile = editfilenames(f(1,:),'prefix',prefix{4});
mepifile = mepifile{1};
matlabbatch{end+1}.spm.spatial.normalise.est.subj.source     = editfilenames(f(1,:),'prefix',prefix{4});
matlabbatch{end}.spm.spatial.normalise.est.subj.wtsrc        = '';
matlabbatch{end}.spm.spatial.normalise.est.eoptions.template = {'/home/global/matlab_toolbox/spm8/templates/EPI.nii,1'};
matlabbatch{end}.spm.spatial.normalise.est.eoptions.weight   = '';
matlabbatch{end}.spm.spatial.normalise.est.eoptions.smosrc   = 8;
matlabbatch{end}.spm.spatial.normalise.est.eoptions.smoref   = 0;
matlabbatch{end}.spm.spatial.normalise.est.eoptions.regtype  = 'mni';
matlabbatch{end}.spm.spatial.normalise.est.eoptions.cutoff   = 25;
matlabbatch{end}.spm.spatial.normalise.est.eoptions.nits     = 16;
matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg      = 1;

[p,n,e] = fileparts(mepifile);
matlabbatch{end+1}.spm.spatial.normalise.write.subj.matname    = cellstr(fullfile(p,[n '_sn.mat']));
matlabbatch{end}.spm.spatial.normalise.write.subj.resample     = editfilenames(f,'prefix',prefix{3});
matlabbatch{end}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{end}.spm.spatial.normalise.write.roptions.bb       = [-78 -112 -50; 78 76 85];
matlabbatch{end}.spm.spatial.normalise.write.roptions.vox      = [2 2 2];
matlabbatch{end}.spm.spatial.normalise.write.roptions.interp   = 1;
matlabbatch{end}.spm.spatial.normalise.write.roptions.wrap     = [0 0 0];
matlabbatch{end}.spm.spatial.normalise.write.roptions.prefix   = 'w';

matlabbatch{end+1}.spm.spatial.normalise.write.subj.matname    = cellstr(fullfile(p,[n '_sn.mat']));
matlabbatch{end}.spm.spatial.normalise.write.subj.resample     = editfilenames(f(1,:),'prefix',prefix{4});
matlabbatch{end}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{end}.spm.spatial.normalise.write.roptions.bb       = [-78 -112 -50; 78 76 85];
matlabbatch{end}.spm.spatial.normalise.write.roptions.vox      = [2 2 2];
matlabbatch{end}.spm.spatial.normalise.write.roptions.interp   = 1;
matlabbatch{end}.spm.spatial.normalise.write.roptions.wrap     = [0 0 0];
matlabbatch{end}.spm.spatial.normalise.write.roptions.prefix   = 'w';


% SMOOTHING

% 1: native space + volume smoothing
matlabbatch{end+1}.spm.spatial.smooth.data = editfilenames(f,'prefix',prefix{3});
matlabbatch{end}.spm.spatial.smooth.fwhm   = [volfwhm volfwhm volfwhm];
matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
matlabbatch{end}.spm.spatial.smooth.im     = 0;
matlabbatch{end}.spm.spatial.smooth.prefix = 'sv';
% 2: native space + surface smoothing
matlabbatch{end+1}.spm.spatial.smooth.data = editfilenames(f,'prefix',prefix{3});
matlabbatch{end}.spm.spatial.smooth.fwhm   = [surffwhm surffwhm surffwhm];
matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
matlabbatch{end}.spm.spatial.smooth.im     = 0;
matlabbatch{end}.spm.spatial.smooth.prefix = 'ss';
% 3: normalized space + volume smoothing
matlabbatch{end+1}.spm.spatial.smooth.data = editfilenames(f,'prefix',['w' prefix{3}]);
matlabbatch{end}.spm.spatial.smooth.fwhm   = [volfwhm volfwhm volfwhm];
matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
matlabbatch{end}.spm.spatial.smooth.im     = 0;
matlabbatch{end}.spm.spatial.smooth.prefix = 'snv';
% 4: normalized space + surface smoothing
matlabbatch{end+1}.spm.spatial.smooth.data = editfilenames(f,'prefix',['w' prefix{3}]);
matlabbatch{end}.spm.spatial.smooth.fwhm   = [surffwhm surffwhm surffwhm];
matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
matlabbatch{end}.spm.spatial.smooth.im     = 0;
matlabbatch{end}.spm.spatial.smooth.prefix = 'sns';


% OUTLIER IDENTIFICATION

% if strcmp(acquisition,'ascending') || strcmp(acquisition,'descending')
%     tmp = editfilenames(f(1,:),'prefix','');
% elseif strcmp(acquisition,'interleaved')
%     tmp = editfilenames(f(1,:),'prefix','a');
% end
% [p,n,e] = fileparts(tmp{1});
% motFile = fullfile(p,['rp_' n '.txt']);
% 
% matlabbatch{end+1}.spm.tools.art.sess.motionfiletype.SPM.mvmtfile = cellstr(motFile);
% matlabbatch{end}.spm.tools.art.sess.nscan                         = editfilenames(f,'prefix',prefix{3});
% matlabbatch{end}.spm.tools.art.sess.threshold.globalsig.globaldiff.zthresh          = 3;
% matlabbatch{end}.spm.tools.art.sess.threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
% matlabbatch{end}.spm.tools.art.sess.threshold.compflag = 1;
% matlabbatch{end}.spm.tools.art.maskfile                = {''};
% matlabbatch{end}.spm.tools.art.savefiles.motionflag    = 1;
% matlabbatch{end}.spm.tools.art.savefiles.analysisflag  = 1;
% matlabbatch{end}.spm.tools.art.savefiles.voxvarflag    = 1;
% matlabbatch{end}.spm.tools.art.savefiles.SNRflag       = 1;
% matlabbatch{end}.spm.tools.art.closeflag               = 1;
% matlabbatch{end}.spm.tools.art.interp                  = 0;


% RUN PROCESS

spm_jobman('run',matlabbatch);
