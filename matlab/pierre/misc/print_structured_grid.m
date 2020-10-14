function print_structured_grid(fname, mri)
% print_structured_grid(fname, mri)
% mri is the structure given by FreeSurfer function MRIread

mri.vol = permute(mri.vol, [2 1 3]);

nx = size(mri.vol, 1);
ny = size(mri.vol, 2);
nz = size(mri.vol, 3);

tempFile=fopen('temp.txt', 'w');

File=fopen(fname, 'w');
fprintf(File, '# vtk DataFile Version 3.0\n');
fprintf(File, 'volume\n');
fprintf(File, 'ASCII\n');
fprintf(File, 'DATASET STRUCTURED_GRID\n');
%fprintf(File, 'DIMENSIONS %d %d %d\n', nx, ny, nz);
fprintf(File, 'DIMENSIONS %d %d %d\n', 101, 101, 101);
%fprintf(File, 'POINTS %d float\n', nx.*ny.*nz);
fprintf(File, 'POINTS %d float\n', 101*101*101);

Mat = zeros(4, 4);
Mat(1, 1) = -1;
Mat(3, 2) = 1;
Mat(2, 3) = -1;
Mat(:, 4) = mri.vox2ras1(:, 4);

for x = 100 : 200
    for y = 100 : 200
        for z = 100 : 200
            %P = Mat * [x; y; z; 1];
            P = [128-x; z-128; 128-y];
            fprintf(File, '%f %f %f\n', P(1), P(2), P(3));
            fprintf(tempFile, '%f\n', mri.vol(x, y, z));
        end
    end
end

fclose(tempFile);
%fprintf(File, 'POINT_DATA %d\n', nx.*ny.*nz);
fprintf(File, 'POINT_DATA %d\n', 101*101*101);
fprintf(File, 'SCALARS Intensity float 1\n');
fprintf(File, 'LOOKUP_TABLE default\n');
fclose(File);

commandline=strcat('!cat temp.txt >>', fname);
eval(commandline);