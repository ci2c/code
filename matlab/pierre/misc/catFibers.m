function fib1 = catFibers(fib1, fib2)
% usage : FIB_OUT = catFibers(FIB_IN1, FIB_IN2)
% 
% Inputs :
%       FIB_IN1  : first input fiber structure as provided by f_readFiber
%       FIB_IN2  : second fiber structure
%
% Options :
%       FIB_OUT  : concatenation of FIB_IN1 and FIB_IN2
%
% Pierre Besson @ CHRU Lille. July 2011.

if nargin ~= 2
    error('invalid usage');
end

L = length(fib1.fiber);
M = length(fib2.fiber);

fib1.nFiberNr = L+M;

for i = 1 : M
    fib1.fiber(L+i) = fib2.fiber(i);
end