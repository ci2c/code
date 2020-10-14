function FMRI_SecondLevel_SPM12(inputdir,Grp,subjectsGrp,NumContrast,ContrastName)


%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

%% Initialise data files
%--------------------------------------------------------------------------
 fidg = fopen(fullfile(inputdir,[subjectsGrp '.txt']));
 CellGrp = textscan(fidg, '%s');
 fclose(fidg);
 CellGrp = CellGrp{1};

%% FACTORIAL DESIGN SPECIFICATION
%-----------------------------------------------------------------------
matlabbatch{end+1}.stats{1}.factorial_design.dir = cellstr(fullfile(inputdir,'GroupAnalysis',Grp,ContrastName));
matlabbatch{end}.stats{1}.factorial_design.des.t1.scans = {};
for i = 1:length(CellGrp)
    if (NumContrast<10)
        tmp = cellstr(fullfile(inputdir,CellGrp{i},'spm','FirstLevel',['con_000' num2str(NumContrast) '.img']));
    else
        tmp = cellstr(fullfile(inputdir,CellGrp{i},'spm','FirstLevel',['con_00' num2str(NumContrast) '.img']));
    end
    matlabbatch{end}.stats{1}.factorial_design.des.t1.scans = [matlabbatch{1}.stats{1}.factorial_design.des.t1.scans ; tmp]
end
matlabbatch{end}.stats{1}.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.stats{1}.factorial_design.masking.tm.tm_none = 1;
matlabbatch{end}.stats{1}.factorial_design.masking.im = 1;
matlabbatch{end}.stats{1}.factorial_design.masking.em = {''};
matlabbatch{end}.stats{1}.factorial_design.globalc.g_omit = 1;
matlabbatch{end}.stats{1}.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{end}.stats{1}.factorial_design.globalm.glonorm = 1;

%% ESTIMATION
%-----------------------------------------------------------------------
matlabbatch{end}.stats{2}.fmri_est.spmmat = cellstr(fullfile(inputdir,'GroupAnalysis',Grp,ContrastName,'SPM.mat'));
matlabbatch{end}.stats{2}.fmri_est.write_residuals = 0;
matlabbatch{end}.stats{2}.fmri_est.method.Classical = 1;


%% INFERENCE
%--------------------------------------------------------------------------

% Definition of contrasts
%-----------------------------------------------------------------------
matlabbatch{end}.stats{3}.con.spmmat = cellstr(fullfile(inputdir,'GroupAnalysis',Grp,ContrastName,'SPM.mat'));
matlabbatch{end}.stats{3}.con.consess{1}.tcon.name = horzcat(Grp,' : ',ContrastName);
matlabbatch{end}.stats{3}.con.consess{1}.tcon.weights = 1;
matlabbatch{end}.stats{3}.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.delete = 0;

% Results
%-----------------------------------------------------------------------
matlabbatch{end}.stats{4}.results.spmmat = cellstr(fullfile(inputdir,'GroupAnalysis',Grp,ContrastName,'SPM.mat'));
matlabbatch{end}.stats{4}.results.conspec.titlestr = horzcat(Grp,' : ',ContrastName);
matlabbatch{end}.stats{4}.results.conspec.contrasts = 1;
matlabbatch{end}.stats{4}.results.conspec.threshdesc = 'FWE';
matlabbatch{end}.stats{4}.results.conspec.thresh = 0.05;
matlabbatch{end}.stats{4}.results.conspec.extent = 5;
matlabbatch{end}.stats{4}.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{end}.stats{4}.results.units = 1;
matlabbatch{end}.stats{4}.results.print = 'ps';
matlabbatch{end}.stats{4}.results.write.none = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(inputdir,'GroupAnalysis',Grp,ContrastName,'batch_analysisSL.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);