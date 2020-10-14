function  [NMI,MI,ka,kb]=MI_for_partitions(class_ind_a,class_ind_b)
%
%   [NMI,MI,ka,kb]=MI_for_partitions(class_indicators_a,class_indicators_b)
%             comparing two different partitions via Mutual Information (MI)
%      as introduced by Strehl & Ghosh (and presented in Fred et al. 2005, PAMI, vol27(6) )
%
%    inputs are two row-vectors containing group-labels as produced by Vector-Quantization
%      outputs are the Normalized_MI (NMI)  and the MI
%      ka and kb are the ''actually-used-bins' ka,kb<=k

%Nikolaos  Laskaris, 5/2007
%http://users.auth.gr/~laskaris/index.html
N=length(class_ind_a);

%table=tabulate(class_ind_a); ta=table(:,1); ka=length(ta);
table=tabulate(class_ind_a);
sel=table(:,2)~=0 ;
table=table(sel,:) ;
ka=length(table(:,1));

Ua=[];
for i=1:ka; 
    Ua(i,:)=[class_ind_a==table(i,1)];
end

Ha=-sum([sum(Ua,2)/N].*log10(sum(Ua,2)/N));

%table=tabulate(class_ind_b); tb=table(:,1); kb=length(tb);
table=tabulate(class_ind_b);  
sel=table(:,2)~=0; 
table=table(sel,:); 
kb=length(table(:,1));

Ub=[];
for i=1:kb; 
    Ub(i,:)=[class_ind_b==table(i,1)];
end

Hb=-sum([sum(Ub,2)/N].*log10(sum(Ub,2)/N));

Sab=Ua*Ub'/N;  
Sa=diag(Ua*Ua'/N); 
Sb=diag(Ub*Ub'/N);

SS=Sab.*log10(Sab./(Sa*Sb'));  

MI=nansum(nansum(SS));

NMI=2*MI/ (Ha+Hb);