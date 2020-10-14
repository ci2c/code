function h = ScaFunction(x, g_max, lambda_min)
% Usage : h = ScaFunction(x, g_max, lambda_min)
%
% Returns spectral graph scaling function
%
% Pierre Besson, 2010

if nargin ~= 3
    error('Invalid usage');
end

h = g_max .* exp(-(x ./ (0.6.*lambda_min)).^4);