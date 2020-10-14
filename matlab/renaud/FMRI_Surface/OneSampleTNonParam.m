function [iCond,iGloNorm,PiCond,sPiCond,sHCform,CONT,sDesign,sDesSave,H,Hnames,B,Bnames] = OneSampleTNonParam(nScan,nperm)

% design module - 1 group, 1 scan per subject
% MultiSub: One Sample T test on diffs/contrasts; 1 condition, 1 scan per
% subject
%_______________________________________________________________________
%
% This plug in effects a one-sample t-test.
%
% A common use of this plug is for random effects analysis of contrast
% images.  For this analysis we only need to assume, under the null
% hypothesis,  that each of the images are exchangeble and the contrast
% images have mean zero, symmetrically distributed data at each
% voxel. (Exchangeability follows from independence of different
% subjects.)  
%
%
%-Number of permutations
%=======================================================================
%
% There are 2^nSubj possible permutations, where nScan is the total
% number of scans.  
% 
% It is recommended that at least 6 or 7 subjects are used; with only 5
% subjects, the permutation distribution will only have 2^5 = 32 elements
% and the smallest p-value will be 1/32=0.03125.
%
%
%-Prompts
%=======================================================================
%
% 'Select all scans':  Enter the scans to be analyzed.
%
% '# of confounding covariates' & '[<len>] - Covariate <num>': Use these
% prompts to specify a covariate of no interest.  As mentioned above,
% fitting a confounding covariate of age may be desirable.
%
% '<nPerms> Perms.  Use approx. test':  This prompt will inform you of the
% number of possible permutations, that is, the number of ways the group
% labels can be arranged under the assumption that there is no group
% effect.  Fewer than 200 permutations is undesirable; more than 10,000
% is unnecessary.  If the number of permutations is much greater than 10,000
% you should use an approximate test.  Answering 'y' will produce another
% prompt... 
% '# perms. to use? (Max <MaxnPerms>)': 10,000 permutations is regarded as
% a sufficient number to characterize the permutation distribution well.
%
%
%-Variable "decoder" - This PlugIn supplies the following:
%=======================================================================
% - core -
% P             - string matrix of Filenames corresponding to observations
% iGloNorm      - Global normalisation code, or allowable codes
%               - Names of columns of design matrix subpartitions
% PiCond        - Permuted conditions matrix, one labelling per row, actual
%                 labelling on first row
% sPiCond       - String describing permutations in PiCond
% sHCform       - String for computation of HC design matrix partitions
%                 permutations indexed by perm in snpm_cp
% CONT          - single contrast for examination, a row vector
% sDesign       - String defining the design
% sDesSave      - String of PlugIn variables to save to cfg file
%
% - design -
% H,Hnames      - Condition partition of design matrix, & effect names
% B,Bnames      - Block partition (constant term), & effect names
%
% - extra -
% iCond         - Condition indicator vector
%
%_______________________________________________________________________

% 
% Note:  For a multisubject, no-replication design,
% exchagiblity is guaranteed for all observations by random selection of
% subjects from the populations of interest.  Hence, Xblk is all scans.
%

%-Initialisation
%-----------------------------------------------------------------------
iGloNorm = '123';		% Allowable Global norm. codes
sDesSave = 'iCond';		% PlugIn variables to save in cfg file
rand('seed',sum(100*clock));	% Initialise random number generator

%-Get filenames and iCond, the condition labels
%=======================================================================

iCond = ones(1,nScan);
nFlip = 0;

%-Get confounding covariates
%-----------------------------------------------------------------------
G = []; Gnames = ''; Gc = []; Gcnames = ''; q = nScan;
g = 0;
while size(Gc,2) < g
  nGcs = size(Gc,2);
  d = spm_input(sprintf('[%d] - Covariate %d',[q,nGcs + 1]),'0');
  if (size(d,1) == 1), d = d'; end
  if size(d,1) == q
    %-Save raw covariates for printing later on
    Gc = [Gc,d];
    %-Always Centre the covariate
    bCntr = 1;	    
    if bCntr, d  = d - ones(q,1)*mean(d); str=''; else, str='r'; end
    G = [G, d];
    dnames = [str,'ConfCov#',int2str(nGcs+1)];
    for i = nGcs+1:nGcs+size(d,1)
      dnames = str2mat(dnames,['ConfCov#',int2str(i)]); end
    Gcnames = str2mat(Gcnames,dnames);
  end
end
%-Strip off blank line from str2mat concatenations
if size(Gc,2), Gcnames(1,:)=[]; end
%-Since no FxC interactions these are the same
Gnames = Gcnames;


%-Compute permutations of subjects (we'll call them scans)
%=======================================================================
%-Compute permutations for a single exchangability block
%-----------------------------------------------------------------------
nPiCond   = 2^nScan;
bAproxTst = true;
if (bAproxTst)
  tmp = 0;
  while ((tmp>nPiCond) | (tmp==0) )
    tmp = nperm;
    tmp = floor(max([0,tmp]));
  end
  if (tmp==nPiCond), bAproxTst=0; else, nPiCond=tmp; end
end

%-Two methods for computing permutations, random and exact; exact
% is efficient, but a memory hog; Random is slow but requires little
% memory.
%-We use the exact one when the nScan is small enough; for nScan=12,
% PiCond will initially take 384KB RAM, for nScan=14, 1.75MB, so we 
% use 12 as a cut off. (2^nScan*nScan * 8bytes/element).  
%-If user wants all perms, then random method would seem to take an
% absurdly long time, so exact is used.

if nScan<=12 | ~bAproxTst                    % exact method

    %-Generate all labellings of nScan scans as +/- 1
    PiCond=[];
    for i=0:nScan-1
        PiCond=[ones(2^i,1),PiCond;-ones(2^i,1),PiCond];
    end

    %-Only do half the work, if possible
    bhPerms=0;
    if ~bAproxTst
        PiCond=PiCond(PiCond(:,1)==1,:);
        bhPerms=1;
    elseif bAproxTst                 % pick random supsample of perms
        tmp=randperm(size(PiCond,1));
        PiCond=PiCond(tmp(1:nPiCond),:);
        % Note we may have missed iCond!  We catch this below.	
    end	

else                                          % random method
    
    d       = nPiCond-1;
    tmp     = pow2(0:nScan-1)*iCond';  % Include correctly labeled iCond

    while (d>0)
      tmp = union(tmp,floor(rand(1,d)*2^nScan));
      tmp(tmp==2^nScan) = [];  % This will almost never happen
      d   = nPiCond-length(tmp);
    end
    
    % randomize tmp before it is used to get PiCond
    rand_tmp=randperm(length(tmp));
    tmp=tmp(rand_tmp);
    
    PiCond = 2*rem(floor(tmp(:)*pow2(-(nScan-1):0)),2)-1;

    bhPerms=0;    

end

%-Find (maybe) iCond in PiCond, move iCond to 1st; negate if neccesary
%-----------------------------------------------------------------------
perm = find(all((meshgrid(iCond,1:size(PiCond,1))==PiCond)'));
PiCond(1,:) = iCond;
    perm = 1;
% if (bhPerms)
%     perm=[perm,-find(all((meshgrid(iCond,1:size(PiCond,1))==-PiCond)'))];
% end
% if length(perm)==1
%     if (perm<0), PiCond=-PiCond; perm=-perm; end
%     %-Actual labelling must be at top of PiCond
%     if (perm~=1)
% 	PiCond(perm,:)=[];
% 	PiCond=[iCond;PiCond];
%     end
%     if ~bAproxTst    
% 	%-Randomise order of PiConds, unless already randomized
% 	% Allows interim analysis	
% 	PiCond=[PiCond(1,:);PiCond(randperm(size(PiCond,1)-1)+1,:)];
%     end	
% elseif length(perm)==0 & (nScan<=12) & bAproxTst
%     % Special case where we missed iCond; order of perms is random 
%     % so can we can just replace first perm.
%     PiCond(1,:) = iCond;
%     perm = 1;
% else    
%     error(['Bad PiCond (' num2str(perm) ')'])
% end    


%-Form non-null design matrix partitions (Globals handled later)
%=======================================================================
%-Form for HC computation at permutation perm
sHCform    = 'spm_DesMtx(PiCond(perm,:),''C'',''Mean'')';
%-Condition partition
[H,Hnames] = spm_DesMtx(iCond,'C','Mean');
%-Contrast of condition effects
% (spm_DesMtx puts condition effects in index order)
CONT       = [1];
%-No block/constant
B=[]; Bnames='';


%-Design description
%-----------------------------------------------------------------------
sDesign = sprintf('MultiSub: One Sample T test on diffs/contrasts; 1 condition, 1 scan per subject: %d(subj)',nScan);
sPiCond = sprintf('%d permutations of conditions, bhPerms=%d',size(PiCond,1)*(bhPerms+1),bhPerms);