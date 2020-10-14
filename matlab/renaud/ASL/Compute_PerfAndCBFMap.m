clear all; close all

%% INIT

aslFile  = '/home/renaud/NAS/pierre/Epilepsy/FreeSurfer5.0/Patients_fmri_dti/Bourgeois_Aurelie/asltest2/asltbx/asl.mc.nii';
maskFile = '/home/renaud/NAS/pierre/Epilepsy/FreeSurfer5.0/Patients_fmri_dti/Bourgeois_Aurelie/asltest2/asltbx/asl_mask.nii'; 

Labeltime = 1.65;
Delaytime = 1.525;
labeff    = 0.85;  % 0.85
minTR     = 4046;
nslices   = 24;

FirstimageType   = 1;
SubtractionType  = 0;
SubtractionOrder = 1;

BOLDFlag = 0;
OutPerfFlag = 0;

Slicetime = (minTR-Labeltime*1000-Delaytime*1000)/nslices;

imgaffix = '.nii';
[tempa,tempb,tempc] = fileparts(aslFile);
Filename = spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4);

%%

spmver    = spm('ver',[],1);
modernSPM = any(strcmp(spmver,{'SPM5','SPM8','SPM12b', 'SPM12', 'SPM16'}));

BPTransTime=200;          % Blood pool transit time
TissueTransTime=1500;     % Tissue transit time
MinGrayT1=900;            % Min T1 of gray matter in ms
MaxGrayT1=1600;           % Max T1 of gray matter in ms
MinWhiteT1=300;           % Min T1 of wht matter in ms
MaxWhiteT1=900;           % Max T1 of wht matter in ms
TI1=700;                  % Tagging bolus duration in ms, for the QUIPSS II. This is the default value, but you can use Labeltime to input a specific value, see line 649
qTI=0.85;  
Rwm=1.19;     %1.06 in Wong 97. 1.19 in Cavosuglu 09, Proton density ratio between blood and WM;
                  % needed only for AslType=0 (PASL) with QuantFlag=1 (unique M0 based quantification)
Rcsf=0.87;    % both Rwm and Rcsf are for 3T only, you need to change them for other field strength.
lambda=0.9; %*100*60;   %0.9 mL/g

% 3T
T2wm    = 44.7;   % used to be 40;
T2b     = 43.6;    % used to be 80;   
T2csf   = 74.9;
BloodT1 = 1664;    % 1664 % was 1490 in Wang 03;

% 1.5T
T2wm    = 55;
T2b     = 100;
BloodT1 = 1200;

relthresh = 0.05;

Labeltime = Labeltime*1000;
Delaytime = Delaytime*1000;

r1a = 1/BloodT1; %0.601 sec for 3T was set to 0.67  sec in Wang 03

%%

Vall = spm_vol(deblank( Filename ) );
Is4D = size(Filename,1)<2;

if spm_check_orientations(Vall)
    alldat=spm_read_vols(Vall);
else
    alldat=[];
    for im=1:size(Filename,1)
        alldat=cat(4,alldat,spm_read_vols(Vall(im)));
    end
end
alldat(find(isnan(alldat)))=0;
tlen=size(alldat,4);
if tlen<2, fprintf('You should select at least a pair of ASL raw images!\n');return;end;
perfno=fix(tlen/2);
imno=perfno*2;

% mask
vmm     = spm_vol(deblank( maskFile ) );
maskdat = spm_read_vols(vmm);
glmask  = maskdat>0.75;                 % global threshold

brain_ind = find(glmask>0);            % within brain voxels
vxidx     = brain_ind;                 % vxidx indicates voxel locations for quantification

MEANSCALE=mean(alldat(glmask));  % a scale for removing outliers

meanBOLDimg = zeros(Vall(1).dim(1),Vall(1).dim(2),Vall(1).dim(3));
meanPERFimg = zeros(Vall(1).dim(1),Vall(1).dim(2),Vall(1).dim(3));
meanCBFimg  = zeros(Vall(1).dim(1),Vall(1).dim(2),Vall(1).dim(3));

if FirstimageType  % 1 control first
    conidx = 1:2:2*perfno;
    labidx = 2:2:2*perfno;
else   % 0 label first
    conidx = 2:2:2*perfno;
    labidx = 1:2:2*perfno;
end

[pth,nm,xt] = fileparts(deblank(Filename(1,:)));
prevpth=pth;
fseq=0;
fprintf('\n\rCBF quantification for L/C pair: %35s',' ');
midname4D='';

for p=1:perfno
    
    str   = sprintf('#%3d /%3d: ',p,perfno );
    fprintf('%s%15s%20s',repmat(sprintf('\b'),1,35),str,'...calculating');
    
    [pth,nm,xt] = fileparts(deblank(Filename( (2*(p-1)+1+FirstimageType),:)));
    xt=strtok(xt,',');  % removing the training ','
    midname=spm_str_manip(Filename(2*(p-1)+1,:),'dts');

    midname=strtok(midname,',');  % this could be redundant
    midname=spm_str_manip(midname,'dts');
    if p==1, midname4D=midname; end;
    if strcmp(prevpth,pth)==0   fseq=0;    end
    fseq    = fseq+1;
    prevpth = pth;
    prefix     = [pth filesep 'Perf_' num2str(SubtractionType)];
    cbfprefix  = fullfile(pth, ['cbf_' num2str(SubtractionType)]);
    BOLDprefix = [pth filesep 'PseuBold'];

    Vlabimg = alldat(:,:,:,labidx(p));
    
    % Here we assumed that the image values are modest, so no overflow will occur.
    switch SubtractionType
        
       case 1   % The linear interpolation method "surround average"

           Vconimg = alldat(:,:,:,conidx(p));

           if FirstimageType
               if p<perfno
                    Vconimg = (Vconimg+squeeze(alldat(:,:,:,conidx(p+1))))/2;
               end
           else
                if p>1 
                    Vconimg = (Vconimg+squeeze(alldat(:,:,:,conidx(p-1))))/2; 
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
           nimg = alldat(:,:,:,conidx(idx));
           nimg=reshape(nimg,size(nimg,1)*size(nimg,2)*size(nimg,3),size(nimg,4));
           clear tmpimg;
           [pn,tn]=size(nimg);
           tmpimg=sinc_interpVec(nimg(brain_ind,:),normloc);
           Vconimg=zeros(size(nimg,1),1);
           Vconimg(brain_ind)=tmpimg;
           Vconimg=reshape(Vconimg,Vall(1).dim(1),Vall(1).dim(2),Vall(1).dim(3));
           clear tmpimg pn tn;
           
       otherwise

           Vconimg = alldat(:,:,:,conidx(p));
           
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % perform subtraction
    perfimg=Vconimg-Vlabimg;
    if SubtractionOrder==0  %label-control
        perfimg=-1.0*perfimg;
    end
    perfimg=perfimg.*glmask;
 
    slicetimearray=ones(Vall(1).dim(1)*Vall(1).dim(2),Vall(1).dim(3));
    for sss=1:Vall(1).dim(3)
        slicetimearray(:,sss)=slicetimearray(:,sss).*(sss-1)*Slicetime;    
    end
    slicetimearray=reshape(slicetimearray,Vall(1).dim(1),Vall(1).dim(2),Vall(1).dim(3));
    slicetimearray=slicetimearray(vxidx);

    BOLDimg=(Vconimg+Vlabimg)/2.;
    meanbold=squeeze(mean(BOLDimg,4));

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
    meanPERFimg=meanPERFimg+perfimg;
    if BOLDFlag==1 meanBOLDimg=meanBOLDimg+Vconimg;  end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CBF quantification
    cbfimg=zeros(size(perfimg));

    omega=Delaytime+slicetimearray;
    clear tcbf;
    M0=Vconimg(brain_ind);
    tperf=perfimg(brain_ind);
    tcbf=zeros(size(M0));
    effidx=find(abs(M0)>1e-3*mean(M0(:)));
    omega=omega(effidx);
    effM0=M0(effidx);
    efftperf=tperf(effidx);

    efftcbf=efftperf./effM0;
    efftcbf=6000*1000*lambda*efftcbf*r1a./(2*labeff* (exp(-omega*r1a)-exp( -1*(Labeltime+omega)*r1a) ) );
    tcbf(effidx)=efftcbf;
    cbfimg(brain_ind)=tcbf;

    meanCBFimg=meanCBFimg+cbfimg;
           
    % Getting a mask for outliers
    % mean+3std has problem in some cases
    nanmask=isnan(cbfimg);
    outliermask=((cbfimg<-40)+(cbfimg>150))>0;
    sigmask=glmask-outliermask-nanmask;
    wholemask=glmask-nanmask;
    whole_ind=find(wholemask>0);
    outliercleaned_maskind=find(sigmask>0);

    gs(p,2)=mean(cbfimg(outliercleaned_maskind));
    gs(p,4)=mean(cbfimg(whole_ind));

    VCBF=Vall(1);
    VCBF.fname=[cbfprefix '_' midname '_' num2str(fseq,'%0.3d') imgaffix];
    if modernSPM
        VCBF.dt=[16,0];
    else
        VCBF.dim(4)=16; %'float' type
    end
    VCBF=spm_write_vol(VCBF,cbfimg);


    gs(p,1)=mean(perfimg(outliercleaned_maskind));
    gs(p,3)=mean(perfimg(whole_ind));

    if OutPerfFlag
        Vdiff=Vall(1);
        
        Vdiff.fname=[prefix '_' midname '_' num2str(fseq,'%0.3d') imgaffix];
        if modernSPM
            Vdiff.dt=[16 0];
        else
            Vdiff.dim(4)=16;
        end
        Vdiff=spm_write_vol(Vdiff,perfimg);
    end
    
end  %end the main loop
fprintf('%s%20s',repmat(sprintf('\b'),1,20),'...done');

% Mean images
meanPERFimg = meanPERFimg./perfno;
meanCBFimg  = meanCBFimg./perfno; 
if BOLDFlag==1, meanBOLDimg=meanBOLDimg./perfno;end;

% output the mean images
Vmean=Vall(1);
if modernSPM
    Vmean.n = [1 1];
end

nm=midname;
Vmean.fname=fullfile(pth, ['meanPERF_' num2str(SubtractionType) '_' nm imgaffix]);
if modernSPM
    Vmean.dt=[16 0]; 
else %
    Vmean.dim(4)=16; %'float' type 
end
  
Vmean=spm_write_vol(Vmean,meanPERFimg);
if BOLDFlag==1,  
    Vmean.fname=fullfile(pth, ['meanBOLD_' num2str(SubtractionType) '_' nm imgaffix]);
    Vmean=spm_write_vol(Vmean,meanBOLDimg);
end

Vmean.fname = fullfile(pth, ['meanCBF_' num2str(SubtractionType) '_' nm imgaffix]);
Vmean       = spm_write_vol(Vmean,meanCBFimg);
cbf_mean    = mean(meanCBFimg(outliercleaned_maskind));
glcbf       = cbf_mean;
fprintf('\nThe mean CBF is %03f (%03f).\n',cbf_mean, mean(meanCBFimg(whole_ind)));




