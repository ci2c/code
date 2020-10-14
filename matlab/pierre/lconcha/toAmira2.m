% function toAmira2(data3D, fname, xdim,ydim,zdim)
% be careful with xdim and ydim if not isotropic, as matlab 
% has the matrices transposed.  Your data might have x and y
% components flipped.
% Function to create a file for input to Amira.
%
% Inputs:
%    data3D = 3D data set.
%    fname = File name string.
%
% Outputs:
%    File updates.
%


function toAmira2(data3D,fname,xdim,ydim,zdim)


% Data.
if isa(data3D, 'double') 
    % floating point.
    fmt = '%.8f ';
    formatString = 'float';
    
% added January 2007, Luis Concha
elseif isa(data3D, 'single')
    % single precision
    fmt = '%.4f ';
    formatString = 'float';
% end of addition

else
    % Integer.
    fmt = '%i ';
    formatString = 'byte';
end


% first, make sure there are no NaNs, and if there are, make them zeros.
index = find(isnan(data3D));
data3D(index) = 0;

%Now write the ami file
[x,y,z] = size(data3D);
file = fopen(fname, 'w');

% Header.
fprintf(file, '#AmiraMesh ASCII 1.0\n');
fprintf(file, 'define Lattice %d %d %d\n', y, x, z);
fprintf(file, 'Parameters {\n');
fprintf(file, 'CoordType "uniform",\n');
fprintf(file, '# BoundingBox is xmin xmax ymin ymax zmin zmax\n');
fprintf(file, 'BoundingBox %d %d %d %d %d %d\n', 0, ydim*(y-1), 0, xdim*(x-1), 0, zdim*(z-1));
fprintf(file, '}\n\n');

fprintf(file, 'Lattice { %s ScalarField } = @1\n\n',formatString);

fprintf(file, '@1\n\n');



len=x*y;
for i=1:z
    fprintf(file, fmt, reshape(double(data3D(:,:,i))',[len,1]));
    fprintf(file, '\n');
end

fclose(file);
disp('Done');

return