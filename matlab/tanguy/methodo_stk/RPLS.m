function out=RPLS(X,Y,flag,LambdaRange,Parameters,Kappa);


%%  Last Modification : November, 16 2004.
%%  (Algo : Fort & Lambert-Lacroix, Bioinformatics, 2005).
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%  X   : matrix n x p
%%      data matrix
%%  Y   : matrix n x 1
%%      response variable {0,1}-valued vector
%%  flag    : real
%%      1 if X has to be standardized; 0 otherwise.
%%  LambdaRange : matrix
%%      Range of the possible values for the regularization parameter
%%      Lambda
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration in the IRRLS part
%%      Parameter(2) : Threshold value for the stopping rule of IRRLS
%%      Suggestion : Parameters=[50 10^(-12)];
%%  Kappa   : vector
%%      Nbr of PLS components; if it is a vector, RPLS returns as many
%%      estimates as the length of Kappa.
%%
%%
%%  OUTPUT variables
%%%%%%%%%%%%%%%%%%%%%
%% Structure with fields
%%      Gamma : estimate of the regression coefficients 
%%              matrix (p+1) x length(Kappa).
%%      LambdaOpt : optimal value of Lambda
%%      NbrIterIRRLS : Nbr of iterations till convergence of IRRLS when
%%          applied with LambdaOpt.
%%      DiagCvgIRRLS : 1 if IRRLS converges and 0 otherwise.
%%
%%
%%  CALL the functions :
%%%%%%%%%%%%%%%%%%%%%%%%
%%  IRRLS.m





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TEST : on the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<6,
    disp(sprintf('Message from RPLS.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from RPLS.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from RPLS.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
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

%   Form the design matrix Z
Z=[ones(nLearn,1) Xspeed]; % matrix nLearn x (rr+1)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 :
%%      Choose lambda by minimizing the BIC critetion over the range
%%      specified by LambdaRange : return LambdaOpt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NbrLambda=length(LambdaRange);
if NbrLambda==1,
    LambdaOpt=LambdaRange;
else
    %% 1. Stock the results to compare the different Lambda
    %%  a matrix that collects a binary variable
    %%  (row #1: 1 if cvgce of IRRLS)
    %%  (row #2: the value of the BIC criterion)
    CompResult=zeros(2,NbrLambda);
    CompResult(2,:)=ones(1,NbrLambda);
   
    %% 2. Loop on the different values of Lambda  
    for ll=1:length(LambdaRange)
        Lambda=LambdaRange(ll);
        outIRRLS=IRRLS(Y,Z,Lambda,Parameters);
        if outIRRLS.DiagCvg==0, % (i.e. if non-convergence of IRRLS)
            CompResult(1,ll)=0;
            CompResult(2,ll)=0;
        else % (i.e. if convergence )
            Dim=outIRRLS.TraceHat;
            Eta=Z*outIRRLS.Gamma;
            Pi=1./(1+exp(-Eta));
            LogLike=Y'*Eta+sum(log(1-Pi));
            CompResult(1,ll)=-2*LogLike+Dim*log(nLearn);
        end; % "end" relative to "if"
    end; % "end" relative to "for"
        
    %%  3. Compute LambdaOpt
    AvailableLambda=find(CompResult(2,:)==1);
    if size(AvailableLambda,2)==0, % test if some Lambda are available
        ss=sprintf('Message from Step 2 of RPLS : \n \t No optimal Lambda for the given LambdaRange');
        disp(ss)
        LambdaOpt=0;
        return;
    else
    [   out1 out2]=sort(CompResult(1,AvailableLambda));
        Optima=find(out1==out1(1));
        LambdaOpt=LambdaRange(AvailableLambda(min(out2(Optima))));
    end;
end;
    
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      1/ Determine the pseudo-variable and the weight matrix
%%      2/ Run Weighted-PLS
%%      3/ Express the regression coefficients wrt the columns of X
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outIRRLS=IRRLS(Y,Z,LambdaOpt,Parameters);

%%  1. Determine the pseudo-variable and Weight
% PseudoVar=Psi1 + Weight^{-1} Psi2
Psi1=Z*outIRRLS.Gamma;
Pi=1./(1+exp(-Psi1));
Psi2=Y-Pi;
Weight=diag(Pi.*(1-Pi));



%%  2. Run PLS
KappaMax=max(Kappa);
   %   Weighted centering of Y
    WgtMeanPseudo=(ones(nLearn,1)'*Weight*Psi1+ones(nLearn,1)'*Psi2)/(ones(nLearn,1)'*Weight*ones(nLearn,1)); % matrix 1x1
    WeightCtrPsi1=Psi1-WgtMeanPseudo;    % matrix nLearn x 1
    WeightCtrPsi2=Psi2; % matrix nLearn x 1
    %   Weighted centering of Xspeed
    WgtMeanXspeed=ones(nLearn,1)'*Weight*Xspeed/(ones(nLearn,1)'*Weight*ones(nLearn,1));
    WeightCtrX=Xspeed-ones(nLearn,1)*WgtMeanXspeed;
    % Test if KappaMax is not larger than the upper bound
    auxUpper=WeightCtrX'*(Weight*WeightCtrPsi1+WeightCtrPsi2);
    auxEig=eig(WeightCtrX'*WeightCtrX);
    S1=length(find(abs(auxEig.*auxUpper)>0));
    auxEig=auxEig(find(auxEig>0));
    KappaUpper=S1-sum(auxEig(2:length(auxEig))./auxEig(1:length(auxEig)-1)==1);
    if KappaMax>KappaUpper
        disp(sprintf('Message from RPLS.m : \n \t Kappa is larger than the maximal number of PLS components. It is set to the maximal value.'));
    end;
    %   Initialize some variables
    PsiAux=eye(rr); % matrix rr x rr
    E=WeightCtrX; % matrix nLearn x rr
    f1=WeightCtrPsi1; % matrix nLearn x 1
    f2=WeightCtrPsi2;
    %   WPLS loop
    for count=1:KappaMax,
        w=E'*(Weight*f1+f2);  % matrix rr x 1
        Omega(:,count)=w;   
        %   Score vector
        t=E*w;  % matrix nLearn x 1
        c(count)=w'*E'*Weight*E*w;   % matrix 1 x 1
        Scores(:,count)=t;
        TildePsi(:,count)=PsiAux*w;
        %   Deflation of Xspeed
        Loadings(:,count)=(t'*Weight*E)'/c(count);
        E=E-t*Loadings(:,count)';
        %   Deflation of Y
        qcoeff(count)=(f1'*Weight+f2')*t/c(count);
        f1=f1-qcoeff(count)*t;
        f2=f2;
        %   Recursve definition of RMatrix
        PsiAux=PsiAux*(eye(rr)-w*Loadings(:,count)');
    end;
        
    
%%  3. Express the regression coefficients w.r.t. the columns of X
for count=1:KappaMax
    %   Coefficients Gamma w.r.t. [1 Xspeed]
    Gamma(2:rr+1,count)=TildePsi(:,1:count)*qcoeff(1:count)';
    Gamma(1,count)=WgtMeanPseudo-WgtMeanXspeed*Gamma(2:rr+1,count);
    %   Coefficients Gamma w.r.t. [1 CtrX]
    Gamma(2:p+1,count)=InvSigma*Vtr*Gamma(2:rr+1,count);    % Gamma(1) is unchanged
    %   Coefficients Gamma w.r.t. [1 X]
    Gamma(1,count)=Gamma(1,count)-MeanX*Gamma(2:p+1,count);  % Gamma(2:p+1) is unchanged
end;
   
    
    
%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 4 :
%%      Conclusion
%%%%%%%%%%%%%%%%%%%%%%%%%
out.Gamma=Gamma(:,Kappa);    % matrix (p+1) x length(Kappa)
out.NbrIterIRRLS=outIRRLS.NbrIter;  % real
out.DiagCvgIRRLS=outIRRLS.DiagCvg;  % real
out.Lambda=LambdaOpt;   % real

       

            







