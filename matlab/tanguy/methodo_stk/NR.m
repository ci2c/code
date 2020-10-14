function out=NR(X,Y,flag,Parameters,Kappa);



%%  Last Modification : November, 22 2004. 
%%  (Algo : Nguyen & Rocke, Bioinformatics, 2002).
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%  X   : matrix n x p
%%      data matrix
%%  Y   : matrix n x 1
%%      response variable {0,1}-valued vector
%%  flag    : real
%%      1 if X has to be standardized; 0 otherwise.
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration in the IRLS part
%%      Parameter(2) : Threshold value for the stopping rule of IRLS
%%      Suggestion :  Parameters=[50 10^(-10)];
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
%%      NbrIter : Nbr of iterations till convergence of IRLS 
%%      Separation : 1 if (quasi)-separation is detected and 0 otherwise.
%%
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TEST : on the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5,
    disp(sprintf('Message from NR.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from NR.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from NR.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 :
%%      Determine the PLS-components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KappaMax=max(Kappa);    

    %   Center Y
    MeanY=ones(nLearn,1)'*Y./nLearn; % matrix 1 x 1
    CtrY=Y-MeanY;    % matrix nLearn x 1
    % Check if KappaMax is lower than the maximal number of PLS components 
    auxUpper=Xspeed'*CtrY;
    auxEig=eig(Xspeed'*Xspeed);
    S1=length(find(abs(auxEig.*auxUpper)>0));
    auxEig=auxEig(find(auxEig>0));
    KappaUpper=S1-sum(auxEig(2:length(auxEig))./auxEig(1:length(auxEig)-1)==1);
    if KappaMax>KappaUpper
        disp(sprintf('Message from NR.m : \n \t Kappa is larger than the maximal number of PLS components. It is set to the maximal value.'));
    end;
    %   PLS Loop
        %   Initialize some variables
        PsiAux=eye(rr); % matrix rr x rr
        E=Xspeed; % matrix nLearn x rr
        f=CtrY; % matrix nLearn x 1
        for count=1:KappaMax,
            w=E'*f;  % matrix rr x 1
            %   Score vector
            t=E*w;  % matrix nLearn x 1
            c(count)=w'*E'*E*w;   % matrix 1 x 1
            Scores(:,count)=t;
            TildePsi(:,count)=PsiAux*w;
            %   Deflation of Xspeed
            Loadings(:,count)=(t'*E)'/c(count);
            E=E-t*Loadings(:,count)';
            %   Deflation of Y
            qcoeff(count)=f'*t/c(count);
            f=f-qcoeff(count)*t;
            %   Recursve definition of RMatrix
            PsiAux=PsiAux*(eye(rr)-w*Loadings(:,count)');
        end;
        
         

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      1/ Fit a logistic regression model  w.r.t. [1 Scores]
%%      2/ Express the regression coefficient wrt [1 X]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk=Kappa
    Znew=[ones(nLearn,1) Scores(:,1:kk)]; % matrix nLearn x (kk+1)
    %%  1. Initialisation
        %   Initialisation of Gamma 
    c=log(3);
    Eta=c*Y-c*(1-Y); % matrix nLearn x 1
    Pi=1./(1+exp(-Eta)); % matrix nLearn x 1
    DiagW=Pi.*(1-Pi); % matrix nLearn x 1
    PseudoVar=Eta+(Y-Pi)./DiagW; % matrix nLearn x 1
    Weight=diag(DiagW); % matrix nLearn x nLearn
    GammaOld=inv(Znew'*Weight*Znew)*Znew'*Weight*PseudoVar; % matrix (kk+1) x 1
        % Initialisation : auxiliary variables
    StopRule=0;
    NbrIter=1;
    Separation=0;
    IllCond=0;
    
    %%  2. Iterative procedure IRLS
    while StopRule==0,
        Eta=Znew*GammaOld; % matrix nLearn x 1
        Pi=1./(1+exp(-Eta)); % matrix nLearn x 1
        Gradient=Znew'*(Y-Pi);  % matrix (kk+1) x 1
        Weight=diag(Pi.*(1-Pi)); % matrix nLearn x nLearn
        GammaNew=GammaOld+inv(Znew'*Weight*Znew)*Gradient; % matrix (kk+1) x 1
        % Test for stopping the iterative procedure
            % this is to detect (quasi)-separation
            AuxEta=Znew*GammaNew;  % matrix n x 1
            [xxx test]=max([zeros(nLearn,1) AuxEta]');
            if sum((test-1)==Y')==nLearn,
                Separation=1;
            end;
            
            % this is to detect ill-conditioned problem
            Auxm=1./(1+exp(-AuxEta));
            AuxWeight=diag(Auxm.*(1-Auxm));
            if (rcond(Z'*AuxWeight*Z)<=10^(-16))
                %disp(' Ill conditioned matrix; IRLS stopped');
                IllCond=-1;
            end;
            % this is to detect convergence
            StopRule=max(abs((GammaNew-GammaOld)./GammaOld))<=Parameters(2);
            StopRule=max([StopRule,NbrIter>=Parameters(1),Separation==1,IllCond<0]);
        % Update the former value of Gamma
        GammaOld=GammaNew; % matrix (kk+1) x 1
        % Increment the number of iterations
        NbrIter=NbrIter+1;
   end;
   NbrIterStock(kk)=NbrIter-1;
   SeparationStock(kk)=Separation;
   DiagCvgStock(kk)=((NbrIter-1<Parameters(1)) & (IllCond==0) & (Separation==0));

   %% 3. Expression of the regression coefficients
        % w.r.t. [1 Xspeed]
   Gamma(1,kk)=GammaNew(1);
   Gamma(2:rr+1,kk)=TildePsi(:,1:kk)*GammaNew(2:kk+1);
        % w.r.t. [1 X]
   Gamma(2:p+1,kk)=InvSigma*Vtr*Gamma(2:rr+1,kk);
   Gamma(1,kk)=Gamma(1,kk)-MeanX*Gamma(2:p+1,kk);
   
end;



%%%%%%%%%%%%%%%%%%%%
%%  STEP 4 : 
%%      Conclusion
%%%%%%%%%%%%%%%%%%%%
out.Gamma=Gamma(:,Kappa);
out.NbrIter=NbrIterStock(Kappa);
out.Separation=SeparationStock(Kappa);
out.DiagCvg=DiagCvgStock;












