function DesignNonParametricTest(mapfiles,outdir,nperm,varSmo,globNorm,GMval,threshmask)

% Usage :
% DesignNonParametricTest(mapfiles,outdir,varSmo,globNorm,GMval,threshmask)
%
% Description : Set up for general linear model and permutation/random
%               analysis. 
% Inputs :
%    mapfiles      : List of scans
%    outdir        : output folder
%    nperm         : number of permutations
%
% Options :
%    varSmo        : FWHM for variance smoothing (Default: 10)
%    globNorm      : global normalization (1: none - 2:proportional scaling
%                    3: AnCova - 4: AnCova {subject-specific}
%                    5: AnCova {study-specific}  (Default: 2)
%    GMval         : value scaling (Default: 50)
%    threshmask    : threshold value defining voxels to analyse (Default:
%    1)
%
% Renaud Lopes @ CHRU Lille, Dec 2012

if nargin < 3
    error('invalid usage');
end

default_varSmo     = 10;
default_globNorm   = 2;
default_GMval      = 50;
default_threshmask = 1;

% check args
if nargin < 4
    varSmo = default_varSmo;
end
if nargin < 5
    globNorm = default_globNorm;
end
if nargin < 6
    GMval = default_GMval;
end
if nargin < 7
    threshmask = default_threshmask;
end

%-Initialise workspace
%-----------------------------------------------------------------------
global defaults
if isempty(defaults), spm('defaults', 'FMRI'); end
global SnPMdefs
if isempty(SnPMdefs), snpm_defaults; end

nScan = length(mapfiles);

%-Variable initialisation prior to running PlugIn
%-----------------------------------------------------------------------
iStud = [];	    % Study indicator vector
iSubj = [];	    % Subject indicator vector
iCond = [];	    % Condition indicator vector
iRepl = [];	    % Replication indicator vector
iXblk = [];  	% Exchangability block indicator vector
H=[]; Hnames = ''; % Condition partition & effect names
C=[]; Cnames = ''; % Covariates (of interest)
Cc = [];		% Covariates (of interest)	| Required only for covariate
Ccnames = [];	% Names of covariates		| by factor interactions
B=[]; Bnames=[];% Block partition & effect names
G=[];Gnames='';	% Covariates (no interest)
Gc      = [];   % Covariates (no interest)	| Required only for covariate
Gcnames = [];	% Names of covariates		| by factor interactions
bST     = 0;		% Flag for collection of superthreshold info
bVarSm  = 0;	% Flag for variance smoothing
sVarSm  = '';	% String describing Variance Smoothing
bVolm   = 0;	% Flag for volumetric computation
nMax4DefVol = SnPMdefs.nMax4DefVol;
                % Default to volumetric if less than nMax4DefVol scans
sPiCond  = '';	% String describing permutations in PiCond
bhPerms  = 0;	% Flag for half permutations. Rest are then their inverses
sDesSave = '';	% String of PlugIn variables to save to cfg file
iGXcalc  = '23';   % Global calculation
iGMsca   = '21';  % Grand mean scaling of globals
df1      = 1;   % For F stat, it will be the numerator df; For T stat, it
                % will be 1.
                
sDesFile = 'OneSampleTNonParam';
                
[iCond,iGloNorm,PiCond,sPiCond,sHCform,CONT,sDesign,sDesSave,H,Hnames,B,Bnames] = OneSampleTNonParam(nScan,nperm);

cur_path = pwd;
cd(outdir);

%-Variance smoothing & volumetric computation
%-----------------------------------------------------------------------
vFWHM = varSmo;
vFWHM = vFWHM * ones(1,3);

%-Decide upon volumetric operation
if (nScan <= nMax4DefVol)
	bVolm = 1;
elseif (vFWHM(3)~=0)
	fprintf(['%cWARNING: Working volumetrically because of smoothing '... 
		 'in z (%g),\nbut more than %d scans analyzed.\nMay run out'...
		 'of memory.\n'],7,vFWHM(3),nScan);
	bVolm = 1;
else
	%bVolm = spm_input(sprintf('%d scans: Work volumetrically?',nScan),'+1','y/n',[1,0],1);
    bVolm = 1;
end
if ~all(vFWHM==0), bVarSm=1; end
if bVarSm
    sVarSm = sprintf('Pseudo-t: Variance smoothed with FWHM [%dx%dx%d]  mm',vFWHM);
end

%-Ask about collecting Supra-Threshold cluster statistics
%-----------------------------------------------------------------------
%bST = spm_input('Collect Supra-Threshold stats?','+1','y/n',[1,0],2);
bST = 0;

% Add: get primary threshold for STC analysis if requested
if bST
    pU_ST_Ut=-1;
else
    pU_ST_Ut=NaN; 
end 

%-Global normalization options
%-----------------------------------------------------------------------
%-Global normalization                                    (GloNorm)
sGloNorm=str2mat(... 
	'<no global normalisation>',...				%-1
	'proportional scaling',...				    %-2
	'AnCova',...						        %-3
	'AnCova {subject-specific}',...				%-4
	'AnCova {study-specific}');				    %-5

tmp = []; for i = 1:length(iGloNorm), tmp = [tmp, eval(iGloNorm(i))]; end
if length(iGloNorm) > 1
    %-User has a choice from the options in iGloNorm.
    iGloNorm = globNorm;
else
    iGloNorm = tmp;
end
sGloNorm = deblank(sGloNorm(iGloNorm,:));


%-Get value to be assigned to grand mean:
%-----------------------------------------------------------------------
%-Global calculation options                               (GXcalc)
sGXcalc  = str2mat(...
    'omit',...							                    %-1
    'user specified',...					                %-2
    'mean voxel value (within per image fullmean/8 mask)');	%-3

%-Grand mean scaling options                                (GMsca)
sGMsca = str2mat(...
    'scaling of overall grand mean',...		    %-1
    '<no grand Mean scaling>'	);				%-2

if iGloNorm==2
	iGMsca = 1;	%-grand mean scaling implicit in PropSca GloNorm
else
    tmp = []; for i = 1:length(iGMsca), tmp = [tmp, eval(iGMsca(i))]; end
    iGMsca = 1;
end

if (iGMsca==1)
    if (iGloNorm==2)
        str = 'PropSca global mean to';
    else
        str = [strrep(sGMsca(iGMsca,:),'scaling of','scale'),' to'];
    end
    GM = GMval;
elseif (iGMsca==2)
    GM = 0;
end


%-Get globals
%-----------------------------------------------------------------------
if (iGloNorm==1) & (iGMsca==2)
  % No need for globals, omit
   iGXcalc = 1;
else
  tmp = []; for i = 1:length(iGXcalc), tmp = [tmp, eval(iGXcalc(i))]; end
  if length(iGXcalc)>1
    iGXcalc = 3;
  else
    iGXcalc = tmp;
  end
end
sGXcalc = deblank(sGXcalc(iGXcalc,:));

if iGXcalc==2				%-Get user specified globals
    
  GX = 50*ones(nScan,1);
  rg = GX;
  
end


%-Get threshold defining voxels to analyse
%-----------------------------------------------------------------------
str = 'none|proportional|absolute'; 
%-glob:absolute is absolute fraction of global.
iTHRESH = threshmask;
if (iTHRESH==1)
    THRESH  = -Inf;
    sThresh = 'None';
elseif (iTHRESH==2)
    THRESH  = 0.8;
    sThresh = sprintf('Proportional (%g)',THRESH);
elseif (iTHRESH==3)
    THRESH  = 0.8;
    sThresh = sprintf('Absolute (%g)',THRESH);
end

%-Get analysis mask
%-----------------------------------------------------------------------
iMASK = false;
if (iMASK)
    MASK = spm_select(1,'image','Select analysis mask');
else
    MASK = '';
end


%=======================================================================
%- Computation
%=======================================================================

%- Condition Cc & Gc "Shadow" partitions if no FxC interactions
%  These store the covariate values for printing only
%-----------------------------------------------------------------------
if (isempty(Cc) & ~isempty(C)), Cc=C; Ccnames=Cnames; end
if (isempty(Gc) & ~isempty(G)), Gc=G; Gcnames=Gnames; end

%- Examine images
%=======================================================================

%- MMap image files
P = cellstr(mapfiles);
P = char(P);
V = spm_vol(P);

%-Check compatability of images (Bombs for single image)
%-----------------------------------------------------------------------
if any(any(diff(cat(1,V(:).dim),1,1),1)&[1,1,1]) 
	error('images do not all have the same dimensions')
end
if any(any(any(diff(cat(3,V(:).mat),1,3),3)))
	error('images do not all have same orientation & voxel size')
end

%- Get ORIGIN, etc
DIM    = [V(1).dim(1)   V(1).dim(2)   V(1).dim(3)]';
M      = V(1).mat(1:3, 1:3);
VOX    = sqrt(diag(M'*M))';
MAT    = V(1).mat;
IMAT   = inv(MAT);
ORIGIN = IMAT(1:3,4);

%- Global calculation
%-----------------------------------------------------------------------
if iGXcalc==2
  %-User specified globals
elseif iGXcalc==3
  %-Compute global values
  rg     = zeros(nScan,1);
  for i  = 1:nScan, rg(i) = spm_global(V(i)); end
  GX     = rg;
elseif iGXcalc==1
  rg     = [];
  GX     = [];
end

%-Scale scaling coefficients so that Grand mean, mean(GX), is = GM (if GM~=0)
% Since images are unmapped, this must be replicated in snpm_cp
% Done here to provide check on V's in snpm_cp
if GM ~= 0
	GMscale = GM/mean(GX);
	for i = 1:nScan, 
		V(i).pinfo(1:2,:)  = V(i).pinfo(1:2,:) * GMscale;
	end
	GX      = GX * GMscale;
else
	GMscale = 1;
end

%-Compute Grey matter threshold for each image
if isempty(GX)
    TH    = repmat(THRESH,nScan,1);
elseif (iTHRESH==3)
    % Absolute threshold
    TH    = THRESH * ones(size(GX));
else
    TH    = THRESH * GX;
end


%-Construct Global part of covariates of no interest partition.
%-Centre global means if included in AnCova models, by mean correction.
%=======================================================================
Gc    = [Gc,GX];
if isempty(Gcnames), Gcnames = 'Global';
else Gcnames = str2mat(Gcnames,'Global'); end

if iGloNorm == 1				%-No global adjustment
%-----------------------------------------------------------------------
elseif iGloNorm == 2				%-Proportional scaling
%-----------------------------------------------------------------------
% Since images are unmapped, this must be replicated in snpm_cp
% Done here to provide check on V's in snpm_cp
   for i = 1:nScan,
      V(i).pinfo(1:2,:) = GM*V(i).pinfo(1:2,:)/GX(i);
   end

elseif iGloNorm == 3				%-AnCova
%-----------------------------------------------------------------------
   G = [G,(GX - mean(GX))];
   if isempty(Gnames), Gnames = 'Global'; 
       else Gnames = str2mat(Gnames,'Global'); end

elseif iGloNorm == 4				%-AnCova by subject
%-----------------------------------------------------------------------
    [GL,GLnames] = spm_DesMtx([iSUBJ',GX-mean(GX)],'FxC',['SUBJ  ';'Global']);
    G = [G,GL];
    if isempty(Gnames), Gnames = GLnames;
        else Gnames = str2mat(Gnames,GLnames); end

elseif iGloNorm == 5				%-AnCova by study
%-----------------------------------------------------------------------
    [GL,GLnames] = spm_DesMtx([iStud',GX-mean(GX)],'FxC',['Stud  ';'Global']);
    G = [G,GL];
    if isempty(Gnames), Gnames = GLnames; 
        else Gnames = str2mat(Gnames,GLnames); end
else
%-----------------------------------------------------------------------
    error(sprintf('%cError: invalid iGloNorm option\n',7))
end % (if)


%=======================================================================


%-Ensure validity of contrast of condition effects, zero pad
%-----------------------------------------------------------------------
%-Only a single contrast
if size(CONT,1)==1
    if size(H,2)>1
        CONT(1:size(H,2)) = CONT(1:size(H,2)) - mean(CONT(1:size(H,2)));
    end
end
%-Zero pad for B & G partitions.
% (Note that we trust PlugIns to create valid contrasts for [H C])
CONT  = [CONT, zeros(size(CONT,1),size([B G],2))];

%-Construct full design matrix and name matrices for display
%-----------------------------------------------------------------------
[nHCBG,HCBGnames] = spm_DesMtx('Sca',H,Hnames,C,Cnames,B,Bnames,G,Gnames);

%-Setup is complete - save SnPMcfg Mat file
%-----------------------------------------------------------------------
s_SnPMcfg_save = ['s_SnPMcfg_save H C B G HCBGnames P PiCond ',...
	'sPiCond bhPerms sHCform iGloNorm sGloNorm GM rg GX GMscale CONT ',...
	'THRESH MASK TH bVarSm vFWHM sVarSm bVolm bST sDesFile sDesign ',...
        'V pU_ST_Ut df1 ', ...
	'sDesSave ',sDesSave];
eval(['save SnPMcfg ',s_SnPMcfg_save])

%=======================================================================
%-Display parameters
%=======================================================================

%-Muck about a bit to set flags for various indicators - handy for later
bMStud=~isempty(iStud);
bMSubj=~isempty(iSubj);
bMCond=~isempty(iCond);
bMRepl=~isempty(iRepl);
bMXblk=~isempty(iXblk);

%-Compute common path components - all paths will begin with file separator
%-----------------------------------------------------------------------
d     = max(find(P(1,1:min(find(~all(P == ones(nScan,1)*P(1,:))))-1)==filesep)) - 1;
CPath = P(1,1:d);
Q     = P(:,d+1:size(P,2));

%-Display data parameters
%=======================================================================
spm_jobman('initcfg');
Fgraph = spm_figure('FindWin','Graphics');
if isempty(Fgraph), Fgraph=spm_figure('Create','Graphics'); end
spm_clf(Fgraph)
figure(Fgraph); spm_clf; axis off
text(0.30,1.02,'Statistical analysis','Fontsize',16,'Fontweight','Bold');
text(-0.10,0.85,'Scan Index','Rotation',90)
if bMStud, text(-0.05,0.85,'Study',      'Rotation',90); end
if bMSubj, text(+0.00,0.85,'Subject',    'Rotation',90); end
if bMCond, text(+0.05,0.85,'Condition',  'Rotation',90); end
if bMRepl, text(+0.10,0.85,'Replication','Rotation',90); end
if bMXblk, text(+0.15,0.85,'Exchange Blk','Rotation',90); end
x0    = 0.20; y0 = 0.83;
dx    = 0.15; dy = 0.02;
x     = x0;
for i = 1:size(Cc,2)
    text(x + 0.02,0.85,Ccnames(i,:),'Rotation',90);
    x = x + dx; end
for i = 1:size(Gc,2)
    text(x + 0.02,0.85,Gcnames(i,:),'Rotation',90);
x = x + dx; end
text(x,0.92,'Base directory:','FontSize',10,'Fontweight','Bold');
text(x,0.90,CPath,'FontSize',10,'interpreter','none');
text(x,0.87,'Filename Tails');
y     = y0;

for i = 1:nScan
	text(-0.12,y,sprintf('%02d :',i));
   if bMStud, text(-0.06,y,sprintf('%2d',iStud(i))); end
   if bMSubj, text(-0.01,y,sprintf('%2d',iSubj(i))); end
   if bMCond, text(+0.04,y,sprintf('%2d',iCond(i))); end
   if bMRepl, text(+0.09,y,sprintf('%2d',iRepl(i))); end
   if bMXblk, text(+0.14,y,sprintf('%2d',iXblk(i))); end
   x     = x0;
   for j = 1:size(Cc,2)
	text(x,y,sprintf('%-8.6g',Cc(i,j)),'FontSize',10)
	x = x + dx; end
   for j = 1:size(Gc,2)
	text(x,y,sprintf('%-8.6g',Gc(i,j)),'FontSize',10)
	x = x + dx; end
   text(x,y,Q(i,:),'FontSize',10,'interpreter','none');
   y     = y - dy;
   if y < 0;
	spm_print
	spm_clf; axis off
	y = y0;
	text(0.16,1.02,['Statistical analysis (continued)'],...
	    'Fontsize',16,'Fontweight','Bold');
   end
end

%-Print miscellaneous data parameters
%-----------------------------------------------------------------------
y      = y - dy;
dy     = dy*1.2;
if (GM~=0)
    text(0,y,sprintf(['Images scaled to a grand mean of %g'],GM))
    y = y - dy;
end
text(0,y,sprintf(...
    'Analysis threshold is %3.0f%% of the whole brain mean',THRESH*100))

save(fullfile(outdir,'SnPMcfg.mat'),'B','C','CONT','G','GM','GMscale','GX','H','HCBGnames','MASK','P','PiCond','TH','THRESH','V', ...
    'bST','bVarSm','bVolm','bhPerms','df1','iCond','iGloNorm','pU_ST_Ut','rg','sDesFile','sDesSave','sDesign','sGloNorm','sHCform', ...
    'sPiCond','sVarSm','s_SnPMcfg_save','vFWHM');

spm_print


%-Display design parameters
%=======================================================================
figure(Fgraph); spm_clf(Fgraph); axis off
text(0.30,1.02,'Design Matrix','Fontsize',16,'Fontweight','Bold');

%-Label the effects
%-----------------------------------------------------------------------
hDesMtx = axes('Position',[0.2 0.3 0.6 0.5]);
image((nHCBG + 1)*32);
ylabel('Observations')
set(hDesMtx,'XTick',[],'XTickLabel','')
hEfLabs = axes('Position',[0.2 0.82 0.6 0.1],'Visible','off');
y     = 0.1;
dx    = 1/size(nHCBG,2);
for i = 1:size(nHCBG,2)
    text((i - 0.5)*dx,y,deblank(HCBGnames(i,:)),...
    'Fontsize',8,'Rotation',90)
end


%-Display non-parametric analysis summary
%-----------------------------------------------------------------------
hPramAxes=axes('Position',[0.05 0.08 0.8 0.20],'Visible','off');
text(0,1.00,sDesign,'Fontsize',10);
text(0,0.90,['SnPM design flie: ',sDesFile],'Fontsize',10);
text(0,0.80,sPiCond,'Fontsize',10);
text(0,0.70,['Global normalisation: ',deblank(sGloNorm)],'Fontsize',10);
text(0,0.60,['Threshold masking: ',deblank(sThresh)],'Fontsize',10);

%-Display parameter summary
%-----------------------------------------------------------------------
text(0,.5,'Parameters:','Fontsize',10,'Fontweight','Bold');
text(0,.4,sprintf(['%d Condition + %d Covariate ',...
	'+ %d Block + %d Confound'],...
	size(H,2),size(C,2),size(B,2),size(G,2)),...
	'Fontsize',10);
text(0,.3,sprintf(['= %d parameters, having %d degrees of freedom, ',...
	'giving %d residual df (%d scans).'],...
	size([H C B G],2),rank([H C B G]),nScan-rank([H C B G]),nScan),...
	'Fontsize',10);
if (bVarSm) text(0,0.2,sVarSm,'Fontsize',10);
end

spm_print

cd(cur_path);