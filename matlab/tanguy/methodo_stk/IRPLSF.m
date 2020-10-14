function out=IRPLSF(X,Y,flag,Parameters,Kappa);


%%  Last Modification : November, 17 2004. 
%%  (Algo : Ding & Gentleman, Technical report Bioconductor, 2004).
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
%%      Suggestion : Parameters=[100 10^(-4)];
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
%%      NbrIter : Nbr of iterations till convergence of IRPLSF when
%%              applied with Kappa.
%%              matrix length(Kappa) x 1
%%      DiagCvg : 1 if IRPLSF converges and 0 otherwise.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TEST : on the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5,
    disp(sprintf('Message from IRPLSF.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from IRPLSF.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from IRPLSF.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 :
%%      1/ Run the iterative algorithm : Firth-penalized Iterative Reweighted PLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk=Kappa,
    % Initialize the iterative part
    NbrIter=1;
    StopRule=0;
    IllCond=0;
    GammaOld=10*ones(1,rr+1);
    while StopRule==0,
        % Determine the Pseudo Variable
        % PseudoVar=Psi1+(WeightStar)^{-1} Psi2
        if NbrIter==1,
            PseudoVar=0.25*(Y==0)+0.75*(Y==1);  % matrix nLearn x 1
            Psi1=PseudoVar;
            Psi2=zeros(nLearn,1);
            Pi=1./(1+exp(-PseudoVar));  % matrix nLearn x 1
            WeightStar=diag(Pi.*(1-Pi));   % matrix nLearn x nLearn
       else
            H=Z*pinv(Z'*Weight*Z)*Z'*Weight; % matrix nLearn x nLearn
            h=diag(H); % matrix nLearn x 1
            WeightStar=Weight*diag(1+h); % matrix nLearn x nLearn
            Ystar=Y+h/2;   % matrix nLearn x 1 
            PiStar=(1+h).*Pi;  % matrix nLearn x 1
            Psi1=Eta;   % matrix nLearn x 1
            Psi2=Ystar-PiStar;  % matrix nLearn x 1
        end;
        %% 1. Determine the Gamma-PLS estimate
            %   Weighted centering of PseudoVar=Psi1+WeightStar^{-1}*Psi2
            WgtMeanPseudo=(ones(nLearn,1)'*WeightStar*Psi1+ones(nLearn,1)'*Psi2)/(ones(nLearn,1)'*WeightStar*ones(nLearn,1)); % matrix 1x1
            WeightCtrPsi1=Psi1-WgtMeanPseudo;    % matrix nLearn x 1
            WeightCtrPsi2=Psi2; % matrix nLearn x 1
            %   Weighted centering of Xspeed
            WgtMeanXspeed=ones(nLearn,1)'*WeightStar*Xspeed/(ones(nLearn,1)'*WeightStar*ones(nLearn,1));
            WeightCtrX=Xspeed-ones(nLearn,1)*WgtMeanXspeed;
            % Test if KappaMax is not larger than the upper bound
            auxUpper=WeightCtrX'*(WeightStar*WeightCtrPsi1+WeightCtrPsi2);
            auxEig=eig(WeightCtrX'*WeightCtrX);
            S1=length(find(abs(auxEig.*auxUpper)>0));
            auxEig=auxEig(find(auxEig>0));
            KappaUpper=S1-sum(auxEig(2:length(auxEig))./auxEig(1:length(auxEig)-1)==1);
            if max(Kappa)>KappaUpper
                disp(sprintf('Message from IRPLSF.m : \n \t Kappa is larger than the maximal number of PLS components. It is set to the maximal value.'));
            end;
            %   Initialize some variables
            PsiAux=eye(rr); % matrix rr x rr
            E=WeightCtrX; % matrix nLearn x rr
            f1=WeightCtrPsi1; % matrix nLearn x 1
            f2=WeightCtrPsi2;
            %   WPLS loop
            for count=1:kk,
                w=E'*(WeightStar*f1+f2);  % matrix rr x 1
                Omega(:,count)=w;   
                %   Score vector
                t=E*w;  % matrix nLearn x 1
                c(count)=w'*E'*WeightStar*E*w;   % matrix 1 x 1
                Scores(:,count)=t;
                TildePsi(:,count)=PsiAux*w;
                %   Deflation of Xspeed
                Loadings(:,count)=(t'*WeightStar*E)'/c(count);
                E=E-t*Loadings(:,count)';
                %   Deflation of Y
                qcoeff(count)=(f1'*WeightStar+f2')*t/c(count);
                f1=f1-qcoeff(count)*t;
                f2=f2;
                %   Recursve definition of RMatrix
                PsiAux=PsiAux*(eye(rr)-w*Loadings(:,count)');
            end;
            % Regression coefficent
                %   Coefficients Gamma w.r.t. [1 Xspeed]
                GammaNew(2:rr+1)=TildePsi*qcoeff';
                GammaNew(1)=WgtMeanPseudo-WgtMeanXspeed*GammaNew(2:rr+1)';
        
               
        
        %% 2. Update the weight matrix
        Eta=Z*GammaNew'; % matrix nLearn x 1
        Pi=1./(1+exp(-Eta)); % matrix nLearn x 1
        Weight=diag(Pi.*(1-Pi)); % matrix nLearn x nLearn
       
        
        %% 3. Evaluate the stopping criterion
            % based on the conditioning of some matrix
            if rcond(Z'*Weight*Z)<=10^(-16),
                IllCond=-1;
            end;
        StopRule=max(abs((GammaNew-GammaOld)./GammaOld))<=Parameters(2);
        StopRule=max([StopRule,NbrIter>=Parameters(1),IllCond<0]);
        
        %% 4. Prepare the next iteration
        NbrIter=NbrIter+1;
        GammaOld=GammaNew;
        
      
    end;
    %   Express the regression coefficient with respect to the columns of [1 X]
    Gamma(2:p+1,kk)=InvSigma*Vtr*GammaNew(2:rr+1)';
    Gamma(1,kk)=GammaNew(1)-MeanX*Gamma(2:p+1,kk);
    
    NbrIterStock(kk)=NbrIter-1;
    DiagCvgStock(kk)=((NbrIter<Parameters(1)) & IllCond==0);
end;



%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      Conclusion
%%%%%%%%%%%%%%%%%%%%%%%%%
out.Gamma=Gamma(:,Kappa);    % matrix (p+1) x length(Kappa)
out.NbrIter=NbrIterStock(Kappa);  % matrix 1 x length(Kappa)
out.DiagCvg=DiagCvgStock(Kappa); % matrix 1 x length(Kappa)
  
    


    
    
    
    
    
    
    
    
    
    



            







