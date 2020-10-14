function [D alph xminp xmax pval gamm xmine V pvalR]=powerlaw_pval(X,reps,xmax)

%[D alph xmin xmax pval]=powerlaw_pval(X,reps,xmax)
%
%   Inputs:     X,          distribution
%               reps,       number of repetitions
%               xmax,       fixed x_max
%
%   Outputs:    D,          Kolmogorov-Smirnov statistic
%               alph,       power-law exponent
%               xmin,       lower bound on distribution
%               xmax,       upper bound on distribution
%               pval,       goodness-of-fit p-value
%               gamm,       exponential factor
%               V,          Vuong's statistic
%               pvalr,      likelihood test p-value

[D alph xminp xmaxp P Alphx]=powerlaw_fit(X,xmax);
pval=gof_test(X,P,xminp,xmax,D,reps);

[x gamm xmine xmaxe x Gammx]=exponential_fit(X,xmax,0.002:0.002:1,5000);
xmin=floor((xminp+xmine)/2);
if (xmax~=xmaxp || xmax~=xmaxe); error('xmaxes differ'); end
[V pvalR]=llr_test(X,xmin,xmax,Alphx(xmin),Gammx(xmin));


function pval=gof_test(X,P,xmin,xmax,D,reps)
ind=(X>=xmin);                                      %all X's are already smaller than xmax
n=nnz(ind);
Ds=zeros(1,reps);
for i=1:reps
    X(ind)=randipl(n,P);
    Ds(i)=powerlaw_fit(X,xmax);
end
pval=nnz(Ds>D)/reps;                                %pval for goodness-of-fit


function [V pvalR]=llr_test(X,xmin,xmax,alph,gamm)

persistent Zeta_ax Alph lx Exp_gx Gamm
if isempty(Zeta_ax)
    powerlaw_fit('zeta_table')
    load('zeta_table','Zeta_ax','Alph','lx')

    disp('Generating reference table')
    Gamm=(0.002:0.002:1).';
    Exp_gx=exp(-Gamm*(1:lx));
end

ind=(X>=xmin);
n=nnz(ind);
ai=Alph==alph;
gi=Gamm==gamm;

p1=((1:xmax).^(-alph))                  ./(Zeta_ax(ai,xmin)-Zeta_ax(ai,xmax+1));
p2=exp(-gamm*(1:xmax)).*(1-Exp_gx(gi,1))./(Exp_gx(gi,xmin) - Exp_gx(gi,xmax+1));

L1=p1(X(ind));
L2=p2(X(ind));
r=(log(L1)-log(L2));
R=sum(r);                                           %log likelihood ratio
V=R/sqrt(n*var(r,1));                               %Vuong's statistic
pvalR=erfc(abs(R)/sqrt(2*n*var(r,1)));              %Clauset's Eq C.6 (verified manually)
