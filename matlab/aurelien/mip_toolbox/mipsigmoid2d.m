function S = mipsigmoid2d(A,m,M,N)
% MIPSIGMOID2D  Sigmoid image
%
%   SIMG = MIPSIGMOID2D(A,m,M,N)
%
%   This generates a 2D sigmoid image
%   for a given amplitude A and a matrix of MxN
%   where the slope m varies between 0 and 1
%
%   See also MIPSPHEREIMAGE MIPDISKIMAGE
%
%   Example:
%   simg = mipsigmoid2d(100,0.3,256,256);
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

cx = M/2; cy = N/2;
[x,y] = meshgrid(0:M,0:N);
S = A./((1+exp(-m*(x-cx))).*(1+exp(-m*(y-cy))));

