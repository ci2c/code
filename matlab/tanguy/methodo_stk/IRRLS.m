function out=IRRLS(Y,Z,Lambda,Parameters);



%%  Last Modification : November, 12 2004.
%%
%%  INPUT variables
%%%%%%%%%%%%%%%%%%%%
%%
%%  Z   : matrix nLearn x (rr+1)
%%      data matrix
%%  Y   : matrix nLearn x 1
%%      response variable {0,1}-valued vector
%%  Lambda : real > 0
%%      value of the regularization parameter Lambda
%%  Parameters  : vector with  2 components
%%      Parameter(1) : Max Nbr of iteration in the IRRLS part
%%      Parameter(2) : Threshold value for the stopping rule of IRRLS
%%
%%
%%  OUTPUT variables
%%%%%%%%%%%%%%%%%%%%%
%%  Structure with fields
%%      Gamma : estimate of the regression coefficients 
%%              matrix (rr+1) x 1
%%      NbrIter : Nbr of iterations till convergence
%%      DiagCvg : binary variable
%%              indicate if the algorithm converges.
%%      TraceHat : trace of the hat matrix.

rr=size(Z,2)-1;

R=eye(rr+1);
R(1,1)=0;


%%  Initialisation of the algorithm
c0=log(3);
Eta=c0*Y-c0*(1-Y); % matrix nLearn x 1
m=1./(1+exp(-Eta)); % matrix nLearn x 1
DiagW=m.*(1-m); % matrix nLearn x 1
PseudoVar=Eta+(Y-m)./DiagW; % matrix nLearn x 1
Weight=diag(DiagW); % matrix nLearn x nLearn
AuxGammaOld=inv(Z'*Weight*Z+Lambda*R)*Z'*Weight*PseudoVar; % matrix  (rr+1) x 1
EtaOld=Z*AuxGammaOld; % matrix nLearn x 1
    
    
%%  Newton-Raphson loop
StopRule=0;
NbrIter=0;   
while StopRule==0,
    % Definition of the pseudo-variable and weight matrix
    m=1./(1+exp(-EtaOld)); % matrix nLearn x 1
    DiagW=m.*(1-m); % matrix nLearn x 1
    Gradient=Z'*(Y-m)-Lambda*R*AuxGammaOld;
    Weight=diag(DiagW);
    % Update Gamma
    AuxGammaNew=AuxGammaOld+inv(Z'*Weight*Z+Lambda*R)*Gradient;
    % Update the linear predictor Eta and the mean Pi
    EtaNew=Z*AuxGammaNew;
    % Compute the stopping criterion : 
         % on the ill-conditioned matrix
         PiNew=1./(1+exp(-EtaNew));
         AuxWeight=diag(PiNew.*(1-PiNew));
         if (rcond(Z'*AuxWeight*Z)<=10^(-16))
                %disp(' Ill conditioned matrix; IRLS stopped');
                NbrIter=-1;
         end;
         %   on the norm of the gradient
         Gradient=Z'*(Y-PiNew)-Lambda*R*AuxGammaNew;
     StopRule=norm(Gradient)<=Parameters(2);
     StopRule=max([StopRule,NbrIter==Parameters(1),NbrIter<0]);
     % Update the former values of Gamma and Eta
     AuxGammaOld=AuxGammaNew;
     EtaOld=EtaNew;
     % Increment the number of iterations
     NbrIter=NbrIter+1;
end;
    
       
%%  Conclude
%   Estimated parameter
    out.Gamma=AuxGammaNew;    % matrix (p+1) x 1
%   Nbr of iteration
    out.NbrIter=NbrIter;
    out.DiagCvg=((NbrIter<Parameters(1)) & (NbrIter>0));
%   Trace of the Hat Matrix 
    Hat=Z*inv(Z'*AuxWeight*Z+Lambda*R)*Z'*AuxWeight;
    Dim=trace(Hat);
    out.TraceHat=Dim;
    





