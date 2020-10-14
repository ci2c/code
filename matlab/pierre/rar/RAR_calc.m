function [rar,mddi,mdd,rmm,rmmi,diagnostic]=RAR_calc(c1,c2,mat1,mat2,gmat1,gmat2)

%Francisco Rodrigues Pinto, Setembro de 2005, Oeiras
%Function to compute the measure RAR
%c1 and c2 are the classification/cluster vectors
%mat1 and mat2 are square distance matrices between objects
%gmat1 and gmat2 are square distance matrices between
%groups/clusters/partitions
%rar the ranked adjusted rand 
%mddi is the expected mean diagonal deviation under independence
%mdd is the mean diagonal deviation (mdd)
%rmm is the ranked mismatch matrix (rmm)
%rmmi is the expected rmm under random clusterings
%diagnostic is a helper variable for debugging purposes
%Note - this function uses pdist, that is a function from
%the statistic toolbox of matlab

n=length(c1);%number of objects
ng1=max(c1);%number of groups in c1
ng2=max(c2);%number of groups in c2
bothclass=full(sparse(c1,c2,1,ng1,ng2));


%build gmat1 and gmat2 if they are not in the imput
if isempty(mat1)==0 & isempty(gmat1)
    ii=repmat(c1(:),n,1);
    rc1=c1(:);
    rc1=rc1';
    jj=repmat(rc1,n,1);
    jj=jj(:);
    gmat1=zeros(ng1,ng1);
    gmat1=full(sparse(ii,jj,mat1(:),ng1,ng1))./full(sparse(ii,jj,1,ng1,ng1));
    for i=1:ng1
        [b,m,gmat1(:,i)]=unique(gmat1(:,i));
    end
elseif isempty(gmat1)
    gmat1=1+(eye(ng1)==0);
elseif isempty(gmat1)==0
    for i=1:ng1
        [b,m,gmat1(:,i)]=unique(gmat1(:,i));
    end
end
            
if isempty(mat2)==0 & isempty(gmat2)
    ii=repmat(c2(:),n,1);
    rc2=c2(:);
    rc2=rc2';
    jj=repmat(rc2,n,1);
    jj=jj(:);
    gmat2=zeros(ng2,ng2);
    gmat2=full(sparse(ii,jj,mat2(:),ng2,ng2))./full(sparse(ii,jj,1,ng2,ng2));
    for i=1:ng2
        [b,m,gmat2(:,i)]=unique(gmat2(:,i));
    end
elseif isempty(gmat2)
    gmat2=1+(eye(ng2)==0);
elseif isempty(gmat2)==0
    for i=1:ng2
        [b,m,gmat2(:,i)]=unique(gmat2(:,i));
    end
end

dim1=max(gmat1(:));
dim2=max(gmat2(:));

rmmi=zeros(dim1,dim2);

mismatchrank1=gmat1(c1,c1);
mismatchrank2=gmat2(c2,c2);

rmm=zeros(dim1,dim2);
rmm=full(sparse(mismatchrank1(:),mismatchrank2(:),1,dim1,dim2));
rmm(1,1)=rmm(1,1)-n;
clear mismatchrank1;
clear mismatchrank2;
%rmm=rmm/2;

nprod1=(sum(bothclass')')*(sum(bothclass'));
nprod2=(sum(bothclass)')*(sum(bothclass));

rmmi=zeros(dim1,dim2);

for i=1:dim1
    for j=1:dim2
       d1=sum(sum(nprod1(gmat1==i)));
       d2=sum(sum(nprod2(gmat2==j)));
       rmmi(i,j)=d1*d2/(n^2);
    end
end
rmmi(1,1)=rmmi(1,1)-n;
%rmmi=rmmi/2;

[nr,nc]=size(rmm);
devmat=(repmat((0:(nr-1))'/(nr-1),1,nc)-repmat((0:(nc-1))/(nc-1),nr,1));


%m=(size(rmm,1)-1)/(size(rmm,2)-1);
%mp=-1/m;
%b=1-m;
%xall=repmat((1:size(rmm,2)),size(rmm,1),1);
%yall=repmat((1:size(rmm,1))',1,size(rmm,2));
%ball=yall-mp*xall;
%xint=(ball-b)/(m-mp);
%yint=xint*mp+ball;
%devmat=(((xall-xint).^2)+((yall-yint).^2)).^(0.5);
%devmat=devmat/max(devmat(:));
sumdev=sum(sum(abs(devmat).*rmm));
indsumdev=sum(sum(abs(devmat).*rmmi));
mddi=(indsumdev/sum(rmmi(:)));
mdd=(sumdev/sum(rmm(:)));
rar=(mddi-mdd)/mddi;

if nargin==6
    diagnostic.crosstab=full(sparse(c1,c2,1,ng1,ng2));
    y1=pdist(c1(:),'ham');
    y2=pdist(c2(:),'ham');
    diagnostic.abcd(1,1)=sum((y1'==0).*(y2'==0));
    diagnostic.abcd(1,2)=sum((y1'==0).*(y2'~=0));
    diagnostic.abcd(2,1)=sum((y1'~=0).*(y2'==0));
    diagnostic.abcd(2,2)=sum((y1'~=0).*(y2'~=0));
    for i=1:ng1
        mismatchrank1=gmat1(c1(c1==i),c1);
        mismatchrank2=gmat2(c2(c1==i),c2);
        diagnostic.c1.rmm{i}=full(sparse(mismatchrank1(:),mismatchrank2(:),1,dim1,dim2));
        diagnostic.c1.rmm{i}(1,1)=diagnostic.c1.rmm{i}(1,1)-sum(c1==i);
    end
    for i=1:ng2
        mismatchrank1=gmat1(c1,c1(c2==i));
        mismatchrank2=gmat2(c2,c2(c2==i));
        diagnostic.c2.rmm{i}=full(sparse(mismatchrank1(:),mismatchrank2(:),1,dim1,dim2));
        diagnostic.c2.rmm{i}(1,1)=diagnostic.c2.rmm{i}(1,1)-sum(c2==i);
    end
end


