function out=PreProcess(IndexLearn,DATA,LABELS,NbrClass,method,Apply,DataSet);



%%  Last Modification : November, 15 November.
%%  (a pre-processing box for standard Microarrays data set).
%%
%% INPUT variables
%%%%%%%%%%%%%%%%%%%
%%  IndexLearn ; matrix nLearn x 1
%%      indes of samples forming the learning set
%%  DATA : matrix n x pmax,  n >=nLearn
%%      contains the expression levels of all the genes in ALL the data set
%%  LABELS : matrix nLearn x 1
%%      LABELS of the samples in the LEARNING set : {0, ...,NbrClass-1}-valued
%%  NbrClass : matrix 1 x 1
%%      contains the number of classes; 
%%      the LABELS are \{0,...,NbrClass-1\}-valued.
%%  method : character
%%      indicates the statistic with which genes are sorted
%%  Apply : matrix 1 x 4
%%      four binary variables to indicate what kind of pre-process has to
%%      be applied.
%%      Apply(1)=1 iff Thresholding has to be applied.
%%      Apply(2)=1 iff Filtering has to be applied.
%%      Apply(3)=1 iff Log-Transform has to be applied.
%%      Apply(4)=1 iff Standardization per row has to be applied.
%%
%%  Optional input :
%%      DataSet : a character string
%%                 either 'Colon','Leukemia','Lymphoma','Prostate'.
%%                 defines some parameters for the Thresholding and
%%                 Filtering steps.
%%
%%
%%  OUTPUT variables
%%%%%%%%%%%%%%%%%%%%%
%%  A structure with fields :
%%      GENES : matrix n x pmax 
%%          the columns of GENES are sorted in the ascending value of the
%%          statistic; the last column has the largest value of the statistic.
%%      Statistic : the value of the statistic of all the genes, sorted as
%%          in DATA.
%%      InitPos : Position of the genes w.r.t. its initial position in DATA
%%
%%  Remarks :
%%      The indices of non-cancelled genes are in the variable: index
%%      The indices of the sorted genes can be founded in index(out2)
%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 1 : 
%%      TEST ON THE INPUT VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Number of Input variables
    if nargin<6,
        disp(sprintf('From PreProcess.m : \n \t Not enough input arguments'));
        out=[];
        return;
    end;
    if nargin==7 & ~isequal(DataSet,'Colon') & ~isequal(DataSet,'Lymphoma') & ~isequal(DataSet,'Leukemia') & ~isequal(DataSet,'Prostate'),
        disp(sprintf('From PreProcess.m : \n \t The DataSet is not known and the default parameters are used'));
        DataSet='Default';
    end;
    if (nargin==6 & sum(Apply(1:2))>0),
        disp(sprintf('From PreProcess.m : \n \t The default parameters are used'));
        DataSet='Default';
    end;
%   Size of DATA and LABELS
    if length(LABELS)~=size(DATA,1)
        disp(sprintf('From PreProcess : \n \t Error in the input variables, check the size of "%s" and "%s"',inputname(1),inputname(2)));
        out=[]; 
        return;
    end;
%  Preprocessing method
    if (~isequal(method,'Dudoit') & ~isequal(method,'Nguyen') & ~isequal(method,'Wilkoxon'))
        disp(sprintf('From PreProcess : \n \t Error in the input variables, check the name of the statistic'));
        out=[];
        return;
    end;
%  Method and Multiclass
    if ((NbrClass>2) & ~isequal(method,'Dudoit'))
       disp(sprintf('From PreProcess : \n \t Error in the input variables, "%s" must be Dudoit',inputname(4)));
       out=[]; 
       return;
    end;
%  Method and Multiclass
    maxL=max(LABELS);
    if NbrClass<=maxL
        disp(sprintf('From PreProcess : \n \t Error in the input variables, check the number of classes'));
        out=[];
        return;
    end;


    
%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 2 : 
%%       PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%
%% TRESHOLD
if Apply(1)==1,
    % Floor of  100 and Ceil at 16000
    if isequal(DataSet,'Leukemia') | isequal(DataSet,'Colon') | isequal(DataSet,'Default')
        DATA=(DATA<100)*100+(DATA>=100).*DATA;
        DATA=(DATA>=16000)*16000+(DATA<16000).*DATA;  
    elseif isequal(DataSet,'Lymphoma')
        DATA=(DATA<20)*20+(DATA>=20).*DATA; 
        DATA=(DATA>=16000)*16000+(DATA<16000).*DATA; 
    elseif isequal(DataSet,'Prostate')
        DATA=(DATA<10)*10+(DATA>=10).*DATA; 
        DATA=(DATA>=16000)*16000+(DATA<16000).*DATA; 
    end;
end;

%%  FILTERING
DATAL=DATA(IndexLearn,:);
if Apply(2)==1,
    MaxCol=max(DATAL,[],1);
    MinCol=min(DATAL,[],1);
    if isequal(DataSet,'Leukemia') | isequal(DataSet,'Colon') | isequal(DataSet,'Default')
        index=find(MaxCol./MinCol>5 & MaxCol-MinCol>500);
    elseif isequal(DataSet,'Prostate')
        index=find(MaxCol./MinCol>5 & MaxCol-MinCol>50);
    end;    
    GENES=DATA(:,index);
else
    GENES=DATA;
end;

%%  LOG10-TRANSFORM
if Apply(3)==1,
    GENES=log10(GENES);
end;

%%  STANDARDIZATION     
if Apply(4)==1,
    pInit=size(GENES,2);
    MeanRow=mean(GENES,2);
    StdRow=std(GENES,1,2);
    GENES=(GENES-repmat(MeanRow,1,pInit))./repmat(StdRow,1,pInit);
        % now, the mean of each row is 0; and the sum of the square is
        % the length of each row;
end;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 3 : 
%%      SORT THE COLUMNS, by a ranking statistic 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Y=LABELS(IndexLearn,1);
    X=GENES(IndexLearn,:);
    [n,p]=size(X);   
switch method
    case 'Dudoit'
        Num=zeros(1,p);
        Den=zeros(1,p);
        X=X-ones(n,1)*mean(X,1);
        
         for kk=1:NbrClass,
            IndexClass=find(Y==kk-1);
            MeanClass=mean(X(IndexClass,:),1);
            LengthClass=length(IndexClass);
            Num=Num+MeanClass.^2*LengthClass;
            Den=Den+var(X(IndexClass,:),1)*LengthClass;
        end;
        Statistic=Num./Den;
        [out1, out2]=sort(Statistic);     
        
        
    case 'Nguyen'
        for kk=1:NbrClass,
            IndexClass=find(Y==kk-1);
            N(kk)=length(IndexClass);
            Mean(kk,:)=sum(X(IndexClass,:),1)/N(kk);
            CtrX=X(IndexClass,:)-repmat(Mean(kk,:),N(kk),1);
            SumSquare(kk,:)=sum(CtrX.^2,1);
        end;
        Statistic=(Mean(1,:)-Mean(2,:))./sqrt(SumSquare(1,:)/(N(1)*(N(1)-1))+SumSquare(2,:)/(N(2)*(N(2)-1)));
        [out1, out2]=sort(Statistic);     
    
        
    case 'Wilkoxon'
        if NbrClass~=2,
            disp('Can not use the Wilkoxon test');
            return;
        end;
        IndexClass0=find(Y==0);
        IndexClass1=setdiff(1:n,IndexClass0);
        N0=length(IndexClass0);
        N1=n-N0;
        if N0>=N1,
            for kk=1:p,
                lgsample=X(IndexClass0,kk);
                smsample=X(IndexClass1,kk);
                ns=N1;
                [ranks, tieadj] = tiedrank([smsample; lgsample]);
                xrank = ranks(1:ns);
                w(kk)= sum(xrank);
            end;
        else
            for kk=1:p,
                smsample=X(IndexClass0,kk);
                lgsample=X(IndexClass1,kk);
                ns=N0;
                [ranks, tieadj] = tiedrank([smsample; lgsample]);
                xrank = ranks(1:ns);
                w(kk)= sum(xrank);
            end;
         end;
        
        [out1, out2]=sort(w);
        Statistic=fliplr(w);
        out2=fliplr(out2);
end;
   



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  STEP 4 :
%%      CONCLUSION
%%%%%%%%%%%%%%%%%%%%%%%%%%
    % columns are sorted in the increasing order of the statistic.
    GENES=GENES(:,out2);
    out.GENES=GENES;
    % Index of the genes w.r.t. the initial list (i.e. in the DATA matrix)
    out.InitPos=index(out2);
    % Ths value of the statistic w.r.t. the initial genes;
    % set to zero when the genes is cancelled in the pre-processing steps.
    out.Statistic=zeros(1,size(DATA,2));
    out.Statistic(index)=Statistic;
   