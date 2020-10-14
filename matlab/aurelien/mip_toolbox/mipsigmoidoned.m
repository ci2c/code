function [S,sx] = mipsigmoidoned(A,m,W) 
% SIGMOIDONED Sigmoid function in 1D
%
%   [S,SX] = SIGMOIDONED(A,m,W)
%
%   S: Sigmoid function defined at points in SX defined in [1 W]
%   with and amplitude A and a slope M
%
%   See also MIPSIGMOIDTWOD

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

cx = W/2; 
sx = linspace(1,W,2*W+1);
S  = A./(1+exp(-m*(sx-cx)));