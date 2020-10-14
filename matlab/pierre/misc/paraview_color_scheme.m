function paraview_color_scheme(scheme, outfile, scheme_name)
% usage : paraview_color_scheme(scheme, outfile, scheme_name)
%
% scheme  : name of a matlab color bar (i.e. 'jet') or N x 3 RGB table
% outfile : path to the .xml output
% scheme_name : name of the color scheme (i.e. 'my_colortable' or 'hot')

if nargin ~= 3
    error('invalid usage');
end

if ischar(scheme) && exist('scheme') ~= 1
    scheme='jet';
    scheme = eval(scheme);
end

N = length(scheme);
fid = fopen(outfile, 'w');
fprintf(fid, '<ColorMap name="%s" space="HSV">\n', scheme_name);

for i=1:N
  x = [(i-1)/(N-1); scheme(i,:)'];
  fprintf(fid, '  <Point x="%f" o="1" r="%f" g="%f" b="%f"/>\n', x);
end

fwrite(fid, '</ColorMap>');
fclose(fid);