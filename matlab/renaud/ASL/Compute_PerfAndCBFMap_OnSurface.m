function Compute_PerfAndCBFMap_OnSurface(aslFile,PLD,LabelDur,TE,SubtractionType,FirstimageType)

% Calculation of perfusion and CBF maps
%
% Usage: Compute_PerfAndCBFMap_Bis(aslFile,maskFile,PLD,LabelDur,TE,SubtractionType,FirstimageType)
% 
% Inputs
%   aslFile         : path to asl file (cell {lh,rh} .nii)
%   PLD             : post labeling delay value (ms)
%   LabelDur        : labeling duration (ms)
%   TE              : echo time (ms)
%   SubtractionType : (0: simple subtraction; 1: surround subtraction; 2:
%       sinc subtraction)
%   FirstimageType  : (0: Label image; 1: Control image)
%
% Outputs
%   Mean perfusion map (meanPERF_*.nii)
%   Mean CBF map (meanCBF_*.nii)
%
% Renaud Lopes @ CHRU Lille, June 2014  

%% INIT

SubtractionOrder = 1;

BOLDFlag    = 0;
OutPerfFlag = 0;


%% READ ASL

hdr_lh   = load_nifti(aslFile{1});
hdr_rh   = load_nifti(aslFile{2});
data_lh  = squeeze(hdr_lh.vol);
data_rh  = squeeze(hdr_rh.vol);
nbleft   = size(data_lh,1);

data     = [data_lh;data_rh];
tseries  = data';
clear data_lh data_rh data; 


%% PARAMETERS

spmver    = spm('ver',[],1);
modernSPM = any(strcmp(spmver,{'SPM5','SPM8','SPM12b', 'SPM12', 'SPM16'}));

% 3T
T1A    = 1664;
T1_gm  = 1249;
T2sA   = 106;
T2sCSF = 75;
T2s_gm = 44.2;
T2s_wm = 44.7;
T2sT   = 44.5;
lambda_gm = 0.98;
lambda_wm = 0.84;
lambda = 0.91;
alpha  = 0.95;

%    Timeshift - only valid for sinc interpolation, it's a value between
%    0 and 1 to shift the labeled image forward or backward.
Timeshift = 0.5;


%%

tlen   = size(tseries,1);
perfno = fix(tlen/2);

MEANSCALE = mean(tseries(:));  % a scale for removing outliers

meanBOLDimg = zeros(1,size(tseries,2));
meanPERFimg = zeros(1,size(tseries,2));
meanCBFimg  = zeros(1,size(tseries,2));

if FirstimageType  % 1 control first
    conidx = 1:2:2*perfno;
    labidx = 2:2:2*perfno;
else   % 0 label first
    conidx = 2:2:2*perfno;
    labidx = 1:2:2*perfno;
end

fseq=0;
fprintf('\n\rCBF quantification for L/C pair: %35s',' ');

[pth,midname1,ext] = fileparts(aslFile{1});
[pth,midname2,ext] = fileparts(aslFile{2});

prefix     = [pth filesep 'Perf_' num2str(SubtractionType)];
cbfprefix  = fullfile(pth, ['cbf_' num2str(SubtractionType)]);
BOLDprefix = [pth filesep 'PseuBold'];

hdr_lh.dim(1) = 3;
hdr_lh.dim(5) = 1;
hdr_lh.pixdim(5) = 0;

hdr_rh.dim(1) = 3;
hdr_rh.dim(5) = 1;
hdr_rh.pixdim(5) = 0;

for p = 1:perfno
    
    str   = sprintf('#%3d /%3d: ',p,perfno );
    fprintf('%s%15s%20s',repmat(sprintf('\b'),1,35),str,'...calculating');

    fseq = fseq+1;

    Vlabimg = tseries(labidx(p),:);
    
    % Here we assumed that the image values are modest, so no overflow will occur.
    switch SubtractionType
        
       case 1   % The linear interpolation method "surround average"

           Vconimg = tseries(conidx(p),:);

           if FirstimageType
               if p<perfno
                    Vconimg = (Vconimg+squeeze(tseries(conidx(p+1),:)))/2;
               end
           else
                if p>1 
                    Vconimg = (Vconimg+squeeze(tseries(conidx(p-1),:)))/2; 
                end
           end

       case 2   % sinc-subtraction
           
           % 6 point sinc interpolation
           if FirstimageType==0
               idx=p+[-3 -2 -1 0 1 2];
               normloc=3-Timeshift;
           else
               idx=p+[-2 -1 0 1 2 3];
               normloc=2+Timeshift;
           end
           idx(find(idx<1))=1;
           idx(find(idx>perfno))=perfno;
           nimg = tseries(conidx(idx),:)';
           clear tmpimg;
           [pn,tn] = size(nimg);
           tmpimg  = sinc_interpVec(nimg,normloc);
           Vconimg = zeros(size(nimg,1),1);
           Vconimg = tmpimg';
           clear tmpimg pn tn;
           
       otherwise

           Vconimg = tseries(conidx(p),:);
           
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % perform subtraction
    perfimg = Vconimg-Vlabimg;
    if SubtractionOrder==0  %label-control
        perfimg = -1.0*perfimg;
    end

    BOLDimg  = (Vconimg+Vlabimg)/2.;
    meanbold = squeeze(mean(BOLDimg,1));

    if BOLDFlag
        Vbold=Vall(1);
        Vbold.fname=[BOLDprefix '_' midname '_' num2str(fseq,'%0.3d') imgaffix];
        if modernSPM
        Vbold.dt=[16 0];
        else
        Vbold.dim(4)=16;
        end
        Vbold=spm_write_vol(Vbold,BOLDimg);
    end
    meanPERFimg = meanPERFimg+perfimg;
    if BOLDFlag==1 meanBOLDimg=meanBOLDimg+Vconimg;  end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CBF quantification
    cbfimg = zeros(size(perfimg));
    
    clear tcbf;
    M0    = Vconimg;
    tperf = perfimg;
    tcbf  = zeros(size(M0));
    
    effidx = find(abs(M0)>1e-3*mean(M0(:)));
    effM0  = M0(effidx);
    efftperf = tperf(effidx);

    efftcbf = (-6000*1000*lambda*efftperf)./( 4*alpha.*effM0.*(exp(TE/T2sT)./lambda).*T1_gm.*( exp(-(PLD+LabelDur)/T1A) - exp(-LabelDur/T1_gm) ) );
%     efftcbf=efftperf./effM0;
%     efftcbf=6000*1000*lambda*efftcbf*r1a./(2*labeff* (exp(-omega*r1a)-exp( -1*(Labeltime+omega)*r1a) ) );
    tcbf(effidx) = efftcbf;
    cbfimg = tcbf;

    meanCBFimg = meanCBFimg+cbfimg;
           
    % Getting a mask for outliers
    % mean+3std has problem in some cases
    nanmask         = isnan(cbfimg);
    cbfimg(nanmask) = 0;

    hdr_lh.vol = cbfimg(1:nbleft)';
    fname = [cbfprefix '_' num2str(fseq,'%0.3d') '_' midname1 ext];
    save_nifti(hdr_lh,fname);
    hdr_rh.vol = cbfimg(nbleft+1:end)';
    fname = [cbfprefix '_' num2str(fseq,'%0.3d') '_' midname2 ext];
    save_nifti(hdr_rh,fname);
        
    if OutPerfFlag
        hdr_lh.vol = perfimg(1:nbleft)';
        fname = [prefix '_' num2str(fseq,'%0.3d') '_' midname1 ext];
        save_nifti(hdr_lh,fname);
        hdr_rh.vol = perfimg(nbleft+1:end)';
        fname = [prefix '_' num2str(fseq,'%0.3d') '_' midname2 ext];
        save_nifti(hdr_rh,fname);
    end
    
end  %end the main loop
fprintf('%s%20s',repmat(sprintf('\b'),1,20),'...done');

% Mean images
meanPERFimg = meanPERFimg./perfno;
meanCBFimg  = meanCBFimg./perfno; 
if BOLDFlag==1, meanBOLDimg=meanBOLDimg./perfno; end;

% Save perfusion image
hdr_lh.vol = meanPERFimg(1:nbleft)';
fname = fullfile(pth,['meanPERF_' num2str(SubtractionType) '_' midname1 ext]);
save_nifti(hdr_lh,fname);
hdr_rh.vol = meanPERFimg(nbleft+1:end)';
fname = fullfile(pth,['meanPERF_' num2str(SubtractionType) '_' midname2 ext]);
save_nifti(hdr_rh,fname);

% Save cbf image
hdr_lh.vol = meanCBFimg(1:nbleft)';
fname = fullfile(pth,['meanCBF_' num2str(SubtractionType) '_' midname1 ext]);
save_nifti(hdr_lh,fname);
hdr_rh.vol = meanCBFimg(nbleft+1:end)';
fname = fullfile(pth,['meanCBF_' num2str(SubtractionType) '_' midname2 ext]);
save_nifti(hdr_rh,fname);

if BOLDFlag==1
    hdr_lh.vol = meanBOLDimg(1:nbleft)';
    fname = fullfile(pth,['meanBOLD_' num2str(SubtractionType) '_' midname1 ext]);
    save_nifti(hdr_lh,fname);
    hdr_rh.vol = meanBOLDimg(nbleft+1:end)';
    fname = fullfile(pth,['meanBOLD_' num2str(SubtractionType) '_' midname2 ext]);
    save_nifti(hdr_rh,fname);
end

