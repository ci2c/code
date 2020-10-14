function Out = ColorROIs(subjdir, roin, f)
% Usage : ColorROIs(Subj_dir, ROI_name, F)
%
% Color the ROIs of the annot files named ?h.roin.annot in subjdir with the
% vector F and save it as ?h.Out_name curv format
%
% First part of F must be assigned to the left hemisphere then to the right
% hemisphere
%
% Pierre Besson, 2010

if nargin ~= 3
    error('Invalid usage');
end

% Left
Left = strcat(subjdir, '/label/lh.', roin, '.annot');
[v, label, colortable] = read_annotation(Left);
Labels = unique(label);

Out = zeros(size(label));

for i = 1 : length(Labels)
    Out(label==Labels(i)) = f(i);
end

Offset = length(Labels);

% Right
Right = strcat(subjdir, '/label/rh.', roin, '.annot');
[v, label, colortable] = read_annotation(Right);
Labels = unique(label);

Out_temp = zeros(size(label));

for i = 1 : length(Labels)
    Out_temp(label==Labels(i)) = f(i+Offset);
end

Out = [Out; Out_temp];