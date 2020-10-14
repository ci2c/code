function [p d]=hierarchical_form(n,htype,alpha)
%hierarhical_form: Within-level connection density for make_fractal2

%Input          n:      number of hierarchies
%               htype:  'pow', 'exp', 'lin'
%               alpha:  exponent, or exponent factor

%Output
%               p:      absolute proportion of within-level links
%               d:      within-level link density

%Linear form ('lin')
%   alpha: slope factor (min 0, max 100)
%     9 corresponds to homogeneous density
%     avoid 0 and 100 (boundaries have no links)
%   m: slope
%   c: y intercept
%
%   n(n-1)/2 m + hc = 1

%Power-law form ('pow')
%   alpha: exponent
%   C: normalizing constant
%
%   \sum_(x=1:n) (C x^(-alpha)) = 1
%   C = 1 / (\sum_(x=1:n) x^(-alpha))

%Exponential form ('exp')
%   alpha: exponent factor
%   C: normalizing constant
%
%   \sum_(x=1:n) (C exp^(-alpha*x)) = 1
%   C = 1 / (\sum_(x=1:n) exp^(-alpha*x))

switch htype
    case 'lin', m_max=2/(n*(n-1));
                m=-m_max+(2*m_max)*(alpha/100);
                c=1/n - m.*(n-1)/2;
                d=m*(0:n-1)+c;

    case 'pow', d=((1:n).^(-alpha))./sum((1:n).^(-alpha));

    case 'exp', d=exp(-alpha*(1:n))./sum(exp(-alpha*(1:n)));
end

p=d.*(2.^(0:n-1));      %hierarchy i has twice as many links as hierarchy i-1
p=p/sum(p);
