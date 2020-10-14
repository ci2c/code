function Mat_b = doBootstrap(Mat, Ite)
% Usage: MAT_B = doBootstrap(MAT, ITE)
%
% Input  :   
%            MAT      : M x M x N Connectivity Matrix
%            ITE      : Number of Bootstraps iterations to average
%
% Output :   
%            MAT_B    : Bootstraped average matrix
%
% Pierre Besson, Oct. 2009

if nargin ~= 2
    error('Incorrect usage');
end

M = size(Mat,1);
N = size(Mat,3);
Mat_b = zeros(M);
Choice = 1:N;

for i = 1 : Ite
    Permut = randsample(Choice, N, 1);
    Mat_b = Mat_b + mean(Mat(:,:,Permut), 3);
end

Mat_b = Mat_b ./ Ite;