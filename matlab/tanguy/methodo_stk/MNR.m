function out=MNR(X,Y,NbrClass,flag,Parameters,Kappa);


%%  Last Modification : November, 18 2004. 
%%  (Algo : Nguyen & Rocke, 2002, Bioinformatics)
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
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration in the IRLS part
%%      Parameter(2) : Threshold value for the stopping rule of IRLS
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
%%      NbrIterIRLS : Nbr of iterations till convergence of the iterative part when
%%          applied with LambdaOpt.
%%      DiagCvgIRLS : 1 if IRLS converges and 0 otherwise.
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TEST on the INPUT variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<6,
    disp(sprintf('Message from MNR.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from MNR.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from MNR.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
    out=[];
    return 
end;
aux=repmat(Y,1,NbrClass)==repmat(0:NbrClass-1,length(Y),1);
if min(sum(aux))==0,
   disp(sprintf('Message from MNR.m : \n \t Some class is not present in the learning set'));
   out=[];
   return 
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 1 :
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
  
%   Form the array matrix Yarray 
c=NbrClass-1;
Yarray=zeros(nLearn,c);    % matrix nLearn x c
for cc=1:c,    
    ff=find(Y==cc);
    Yarray(ff,cc)=1;
end;
       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 : 
%%      Determine the PLS-components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Standardize Yarray
MeanY=ones(1,nLearn)*Yarray/nLearn;
CtrYarray=Yarray-ones(nLearn,1)*MeanY;
ssy=sqrt(diag(CtrYarray'*CtrYarray));
InvSigmaY=diag(1./ssy);
StdYarray=CtrYarray*InvSigmaY;
   
%% 2. Initialization
E=Xspeed;
f=StdYarray;
PsiAux=eye(rr);
Scores=zeros(nLearn,max(Kappa));
Loading=zeros(rr,max(Kappa));
Omega=zeros(rr,max(Kappa));
q=zeros(c,max(Kappa));
    
%% 3. PLS Loop
    for kk=1:max(Kappa),
        [U D V]=svd(E'*f*f'*E);
        Omega(:,kk)=U(:,1);
        Scores(:,kk)=E*Omega(:,kk);
        Loading(:,kk)=(Scores(:,kk)'*E)'/(Scores(:,kk)'*Scores(:,kk));
        q(:,kk)=(Scores(:,kk)'*f)'/(Scores(:,kk)'*Scores(:,kk));
        E=E-Scores(:,kk)*Loading(:,kk)';
        f=f-Scores(:,kk)*q(:,kk)';
        Psi(:,kk)=PsiAux*Omega(:,kk);
        PsiAux=PsiAux*(eye(rr)-Omega(:,kk)*Loading(:,kk)');
    end;

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      1/ Fit a logistic regression model  w.r.t. [1 Scores]
%%      2/ Express the regression coefficient wrt [1 X]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for xx=1:length(Kappa),
    kk=Kappa(xx);
    
    %% 1. Prepare the design and response variable for the IRLS loop
        % Standardize the design
    MeanXnew=ones(nLearn,1)'*Scores(:,1:kk)/nLearn;
    CtrXnew=Scores(:,1:kk)-ones(nLearn,1)*MeanXnew;
    InvSigmaBis=diag(1./sqrt(diag(CtrXnew'*CtrXnew)));
    StdXnew=CtrXnew*InvSigmaBis;
    % Build the new design in the reduced space
    Xi=[ones(nLearn,1) StdXnew];
    % Prepare the block matrices
    XiBlock=zeros(nLearn*c,c*(kk+1)); % matrix (nc) x (Rank(CtrX)+1)c
    Yblock=zeros(nLearn*c,1);    % matrix (nc) x 1
    for cc=1:c,
        row=(0:1:nLearn-1)*c+cc;
        col=(kk+1)*(cc-1)+(1:1:kk+1);
        XiBlock(row,col)=Xi;
        ff=find(Y==cc);
        Yblock((ff-1)*c+cc)=1;
    end;
     %% 2. IRLS LOOP
        % Initialisation
    Pi=(3*Yblock+ones(nLearn*c,1)-Yblock)/(3+c);   % matrix nc x 1
    for ll=1:nLearn,
        ss(ll)=1-sum(Pi(c*(ll-1)+(1:c),1));
        BlocPi=Pi(c*(ll-1)+(1:c),1);
        BlocW=-BlocPi*BlocPi';
        BlocW=BlocW+diag(BlocPi);
        Weight(c*(ll-1)+(1:c),c*(ll-1)+(1:c))=BlocW; % matrix nc x nc
        Eta(c*(ll-1)+(1:c),1)=log(BlocPi)-log(ss(ll));
    end;
    AuxGammaOld=pinv(XiBlock)*Eta;
    Gradient=XiBlock'*(Yblock-Pi);
      
    StopRule=0;
    NbrIter=1;   
    IllCond=0;
    Separation=0;
    while StopRule==0,
        AuxGammaNew=AuxGammaOld+inv(XiBlock'*Weight*XiBlock)*Gradient;
        Eta=XiBlock*AuxGammaNew;
        for ll=1:nLearn,
            Pi(c*(ll-1)+(1:c),1)=exp(Eta(c*(ll-1)+(1:c),1))./(1+sum(exp(Eta(c*(ll-1)+(1:c),1))));
            BlocPi=Pi(c*(ll-1)+(1:c),1);
            BlocW=-BlocPi*BlocPi';
            BlocW=BlocW+diag(BlocPi);
            Weight(c*(ll-1)+(1:c),c*(ll-1)+(1:c))=BlocW; 
         end;
         % Compute the stopping criterion : 
            % on the ill-conditioned matrix
         if (rcond(XiBlock'*Weight*XiBlock)<=10^(-16))
            IllCond=-1;
         end;
            % on the separation
         [xxx test]=max([zeros(nLearn,1) reshape(Eta,c,nLearn)']');
         if sum((test-1)==Y')==nLearn,
             Separation=1;
         end;
            % on the gradient
         Gradient=XiBlock'*(Yblock-Pi);
         StopRule=norm(Gradient)<=Parameters(2);
         StopRule=max([StopRule,NbrIter>=Parameters(1),IllCond<0,Separation==1]);
         % Prepare the following iteration
         AuxGammaOld=AuxGammaNew;
         NbrIter=NbrIter+1;
     end;
     %% 2. Express the regression coefficient 
        %%   w.r.t. [1 StdXnew]
    GammaNew=reshape(AuxGammaNew,kk+1,c);
        %%   w.r.t. [1 CtrXnew]
    GammaNew(2:kk+1,:)=InvSigmaBis*GammaNew(2:kk+1,:);
        %%   w.r.t. [1 Scores]
    GammaNew(1,:)=GammaNew(1,:)-MeanXnew*GammaNew(2:kk+1,:);
        %%   w.r.t. [1 X]
    for cc=1:c,
        Gamma(2:p+1,cc)=InvSigma*Vtr*Psi(:,1:kk)*GammaNew(2:kk+1,cc);
        Gamma(1,cc)=GammaNew(1,cc)-MeanX*Gamma(2:p+1,cc);
    end;
    
    out.Gamma(xx,:,:)={Gamma};
    NbrIterStock(xx)=NbrIter-1;
    DiagCvgStock(xx)=((NbrIter-1<Parameters(1)) & (IllCond==0) & (Separation==0));
    SeparationStock(xx)=Separation;
end;







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  CONCLUSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.NbrIter=NbrIterStock;
out.DiagCvg=DiagCvgStock;
out.Separation=SeparationStock;
