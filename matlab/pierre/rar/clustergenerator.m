function [C1,C2,gmat1,gmat2,r,HA]=clustergenerator(n,nc,fme,cdp,l2x)

%Francisco Rodrigues Pinto, Lisboa 2006
%Function to generate pairs of artificial clusterings C1 and C2 (which are
%vectors of cluster membership
%n is the desired number of entities
%nc is the desired number of clusters
%fme is the fraction of entities that change location from C1 to C2
%cdp is the parameter controling the cluster size distribution
%l2x is the parameter defining the neighbour rank distance of the target cluster to
%which moving entities are assigned in C2 (relatively to the original
%clusters in C1)
%gmat1 and gmat2 are square distance matrices between
%r is the correlation coefficient between distance matrices of C1 and C2
%HA is the adjusted rand index
%Note - this function uses pdist, squareform and corr, which are functions from
%the statistic toolbox of matlab

clcoord=rand(nc,5);
clmat=zeros(nc,nc);
clmat=squareform(pdist(clcoord));
gmat1=clmat;
nextracl=ceil(0.05*nc*rand)-1;
nc2=nc+nextracl;
extraclcoord=rand(nextracl,5);
clcoord2=[clcoord; extraclcoord];
clmat2=zeros(nc2,nc2);
clmat2=squareform(pdist(clcoord2));

gmat2=clmat2;

for i=1:nc2
    [b,m,gmat2(:,i)]=unique(gmat2(:,i));
end
maxdist=max(gmat2);
targetdist=ceil(l2x*maxdist);
for i=1:nc2
    tt=find(gmat2(:,1)==targetdist(i));
    targetcl(i,1)=tt(1);
end


C1=zeros(n,1);
C1=givecluster(C1,nc,cdp);

[sorted,tochange]=sort(rand(n,1));
clear sorted;
n2x=max(round(fme*n),nc2);
tochange=tochange(1:n2x);
tochange=sort(tochange);

C2=C1;
%toadd=ceil((nc2)*rand(size(tochange,1),1));
%toadd(toadd==0)=1;
C2(tochange)=targetcl(C2(tochange));%C2(tochange)+toadd;
C2(tochange(1:nc2))=(1:nc2)';
%C2(C2>(nc2))=C2(C2>(nc2))-(nc2);

distC1=gmat1(C1,C1);
distC2=gmat2(C2,C2);

r=corr(distC1(:),distC2(:));

dn=n*(n-1)/2;

y1=pdist(C1(:),'ham');
y2=pdist(C2(:),'ham');

ad=sum((y1'==y2'));
a=sum((y1'==0).*(y2'==0));
d=ad-a;
ab=sum(y1'==0);
b=ab-a;
c=dn-ad-b;
denomHA=(dn^2-((a+b)*(a+c)+(c+d)*(b+d)));
if denomHA==0
    HA=0;
else
    HA=(dn*ad-((a+b)*(a+c)+(c+d)*(b+d)))/denomHA;
end

