function out=MIRPLSF(X,Y,NbrClass,flag,Parameters,Kappa);


%%  Last Modification : November, 17 2004. 
%%  (Algo : Ding & Gentleman, Technical report, Bioconductor, 2004).
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%
%%  X   : matrix n x p
%%      data matrix
%%  Y   : matrix n x 1
%%      response variable {0,1}-valued vector
%%  NbrClass : integer > 0
%%      Number of classes
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TEST on the INPUT variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<6,
    disp(sprintf('Message from MIRPLSF.m : \n \t Not enough input arguments.'));
    out=[];
    return 
 end;
if size(X,1)~=length(Y)
    disp(sprintf('Message from MIRPLSF.m : \n \t Error in the definition of %s and %s',inputname(1),inputname(2)));
    out=[];
    return 
end;
if ((length(Parameters)~=2) | (ceil(Parameters(1))~=Parameters(1)))
    disp(sprintf('Message from MIRPLSF.m : \n \t Error in the definition of the variable "%s"',inputname(5)));
    out=[];
    return 
end;
aux=repmat(Y,1,NbrClass)==repmat(0:NbrClass-1,length(Y),1);
if min(sum(aux))==0,
   disp(sprintf('Message from MIRPLSF.m : \n \t Some class is not present in the learning set'));
   out=[];
   return 
end;




c=NbrClass-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 1 :
%%      1/ Standardize or not the design matrix
%%      2/ Define the block-matrices
%%      3/ Move in the reduced space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% Move in some reduced space
Xi=[ones(nLearn,1) StdX]; % matrix nLearn x (p+1)
[U D V]=svd(Xi);
rr=rank(D);
UD=U(:,1:rr)*D(1:rr,1:rr); % matrix nLearn x rr
Vtr=V(:,1:rr);  % matrix (p+1) x rr


%%  Define the design (block)-matrix
%%  and the (block)-response variable
Xiblock=zeros(nLearn*c,c*rr); % matrix (nLearn c) x rr c
Yblock=zeros(nLearn*c,1);    % matrix (nLearn c) x 1
for cc=1:c,
    row=(0:1:nLearn-1)*c+cc;
    col=rr*(cc-1)+(1:1:rr);
    %Xiblock(row,col)=Xi;
    Xiblock(row,col)=UD;
    ff=find(Y==cc);
    Yblock((ff-1)*c+cc)=1; 
end;
       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 :
%%      1/ Run the iterative algorithm : Firth-penalized Iterative Reweighted PLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for xx=1:length(Kappa)
    kk=Kappa(xx);
    %% 1. Loop
    NbrIter=1;
    StopRule=0;
    IllCond=0;
    while   StopRule==0,
        %   Define the Pseudo-variable
            %% PseudoVar=Psi1+inv(Weight)*Psi2
        if NbrIter==1
            ThetaOld=10*ones(c*rr,1);   % matrix c(rr+1) x 1
            Weight=diag(abs(randn(nLearn*c,1))); % matrix (nLearn c) x (nLearn c)
            PseudoVar=0.25*(Yblock==0)+0.75*(Yblock==1); % matrix (nLearn c) x 1
            Psi1=PseudoVar; % matrix (nLearn c) x 1
            Psi2=zeros(nLearn*c,1); % matrix (nLearn c) x 1
            
            Weight=eye(nLearn*c);
        else
            % Update the Hat matrix
            Hat=Xiblock*pinv(Xiblock'*Wblock*Xiblock)*Xiblock'*Wblock; % matrix (nLearn c) x (nLearn c)
            h=diag(Hat); % matrix (nLearn c) x 1
            Auxh=reshape(repmat(sum(reshape(h,c,nLearn),1),c,1),nLearn*c,1);  % matrix (nLearn c) x 1
            %   Update the Weight for WPLS
            Weight=Wblock*diag(ones(nLearn*c,1)+0.5*(h+Auxh));  % matrix (nLearn c) x (nLearn c)
            Psi1=Eta; % matrix (nLearn c) x 1
            Psi2=Yblock-Piblock'+0.5*h-0.5*(h+Auxh).*Piblock';  % matrix (nLearn c) x 1
        end;
       
        %  PLS loop
        PsiAux=eye(rr*c); % matrix (rr c) x (rr c)
        E=Xiblock; % matrix (nLearn c) x (rr c)
        f1=Psi1;    % matrix (nLearn c) x 1 
        f2=Psi2;   % matrix (nLearn c) x 1 
        for count=1:kk,
            w=E'*(Weight*f1+f2);  % matrix (rr c) x 1
            Omega(:,count)=w;   
            t=E*w;  % matrix (nLearn c) x 1
            nn(count)=w'*E'*Weight*E*w;   % matrix 1 x 1
            Scores(:,count)=t;
            TildePsi(:,count)=PsiAux*w; % matrix (rr c) x 1
            Loadings(:,count)=(t'*Weight*E)'/nn(count); % matrix (rr c) x 1
            E=E-t*Loadings(:,count)';   % matrix (nLearn c) x (rr c)
            qcoeff(count)=(f1'*Weight+f2')*t/nn(count); % real
            f1=f1-qcoeff(count)*t; % matrix (nLearn c) x 1 
            f2=f2;  % matrix (nLearn c) x 1 
            PsiAux=PsiAux*(eye(rr*c)-w*Loadings(:,count)'); % matrix (rr c) x (rr c)
        end;
        ThetaNew=TildePsi*qcoeff'; % matrix (rr c) x 1
         
        %   Update the Weight for the Hat matrix
        Eta=Xiblock*ThetaNew; % matrix (nLearn c) x 1
        Wblock=zeros(nLearn*c,nLearn*c);  % matrix (nLearn c) x (nLearn c)
        for ll=1:nLearn,
            row=(ll-1)*c+(1:c);
            col=(ll-1)*c+(1:c);
            m=exp(Eta(row));
            m=m/(1+sum(m));
            Piblock(row)=m;
            Wblock(row,col)=diag(m)-m*m';
        end;
         
        % Stopping Rule
            % Based on the conditionning of some weight
        if rcond(Xiblock'*Wblock*Xiblock)<=10^(-16),
            IllCond=-1;
        end;
        % Based on the variation of the regression coefficient
        StopRule=max(abs((ThetaNew-ThetaOld)./ThetaOld))<=Parameters(2);
        StopRule=max([StopRule,NbrIter>=Parameters(1),IllCond<0]);
   
        % Prepare the next iteration
        NbrIter=NbrIter+1; 
        ThetaOld=ThetaNew;
        
    end;

    %%  2. Express the coefficient w.r.t the columns of [1 X]
    for cc=1:c
        Aux=Vtr*[ThetaNew(1+(cc-1)*rr) ThetaNew((cc-1)*rr+(2:rr))']';
        AuxGamma(:,cc)=[Aux(1)-MeanX*InvSigma*Aux(2:p+1)  (InvSigma*Aux(2:p+1))']'; % matrix 1 x (p+1)
    end;
    out.Gamma(xx,:,:)={AuxGamma};
    NbrIterStock(xx)=NbrIter-1;
    DiagCvgStock(xx)=((NbrIter<Parameters(1)) & IllCond==0);    
end;    % loop in kk




%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 :
%%      CONCLUSION
%%%%%%%%%%%%%%%%%%%%%
out.NbrIter=NbrIterStock;  % matrix 1 x length(Kappa)
out.DiagCvg=DiagCvgStock; % matrix 1 x length(Kappa)
  

     
        
       



