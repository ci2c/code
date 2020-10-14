function mask = tract2mask(tract,maskType)
% function mask = tract2mask(tract,maskType)
% tract: A structure with the tract information. This is a particular type
% of structure, as that one created using the function f_readFiber.m
%
% maskType: Char array. Options are 'binary' or 'frequency'. If 'frequency'
% is used, every voxel will show how many tracts pass through it. Default
% is 'binary'.
%
% Luis Concha.

if nargin<2
   disp('Generating a binary mask');
   maskType = 'binary'; 
end

disp('Generating mask');

nPointsTotal = 0;
for f = 1 : tract.nFiberNr
    nPointsTotal = nPointsTotal + tract.fiber(f).nFiberLength;
end

xyz = zeros(nPointsTotal,3);

start = 0;
stop  = 0;
for f = 1 : tract.nFiberNr
    start = stop +1;
    stop  = start + tract.fiber(f).nFiberLength -1;
    xyz(start:stop,:) = tract.fiber(f).xyzFiberCoord;
end



xyz = floor(xyz);

if strcmp(maskType,'frequency')
    voxels    = xyz;
else
    voxels    = unique(xyz,'rows');
end

rowZ  = voxels(:,3);
index = find(rowZ<0);
voxels(index,:)=[];    %Remove voxels with Z coordinate < 0
voxels = voxels +1;

if strcmp(maskType,'frequency');
    mask = zeros(tract.nImgHeight,tract.nImgWidth,tract.nImgSlices);
    for i=1:length(voxels)
        r = voxels(i,2);
        c = voxels(i,1);
        s = voxels(i,3);
        mask(r,c,s) = mask(r,c,s) + 1;
    end
else
    mask = false(tract.nImgHeight,tract.nImgWidth,tract.nImgSlices);
    for i=1:length(voxels)
        r = voxels(i,2);
        c = voxels(i,1);
        s = voxels(i,3);
        mask(r,c,s) = true;
    end
end
