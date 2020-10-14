function cvt = mipcurvature (v,sigma)
% MIPCURVATURE1D     Curvature Function
%
%   CVT = MIPCURVATURE(V,SIGMA)
%-----------------------------------------------------------------------
%   This function computes the curvature of a boundary based on      
%   the formula                                                     
%                c = ( x'*y" - y'*x")/(x'^2 + y'^2)^(3/2)             
%                                                                    
%    where y' and y" are 1st and 2nd  derivative of y(t) and         
%    similarly  x' and x" are 1st and 2nd derivatives of x(t).        
%-----------------------------------------------------------------------
%
%   See also MIPCURVEPARAM MIPDOG MIPSDOG MIPCIRCCONV

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

x = v(:,1)';
y = v(:,2)';
epsilon = 0.01;
DOG  = mipdog(sigma);
SDOG = mipsdog(sigma);
DOG  = DOG./sum(abs(DOG));
SDOG = SDOG./sum(abs(SDOG));
dx   = mipcircconv(x,DOG);
dy   = mipcircconv(y,DOG);
dxx  = mipcircconv(x,SDOG);
dyy  = mipcircconv(y,SDOG);
grdsq =  dx.*dx + dy.*dy;
grdsq(grdsq == 0) = epsilon;
cvt   = (dx.*dyy - dy.*dxx)./(grdsq).^1.5;
