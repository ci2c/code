function out_mat = reorderfMRIMat(in_mat, fsdir, subj, parc, Connectome)
% usage : out_mat = reorderfMRIMat(in_mat, fsdir, subj, parc, Connectome)
%
% Inputs :
%       in_mat            : input fMRI connectivity matrix
%       fsdir             : FS output directory, i.e. SUBJECTS_DIR
%       subj              : subject ID
%       parcname          : parcellation file to use, i.e. aparc.a2009s
%       Connectome        : Connectome constructed on the provided
%                            parcellation
%
% Output :
%       out_mat           : output reordered fMRI connectivity matrix
%
% Pierre Besson @ CHRU Lille, Jul. 2012

if nargin ~= 5
    error('invalid usage');
end

try
    Connectome.region(1).surface_label;
catch
    Connectome = findSurfaceLabels(fsdir, subj, parc, Connectome);
end

lh_annot = [fsdir, '/', subj, '/label/lh.', parc, '.annot'];
rh_annot = [fsdir, '/', subj, '/label/rh.', parc, '.annot'];

[vertices_lh, label_lh, colortable_lh] = read_annotation(lh_annot);
[vertices_rh, label_rh, colortable_rh] = read_annotation(rh_annot);

nROI = length(Connectome.region);
out_mat = zeros(nROI);

Surface_labels = cat(1, Connectome.region.surface_label);

Label = [label_lh; label_rh];
Label = unique(Label);
nLabel = size(in_mat, 1);

% Double loop (bouhhhh) for testing
% for i = 2 : nLabel
%     Fi = find(Surface_labels == Label(i));
%     
%     if isempty(Fi)
%         continue;
%     end
%     
%     for j = 1 : i-1
%         Fj = find(Surface_labels == Label(j));
%         if ~isempty(Fj)
%             out_mat(Fi,Fj) = in_mat(i,j);
%         end
%     end
% end
% 
% out_mat = out_mat + out_mat';

index = 1;
to_discard = [];

for i = 1 : nLabel
    F = find(Surface_labels == Label(i));
    if ~isempty(F)
        corresp(index) = F;
        index = index + 1;
    else
        to_discard = [to_discard, i];
    end
end

corresp = corresp';

in_mat(to_discard, :) = [];
in_mat(:, to_discard) = [];

nLabel = size(in_mat, 1);

index_i = repmat(corresp, 1, nLabel);
index_j = repmat(corresp', nLabel, 1);

index_ij = index_i + nROI * (index_j-1);
out_mat(index_ij) = in_mat(:);
out_mat(eye(size(out_mat))~=0) = 0;