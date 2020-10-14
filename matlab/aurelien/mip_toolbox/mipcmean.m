function cm = mipcmean(h, I1, I2) 
% MIPCMEAN     Computes the class mean
%
%   CM = MIPCMEAN(X,I1,I2)
%
%   This function will compute the class mean, whose intensity range is
%   [I1, I2], from the histogram. The default range is [1, length(h)]
%
%   See also MIPCVAR

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if nargin == 1
    n1 = 1;
    n2 = length(h);
end

p  = 0;
sm = 0;
for i = I1:I2
	sm = sm + i*h(i);
	p  = p + h(i);
end;
if p == 0
	cm = 0;
else
	cm = sm/p;
end;