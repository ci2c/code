%%  Example : Binary classification 
%%      Real data set : COLON DATA
%%
%%


clear all

%%  1/ Load the data set
%%%%%%%%%%%%%%%%%%%%%%%%%
    load ColonDataSet.dat  
    % this yields : ColonDataSet a 62 x 2001 matrix, 
    % the first column is the response variable Y
    % the last 2000 columns are the gene expression levels.
    LABELS=ColonDataSet(:,1);
    DATA=ColonDataSet(:,2:2001);
    clear ColonDataSet
    
    
%%  2/ Define the learning set and the test set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [n pinit]=size(DATA);
    IndexLearn=1:n/2;
    IndexTest=setdiff(1:n,IndexLearn);
    
%%  3/ Pre-process the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NbrClass=2;
    method='Dudoit';
    Apply=[1 1 1 0];
    DataSet='Colon';
    outPreProc=PreProcess(IndexLearn,DATA,LABELS,NbrClass,method,Apply,DataSet);
    
%%  4/ Pre-select some genes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pmax=size(outPreProc.GENES,2);
    p=pmax;
    if isequal(method,'Dudoit')
        Xall=outPreProc.GENES(:,pmax-p+1:pmax);
    else
        Xall=outPreProc.GENES(:,[1:floor(p/2) pmax-ceil(p/2)+1:pmax]);
    end;
    
%%  5/ Estimate the regression coefficients from the learning test
%%      and count the misclassified samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(sprintf('\t \t \t PLS for BINARY CLASSIFICATION \n'));
    disp(sprintf('The data set is divided into a Learning set (size %d) and a Test set (size %d)',length(IndexLearn),length(IndexTest)));
    disp(sprintf('%d genes among the %d available are included in the model \n',p,pmax));
    
    %   by NR
    %%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[50 10^(-10)];
    Kappa=1:6;
    outNR=NR(X,Y,flag,Parameters,Kappa);
    Class=([ones(n,1) Xall]*outNR.Gamma)>=0; % matrix n x length(Kappa);
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on NR'))
    disp(sprintf('\t For Kappa =  %s ',num2str(Kappa)));
    disp(sprintf('\t \t Separation (1 if detected) : %s',num2str(outNR.Separation)));    
    disp(sprintf('\t \t Number of iterations before the iterative part stops (max=%d): %s',Parameters(1),num2str(outNR.NbrIter)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
    
     %   by IRPLS
    %%%%%%%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[50 10^(-4)];
    Kappa=1:6;
    outIRPLS=IRPLS(X,Y,flag,Parameters,Kappa);
    Class=([ones(n,1) Xall]*outIRPLS.Gamma)>=0; % matrix n x length(Kappa);
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on IRPLS'));
    disp(sprintf('\t For Kappa = %s',num2str(Kappa)));
    disp(sprintf('\t \t Number of iterations before the IRPLS-iterative part stops (max=%d) : %s',Parameters(1),num2str(outIRPLS.NbrIterIRPLS)));
    disp(sprintf('\t \t Convergence (1 if observed) : %s',num2str(outIRPLS.DiagCvgIRPLS)));    
    disp(sprintf('\t \t Number of iterations before the IRLS-iterative part stops (max=%d) : %s',Parameters(1),num2str(outIRPLS.NbrIterIRLS)));
    disp(sprintf('\t \t Separation (1 if detected) : %s',num2str(outIRPLS.Separation)));    
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));

    %   by IRPLSF
    %%%%%%%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[100 10^(-4)];
    Kappa=1:6;
    outIRPLSF=IRPLSF(X,Y,flag,Parameters,Kappa);
    Class=([ones(n,1) Xall]*outIRPLSF.Gamma)>=0; % matrix n x length(Kappa);
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on IRPLSF'));
    disp(sprintf('\t For Kappa = %s',num2str(Kappa)));
    disp(sprintf('\t \t Convergence (1 if observed) : %s',num2str(outIRPLSF.DiagCvg)));    
    disp(sprintf('\t \t Number of iterations before the iterative part stops (max=%d) : %s',Parameters(1),num2str(outIRPLSF.NbrIter)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
   
    %   by RPLS
    %%%%%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[50 10^(-12)];
    Kappa=1:6;
    LambdaRange=10.^[-3:0.1:3];
    outRPLS=RPLS(X,Y,flag,LambdaRange,Parameters,Kappa);
    Class=([ones(n,1) Xall]*outRPLS.Gamma)>=0; % matrix n x length(Kappa);
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on RPLS'));
    disp(sprintf('\t Number of iterations before the iterative part stops (max=%d): %s',Parameters(1),num2str(outRPLS.NbrIterIRRLS)));
    disp(sprintf('\t Convergence (1 if observed) : %s',num2str(outRPLS.DiagCvgIRRLS)));  
    disp(sprintf('\t Optimal value of the shrinkage parameter : lambda = 10^(%f)',log10(outRPLS.Lambda)));
    disp(sprintf('\t For Kappa = %s ',num2str(Kappa)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
    
    
     %   by RIDGE
     %%%%%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[50 10^(-12)];
    Kappa=1:6;
    LambdaRange=10.^[-3:0.1:3];
    outRIDGE=MRIDGE(X,Y,NbrClass,flag,LambdaRange,Parameters);
    clear Class
    Class=([ones(n,1) Xall]*outRIDGE.Gamma)>=0; % matrix n x 1;
    ErrorTest=Class(IndexTest)~=repmat(LABELS(IndexTest),1,1);
    ErrorLearn=Class(IndexLearn)~=repmat(LABELS(IndexLearn),1,1);
    
    disp(sprintf('Inference and Classification based on RIDGE'));
    disp(sprintf('\t Number of iterations before the iterative part stops (max=%d): %s',Parameters(1),num2str(outRIDGE.NbrIterIRRLS)));
    disp(sprintf('\t Convergence (1 if observed) : %s',num2str(outRIDGE.DiagCvgIRRLS)));  
    disp(sprintf('\t Optimal value of the shrinkage parameter : lambda = 10^(%f)',log10(outRIDGE.Lambda)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
    
    
    
    
    
    