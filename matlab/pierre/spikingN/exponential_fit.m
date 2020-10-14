function [D gamm xmin xmax P Gammx] = exponential_fit(X, m, Gamm0, lx0)
%[D gamm xmin xmax P] = exponential_fit(X, m, Gamm, lx)
%
%   Fit exponential,
%   Inputs,
%    X,     input distribution
%    m,     size of system (xmax will be fixed as m)
%    Gamm,  range of exponents [gamm_min:increment:gamm_max]
%    lx,    maximum upper bound of x
%    [e.g.  exponential_fit('exp_table',X,m,0.01:0.01:1,5000);]
%
%   Outputs,
%    D,     Kolmogorov-Smirnov statistic
%    gamm,  exponent
%    xmin,  lower bound on distribution
%    xmax,  upper bound on distribution
%    P,     probability distribution for perfect power-law

persistent Exp_gx Gamm lg lx

%preparation of reference exponential tables
if isempty(Exp_gx)
    if ~exist('lx0','var')
       Gamm0=0.01:0.01:1;
       lx0=5000;
    end
    disp('Generating reference table')
    Gamm=Gamm0(:);
    lg=length(Gamm);
    lx=lx0;    
    Exp_gx=exp(-Gamm*(1:lx));
end

%for each xmin, the best gamma maximizes:
%n*ln(1-exp(-gamm))-n*ln(exp(-gamm*xmin)-exp(-gamm(xmax+1)))+\sum(i=0,n,exp(-gamm*x_i)))

[F C lim]= histi(int32(X));                                         %distributions and their range
if lim(2)>m
    error('Distribution maximum exceeds system size')
end
F=[  zeros(1,lim(1)-1) F zeros(1,m-lim(2))];                        %ensure distributions range from 1 to m
C=[C(ones(1,lim(1)-1)) C zeros(1,m-lim(2))];
r=ceil(lim(2)/10);                                                  %maximum of xmin
xmax=m;                                                             %fix xmax as the system size

%get best gamm for each xmin
S_x=fliplr(cumsum((m:-1:1).*F(end:-1:1)));                          %cumulative sum (X) (X>=x, 1<=x<=m)
[ignore Gi] = max(                                      ...
    C(ones(1,lg),1:r).*( log(1-Exp_gx(:,ones(1,r))) -   ...
    log(Exp_gx(:,1:r)-Exp_gx(:,m(ones(1,r))+1)) ) -     ...
    Gamm(:,ones(1,r)).*S_x(ones(1,lg),1:r)              ...
    );

%get best xmin
P_n=Exp_gx(Gi,1:m)-Exp_gx(Gi,m(ones(1,m))+1);                       %numerator matrix
P_d=diag(Exp_gx(Gi,1:r))-Exp_gx(Gi,m+1);                            %denominator vector for gamm/xmin pairs
[D xmin]=min(max(triu(abs(                              ...         %KS statistic and corresponding best xmin
    C(ones(1,r),:)./C(ones(1,m),1:r).' -                ...         %observed cumulative distribution
    P_n./P_d(:,ones(1,m))                               ...         %model distributions
    )),[],2));

gamm=Gamm(Gi(xmin));                                                %best gamm for best xmin
Gammx=Gamm(Gi);                                                     %best gamm for all xmin
P=[P_n(xmin,:)./P_d(xmin) 0];                                       %best model CDF
