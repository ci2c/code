function BPM = bpm_con_man_surf(BPM,nbleft)

% Command line branch of execution

nContrasts = size(BPM.contrast,1);

if strcmp(BPM.type,'REGRESSION')
   c = BPM.contrast{1};
else
   c = BPM.contrast(nContrasts,:)';
end

Vb_surf = double(SurfStatReadData(BPM.beta));

Vs_surf = double(SurfStatReadData(BPM.sig2));
% %-voxel size
% M=Vs.mat(1:3, 1:3);
% VOX=sqrt(diag(M'*M))';

% read mask header if present
if ~isempty(BPM.mask)
    load(BPM.mask);
    brain_mask_surf = ~Mask;
end

% create Tmap or Fmap header for writing by slice
[path,name,ext] = fileparts(BPM.sig2{1});
if strcmp(BPM.type,'REGRESSION') || strcmp(BPM.type, 'MODEL_II_REGRESSION') || strcmp(BPM.type, 'REGRESSION_CALIBRATION')
    nContrasts = size(BPM.contrast,2);
    if strcmp(BPM.Type_STAT,'F')
       Smap_fname = sprintf('Fmap%d.img',nContrasts);
    else
       Smap_fname = sprintf('Tmap%d.img',nContrasts);
    end
else
    nContrasts = size(BPM.contrast,1);
    lh_Smap_fname = sprintf('lh.Tmap%d',nContrasts);
    rh_Smap_fname = sprintf('rh.Tmap%d',nContrasts);
end

BPM.Stat(nContrasts,:) = { fullfile(path,lh_Smap_fname) fullfile(path,rh_Smap_fname) };


% Get dimensions from sig2 header
M = size(Vs_surf,2);

% for ANCOVA and REGRESSION, XtX design matrices will be read
% from a binary file;
% otherwise, X will be loaded from X.mat specified in BPM.X

if strcmp(BPM.type, 'ANCOVA')  || strcmp(BPM.type, 'REGRESSION') || strcmp(BPM.type, 'MODEL_II_REGRESSION') || strcmp(BPM.type, 'REGRESSION_CALIBRATION')
  
    % set XtX dimensions for reshaping
    if strcmp(BPM.type, 'ANCOVA')
        nr = size(BPM.contrast,2);
    else 
        % REGRESSION
        nr = sum(BPM.DMS);
    end
    nx = M*nr*nr;        
    XtX = zeros(nr*nr,M);
    
    %
    % open design matrix file for reading by slice
    [fid, message] = fopen(BPM.XtX, 'r', 'b');
    if fid == -1
        error(message);
    end
end
%
if strcmp(BPM.type, 'ANCOVA')  | strcmp(BPM.type, 'ANOVA') | strcmp(BPM.type, 'ANCOVA_ROI')
    caption = 'Generating Tmap';
else 
    % REGRESSION
    if strcmp(BPM.Type_STAT,'F')
        Rc = rank(c);
        BPM.dof = [Rc BPM.dof];
        caption = 'Generating Fmap';
    else 
        caption = 'Generating Tmap';
    end
end

BETA = zeros(size(BPM.beta,1),M);

if BPM.Nonpf
    %-Variance smoothing for BnPM
    % Blurred mask is used to truncate kernal to brain; if not
    % used variance at edges would be underestimated due to
    % convolution with zero activity out side the brain.
    %-----------------------------------------------------------------
    ResSS = spm_read_vols(Vs);
    vFWHM = BPM.vFWHM;
    if BPM.bVarSm
        SmResSS   = zeros(M,N,L);
        SmMask    = zeros(M,N,L);
        TmpVol    = zeros(M,N,L);
        sig2par   = zeros(M,N,L);
        TmpVol    = brain_mask_vol;
        TmpVol    = double(TmpVol);
        spm_smooth(TmpVol,SmMask,vFWHM./VOX);
        TmpVol    = ResSS;
        spm_smooth(TmpVol,SmResSS,vFWHM./VOX);
        sig2par(SmMask>0) = SmResSS(SmMask>0)./SmMask(SmMask>0);
    else
        sig2par = ResSS;
    end
end

% Compute and write out the surface map
Smap = zeros(1,M);

ConImage = zeros(1,M);
c
for k = 1:size(BPM.beta,1)
    BETA(k,:) = Vb_surf(k,:);
    ConImage = ConImage + BETA(k,:) * c(k);
end
if BPM.Nonpf
    sig2 = sig2par(:,:,slice_no);
else    
    sig2 = Vs_surf;        
end

% Computing the Statistical maps
switch BPM.type
    case{'ANCOVA', 'REGRESSION'} 
        % read design matrices for slice    
        fid
        [XtX, count] = fread(fid, nx, 'double');       
        if count ~= nx               
            error(sprintf('error reading design matrix file'));             
        end       
        XtX = reshape(XtX,nr*nr,M);       
           
        if strcmp(BPM.type, 'ANCOVA')           
            Smap = bpm_compute_Tmap_surf(ConImage, XtX, c, brain_mask_surf, sig2, Smap, M, nr); 
        else                       
            % regression      
            if strcmp(BPM.Type_STAT,'F') 
                Smap(:,:,slice_no) = wfu_bpm_compute_Fmap(BETA_slice,XtX, c, Rc, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr); 
%                     Smap(:,:,slice_no) = compute_Robust_Fmap(BETA_slice,XtX, c, Rc, brain_mask, sig, Smap(:,:,slice_no),M,N,nr);                                     
            else                
                Smap(:,:,slice_no) = wfu_bpm_compute_Tmap(ConImage, XtX, c, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr);    
                %                     Smap(:,:,slice_no) = compute_Robust_Tmap(ConImage, XtX, c, brain_mask, sig, Smap(:,:,slice_no),M,N,nr);                        
            end
        end
        
    case{'ANOVA', 'ANCOVA_ROI'}    
        % anova & ancova with ROI       
        load(BPM.X);   
        Smap(:,:,slice_no) = wfu_bpm_compute_Tmap2(ConImage, X, c,brain_mask, sig2, Smap(:,:,slice_no),M,N);
                  
    case 'MODEL_II_REGRESSION'  
        % read design matrices for slice 
        [XtX, count] = fread(fid, nx, 'double');      
        if count ~= nx
            error(sprintf('error reading design matrix file on slice %d', slice_no));           
        end        
        XtX = reshape(XtX, M, N, nr*nr);          
        if BPM.fmuimg           
            Vu = spm_vol(BPM.prior);           
            mu = spm_slice_vol(Vu, spm_matrix([0 0 slice_no]), Vu.dim(1:2), 0); % read prior image            
        else            
            mu = BPM.prior(:);          
        end        
        nsubj = BPM.nsubj;          
        Smap(:,:,slice_no) = modelII_compute_Tmap(BETA_slice, XtX, c, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr,mu.^2,nsubj,BPM.fmuimg);                  
      
    case 'REGRESSION_CALIBRATION'        
        % read design matrices for slice      
        [XtX, count] = fread(fid, nx, 'double');      
        if count ~= nx      
            error(sprintf('error reading design matrix file on slice %d', slice_no));        
        end        
        XtX = reshape(XtX, M, N, nr*nr);      
        Smap(:,:,slice_no) = rc_compute_Tmap(ConImage, XtX, c, brain_mask, Smap(:,:,slice_no),M,N,nr);   
end        
Tmap_lh = Smap(1:nbleft);
Tmap_rh = Smap(nbleft+1:end);
SurfStatWriteData(fullfile(BPM.result_dir,lh_Smap_fname), Tmap_lh , 'b' );
SurfStatWriteData(fullfile(BPM.result_dir,rh_Smap_fname), Tmap_rh , 'b' );

% close all input and output files
if strcmp(BPM.type, 'ANCOVA') || strcmp(BPM.type, 'REGRESSION') || strcmp(BPM.type, 'MODEL_II_REGRESSION') || strcmp(BPM.type, 'REGRESSION_CALIBRATION')
    fclose(fid);
end

% % ------------- Update BPM file -------------------------- %
if nargin < 1
   save(BPM_fname, 'BPM');
   % close SPM figure
   spm_figure('Clear','Interactive'); 
   close(H) 
else    
   save BPM BPM
end

