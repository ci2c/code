function cv = mipcvar(h,mu,I1,I2)
% MIPCVAR     Computes class variance
%
%   CV = MIPCVAR(X,MU,I1,I2)
%
%   This function will compute the class variance, whose mean is MU and 
%   intensity range is [I1, I2], from the histogram H. 
%   The default range is [1, length(H)]
%
%   See also MIPCMEAN

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if nargin == 1
    n1 = 1;
    n2 = length(h);
end
p  = 0;
sm = 0;
for i = I1:I2
	temp = (i-mu);
	sm   = sm + h(i)*temp*temp;
	p    = p+h(i);
end;
if p == 0
	cv = 0;
else
	cv = sm/p;
end;
