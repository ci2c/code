function M = getNeighbourMatrix(fsdir, subj, parc, Connectome, weight)
% usage : M = getNeighbourMatrix(fsdir, subj, parcname, Connectome, [weight])
%
% Inputs :
%       fsdir             : equivalent to FS SUBJECTS_DIR
%       subj              : subject ID
%       parcname          : parcellation file to use, i.e. aparc.a2009s
%       Connectome        : Connectome constructed on the provided
%                            parcellation
%       weight            : Set true to return distance matrix instead of
%                            neighbors matrix. Default : false
%
% Outputs :
%       M                 : neighbour matrix
%
% Pierre Besson @ CHRU Lille, Jul. 2012

if nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

if nargin == 4
    weight = false;
end

Surf = SurfStatReadSurf([{[fsdir, '/', subj, '/surf/lh.white']}, {[fsdir, '/', subj, '/surf/rh.white']}]);

lh_annot = [fsdir, '/', subj, '/label/lh.', parc, '.annot'];
rh_annot = [fsdir, '/', subj, '/label/rh.', parc, '.annot'];

[vertices_lh, label_lh, colortable_lh] = read_annotation(lh_annot);
[vertices_rh, label_rh, colortable_rh] = read_annotation(rh_annot);

nROI = length(Connectome.region);

M = zeros(nROI);

try
    Connectome.region(1).surface_label;
catch
    Connectome = findSurfaceLabels(fsdir, subj, parc, Connectome);
end

Surface_labels = cat(1, Connectome.region.surface_label);

Label = [label_lh; label_rh];
Tri_label = Label(Surf.tri);

for i = 1 : nROI
    if ~isnan(Surface_labels(i))
        Tri_select = sum(Tri_label == Surface_labels(i), 2) ~= 0;
        Tri_select = Tri_label(Tri_select, :);
        Tri_select = unique(Tri_select(:));
        Member = ismember(Tri_select, Surface_labels);
        Tri_select(Member == 0) = []; % Step used to discard medial wall and unused surface labels
        Tri_select(Tri_select == Surface_labels(i)) = [];
        for j = 1 : length(Tri_select)
            F = find(Surface_labels == Tri_select(j));
            M(i, F) = 1;
            M(F, i) = 1;
        end
    end
end

if weight
    g=graph;
    set_matrix(g, M);
    M = dist(g);
end
