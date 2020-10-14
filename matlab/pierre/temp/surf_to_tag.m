function surf_to_tag(Surf, tag_file)
%function surf_to_tag(Surf, tag_file)

if nargin ~= 2
    error('Invalid usage');
end

File = fopen(tag_file, 'w');

fprintf(File, 'MNI Tag Point File\n');
fprintf(File, 'Volumes = 1;\n\n');
fprintf(File, 'Points = \n');

Coord = Surf.coord(:);

fprintf(File, '%f %f %f ""\n', Coord(1:end-3));
fprintf(File, '%f %f %f "";', Coord(end-2:end));

fclose(File);