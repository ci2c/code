function Connectome = findSurfaceLabels(fsdir, subj, parc, Connectome)
% usage : Connectome = findSurfaceLabels(fsdir, subj, parcname, Connectome)
%
% Inputs :
%       fsdir             : equivalent to FS SUBJECTS_DIR
%       subj              : subject ID
%       parcname          : parcellation file to use, i.e. aparc.a2009s
%       Connectome        : Connectome constructed on the provided
%                            parcellation
%
% Outputs :
%       Connectome        : output Connectome structure with the field
%                 surface_label added to each surface ROI
%
% Pierre Besson @ CHRU Lille, Jul. 2012

if nargin ~= 4
    error('invalid usage');
end

lh_annot = [fsdir, '/', subj, '/label/lh.', parc, '.annot'];
rh_annot = [fsdir, '/', subj, '/label/rh.', parc, '.annot'];

[vertices_lh, label_lh, colortable_lh] = read_annotation(lh_annot);
[vertices_rh, label_rh, colortable_rh] = read_annotation(rh_annot);

nROI = length(Connectome.region);
Lh = length(label_lh);
label_lh = [label_lh; zeros(size(label_rh))];
label_rh = [zeros(Lh, 1); label_rh];

for i = 1 : nROI
    if ~isempty(findstr(Connectome.region(i).name, 'lh'))
        for j = 1 : length(colortable_lh.struct_names)
            if ~isempty(strfind(Connectome.region(i).name, char(colortable_lh.struct_names(j))))
                Connectome.region(i).surface_label = colortable_lh.table(j, end);
                break;
            end
        end
    else
        if ~isempty(findstr(Connectome.region(i).name, 'rh'))
            for j = 1 : length(colortable_rh.struct_names)
                if ~isempty(strfind(Connectome.region(i).name, char(colortable_rh.struct_names(j))))
                    Connectome.region(i).surface_label = colortable_rh.table(j, end);
                    break;
                end
            end
        else
            Connectome.region(i).surface_label = NaN;
        end
    end
end