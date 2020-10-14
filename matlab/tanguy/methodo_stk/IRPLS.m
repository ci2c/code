function out=IRPLS(X,Y,flag,Parameters,Kappa);


%%  Last Modification : November, 16 2004. 
%%  (Algo : Marx, Technometrics, 1996).
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%
%%  X   : matrix n x p
%%      data matrix
%%  Y   : matrix n x 1
%%      response variable {0,1}-valued vector
%%  flag    : real
%%      1 if X has to be standardized; 0 otherwise.
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration in the iterative part
%%      Parameter(2) : Threshold value for the stopping rule of the
%%      iterative part
%%      Suggestion : Parameters=[50 10^(-4)];
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
%%      NbrIter : Nbr of iterations till convergence of the iterative part when
%%              applied with Kappa.
%%              matrix length(Kappa) x 1
%%      DiagCvg : 1 if the iterative part converges and 0 otherwise.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TEST : on the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5,
    disp(sprintf('Message from IRPLS.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from IRPLS.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from IRPLS.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
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






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 :
%%      1/ Run the iterative algorithm : Iterative Reweighted PLS
%%          to determine the new covariates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk=Kappa,
    
    % Initialize the iterative part
    NbrIter=1;
    StopRule=0;
    GammaOld=10*ones(rr+1,1);
    AuxDiagCvg=0;
    
    while StopRule==0,
        % Determine the Pseudo Variable
        % PseudoVar=Psi1+(WeightStar)^{-1} Psi2
        if NbrIter==1,
            Pi=0.25*(1-Y)+0.75*Y;
            Eta=log(Pi./(1-Pi));
            Psi1=Eta;
            Psi2=Y-Pi;
            Weight=diag(Pi.*(1-Pi));   % matrix nLearn x nLearn
        else
            Psi1=Eta;   % matrix nLearn x 1
            Psi2=Y-Pi;  % matrix nLearn x 1
        end;
        
        %% 1. Determine the Gamma-PLS estimate
            %   Weighted centering of PseudoVar=Psi1+WeightStar^{-1}*Psi2
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
            if max(Kappa)>KappaUpper
                disp(sprintf('Message from IRPLS.m : \n \t Kappa is larger than the maximal number of PLS components. It is set to the maximal value.'));
            end;
            %   Initialize some variables
            PsiAux=eye(rr); % matrix rr x rr
            E=WeightCtrX; % matrix nLearn x rr
            f1=WeightCtrPsi1; % matrix nLearn x 1
            f2=WeightCtrPsi2;
            %   WPLS loop
            for count=1:kk,
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
            % Regression coefficent
                %   Coefficients Gamma w.r.t. [1 Xspeed]
                GammaNew(2:rr+1)=TildePsi*qcoeff';
                GammaNew(1)=WgtMeanPseudo-WgtMeanXspeed*reshape(GammaNew(2:rr+1),rr,1);
                GammaNew=reshape(GammaNew,rr+1,1);
           
            
        %% 2. Update the pseudo-response variable and the weight matrix
        Eta=Z*GammaNew; % matrix nLearn x 1
        Pi=1./(1+exp(-Eta)); % matrix nLearn x 1
        Weight=diag(Pi.*(1-Pi)); % matrix nLearn x nLearn
         
        
        %% 3. Evaluate the stopping criterion
            % if the path diverges
            if rcond(Weight)<10^(-16),
                AuxDiagCvg=-1;
            end;
        StopRule=max(abs((GammaNew-GammaOld)./GammaOld))<=Parameters(2);
        StopRule=max([StopRule,NbrIter>=Parameters(1),AuxDiagCvg<0]);
 
        NbrIter=NbrIter+1;
        GammaOld=GammaNew;
        
    end;
    
    NbrIterStock1(kk)=NbrIter-1;
    DiagCvgStock1(kk)=((NbrIter<Parameters(1)) & (AuxDiagCvg==0));


     
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      Run the iterative algorithm with a design matrix formed with the
%%      PLS components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    NbrIter=0;
    AuxSep=0;
    
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
            if (sum((AuxEta>0)==Y)==nLearn | sum((AuxEta<0)==Y)==nLearn)
                %disp('Separation detected; IRLS can not converge');
                AuxSep=-1;
            end;
            % this is to detect ill-conditioned problem
            Auxm=1./(1+exp(-AuxEta));
            AuxWeight=diag(Auxm.*(1-Auxm));
            if (rcond(Z'*AuxWeight*Z)<=10^(-10))
                %disp(' Ill conditioned matrix; IRLS stopped');
                AuxSep=-2;
            end;
            % this is to detect convergence
            StopRule=max(abs((GammaNew-GammaOld)./GammaOld))<=Parameters(2);
            StopRule=max([StopRule,NbrIter>=Parameters(1),AuxSep<0]);
        % Update the former value of Gamma
        GammaOld=GammaNew; % matrix (kk+1) x 1
        % Increment the number of iterations
        NbrIter=NbrIter+1;
   end;
   NbrIterStock2(kk)=NbrIter-1;
   SeparationStock(kk)=AuxSep<0;

   %% 3. Expression of the regression coefficients
        % w.r.t. [1 Xspeed]
   Gamma(1,kk)=GammaNew(1)-WgtMeanXspeed*TildePsi(:,1:kk)*GammaNew(2:kk+1);
   Gamma(2:rr+1,kk)=TildePsi(:,1:kk)*GammaNew(2:kk+1);
        % w.r.t. [1 X]
   Gamma(2:p+1,kk)=InvSigma*Vtr*Gamma(2:rr+1,kk);
   Gamma(1,kk)=Gamma(1,kk)-MeanX*Gamma(2:p+1,kk);
end;







%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      Conclusion
%%%%%%%%%%%%%%%%%%%%%%%%%
out.Gamma=Gamma(:,Kappa);    % matrix (p+1) x length(Kappa)
out.NbrIterIRPLS=NbrIterStock1(Kappa);  % matrix 1 x length(Kappa)
out.DiagCvgIRPLS=DiagCvgStock1(Kappa); % matrix 1 x length(Kappa)
out.NbrIterIRLS=NbrIterStock2(Kappa);  % matrix 1 x length(Kappa)
out.Separation=SeparationStock(Kappa); % matrix 1 x length(Kappa)

    


    
    
    
    
    
    
    
    
    
    



            







