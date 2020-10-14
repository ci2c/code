function out=MRPLS(X,Y,NbrClass,flag,LambdaRange,Parameters,Kappa);


%%  Last Modification : January, 31 2005. 
%%  (Algo : Fort & Lambert, 2005)
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%
%%  X   : matrix n x p
%%      data matrix
%%  Y   : matrix n x 1
%%      response variable {0, ..., c}-valued vector
%%  NbrClass    : positive integer
%%      Number of class : c=NbrClass-1.
%%  flag    : real
%%      1 if X has to be standardized; 0 otherwise.
%%  LambdaRange : matrix
%%      Range of the possible values for the regularization parameter
%%      Lambda
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration in the IRRLS part
%%      Parameter(2) : Threshold value for the stopping rule of IRRLS
%%      Suggestion : Parameters=[50 10^(-12)];
%%  Kappa   : matrix
%%      Nbr of PLS components; if it is a vector, RPLS returns as many
%%      estimates as the length of Kappa.
%%
%%
%%  OUTPUT variables
%%%%%%%%%%%%%%%%%%%%%
%%  Structure with fields
%%      Gamma : estimate of the regression coefficients 
%%              cell-array, length(Kappa) x (p+1) x c.
%%      Lambda : optimal value of Lambda
%%      NbrIterIRRLS : Nbr of iterations till convergence of MIRRLS when
%%          applied with LambdaOpt.
%%      DiagCvgIRRLS : 1 if MIRRLS converges and 0 otherwise.
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TEST on the INPUT variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<7,
    disp(sprintf('Message from MRPLS.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from MRPLS.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from MRPLS.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
    out=[];
    return 
end;
aux=repmat(Y,1,NbrClass)==repmat(0:NbrClass-1,length(Y),1);
if min(sum(aux))==0,
   disp(sprintf('Message from MRPLS.m : \n \t Some class is not present in the learning set'));
   out=[];
   return 
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 1:
%%      1/ Center X and Standardize or not the data matrix
%%      2/ Move in the reduced space
%%      3/ Form the response variable and the design matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nLearn p]=size(X);

%   Center and standardize
MeanX=ones(nLearn,1)'*X/nLearn; % matrix 1 x p
CtrX=X-ones(nLearn,1)*MeanX;    % matrix nLearn x p
if flag==1,
    Sigma2=diag(CtrX'*CtrX);
    InvSigma=inv(diag(sqrt(Sigma2)));   % matrix p x p
else
    InvSigma=eye(p);    % matrix p x p
end;
StdX=CtrX*InvSigma;     % matrix nLearn x p 

%   Move in the reduced space
[U,D,V]=svd(StdX); 
rr=rank(D);
Utr=U(:,1:rr);      % matrix nLearn x rr
Dtr=D(1:rr,1:rr);   % matrix rr x rr
Vtr=V(:,1:rr);      % matrix p x rr

Xspeed=Utr*Dtr;     % matrix nLearn x rr
  
%   Form the block matrices Yblock and Zblock
c=NbrClass-1;
Xi=[ones(nLearn,1) Xspeed]; % matrix nLearn x (rr+1)
Zblock=zeros(nLearn*c,c*(rr+1)); % matrix (nLearn c) x (rr+1)c
Yblock=zeros(nLearn*c,1);    % matrix (nLearn c) x 1
for cc=1:c,
    row=(0:1:nLearn-1)*c+cc;
    col=(rr+1)*(cc-1)+(1:1:rr+1);
    Zblock(row,col)=Xi;
        
    ff=find(Y==cc);
    Yblock((ff-1)*c+cc)=1;
end;
       

clear Xi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 :
%%      Choose lambda by minimizing the BIC criterion over the range
%%      specified by LambdaRange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NbrLambda=length(LambdaRange);
%% 1. Stock the results to compare the different Lambda
    %%  a matrix that collects a binary variable
    %%  (row #1: 1 if cvgce of IRRLS)
    %%  (row #2: the value of the BIC criterion)
CompResult=zeros(2,NbrLambda);
CompResult(2,:)=ones(1,NbrLambda);
   

%% 2. Loop on the different values of Lambda  
for ll=1:length(LambdaRange)
    Lambda=LambdaRange(ll);
    outMIRRLS=MIRRLS(Yblock,Zblock,NbrClass,Lambda,Parameters);
    if outMIRRLS.DiagCvg==0, % (i.e. if non-convergence of MIRRLS)
       CompResult(1,ll)=0;
       CompResult(2,ll)=0;
    else % (i.e. if convergence )
       Dim=outMIRRLS.TraceHat;
       Eta=Zblock*outMIRRLS.Gamma;  % matrix (c nLearn) x 1
       for kk=1:nLearn,
             Pi(c*(kk-1)+(1:c),1)=exp(Eta(c*(kk-1)+(1:c),1))./(1+sum(exp(Eta(c*(kk-1)+(1:c),1))));
             ssPi(kk)=sum(Pi(c*(kk-1)+(1:c),1));
       end;
       LogLike=Yblock'*Eta+sum(log(1-ssPi));
       CompResult(1,ll)=-2*LogLike+Dim*log(nLearn);
    end; % "end" relative to "if"
end; % "end" relative to "for"
        
%%  3. Compute LambdaOpt
AvailableLambda=find(CompResult(2,:)==1);
if size(AvailableLambda,2)==0, % test if some Lambda are available
    disp(sprintf('Message from Step 2 of MRPLS : \n \t No optimal Lambda for the given LambdaRange'));
    out=[];
    return;
else
    [out1 out2]=sort(CompResult(1,AvailableLambda));
    Optima=find(out1==out1(1));
    LambdaOpt=LambdaRange(AvailableLambda(min(out2(Optima))));
end;
    
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      1/ Determine the pseudo-variable and the weight matrix
%%      2/ Run Weighted-PLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outMIRRLS=MIRRLS(Yblock,Zblock,NbrClass,LambdaOpt,Parameters);

%%  1. Determine the pseudo-variable and Weight
        % PseudoVar=Psi1 + Weight^{-1} Psi2
Psi1=Zblock*outMIRRLS.Gamma; % matrix (nLearn c) x 1
for kk=1:nLearn,
    Pi(c*(kk-1)+(1:c),1)=exp(Psi1(c*(kk-1)+(1:c),1))./(1+sum(exp(Psi1(c*(kk-1)+(1:c),1))));
    BlocPi=Pi(c*(kk-1)+(1:c),1);
    BlocW=-BlocPi*BlocPi';
    BlocW=BlocW+diag(BlocPi);
    Weight(c*(kk-1)+(1:c),c*(kk-1)+(1:c))=BlocW; % matrix (nLearn c) x (nLearn c)
end;
Psi2=Yblock-Pi;


%%  2. Run PLS
KappaMax=max(Kappa);

col=[1:rr+1:c*(rr+1)];    % matrix 1 x c
Xblock=Zblock(:,setdiff(1:c*(rr+1),col));    % matrix (nLearn c) x (c rr)
Xi=Zblock(:,col);   % matrix (nLearn c) x c
    % Project Xblock and PseudoVar on Xi
    p0=inv(Xi'*Weight*Xi)*Xi'*Weight*Xblock;  % matrix c x (c rr)
    E=Xblock-Xi*p0;    % matrix (nLearn c) x (c rr)
    q0=inv(Xi'*Weight*Xi)*Xi'*(Weight*Psi1+Psi2);   % matrix c x 1
    f1=Psi1-Xi*q0; % matrix (nLearn c) x 1
    f2=Psi2;
    % PLS Loop
    Omega=zeros(rr*c,KappaMax); 
    Scores=zeros(nLearn*c,KappaMax);
    Loading=zeros(c*rr,KappaMax);
    q=zeros(1,KappaMax);
    PsiAux=eye(c*rr);
    Psi=zeros(c*rr,KappaMax);

    for kk=1:KappaMax,
        Omega(:,kk)=E'*(Weight*f1+f2); % matrix (c rr) x 1
        Scores(:,kk)=E*Omega(:,kk); % matrix (nLearn c) x 1
        Loading(:,kk)=(Scores(:,kk)'*Weight*E)'/(Scores(:,kk)'*Weight*Scores(:,kk)); % matrix (rr c) x 1
        q(kk)=Scores(:,kk)'*(Weight*f1+f2)/(Scores(:,kk)'*Weight*Scores(:,kk)); % matrix 1 x 1
        f1=f1-Scores(:,kk)*q(kk); % matrix (nLearn c) x 1
        E=E-Scores(:,kk)*Loading(:,kk)';    % matrix (nLearn c) x (nLearn rr)
        Psi(:,kk)=PsiAux*Omega(:,kk);   % matrix (c rr) x 1
        PsiAux=PsiAux*(eye(c*rr)-Omega(:,kk)*Loading(:,kk)');    % matrix (c rr) x (c rr)
    end;
    
%% 3. Conclude : build Gamma 
    Gamma=zeros(KappaMax,(p+1),c);
    for xx=1:length(Kappa),
        kk=Kappa(xx);
        % Coeff Gamma w.r.t. the columns of Xi and Xblock
        AuxGamma(1,:)=(q0-p0*Psi(:,1:kk)*q(1:kk)')'; % matrix 1 x c
        AuxGamma(2:rr+1,:)=reshape(Psi(:,1:kk)*q(1:kk)',rr,c); % matrix rr x c
        % Coeff Gamma w.r.t. the columns of [1 X]
        AuxGamma(2:p+1,:)=InvSigma*Vtr*AuxGamma(2:rr+1,:); % matrix p x c
        AuxGamma(1,:)=AuxGamma(1,:)-MeanX*AuxGamma(2:p+1,:); % matrix 1 x c
        out.Gamma(xx,:,:)={AuxGamma};
    end;


%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 4 :
%%      Conclusion
%%%%%%%%%%%%%%%%%%%%%%%%%
out.NbrIterIRRLS=outMIRRLS.NbrIter;  % real
out.DiagCvgIRRLS=outMIRRLS.DiagCvg;  % real
out.Lambda=LambdaOpt;   % real





