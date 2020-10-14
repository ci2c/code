function divideParcellation(fsdir, subj, in_annot, out_annot, subdiv)
% usage : divideParcellation(fsdir, subj, in_annot, out_annot, subdiv)
%
% Inputs :
%    fsdir            : equivalent to FS SUBJECTS_DIR
%    subj             : subject name
%    in_annot         : annotation to divide (i.e. aparc.a2009s)
%    out_annot        : name of the output annotation file (i.e. myannot)
%    subdiv           : average size of subdivisions (in vertices)
%
% Pierre Besson @ CHRU Lille, Jun 2012

if nargin ~= 5
    error('invalid usage');
end

path_sphere_lh = [fsdir, '/', subj, '/surf/lh.sphere'];
path_sphere_rh = [fsdir, '/', subj, '/surf/rh.sphere'];

path_white_lh = [fsdir, '/', subj, '/surf/lh.white'];
path_white_rh = [fsdir, '/', subj, '/surf/rh.white'];

path_pial_lh = [fsdir, '/', subj, '/surf/lh.pial'];
path_pial_rh = [fsdir, '/', subj, '/surf/rh.pial'];

path_in_annot_lh  = [fsdir, '/', subj, '/label/lh.', in_annot, '.annot'];
path_in_annot_rh  = [fsdir, '/', subj, '/label/rh.', in_annot, '.annot'];

path_out_annot_lh  = [fsdir, '/', subj, '/label/lh.', out_annot, '.annot'];
path_out_annot_rh  = [fsdir, '/', subj, '/label/rh.', out_annot, '.annot'];

LUT_path = [fsdir, '/', subj, '/label/', out_annot, 'LUT.txt'];

Range = (0:255)';
% Discard all numbers used in subcort LUT
Range([0 10 12 13 14 18 20 30 32 34 42 48 58 60 62 64 70 78 103 108 112 118 119 120 122 134 142 148 150 159 160 164 165 169 176 182 186 190 196 200 204 205 208 216 220 221 225 226 230 234 236 240 245 248 250 255] +1 ) = [];
[A,B,C] = ndgrid(Range, Range, Range);
ColorLUT = [A(:) B(:) C(:)];
clear A B C;
Samples = randsample(length(ColorLUT), 10000);


[label_lh, colortable_lh] = getDividedTable(path_in_annot_lh, path_sphere_lh, subdiv, ColorLUT(Samples(1:5000), :));
[label_rh, colortable_rh] = getDividedTable(path_in_annot_rh, path_sphere_rh, subdiv, ColorLUT(Samples(5001:end), :));

write_annotation(path_out_annot_lh, (1:length(label_lh))-1, label_lh, colortable_lh);
write_annotation(path_out_annot_rh, (1:length(label_rh))-1, label_rh, colortable_rh);

[s,w] = unix(['cp -f ~/SVN/matlab/pierre/subCortLUT.txt ' LUT_path]);
fid = fopen(LUT_path, 'a');

offset_lh = 10000;
for i = 1 : length(colortable_lh.struct_names)
    fprintf(fid, '%d\t %s\t %d \t %d \t %d \t 0\n', i+offset_lh, ['lh_' colortable_lh.struct_names{i}], colortable_lh.table(i,1), colortable_lh.table(i,2), colortable_lh.table(i,3));
end

offset_rh = 20000;
for i = 1 : length(colortable_rh.struct_names)
    fprintf(fid, '%d\t %s\t %d \t %d \t %d \t 0\n', i+offset_rh, ['rh_' colortable_rh.struct_names{i}], colortable_rh.table(i,1), colortable_rh.table(i,2), colortable_rh.table(i,3));
end

fclose(fid);

% Convert aparc to volume
[s,w] = unix(['mri_convert ', fsdir, '/', subj, '/mri/aparc.a2009s+aseg.mgz ', fsdir, '/', subj, '/mri/', out_annot, '.nii --out_orientation RAS']);

correct_aseg(label_lh, colortable_lh, offset_lh, path_white_lh, path_pial_lh, [fsdir, '/', subj, '/mri/', out_annot, '.nii']);
correct_aseg(label_rh, colortable_rh, offset_rh, path_white_rh, path_pial_rh, [fsdir, '/', subj, '/mri/', out_annot, '.nii']);

[s,w] = unix(['mri_convert ', fsdir, '/', subj, '/mri/', out_annot, '.nii ', fsdir, '/', subj, '/mri/', out_annot, '.mgz']);
delete([fsdir, '/', subj, '/mri/', out_annot, '.nii']);