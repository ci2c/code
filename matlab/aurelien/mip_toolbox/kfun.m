function k = kfun(pdf,th)
% KFUN  Determining noise threshold
%
%   k = KFUN(PDF,TH)
%
%   
%   TH: threshold, PDF: image probability distribution function
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

flag = 1;
temp_var = pdf(1);
psize = size(pdf,2);
for i = 2:psize;
    if (temp_var >= th & flag)
        k = i;
        flag = 0;
        break;
    end;
    temp_var = temp_var + pdf(i);   
end;
