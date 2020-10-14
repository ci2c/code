function bpm_analysis_surf(type,flist,contrast,STAT,mask, conf, thr, result_dir,title, Inf_Type, bRobust, r_wfun, prior, winsize,fCluster,template) 
%--------------------------------------------------------------------------
%                                wfu_bpm 
%--------------------------------------------------------------------------  
%   Format: 
%   wfu_bpm(type,flist,contrast,STAT,mask,conf,result_dir,title, Inf_Type)
%--------------------------------------------------------------------------
%   Examples:
%    >> wfu_bpm; %-launches GUI  
%    >> wfu_bpm('CORR','flist.txt',[],[],'mask.img',[],[],[],[],'HCF');
%    >> wfu_bpm('ANCOVA','master_flist.txt',[ 1 -1 0],'T',[],[],[ 1 0.1],[],[],[]);%           
%--------------------------------------------------------------------------
%             wfu_bpm can be executed from the command line 
%
%  Input Parameters:
%   type      - Type of analysis to be performed. Possible values are:
%               'ANOVA'         =   Anova 
%               'ANCOVA'        =   BPM Ancova              
%               'CORR'          =   Correlation
%               'PCORR'         =   Partial Correlation
%               'REGRESSION'    =   BPM Regression
%
%   flist     - The master file. It contains a list of txt files. One per
%               each modality involved in the analysis.
%             
%   contrast  - a given contrast 
%
%   STAT      - Statistic type ('T','F')
%   
%   mask      - (optional) path and file name of the file containing the brain 
%                mask. If the user does not supply one BPM will build one by
%                default. The user must check the resulting mask.img file.%
%             
%   conf      - path and name of the file containing the not imaging confounds 
%    
%    thr      - threshold to build the default brain mask whebn the user
%               does not supply one. thr is a vector with 2 elements. The
%               first one indicates the type of the threshold (1 is 
%               proportional 2 absolute). The second element is the value of
%               the threshold.
%
% result_dir  - the path and name of the directory where results will be
%               stored.
%
% title       - name assigned to the contrast 
%
% Inf_Type    - specify the type of inference to use with the correlation
%              option
%              'HCF'  = Homologous Correlation Field
%              'TF'   = T-fields
%
% bRobust    - 1: use robust regression, 0: use non robust regression
%
% r_wfun     - weight function for robust regression
%--------------------------------------------------------------------------


%========== Initialization ===========%  

    if nargin < 3 & type ~= 'CORR'        
        warning('Not enough input arguments');
        return      
    end
    if strcmp(type,'CORR_V-V')
        type      = 'CORR';
        BPM.corr_type = 'V-V';
        if ~isempty(Inf_Type)
            BPM.Inf_Type = Inf_Type;
        else
            warning(sprintf('Inference type is not defined'));
            return  
        end
    end
    if strcmp(type,'PCORR')        
        BPM.corr_type = '';
        BPM.pc_control_var = conf;
        if ~isempty(Inf_Type)
            BPM.Inf_Type = Inf_Type;
        else
            warning(sprintf('Inference type is not defined'));
            return  
        end
    end
    
%========== set parameters via COMMAND LINE arguments ===========%

    if any(strcmp(type,{'CORR','ANCOVA','REGRESSION','ANOVA','PCORR','MODEL_II_REGRESSION','REGRESSION_CALIBRATION'}))
        BPM.type = type;
    else
        warning(sprintf('Calculation type (%s) is invalid',type));
        return
    end 
    % ----- Number of groups and imaging covariates ------ %
    if ~(strcmp(BPM.type,'CORR') || strcmp(BPM.type,'PCORR') || strcmp(BPM.type,'REGRESSION') ...
            || strcmp(BPM.type,'MODEL_II_REGRESSION') || strcmp(BPM.type, 'REGRESSION_CALIBRATION'))
        flist
        mf = textread(flist, '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0);
        mf{2}
        BPM.DMS(1) = size(textread(mf{2}, '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0),1);
    else
        BPM.DMS(1) = 1;
    end
    
    master_name = flist;
    master_name
    file_names = wfu_bpm_read_flist(master_name);
    
    if (strcmp(BPM.type,'ANOVA'))
        BPM.DMS(3) = 0;
    else
        BPM.DMS(3) = size(file_names,1)-1;
    end
    
    %----- image list -----%        
    
    BPM.flist = master_name; 
    if any(strcmp(type,{'ANOVA','ANCOVA'}))   
        BPM.STAT = 'T';   
        c = contrast(:);        
        c = [0;c];        
        if ~isfield(BPM,'contrast')
            BPM.contrast = c';
            if ~isempty(title)
                BPM.maptitles{1} = title;
            else
                BPM.maptitles{1} = strcat(BPM.STAT,'map','1');
            end
        else   
            BPM.contrast = [BPM.contrast; c'];             
            BPM.maptitles{size(BPM.contrast,1)}   = strcat(BPM.STAT,'map',num2str(size(BPM.contrast,1)));
        end   
    end    
    if any(strcmp(type,{'REGRESSION','MODEL_II_REGRESSION','REGRESSION_CALIBRATION'})) 
        if strcmp(STAT,'F')
            sr = contrast;
            c  = eye(length(sr));
            IndReg = find(sr>0);
            c = c(:,IndReg);
            BPM.Type_STAT = 'F';
        else 
            c = contrast;
            c = c(:);
            BPM.Type_STAT = 'T';
        end
        if ~isfield(BPM,'contrast')
            BPM.contrast    = cell(1);
            BPM.contrast{1} = c;
            if ~isempty(title)
                BPM.maptitles{1} = title;
            else
                BPM.maptitles{1} = strcat(BPM.Type_STAT,'map','1');
            end
        else 
            BPM.contrast{length(BPM.contrast)+1} = c;
            BPM.maptitles{length(BPM.contrast)+1}   = strcat(BPM.STAT,'map',num2str(length(BPM.contrast)+1));
        end           
    end
    
    %----- brain mask -----% 
    if nargin < 5 | isempty(mask)
        BPM.mask = [];      
    else        
        BPM.mask = mask;         
    end    
    %----- non-imaging confounds -----% 
    if nargin < 6 | isempty(conf)
        BPM.conf   = [];    
        BPM.DMS(2) = 0;
    else
        load(conf)
        bname = basename(conf);
        BPM.DMS(2) = size(eval(bname),2);
        BPM.conf   = conf ;
    end
    
    %---------- threshold for building the brain mask ----%
    if nargin < 7 | isempty(thr)
        BPM.mask_pthr = 0.1 ;
    else
        if thr(1) == 1
            BPM.mask_pthr = thr(2);
        else
            BPM.mask_athr = thr(2);
        end        
    end
    
    if nargin < 8 | isempty(result_dir)
        BPM.result_dir = pwd;
    else
        BPM.result_dir = result_dir;
    end
    
    % robust regression
    if nargin < 11 | isempty(bRobust)
        BPM.robust = 0;
    else
        if bRobust ==1
            BPM.robust = 1;
        else
            BPM.robust = 0;
        end
    end
    
    % weight function for robust regression
    if nargin < 12 | isempty(r_wfun)
        BPM.rwfun = 'huber';
    else
        BPM.rwfun = r_wfun;
    end
    
        % Prior for Model II regression
    if nargin < 13 || isempty(prior)
        BPM.prior = [];      
    else        
        BPM.prior = prior;         
    end 
    
    %---------- window size for calculating std ----%
    if nargin < 14 || isempty(winsize)
        BPM.winsize = '' ;
    else
        BPM.winsize = winsize;      
    end
    
    %---------- flag if use cluster ----%
    if nargin < 15 || isempty(fCluster)
        BPM.fcluster = 0;
        BPM.template = '';
    else
        BPM.fcluster = 1; 
        BPM.template = template;
    end

% ------ Reslicing the ROI mask -----------------------------%

if isfield(BPM,'mask_ROI') | isfield(BPM,'mask_ancova_ROI')
    Vmask      = spm_vol(BPM.mask);
    C{1}       = BPM.mask;
    if isfield(BPM,'mask_ROI') 
        Vmask_ROI                = spm_vol(BPM.mask_ROI);
        C{2}                     = BPM.mask_ROI;   
    else
        Vmask_ROI                = spm_vol(BPM.mask_ancova_ROI);
        C{2}                     = BPM.mask_ancova_ROI;
    end
    
    if ~isequal(Vmask.dim(1:3),Vmask_ROI.dim(1:3))              
        P          = strvcat(C);    
        flag.mean  = 0;
        flag.which = 1;
        spm_reslice(P,flag);
        if isfield(BPM,'mask_ROI') 
            [filepath,fname,ext]     = fileparts(BPM.mask_ROI);
            rfname                   = strcat('r',fname);
            BPM.mask_ROI             = fullfile(filepath,strcat(rfname,ext));
        else
            [filepath,fname,ext]     = fileparts(BPM.mask_ancova_ROI);
            rfname                   = strcat('r',fname);
            BPM.mask_ancova_ROI      = fullfile(filepath,strcat(rfname,ext));
        end
        
    end
end

% set file name for design matrix information file
BPM.XtX = fullfile(BPM.result_dir, 'XtX');
warning off MATLAB:divideByZero;

% ---- deleting the content of the result directory ----------%

cd(BPM.result_dir);

delete('lh.Res*');delete('rh.Res*'); delete('R*.mat');
delete('lh.Corr*');delete('rh.Corr*'); delete('C*.mat');
delete('lh.Tmap*');delete('rh.Tmap*'); delete('T*.mat');
delete('lh.beta*');delete('rh.beta*'); delete('b*.mat');
delete('lh.sig2*');delete('rh.sig2*'); delete('s*.mat');
delete('X.mat') ; delete('X*.*'); delete('BPM.mat');

% -----execute after result dir files deleted----- %

BPM.Nonpf = 0;
[results] = bpm_execute_surf(BPM);

%------ writing the results ------%

switch BPM.type
    
    case{'ANOVA' , 'ANCOVA', 'REGRESSION', 'ANCOVA_ROI', 'MODEL_II_REGRESSION', 'REGRESSION_CALIBRATION'} 
        
        % ---------- storing the beta coefficients file names ------------ %
        
        for k = 1:results.nr
            BPM.beta(k,:) = { fullfile(BPM.result_dir,sprintf('lh.beta%03d', k)) fullfile(BPM.result_dir,sprintf('rh.beta%03d', k)) }; 
        end
                 
        % --------- storing the residuals file names -------------------- % 
        for k = 1:results.nsubj
            BPM.E(k,:) = { fullfile(BPM.result_dir,sprintf('lh.Res%03d', k)) fullfile(BPM.result_dir,sprintf('rh.Res%03d', k)) };  
        end 
%         lh.P = strvcat(BPM.E(:,1));
%         rh.P = strvcat(BPM.E(:,2));
        
        % ---------- storing the sig2 in an mgh file ---------------------- %

        BPM.sig2    =  { fullfile(BPM.result_dir,'lh.sig2') fullfile(BPM.result_dir,'rh.sig2') };
        sig2_lh = results.sig2(1:results.nbleft);
        sig2_rh = results.sig2(results.nbleft+1:end);
        SurfStatWriteData(fullfile(BPM.result_dir,'lh.sig2'), sig2_lh , 'b' );
        SurfStatWriteData(fullfile(BPM.result_dir,'rh.sig2'), sig2_rh , 'b' );
        
        % ----------- storing X file -------------------------------------- %
        Xfname = fullfile(BPM.result_dir,'X');   
        X = results.X;
        save(Xfname, 'X')  ; 
        
        % ----------- filling other BPM fields ----------------------------- %
        BPM.X = Xfname     ;
        BPM.dof = results.dof      ;
        BPM.nsubj = results.nsubj;
        if nargin < 1
            BPM.contrast = []  ; 
        end
        if strcmp(BPM.type,'MODEL_II_REGRESSION')
            if isempty(BPM.prior)
                BPM.prior = results.prior;
            end
        end
        
    case{'CORR', 'PCORR'}
        % ---------  residuals file names -------------------- % 
        for k = 1:results.nsubj
            BPM.E(k,:) = { fullfile(BPM.result_dir,sprintf('lh.Res%03d', k)) fullfile(BPM.result_dir,sprintf('rh.Res%03d', k)) };  
        end 
        if  strcmp(BPM.corr_type,'V-V') || strcmp(BPM.type,'PCORR')
            % -------storing both Tmaps and Cmaps when vertex to vertex-----%
            %        Correlation or Partial Correlation                   %
            % ------- storing positive correlation map -------------------%
            BPM.Stat(1,:)    =  { fullfile(BPM.result_dir,'lh.Corr_pos') fullfile(BPM.result_dir,'rh.Corr_pos') };
            Corr_pos_lh = results.C(1:results.nbleft);
            Corr_pos_rh = results.C(results.nbleft+1:end);
            SurfStatWriteData(fullfile(BPM.result_dir,'lh.Corr_pos'), Corr_pos_lh , 'b' );
            SurfStatWriteData(fullfile(BPM.result_dir,'rh.Corr_pos'), Corr_pos_rh , 'b' );         
            % ------- storing negative correlation map -------------------%
            BPM.Stat(2,:)    =  { fullfile(BPM.result_dir,'lh.Corr_neg') fullfile(BPM.result_dir,'rh.Corr_neg') };
            Corr_neg_lh = -results.C(1:results.nbleft);
            Corr_neg_rh = -results.C(results.nbleft+1:end);
            SurfStatWriteData(fullfile(BPM.result_dir,'lh.Corr_neg'), Corr_neg_lh , 'b' );
            SurfStatWriteData(fullfile(BPM.result_dir,'rh.Corr_neg'), Corr_neg_rh , 'b' ); 
            % ------- storing the Tmap ------------------------%         
            BPM.Tmap(1,:)    =  { fullfile(BPM.result_dir,'lh.Tmap_pos') fullfile(BPM.result_dir,'rh.Tmap_pos') };
            Tmap_pos_lh = results.Stats(1:results.nbleft);
            Tmap_pos_rh = results.Stats(results.nbleft+1:end);
            SurfStatWriteData(fullfile(BPM.result_dir,'lh.Tmap_pos'), Tmap_pos_lh , 'b' );
            SurfStatWriteData(fullfile(BPM.result_dir,'rh.Tmap_pos'), Tmap_pos_rh , 'b' );              
            % ------- storing Tmap for testing negative correlations------%
            BPM.Tmap(2,:)    =  { fullfile(BPM.result_dir,'lh.Tmap_neg') fullfile(BPM.result_dir,'rh.Tmap_neg') };
            Tmap_neg_lh = -results.Stats(1:results.nbleft);
            Tmap_neg_rh = -results.Stats(results.nbleft+1:end);
            SurfStatWriteData(fullfile(BPM.result_dir,'lh.Tmap_neg'), Tmap_neg_lh , 'b' );
            SurfStatWriteData(fullfile(BPM.result_dir,'rh.Tmap_neg'), Tmap_neg_rh , 'b' ); 
        else
            % ------- storing Tmap for testing positive correlations-----%
            results.V.fname = fullfile(BPM.result_dir,'Tmap_plus.img');   
            spm_write_vol(results.V,results.Stats) ;
            BPM.Stat{1}    = results.V.fname ;            
            % ------- storing Tmap for testing negative correlations------%
            results.V.fname = fullfile(BPM.result_dir,'Tmap_minus.img');  
            spm_write_vol(results.V,-results.Stats) ;
            BPM.Stat{2}    = results.V.fname;
            % ------- storing the Correlation map ------------------------%
            results.V.fname =  fullfile(BPM.result_dir,'Corr_map.img');   
            spm_write_vol(results.V,results.C) ;       
        end
        
        BPM.dof = results.dof      ;        
end

% --------------- Estimating the smoothness ------------------- %
BPM.fwhm = spm_est_smoothness_surf(BPM); 

% ---------- Deleting the residual files -------------------------%

cd(BPM.result_dir);
% delete('lh.Res*');delete('rh.Res*'); delete('R*.mat');

% ---------- Calling the Contrast Manager in command line regime ----%
if nargin > 0 
    fname = fullfile(BPM.result_dir,'BPM');   
    save(fname, 'BPM');
    if ~any(strcmp(BPM.type,{'CORR','PCORR'}))                
        BPM = bpm_con_man_surf(BPM,results.nbleft);           
        save BPM
    end        
end
return



