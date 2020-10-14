function C=givecluster(C,nc,alfa)

%Francisco Rodrigues Pinto, Lisboa 2006
%auxiliary function of clustergenerator.m

C(1:nc)=(1:nc)';
C(nc+1)=ceil(nc*rand);
n=length(C);

for i=nc+1:n
    beendone=C(1:(i-1));
    counts=histc(beendone,(1:nc));
    %counts=flipud(sort(counts));
    weights=exp(counts*alfa);
    weights=weights/sum(weights);
    cumweights=cumsum(weights);
    C(i)=nc+1-sum((cumweights-rand)>=0);
end


%if isempty(tofill)==0 
%    if tofill(1)==1
%         
%         C=givecluster(C,nc,alfa);
%     else        
%         beendone=C(find(C~=0));
%         counts=histc(beendone,(1:nc));
%         weights=counts.^(-alfa);
%         weights=weights/sum(weights);
%         cumweights=cumsum(weights);
%         C(tofill(1))=sum((cumweights-rand)>=0);
%         C=givecluster(C,nc,alfa);
%     end
% else
%     n=length(c);
%     [lixo,order]=sort(rand(n,1));
%     C=C(order);
% end



    
    