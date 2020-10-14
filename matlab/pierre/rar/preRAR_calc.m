function [ri,HA,jac,w1,w2,lar1,lar2,MH,VI,nVI,VD]=preRAR_calc(c1,c2)

%Francisco Rodrigues Pinto, Setembro de 2005, Oeiras
%Function to compute clustering comparison measures that were available
%before RAR
%c1 and c2 are the classification/cluster vectors
%ri is the rand index
%HA is the adjusted rand index
%jac is the jaccard coefficient
%w1 is the wallace index of c1 relative to c2
%w1 is the wallace index of c2 relative to c1
%lar1 is the larsen index of c1 relative to c2
%lar2 is the larsen index of c2 relative to c1
%MH is the meila-heckerman index
%VI is the variation of information distance
%nVI is the normalized VI
%VD is the VanDongen metric
%Note - this function uses pdist, that is a function from
%the statistic toolbox of matlab

n=length(c1);
ng1=max(c1);
ng2=max(c2);
dn=n*(n-1)/2;

y1=pdist(c1(:),'ham');
y2=pdist(c2(:),'ham');

ad=sum((y1'==y2'));

ri=ad/dn;

a=sum((y1'==0).*(y2'==0));

w1=a/sum(y1'==0);
w2=a/sum(y2'==0);

d=ad-a;

jac=a/(dn-d);

%confmat=crosstab(c1,c2);
confmat=full(sparse(c1,c2,1,ng1,ng2));

coltot=sum(confmat);
rowtot=sum(confmat')';
summat=repmat(coltot,ng1,1)+repmat(rowtot,1,ng2);
larsenmat=2*confmat./summat;

lar1=mean(max((larsenmat'))');
lar2=mean(max(larsenmat)');

todelmat=larsenmat;
cumval=0;
for i=1:min([ng1;ng2])
    [val]=max(max(todelmat)');
    [rr,cc]=find(todelmat==val);
        todelmat(rr(1),:)=0;
        todelmat(:,cc(1))=0;
        cumval=cumval+confmat(rr(1),cc(1));
end
MH=cumval/n;

H1=-sum((rowtot/n).*log2((rowtot/n)));
H2=-sum((coltot/n)'.*log2((coltot/n)'));
indmat=(rowtot/n)*(coltot/n);
nozeromat=(confmat/n)+(confmat==0);
H12=-sum(sum((confmat/n).*log2(nozeromat)));
MI=H1+H2-H12;
VI=H1+H2-2*MI;
nVI=VI/log2(n);
VD=2*n-sum(max(confmat)')-sum(max(confmat')');

nis=sum(rowtot.^2);		%sum of squares of sums of rows
njs=sum(coltot.^2);		%sum of squares of sums of columns

t1=nchoosek(n,2);		%total number of pairs of entities
t2=sum(sum(confmat.^2));	%sum over rows & columnns of nij^2
t3=.5*(nis+njs);

%Expected index (for adjustment)
nc=(n*(n^2+1)-(n+1)*nis-(n+1)*njs+2*(nis*njs)/n)/(2*(n-1));

A=t1+t2-t3;		%no. agreements
D=  -t2+t3;		%no. disagreements

if t1==nc
   HA=0;			%avoid division by zero; if k=1, define Rand = 0
else
   HA=(A-nc)/(t1-nc);		%adjusted Rand - Hubert & Arabie 1985
end