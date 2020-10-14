function FConn_MultipleRegression(epiFile,outdir,TR,seed,motion,covariate,analysis_method,preproc_filter,meanFile)

if nargin < 8
    preproc_filter = [0 0];
    meanFile       = '';
end

if strcmp(analysis_method,'glmSPM')
    
    functionalFiles     = cellstr(epiFile);
    xfunctionalFiles    = functionalFiles;
    [tempa,tempb,tempc] = fileparts(functionalFiles{1}); 
    if length(functionalFiles)==1&&strcmp(tempc,'.nii'),
        xfunctionalFiles=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4)); 
    end

    spm_get_defaults;

    spm_jobman('initcfg');

    for k = 1:length(seed)

        if seed(k).nrois > 0

            matlabbatch = {};
            cp = 0;

            % DESIGN MATRIX
            outdir_seed = fullfile(outdir,seed(k).name);
            if (exist(outdir_seed,'dir'))
                cmd = sprintf('rm -rf %s',outdir_seed);
                unix(cmd);
            end
            cmd = sprintf('mkdir %s',outdir_seed);
            unix(cmd);
            matlabbatch{end+1}.spm.stats.fmri_spec.dir          = cellstr(outdir_seed);
            matlabbatch{end}.spm.stats.fmri_spec.timing.units   = 'scans';
            matlabbatch{end}.spm.stats.fmri_spec.timing.RT      = TR;
            matlabbatch{end}.spm.stats.fmri_spec.timing.fmri_t  = 16;
            matlabbatch{end}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
            matlabbatch{end}.spm.stats.fmri_spec.sess.scans     = xfunctionalFiles;
            matlabbatch{end}.spm.stats.fmri_spec.sess.cond      = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
            matlabbatch{end}.spm.stats.fmri_spec.sess.multi     = {''};

            % Seed
            cp = cp+1;
            matlabbatch{end}.spm.stats.fmri_spec.sess.regress(cp).name = seed(k).name;
            matlabbatch{end}.spm.stats.fmri_spec.sess.regress(cp).val  = seed(k).tseries;

            % Covariates
            for j = 1:length(covariate)
                cp = cp+1;
                matlabbatch{end}.spm.stats.fmri_spec.sess.regress(cp).name = covariate(j).name;
                matlabbatch{end}.spm.stats.fmri_spec.sess.regress(cp).val  = covariate(j).tseries;
            end

            % Motion
            for j = 1:size(motion,2)
                cp = cp+1;
                matlabbatch{end}.spm.stats.fmri_spec.sess.regress(cp).name = ['motion' num2str(j)];
                matlabbatch{end}.spm.stats.fmri_spec.sess.regress(cp).val  = motion(:,j);
            end

            matlabbatch{end}.spm.stats.fmri_spec.sess.multi_reg = {''};
            matlabbatch{end}.spm.stats.fmri_spec.sess.hpf = 128;
            matlabbatch{end}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
            matlabbatch{end}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
            matlabbatch{end}.spm.stats.fmri_spec.volt = 1;
            matlabbatch{end}.spm.stats.fmri_spec.global = 'None';
            matlabbatch{end}.spm.stats.fmri_spec.mthresh = 0.8;
            matlabbatch{end}.spm.stats.fmri_spec.mask = {''};
            matlabbatch{end}.spm.stats.fmri_spec.cvi = 'AR(1)';

            % INFERENCE
            matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1)      = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
            matlabbatch{end}.spm.stats.fmri_est.write_residuals  = 0;
            matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;

            % CONTRAST MANAGER
            matlabbatch{end+1}.spm.stats.con.spmmat(1)             = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
            matlabbatch{end}.spm.stats.con.consess{1}.tcon.name    = [seed(k).name ' > 0'];
            matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = 1;
            matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            matlabbatch{end}.spm.stats.con.delete                  = 0;

            if ~isempty(matlabbatch),
                spm_jobman('run',matlabbatch);
            end

        end

    end
    
elseif strcmp(analysis_method,'glm')
    
    cov = [];
    % Covariates
    for j = 1:length(covariate)
        cov = [cov covariate(j).tseries];
    end

    % Motion
    cov = [cov motion];
    
    % read data
    V   = spm_vol(epiFile);
    Y   = spm_read_vols(V);
    dim = size(Y);
    Nt  = dim(4);
    Y   = reshape(Y,dim(1)*dim(2)*dim(3),Nt)';
    Vm  = spm_vol(meanFile);
    
    for k = 1:length(seed)

        if seed(k).nrois > 0
            
            outdir_seed = fullfile(outdir,seed(k).name);
            if (exist(outdir_seed,'dir'))
                cmd = sprintf('rm -rf %s',outdir_seed);
                unix(cmd);
            end
            cmd = sprintf('mkdir %s',outdir_seed);
            unix(cmd);
            
            X = [seed(k).tseries cov];
            
            iX = pinv(X'*X);
            if (preproc_filter(2)==0)
                DOF = max(0,Nt*( 1/(2*TR) - max(0,preproc_filter(1)))/(1/(2*TR))-rank(X)+1);
            else
                DOF = max(0,Nt*(min(1/(2*TR),preproc_filter(2))-max(0,preproc_filter(1)))/(1/(2*TR))-rank(X)+1);
            end
            
            Y = detrend(Y,'constant');
            B = iX*(X'*Y);
            e = sqrt(sum(abs(Y).^2,1));
            e = e/max(eps,DOF);
            e = reshape(e,dim(1:3));
            Vm.fname = fullfile(outdir_seed,'SEout.nii');
            spm_write_vol(Vm,e);
            beta = reshape(B(1,:)',dim(1:3));
            Vm.fname = fullfile(outdir_seed,'Beta.nii');
            spm_write_vol(Vm,beta);
            
            resid = Y-X(:,1)*B(1,:);
            SSE   = sum(resid.^2,1);
            sd    = sqrt(SSE/DOF);
            
            V      = iX*iX';            
            VV     = V(1,1);
            mag_sd = sqrt(VV)*sd;
            tstat  = (B(1,:)./(mag_sd+(mag_sd<=0)).*(mag_sd>0))';
            
            p    = spm_Ncdf(B(1,:)'*sqrt(max(0,DOF-3)));
            p    = 2*min(p,1-p);
            p(:) = conn_fdr(p(:));
            
            pval = reshape(p,dim(1:3));
            Vm.fname = fullfile(outdir_seed,'Pvalue.nii');
            spm_write_vol(Vm,pval);
            
            StdDev = reshape(mag_sd',dim(1:3));
            Vm.fname = fullfile(outdir_seed,'Std.nii');
            spm_write_vol(Vm,StdDev);
%             Tmap = reshape(tstat',dim(1:3));
%             Vm.fname = fullfile(outdir_seed,'tMap.nii');
%             spm_write_vol(Vm,Tmap);
            
        end
        
    end
               
elseif strcmp(analysis_method,'correlation')
    
    cov = [];
    % Covariates
    for j = 1:length(covariate)
        cov = [cov covariate(j).tseries];
    end

    % Motion
    cov = [cov motion];
    
    % read data
    V   = spm_vol(epiFile);
    Y   = spm_read_vols(V);
    dim = size(Y);
    Nt  = dim(4);
    Y   = reshape(Y,dim(1)*dim(2)*dim(3),Nt)';
    Vm  = spm_vol(meanFile);
    
    % Suppression covariables
    for i = 0:3
        X(:,i+1) = ((1:Nt)').^i;
    end
    X = [X cov];
    beta = (pinv(X'*X)*X')*Y;
    Y    = Y - X*beta;
    
    % Filtering
    bpfilter.tr = TR;
    bpfilter.hp = 0.01;
    bpfilter.lp = 0.08; % Inf
    Y = niak_filter_tseries(Y,bpfilter);
    
    % Normalization
    optn.type = 'mean_var';
    Y = niak_normalize_tseries(Y,optn.type);
    
    % Correlation
    cp = 0;
    for k = 1:length(seed)
        if seed(k).nrois > 0            
            cp = cp+1;            
            reg(:,cp) = seed(k).tseries;            
        end     
    end
            
    C = corr(reg,Y);
    
    cp=0;
    for k = 1:length(seed)

        if seed(k).nrois > 0
            
            cp = cp+1;
            % Fisher
            Z(cp,:) = 0.5 * log( (1+C(cp,:))./(1-C(cp,:)) );
            
            outdir_seed = fullfile(outdir,seed(k).name);
            if (exist(outdir_seed,'dir'))
                cmd = sprintf('rm -rf %s',outdir_seed);
                unix(cmd);
            end
            cmd = sprintf('mkdir %s',outdir_seed);
            unix(cmd);
            
            Zscore = reshape(Z(cp,:)',dim(1:3));
            Vm.fname = fullfile(outdir_seed,'Zscore.nii');
            spm_write_vol(Vm,Zscore);
            
        end
        
    end
    
end
