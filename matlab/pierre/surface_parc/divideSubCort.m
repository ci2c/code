function divideSubCort(surf_path, annot_path, roi_area)
% usage : divideSubCort(SURF_PATH, ANNOT_PATH, ROI_AREA)
%
% Inputs :
%    SURF_PATH      : Path to the surface used for parcellation
%    ANNOT_PATH     : Path to the generated .annot file
%    ROI_AREA       : Desired average ROI area in mm^2
%
% Pierre Besson @ CHRU Lille, Aug. 2012

if nargin ~= 3
    error('invalid usage');
end

try
    Surf = SurfStatReadSurf(surf_path);
catch
    error(['cannot open file ' surf_path]);
end

% Compute total surface area
X = Surf.coord(1,:);
Y = Surf.coord(2,:);
Z = Surf.coord(3,:);

X = X(Surf.tri);
Y = Y(Surf.tri);
Z = Z(Surf.tri);

Xab = (X(:,2) - X(:,1));
Xac = (X(:,3) - X(:,1));
Yab = (Y(:,2) - Y(:,1));
Yac = (Y(:,3) - Y(:,1));
Zab = (Z(:,2) - Z(:,1));
Zac = (Z(:,3) - Z(:,1));
N = cross([Xab Yab Zab], [Xac Yac Zac]);
total_area = sum(0.5 .* sqrt(N(:, 1).^2 + N(:, 2).^2 + N(:, 3).^2));

n_roi = round(total_area ./ roi_area);

if n_roi < 2
    error('ROI_AREA too large');
end

% k-mean on nodes coordinates
% idx = kmeans(Surf.coord', n_roi, 'Distance', 'cityblock', 'MaxIter', 500);
idx = kmeans(Surf.coord', n_roi, 'MaxIter', 500);

% creates colortable stuff
my_colortable.numEntries = n_roi;
my_colortable.orig_tab='';

for i = 1 : n_roi
    my_colortable.struct_names{i} = ['parc', num2str(i, '%.3d')];
end
my_colortable.struct_names = my_colortable.struct_names';

my_colortable.table = randi([0 255], n_roi, 3);
my_colortable.table(:,4) = zeros(n_roi, 1);
my_colortable.table(:,5) = my_colortable.table(:,1) + my_colortable.table(:,2)*2^8 + my_colortable.table(:,3)*2^16;

% Reassign vertices value
V = zeros(size(idx));
for i = 1 : n_roi
    V(idx==i) = my_colortable.table(i, end);
end

write_annotation(annot_path, (1:length(Surf.coord)) - 1, V, my_colortable);