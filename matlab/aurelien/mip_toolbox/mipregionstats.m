% Computes region statistics
% [m,sdv] = RegionStats(gimg,bimg,nClass)
% gimg: input gray level image
% bimg: labeled image
% nClass denotes number of regions within the image
% [m,sdv]: output standard deviation and means for each region
function [m,sdv] = mipregionstats(gimg,bimg,nClass)
for i=1:nClass
    H = gimg(bimg == i);
    if ~isempty(H)
        m(i)   = mean(H);
        sdv(i) = std(H);
    else
        m(i)   = 0;
        sdv(i) = 0;
    end
end;