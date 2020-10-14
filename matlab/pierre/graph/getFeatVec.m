function [Vmean, Vvert, L, OverAllMean] = getFeatVec(fpath, Feat, parcellation)
% Usage : [Vmean, Vvert, L, Mean] = getFeatVec(fpath, Feat, [parcellation])
%
% Return the vector of the mean surface feature Feat in each Broadmann's area
%    fpath : Absolute path to individual directory, i.e.
% ${SUBJECTS_DIR}/patient1
%    Feat : Name of the feature to deal with (i.e. 'thickness'). It assumes
%    that the feature files are located in 'fpath'/surf and are called
%    lh.'Feat' and rh.'Feat'
%
% Vmean is a N x 2 matrix with :
%    * N : number of Broadmann's area
%    * 1st colomn : left hemi.
%    * 2nd colomn : right hemi.
%
% Vvert is a N x 1 matrix :
%    * N is number of vertices
%    * Vvert(i) is the mean Feature attributed to region(i)
%
% L is a N x 1 matrix of the label numbered between 0 and K-1 (K ROIs)
%
% Mean 1 x 2 matrix of the overall mean feature
%
% 'parcellation' is the path to a surface parcelation file. Must be located
%   in 'fpath'/label/ and called like ?h.'parcellation'. We also assume
%   that there is no need to convert values in the file.
% If not mentioned, Broadmann's area used ( 'fpath'/label/?h.aparc.annot )

if nargin ~= 2 && nargin ~=3
    error('Incorrect use')
end

OverAllMean = zeros(1, 2);

%disp('Read left label...')
if nargin == 3
    label = read_curv(strcat(fpath, '/label/lh.', parcellation));
else
    [v,l,c] = read_annotation(strcat(fpath, '/label/lh.aparc.annot'));
    label = zeros(size(l));
    for k = 0 : size(c.table, 1)-1
        label(find(l==c.table(k+1, 5))) = k;
    end
end

[feat1, fnum] = read_curv(strcat(fpath, '/surf/lh.', Feat));
Vmean = zeros(max(label), 2);
Vvert = zeros(size(l, 1), 2);
L = Vvert;
OverAllMean(1, 1) = mean(feat1);

%disp('Print left Vmean & Vvert...')
for k = 0 : max(label)
    ROI = find(label==k);
    if size(ROI, 1) > 0
        Mean = mean(feat1(ROI));
    else
        Mean = 0;
    end
    Vmean(k+1, 1) = Mean;
    Vvert(ROI, 1) = Mean;
    L(ROI, 1) = k;
end

%disp('Read right label...')
if nargin == 3
    label = read_curv(strcat(fpath, '/label/rh.', parcellation));
else
    [v,l,c] = read_annotation(strcat(fpath, '/label/rh.aparc.annot'));
    label = zeros(size(l));
    for k = 0 : size(c.table, 1)-1
        label(find(l==c.table(k+1, 5))) = k;
    end
end

[feat1, fnum] = read_curv(strcat(fpath, '/surf/rh.', Feat));
OverAllMean(1, 2) = mean(feat1);

%disp('Print right Vmean & Vvert...')
for k = 0 : max(label)
    %fprintf('k = %d / %d\n', k, max(label));
    ROI = find(label==k);
    if size(ROI, 1) > 0
        Mean = mean(feat1(ROI));
    else
        Mean = 0;
    end
    Vmean(k+1, 2) = Mean;
    Vvert(ROI, 2) = Mean;
    L(ROI, 2) = k;
end