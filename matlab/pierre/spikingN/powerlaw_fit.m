function [D alph xmin xmax P Alphx] = powerlaw_fit(X, m, Alph0)
%[D alph xmin xmax P] Alphx = powerlaw_fit(X, m, Alph0)
%
%   1) Evaluation of power laws
%
%       Inputs,
%       X,     input distribution
%       m,     size of system (xmax will be fixed as m)
%
%       Outputs,
%       D,     Kolmogorov-Smirnov statistic
%       alph,  exponent
%       xmin,  lower bound on distribution
%       xmax,  upper bound on distribution
%       P,     probability distribution for perfect power-law
%
%   2) Generation of Hurwitz-zeta (zeta(alpha,x)) tables
%
%       Inputs,
%       X,     filename to save table
%       m,     maximum upper bound of x
%       Alph0, range of exponents [alph_min:increment:alph_max]
%       [e.g. powerlaw_fit('zeta_table',5000,1.01:0.01:5);]
%
%   3) Loading of Hurwitz-zeta (zeta(alpha,x)) tables
%
%       Input,
%       X,     filename to load table
%

persistent Alph la lx Zeta_ax

%preparation of reference zeta tables
if ischar(X)
    if nargin==1;                                                   %load tables
        disp('Loading reference table')
        load(X, 'Zeta_ax','Alph','lx','la')

    else                                                            %make tables
        disp('Generating reference table')
        Alph=Alph0;                                                 %Alph0 allows to declare persistent Alph
        lx=m;
        la=length(Alph);

        Zeta_ax=zeros(la,lx);                                       %table of zeta(alph,xmin)
        for i=1:la
            xpa=[0 (1:lx-1).^(-Alph(i))];
            Zeta_ax(i,:) = zeta(Alph(i)) - cumsum(xpa);
        end

        disp('Saving reference table')         	%save tables
        save(X, 'Zeta_ax','Alph','lx','la')
    end
    return
end

if isempty(Alph)
    error('Load reference table: powerlaw_fit(table_filename)');
end

%for each xmin, the best alpha maximizes:
%-alph*sum(ln(X)) - n*ln(zeta(alph,xmin,m+1))
%where zeta(alph,xmin,m+1)=zeta(alph,xmin)-zeta(alph,m+1)

[F C lim]= histi(int32(X));                                         %distributions and their range
if lim(2)>m
    error('Distribution maximum exceeds system size')
end
F=[  zeros(1,lim(1)-1) F zeros(1,m-lim(2))];                        %ensure distributions range from 1 to m
C=[C(ones(1,lim(1)-1)) C zeros(1,m-lim(2))];
r=ceil(lim(2)/10);                                                  %maximum of xmin
xmax=m;                                                             %fix xmax as the system size

%get best alph for each xmin
CLn_g=fliplr(cumsum(log(m:-1:1).*F(end:-1:1)));                     %cumulative sum Ln(X) (X>=x, 1<=x<=m)
[ignore Ai] = max( -Alph(ones(1,r),:).'.*CLn_g(ones(1,la),1:r)      ...
    -C(ones(1,la),1:r).*log((Zeta_ax(:,1:r)-Zeta_ax(:,m(ones(1,r))+1))) );

%get best xmin
Zeta_n=Zeta_ax(Ai,1:m)-Zeta_ax(Ai,m(ones(1,m))+1);                  %zeta(alph,1:m,m+1) matrix
Zeta_d=diag(Zeta_ax(Ai,1:r))-Zeta_ax(Ai,m+1);                       %zeta(alph,xmin,m+1) vector for alph/xmin pairs
[D xmin]=min(max(triu(abs(                              ...         %KS statistic and corresponding best xmin
    C(ones(1,r),:)./C(ones(1,m),1:r).' -                ...         %observed cumulative distribution
    Zeta_n./Zeta_d(:,ones(1,m))                         ...         %zeta(alph,1:m,m+1)/zeta(alph,xmin,m+1)
    )),[],2));

alph=Alph(Ai(xmin));                                                %best alph for best xmin
Alphx=Alph(Ai);                                                     %best alph for all xmin
P=[Zeta_n(xmin,:)./Zeta_d(xmin) 0];                                 %CDF: P=zeta(alph,1:m,m+1)./zeta(alph,xmin,m+1)
