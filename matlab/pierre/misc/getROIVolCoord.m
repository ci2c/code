function Coord = getROIVolCoord(label_path, Connectome)
% Usage : COORD = getROIVolCoord(LABEL_PATH, Connectome)
%
% Return coordinates vectors of the CoG of the volume ROIs
%
% Inputs :
%    LABEL_PATH    : Path to the label volume (nii format)
%    Connectome    : Connectome structure as provided by
%                      getVolumeConnnectMatrix
%
% Output :
%    COORD         : nROI x 3 coordinates matrix
%
% See also getVolumeConnectMatrix
%
% Pierre Besson @ CHRU Lille, Oct. 2011

if nargin ~= 2
    error('Invalid usage');
end

nROI = length(Connectome.region);
Coord = zeros(nROI, 3);

V = spm_vol(label_path);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);

for i = 1 : nROI
    ROI = XYZ(:, labels == Connectome.region(i).label);
    if isempty(ROI)
        Coord(i, :) = [NaN, NaN, NaN];
        continue;
    end
    Temp = distance(mean(ROI, 2), ROI);
    Temp = find(Temp == min(Temp), 1, 'first');
    Coord(i, :) = ROI(:, Temp)';
end