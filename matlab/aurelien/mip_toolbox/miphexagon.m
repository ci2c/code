function im = miphexagon(I1,I2,imSize); 
% MIPHEXAGON   Syntehtic image creation
%
%   IMDISK = MIPHEXAGON(I1,I2,IMSIZE)
%
%   I1 and I2 are the background and hexagon levels
%   imSize: M
%
%   This function generates a hexagon 
%   
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox
       
tmp = zeros(imSize);
r =[14 26 38 50 50 38 26 14]/(64/imSize);
c =[26 14 14 26 38 50 50 38]/(64/imSize);  
hx = double(roipoly(tmp,c,r));
im = (hx+I1).*(hx ==0)+(hx+I2-1).*(hx~=0);
