%%  Example : Polychotomous discrimination
%%      Real data set : LEUKEMIA DATA
%%
%%



%%  1/ Load the data set
%%%%%%%%%%%%%%%%%%%%%%%%%
    load LeukemiaDataSet3.dat  
    % this yields  a 72 x 7130 matrix, 
    % the first column is the response variable Y
    % the last 7129 columns are the gene expression levels.
    LABELS=LeukemiaDataSet3(:,1);
    DATA=LeukemiaDataSet3(:,2:7130);
    clear LeukemiaDataSet3
    
    
    
%%  2/ Define the learning set and the test set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [n pinit]=size(DATA);
    IndexLearn=1:38;
    IndexTest=setdiff(1:n,IndexLearn);
    
%%  3/ Pre-process the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NbrClass=3;
    method='Dudoit';
    Apply=[1 1 1 0];
    DataSet='Leukemia';
    outPreProc=PreProcess(IndexLearn,DATA,LABELS,NbrClass,method,Apply,DataSet);
    
%%  4/ Pre-select some genes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pmax=size(outPreProc.GENES,2);
    p=500;
    if isequal(method,'Dudoit')
        Xall=outPreProc.GENES(:,pmax-p+1:pmax);
    else
        Xall=outPreProc.GENES(:,[1:floor(p/2) pmax-ceil(p/2)+1:pmax]);
    end;
    
%%  5/ Estimate the regression coefficients from the learning test
%%      and count the misclassified samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(sprintf('\t \t \t PLS for POLYCHOTOMOUS DISCRIMINATION \n'));
    disp(sprintf('The data set is divided into a Learning set (size %d) and a Test set (size %d)',length(IndexLearn),length(IndexTest)));
    disp(sprintf('%d genes among the %d available are included in the model \n',p,pmax));
    
    %   by MNR
    %%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[50 10^(-12)];
    Kappa=1:6;
    outMNR=MNR(X,Y,NbrClass,flag,Parameters,Kappa);
    for xx=1:length(Kappa)
        Eta=[zeros(n,1) [ones(n,1) Xall]*outMNR.Gamma{xx}]; % matrix n x 1;
        [xxx AuxClass]=max(Eta');
        Class(:,xx)=AuxClass'-1;
    end;
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on MNR'))
    disp(sprintf('\t For Kappa =  %s ',num2str(Kappa)));
    disp(sprintf('\t \t Separation (1 if observed) : %s',num2str(outMNR.Separation)));    
    disp(sprintf('\t \t Convergence (1 if observed) : %s',num2str(outMNR.DiagCvg)));    
    disp(sprintf('\t \t Number of iterations before the iterative part stops (max=%d): %s',Parameters(1),num2str(outMNR.NbrIter)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
    
   
    %   by MIRPLSF
    %%%%%%%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[100 10^(-4)];
    Kappa=1:6;
    outMIRPLSF=MIRPLSF(X,Y,NbrClass,flag,Parameters,Kappa);
    for xx=1:length(Kappa)
        Eta=[zeros(n,1) [ones(n,1) Xall]*outMIRPLSF.Gamma{xx}]; % matrix n x 1;
        [xxx AuxClass]=max(Eta');
        Class(:,xx)=AuxClass'-1;
    end;
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on MIRPLSF'));
    disp(sprintf('\t For Kappa = %s',num2str(Kappa)));
    disp(sprintf('\t \t Convergence (1 if observed) : %s',num2str(outMIRPLSF.DiagCvg)));    
    disp(sprintf('\t \t Number of iterations before the iterative part stops (max=%d) : %s',Parameters(1),num2str(outMIRPLSF.NbrIter)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
   
    
    
    
    %   by MRPLS
    %%%%%%%%%%%%%
    X=Xall(IndexLearn,:);
    Y=LABELS(IndexLearn);
    flag=1;
    Parameters=[50 10^(-12)];
    Kappa=1:6;
    LambdaRange=10.^[-3:0.1:3];
    outMRPLS=MRPLS(X,Y,NbrClass,flag,LambdaRange,Parameters,Kappa);
    for xx=1:length(Kappa)
        Eta=[zeros(n,1) [ones(n,1) Xall]*outMRPLS.Gamma{xx}]; % matrix n x 1;
        [xxx AuxClass]=max(Eta');
        Class(:,xx)=AuxClass'-1;
    end;
    ErrorTest=Class(IndexTest,:)~=repmat(LABELS(IndexTest),1,length(Kappa));
    ErrorLearn=Class(IndexLearn,:)~=repmat(LABELS(IndexLearn),1,length(Kappa));
    
    disp(sprintf('Inference and Classification based on MRPLS'));
    disp(sprintf('\t Number of iterations before the iterative part stops (max=%d): %s',Parameters(1),num2str(outMRPLS.NbrIterIRRLS)));
    disp(sprintf('\t Convergence (1 if observed) : %s',num2str(outMRPLS.DiagCvgIRRLS)));  
    disp(sprintf('\t Optimal value of the shrinkage parameter : lambda = 10^(%f)',log10(outMRPLS.Lambda)));
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
    Eta=[zeros(n,1) [ones(n,1) Xall]*outRIDGE.Gamma]; % matrix n x 1;
    [xxx AuxClass]=max(Eta');
    Class=AuxClass'-1;
    ErrorTest=Class(IndexTest,:)~=LABELS(IndexTest);
    ErrorLearn=Class(IndexLearn,:)~=LABELS(IndexLearn);
    
    disp(sprintf('Inference and Classification based on RIDGE'));
    disp(sprintf('\t Number of iterations before the iterative part stops (max=%d): %s',Parameters(1),num2str(outRIDGE.NbrIterIRRLS)));
    disp(sprintf('\t Convergence (1 if observed) : %s',num2str(outRIDGE.DiagCvgIRRLS)));  
    disp(sprintf('\t Optimal value of the shrinkage parameter : lambda = 10^(%f)',log10(outRIDGE.Lambda)));
    disp(sprintf('\t \t Number of errors in the Test set : %s',num2str(sum(ErrorTest))));
    disp(sprintf('\t \t Number of errors in the Learning set : %s',num2str(sum(ErrorLearn))));
    
    
    
    
    