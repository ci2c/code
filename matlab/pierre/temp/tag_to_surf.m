function surf = tag_to_surf(insurf, tag_file)
%function surf = tag_to_surf(insurf, tag_file)

if nargin ~= 2
    error('Invalid usage');
end

surf = insurf;


[X, Y, Z] = textread(tag_file, '%f%f%f%*[^\n]', 'headerlines', 4);

surf.coord = [X'; Y'; Z'];