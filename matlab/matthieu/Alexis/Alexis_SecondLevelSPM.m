function Alexis_SecondLevelSPM(inputdir,Grp1VsGrp2,subjectsGrp1,subjectsGrp2,NumContrast,ContrastName)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

%% FACTORIAL DESIGN SPECIFICATION
%-----------------------------------------------------------------------
matlabbatch{1}.stats{1}.factorial_design.dir = cellstr(fullfile(inputdir,'SecondLevel_SPM',Grp1VsGrp2,ContrastName{NumContrast}));
matlabbatch{1}.stats{1}.factorial_design.des.t2.scans1 = {};
matlabbatch{1}.stats{1}.factorial_design.des.t2.scans2 = {};
for i = 1:length(subjectsGrp1)
    if (NumContrast<10)
        tmp = cellstr(fullfile(inputdir,subjectsGrp1{i},'spm','FirstLevel',['con_000' num2str(NumContrast) '.img']));
    else
        tmp = cellstr(fullfile(inputdir,subjectsGrp1{i},'spm','FirstLevel',['con_00' num2str(NumContrast) '.img']));
    end
    matlabbatch{1}.stats{1}.factorial_design.des.t2.scans1 = [matlabbatch{1}.stats{1}.factorial_design.des.t2.scans1 ; tmp]
end
for i = 1:length(subjectsGrp2)
    if (NumContrast<10)
        tmp = cellstr(fullfile(inputdir,subjectsGrp2{i},'spm','FirstLevel',['con_000' num2str(NumContrast) '.img']));
    else
        tmp = cellstr(fullfile(inputdir,subjectsGrp2{i},'spm','FirstLevel',['con_00' num2str(NumContrast) '.img']));
    end
    matlabbatch{1}.stats{1}.factorial_design.des.t2.scans2 = [matlabbatch{1}.stats{1}.factorial_design.des.t2.scans2 ; tmp]
end
matlabbatch{1}.stats{1}.factorial_design.des.t2.dept = 0;
matlabbatch{1}.stats{1}.factorial_design.des.t2.variance = 1;
matlabbatch{1}.stats{1}.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.stats{1}.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.stats{1}.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.stats{1}.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.stats{1}.factorial_design.masking.im = 1;
matlabbatch{1}.stats{1}.factorial_design.masking.em = {''};
matlabbatch{1}.stats{1}.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.stats{1}.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.stats{1}.factorial_design.globalm.glonorm = 1;

%% ESTIMATION
%-----------------------------------------------------------------------
matlabbatch{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(inputdir,'SecondLevel_SPM',Grp1VsGrp2,ContrastName{NumContrast},'SPM.mat'));
matlabbatch{1}.stats{2}.fmri_est.write_residuals = 0;
matlabbatch{1}.stats{2}.fmri_est.method.Classical = 1;

%% INFERENCE
%--------------------------------------------------------------------------

% Definition of contrasts
%-----------------------------------------------------------------------
matlabbatch{1}.stats{3}.con.spmmat = cellstr(fullfile(inputdir,'SecondLevel_SPM',Grp1VsGrp2,ContrastName{NumContrast},'SPM.mat'));
matlabbatch{1}.stats{3}.con.consess{1}.tcon.name = horzcat(Grp1VsGrp2,' : ',ContrastName{NumContrast});
matlabbatch{1}.stats{3}.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{1}.stats{3}.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.delete = 0;

% Results
%-----------------------------------------------------------------------
matlabbatch{1}.stats{4}.results.spmmat = cellstr(fullfile(inputdir,'SecondLevel_SPM',Grp1VsGrp2,ContrastName{NumContrast},'SPM.mat'));
matlabbatch{1}.stats{4}.results.conspec.titlestr = horzcat(Grp1VsGrp2,' : ',ContrastName{NumContrast});
matlabbatch{1}.stats{4}.results.conspec.contrasts = 1;
matlabbatch{1}.stats{4}.results.conspec.threshdesc = 'FWE';
matlabbatch{1}.stats{4}.results.conspec.thresh = 0.05;
matlabbatch{1}.stats{4}.results.conspec.extent = 5;
matlabbatch{1}.stats{4}.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.stats{4}.results.units = 1;
matlabbatch{1}.stats{4}.results.print = 'ps';
matlabbatch{1}.stats{4}.results.write.none = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(inputdir,'SecondLevel_SPM',Grp1VsGrp2,ContrastName{NumContrast},'batch_analysisSL_Vs.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);