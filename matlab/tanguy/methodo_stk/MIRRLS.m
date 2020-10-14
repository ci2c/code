function out=MIRRLS(Y,Z,NbrClass,Lambda,Parameters);



%%  Last Modification : November, 16 2004.
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%      c=NbrClass-1
%%  Z   : matrix (c nLearn) x c(rr+1)
%%      block data matrix
%%  Y   : matrix (c nLearn) x 1
%%      block response variable {0,1}-valued vector
%%  NbrClass : integer >0
%%      Number of classes.
%%  Lambda : real > 0
%%      value of the regularization parameter Lambda
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration 
%%      Parameter(2) : Threshold value for the stopping rule of MIRRLS
%%
%%
%%  OUTPUT variables
%%%%%%%%%%%%%%%%%%%%%
%%  Structure with fields
%%      Gamma : estimate of the regression coefficients 
%%              matrix c(rr+1) x 1
%%      NbrIter : Nbr of iterations till convergence
%%      DiagCvg : binary variable
%%              indicate if the algorithm converges.
%%      TraceHat : trace of the hat matrix.


c=NbrClass-1;
rr=size(Z,2)/c-1;
nLearn=length(Y)/c;


R=eye(c*(rr+1));
grid=1:rr+1:c*(rr+1);
R(grid,grid)=0;


%%  Initialisation of the algorithm
Pi=((1-Y)+3*Y)/(c+3); % matrix (c nLearn) x 1
for kk=1:nLearn,
    ss(kk)=1-sum(Pi(c*(kk-1)+(1:c),1));
    BlocPi=Pi(c*(kk-1)+(1:c),1);
    BlocW=-BlocPi*BlocPi';
    BlocW=BlocW+diag(BlocPi);
    Weight(c*(kk-1)+(1:c),c*(kk-1)+(1:c))=BlocW; % matrix (nLearn c) x (nLearn c)
    Eta(c*(kk-1)+(1:c),1)=log(BlocPi)-log(ss(kk));
end;
AuxGammaOld=pinv(Z)*Eta;
Gradient=Z'*(Y-Pi)-Lambda*R*AuxGammaOld;    % matrix (c nLearn) x 1

%%  Newton-Raphson loop
StopRule=0;
NbrIter=1;   
IllCond=0;

while StopRule==0,
    % Definition of the gradient and the weight matrix
     % Update Gamma
     AuxGammaNew=AuxGammaOld+inv(Z'*Weight*Z+Lambda*R)*Gradient;    % matrix (c nLearn) x 1 
     % Update the linear predictor Eta, the mean Pi, the weight Weight
     EtaNew=Z*AuxGammaNew;   % matrix (c nLearn) x 1
     for kk=1:nLearn,
         PiNew(c*(kk-1)+(1:c),1)=exp(EtaNew(c*(kk-1)+(1:c),1))./(1+sum(exp(EtaNew(c*(kk-1)+(1:c),1))));
         BlocPi=PiNew(c*(kk-1)+(1:c),1);
         BlocW=-BlocPi*BlocPi';
         BlocW=BlocW+diag(BlocPi);
         WeightNew(c*(kk-1)+(1:c),c*(kk-1)+(1:c))=BlocW; % matrix (nLearn c) x (nLearn c)
     end;
     % Stopping rule
        % on the conditioning of the matrix
        if (rcond(Z'*WeightNew*Z+Lambda*R)<=10^(-16))
               IllCond=-1;
        end;
        %   on the norm of the gradient
        Gradient=Z'*(Y-PiNew)-Lambda*R*AuxGammaNew;
     StopRule=norm(Gradient)<=Parameters(2);
     StopRule=max([StopRule,NbrIter==Parameters(1),IllCond<0]);
     
     % Update the former values of Gamma and Eta
     AuxGammaOld=AuxGammaNew;
     Weight=WeightNew;
     % Increment the number of iterations
     NbrIter=NbrIter+1;
end;
    
       
%%  Conclude
%   Estimated parameter
    out.Gamma=AuxGammaNew;    % matrix c(rr+1) x 1
%   Nbr of iteration
    out.NbrIter=NbrIter-1;
    out.DiagCvg=((out.NbrIter<Parameters(1)) & (IllCond==0));
%   Trace of the Hat Matrix 
    Hat=Z*inv(Z'*Weight*Z+Lambda*R)*Z'*Weight;
    Dim=trace(Hat);
    out.TraceHat=Dim;
    

