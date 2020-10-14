function Z = avapower(Ms,bin_size,reps)
%Main avalanche script

En=full(sum(Ms));                                       %size of event at each timepoint
En([1:find(~En,1,'first') find(~En,1,'last'):end])=0;   %remove clipped avalanches
Eind=find(En);                                          %indices of event occurence

Astart=Eind;
Afinit=Eind;
Astart([false Eind(2:end)-1==Eind(1:end-1)])=[];        %commencement of avalanches
Afinit([Eind(1:end-1)+1==Eind(2:end) false])=[];        %termination of avalanches

N=zeros(size(Astart));
for i=1:length(Astart)
    N(i)=sum(En(Astart(i):Afinit(i)));                  %size of avalanches
end
L=bin_size*(Afinit-Astart+1);                           %duration of avalanches
T=bin_size*(Astart(2:end)-Afinit(1:end-1)-1);           %period between avalanches

%m=max(size(Ms,1),max(N));
[dN alphN xminN xmaxN pvalN gammN xmineN VN pvalRN]=powerlaw_pval(N,reps,max(N));
[dL alphL xminL xmaxL pvalL gammL xmineL VL pvalRL]=powerlaw_pval(L,reps,max(L));
[dT alphT xminT xmaxT pvalT gammT xmineT VT pvalRT]=powerlaw_pval(T,reps,max(T));

Z.N=int32(N);
Z.L=int32(L);
Z.T=int32(T);
Z.d   =[   dN    dL    dT];
Z.alph=[alphN alphL alphT];
Z.xmin=[xminN xminL xminT];
Z.xmax=[xmaxN xmaxL xmaxT];
Z.n   =[nnz(N>=xminN) nnz(L>=xminL) nnz(T>=xminT)];
Z.pval=[pvalN pvalL pvalT];

Z.v=[VN VL VT];
Z.pvalr=[pvalRN pvalRL pvalRT];
Z.gamm=[gammN gammL gammT];
Z.xmine=[xmineN xmineL xmineT];
